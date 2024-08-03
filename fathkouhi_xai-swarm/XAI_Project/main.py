"""
This python file is the main driver for the experiment.
A signficant portion of this code was made to be similar to Emmanuel Doumard et al's 
experiment found in:

github.com/EmmanuelDoumard/local_explanation_comparative_study

The largest difference is the implementation of our XAI algorithms that use SWARM 
optimizers as also another approach for explainability.
"""
import pandas as pd
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns

import XAI_Swarm_Opt
import XAI
import time
import pickle

from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import OrdinalEncoder, LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.compose import make_column_selector as selector
import arff
from colorama import Style, Fore
import tools.data_tools as data_tools

import openml as oml

"""
The main function that calls each of the needed steps for the experiment.
"""
def main():
    # preprocess the data
    X_preprocessed, y_preprocessed = process_openml_dataset(61, "test")

    # data_tools.print_variable("X_preprocessed", X_preprocessed)

    # grabs the datasets
    df_datasets = get_datasets()
    print(df_datasets.head())

    return None

"""
Grabs the datasets from a certain criteria. One thing to note is this will be a more updated version so to best
mimic the experiment, hand-picking the datasets may be needed
"""
def get_datasets():
    df_datasets = oml.datasets.list_datasets(output_format = "dataframe")
    df_datasets = df_datasets.drop_duplicates(subset = "did").drop_duplicates(subset = ["name"]).drop_duplicates(subset = df_datasets.
                                                                                                                 drop(["did", "name", "version", "uploader"], axis = 1)
                                                                                                                 .columns, keep = "last")
    # print(df_datasets.columns)

    df_datasets = df_datasets.loc[(df_datasets["NumberOfFeatures"] < 15) &
                                   (df_datasets["NumberOfFeatures"] > 0) &
                                   (df_datasets["NumberOfInstances"] < 10000) &
                                   (df_datasets["NumberOfInstances"] > 50) &
                                   (df_datasets["NumberOfClasses"] > 1) &
                                   (df_datasets["NumberOfClasses"] < 1000)]
    
    return df_datasets


"""
Process Dataset from OpenML
"""
def process_openml_dataset(dataset_index, target_var):
    """
    Grabs the dataset from openml using the dataset_index variable and
    proprocesses the data.

    Preprocesssing Steps:
        - numerical features: impute with median and scale data
        - categorical features: impute with 'missing' and encode
        - label: encode with values between 0 and n_classes - 1

    @Parameters
    (int) dataset_index: index of the dataset
    (string) target_var: name of target variable

    @Returns
    (pandas.dataframe) X_preprocessed: preprocessed data from dataset
    (pandas.dataframe) y_preprocessed: preprocessed data from target values
    """

    # extract the dataset from openml
    try:
        dataset = oml.datasets.get_dataset(dataset_id = dataset_index)

    except oml.exceptions.OpenMLServerException as e:
        if e.code == 362:
            print(e)
        return None, None

    # try to convert to dataframe
    try:
        X, y, categorical_indicator, attribute_names = dataset.get_data(
            dataset_format = "dataframe",
            target = dataset.default_target_attribute
        )
    except Exception as e:
        print(e)
        return None, None
    
    # exclude "object" datatypes
    X = X.select_dtypes(exclude=["object"])

    # preprocess the data
    X_preprocessed, y_preprocessed = preprocess_data(X, y, target_variable = target_var)

    return X_preprocessed, y_preprocessed

"""
Preprocessing Pipeline
"""
def preprocess_data(X, y, target_variable):

    # transformer for numerical features
    numeric_transformer = Pipeline(steps = [
        ("imputer", SimpleImputer(strategy = "median")),
        ("scaler", StandardScaler())
    ])

    # tranformer for categorical features
    categorical_transformer = Pipeline(steps = [
        ("imputer", SimpleImputer(strategy = "constant", fill_value = "missing")),
        ("onehot", OrdinalEncoder())
    ])

    # concatenate into a single column transformer
    column_transformer = ColumnTransformer(transformers = [
        ("num", numeric_transformer, selector(dtype_exclude = ["category"])),
        ("cat", categorical_transformer, selector(dtype_include = "category"))
    ])

    # preprocess the X values
    X_preprocessed = column_transformer.fit_transform(X)
    # format the dataset such that the numerical features are first and then the categorical
    X_preprocessed = pd.DataFrame(X_preprocessed, columns = X.select_dtypes(exclude = ["category"])
                                  .columns.append(X.select_dtypes(include = ["category"]).columns))
    
    # encode the labels
    label_encoder = LabelEncoder()
    y_preprocessed = label_encoder.fit_transform(y)
    y_preprocessed = pd.Series(y_preprocessed, name = target_variable)

    # return the preprocessed data
    return X_preprocessed, y_preprocessed

main()