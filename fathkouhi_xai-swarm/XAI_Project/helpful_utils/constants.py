"""
This python function lists a bunch of constants that will be used for the experiment.
"""

import pandas as pd
import numpy as np

import sklearn
import sklearn.ensemble
import sklearn.linear_model
import xgboost as xgb


# dictionary list of models
models = {
    "logistic_regression": sklearn.linear_model.LogisticRegression(),
    "support_vector_machine": sklearn.svm.SVC(probability = True),
    "random_forests": sklearn.ensemble.RandomForestClassifier()
    # "gradient_boosted_machine": xgb.XGBClassifier(use_label_encoder = False, eval_metrics = "logloss", n_jobs = 1),
}

datasets = {
    # 1 feature

    # 2 features
    "reading_hydro_downstream": 44267,
    "balloon": 512,
    "humandevel": 924,
    "reading_hydro_upstream": 44221,
    "SquareF": 45617,

    # 3 features
    "transplant": 544,
    "prnn_synth": 464,
    "analcatdata_neavote": 523,
    # 4 features
    "iris": 61
}
