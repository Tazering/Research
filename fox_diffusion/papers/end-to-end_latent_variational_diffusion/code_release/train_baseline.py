from typing import NamedTuple, Dict

from argparse import ArgumentParser
from functools import partial
from itertools import islice

import pickle
from omegaconf import OmegaConf
from tqdm import tqdm

import jax
from jax import Array
from flax.jax_utils import replicate, unreplicate

import optax
import tensorflow as tf

from diffusion.dataset import Dataset, Batch
from diffusion.config import Config

from cinn_model import create_flow_model
from cvae_model import create_cvae_model
from pretrained_vae_model import create_vae_model

from train_lvd import create_log_folder, make_optimizer


class TrainingState(NamedTuple):
    params: Dict[str, Array]
    state: Dict[str, Array]
    optimizer_state: Dict[str, Array]


def create_update_fn(cinn_step, optimizer):
    @partial(jax.pmap, axis_name="num_devices")
    def update_fn(
        training_state: TrainingState,
        random_key: jax.random.PRNGKey,
        batch: Batch
    ):
        (total_loss, (metrics, random_key)), grads = cinn_step(
            training_state.params,
            training_state.state,
            random_key,
            batch
        )

        grads = jax.lax.pmean(grads, "num_devices")

        updates, optimizer_state = optimizer.update(
            grads,
            training_state.optimizer_state,
            training_state.params
        )

        params = optax.apply_updates(training_state.params, updates)

        training_state = TrainingState(
            params=params,
            state=training_state.state,
            optimizer_state=optimizer_state
        )

        return training_state, total_loss, metrics, random_key

    return update_fn

# the main function that will run when the this python file runs
def train(
    model_type: str,
    options_file: str,
    training_file: str,
    checkpoint_file: str,
    start_batch: int,
    name: str,
    weights_file
):
    # initialize cuda
    jax.random.normal(jax.random.PRNGKey(0))
    
    # check which model is being run
    if model_type.lower() == "cinn":
        print("Model Type: CINN") # 4.1
        model_factory = create_flow_model
    elif model_type.lower() == "cvae": # 4.1
        print("Model Type: CVAE")
        model_factory = create_cvae_model
    elif model_type.lower() == "vae": # 4.1
        print("Model Type: Pretrain VAE")
        model_factory = create_vae_model
    else:
        raise ValueError(f"Unkown Model Type: {model_type}")
    
    print("Loading Data")

    # grab the dataset
    dataset = Dataset(training_file, weights_file=weights_file)

    # sets the configuration of the 
    config = Config(
        **OmegaConf.load(options_file),
        parton_dim=dataset.parton_dim,
        detector_dim=dataset.detector_dim,
        met_dim=dataset.met_dim
    )

    # creates a dataloader
    dataloader = dataset.create_dataloader(config.batch_size)
    single_device_batch = jax.tree_map(lambda x: x[0], next(dataloader))

    # run the model
    model, loss_fn, step_fn = model_factory(config)
    
    # create the optimizer
    optimizer = make_optimizer(config.learning_rate, config.gradient_clipping)

    # Initialize Model on GPU 0
    # -------------------------------------------------------------------------
    print("Initializing Model")
    random_key = jax.random.PRNGKey(config.seed) # creates a random key using pseudo random number generator 
    random_key, init_key = jax.random.split(random_key, 2) # splits a prng key into num 2 new keys by adding a leading axis


    # checkpoint file
    if checkpoint_file is not None:
        with open(checkpoint_file, 'rb') as file:
            training_state = pickle.load(file)

    else:
        params, state = model.init(init_key, single_device_batch)
        optimizer_state = optimizer.init(params)

        state["~"] = dataset.statistics

        training_state = TrainingState(
            params,
            state,
            optimizer_state
        )

    # Create shared parameters on all devices.
    # -------------------------------------------------------------------------
    random_key = jax.random.split(random_key, jax.device_count())
    training_state = replicate(training_state)

    # Create Update functions
    # -------------------------------------------------------------------------
    cinn_update = create_update_fn(step_fn, optimizer)

    logdir = create_log_folder("./logs", name)
    OmegaConf.save(OmegaConf.structured(config), f"{logdir}/config.yaml")

    summary_writer = tf.summary.create_file_writer(logdir)
    batch_number = start_batch

    with summary_writer.as_default():
        if config.num_batches > 0:
            pbar = tqdm(islice(dataloader, config.num_batches),
                        desc="Training", total=config.num_batches)
        else:
            pbar = tqdm(dataloader, desc="Training")

        for batch in pbar:
            training_state, _, metrics, random_key = cinn_update(
                training_state, random_key, batch)

            if batch_number % config.log_interval == 0:
                metrics = {
                    f"{model_type}/{name}": value.mean().item()
                    for name, value
                    in metrics._asdict().items()
                }

                for name, value in metrics.items():
                    tf.summary.scalar(name, value, step=batch_number)

            if batch_number % config.save_interval == 0:
                with open(f"{logdir}/checkpoint.pickle", 'wb') as file:
                    pickle.dump(unreplicate(training_state), file)

            batch_number += 1


def parse_args():
    parser = ArgumentParser()

    parser.add_argument("model_type", type=str)
    parser.add_argument("options_file", type=str)
    parser.add_argument("training_file", type=str)
    parser.add_argument("--checkpoint_file", "-c", type=str, default=None)
    parser.add_argument("--start_batch", "-s", type=int, default=0)
    parser.add_argument("--name", "-n", type=str, default="cinn")
    parser.add_argument("--weights_file", "-w", type=str, default=None)

    return parser.parse_args()


if __name__ == "__main__":
    train(**parse_args().__dict__)