#Task: Input => GEP for each cell;
#      Output => Activation State for Each Cell;


# call the libraries
library(ggplot2)
library(tensorflow)
library(keras)

# set working director
setwd("C:/Users/tyler/dev/Research/Xie-Research/Xie-Research")
print(getwd())

# clear environment
rm(list=ls())

# read the data
tfdata <- read.csv("TFclusters_TPM2.csv")
n <- nrow(tfdata)
m <- ncol(tfdata)

print(n)
print(m)

# make the neural network

# input (+1 for bias node)
input <- layer_input(shape = (n + 1))

# hidden


# output




