options(stringsAsFactors = F)
library(tensorflow)
tf_config()
print("x")
library(tensorflow)
library(keras)
library(readr)

geneExpression <- read.csv("TFclusters_TPM2.csv") 
str(geneExpression)

load("Response.genes.rank.RData")
load("NA.induced.cell.Rdata")
load("GSE102827neuron.activity.scRNAseq.Rdata")

set.seed(2150)

EXC_0h_index <- sample(slience_0h_cells,2222)
EXC_1h_index <- sample(early_act_1h_cells,757)
EXC_4h_index <- sample(late_act_4h_cells_v2,865)

EXC_train <- t(data[,which(colnames(data) %in% c(EXC_0h_index,EXC_1h_index,EXC_4h_index))])
EXC_train <- EXC_train[,which(colnames(EXC_train)%in%rownames(EXC_rank))]
EXC_train <- as.data.frame(EXC_train)
EXC_train$class <- 0
EXC_train$class[which(rownames(EXC_train) %in% EXC_1h_index)] <- 0.5
EXC_train$class[which(rownames(EXC_train) %in% EXC_4h_index)] <- 1


EXC_test <- data[,which(colnames(data)%in% c(slience_0h_cells,early_act_1h_cells,late_act_4h_cells_v2))]
EXC_test <- t(EXC_test[,-which(colnames(EXC_test) %in% c(EXC_0h_index,EXC_1h_index,EXC_4h_index))])
EXC_test <- EXC_test[,which(colnames(EXC_test)%in%rownames(EXC_rank))]
EXC_test <- as.data.frame(EXC_test)

normalize <- function(x) { 
  return((x - min(x)) / (max(x) - min(x)))
}

# normalize
EXC_train_norm <- as.data.frame(lapply(EXC_train, normalize))
EXC_test_norm <- as.data.frame(lapply(EXC_test, normalize))

# prints the descriptive statistics of the the training data
summary(EXC_train_norm$class)

# arrays to store the sizes of each individual input
dummyInput <- layer_input(shape = c(1))
dummyMid <- dummyInput %>% layer_dense(unit = 1)

inputArr <- c(57, 64, 56, 59, 56, 57, 70, 62, 23, 58, 28, 19)

inputLay <- c(dummyInput, dummyInput, dummyInput, dummyInput, dummyInput, dummyInput, dummyInput,dummyInput, dummyInput,dummyInput, dummyInput, dummyInput)
midLay <- c(dummyMid, dummyMid, dummyMid, dummyMid, dummyMid, dummyMid, dummyMid, dummyMid, dummyMid, dummyMid, dummyMid, dummyMid)

# remove the model to avoid overlapping
rm(model)

# define the input
wolfInput1 <- layer_input(name = "wolfInput1", shape = c(inputArr[1]))
wolfInput2 <- layer_input(name = "wolfInput2", shape = c(inputArr[2]))
wolfInput3 <- layer_input(name = "wolfInput3", shape = c(inputArr[3]))
wolfInput4 <- layer_input(name = "wolfInput4", shape = c(inputArr[4]))
wolfInput5 <- layer_input(name = "wolfInput5", shape = c(inputArr[5]))
wolfInput6 <- layer_input(name = "wolfInput6", shape = c(inputArr[6]))
wolfInput7 <- layer_input(name = "wolfInput7", shape = c(inputArr[7]))
wolfInput8 <- layer_input(name = "wolfInput8", shape = c(inputArr[8]))
wolfInput9 <- layer_input(name = "wolfInput9", shape = c(inputArr[9]))
wolfInput10 <- layer_input(name = "wolfInput10", shape = c(inputArr[10]))
wolfInput11 <- layer_input(name = "wolfInput11", shape = c(inputArr[11]))
wolfInput12 <- layer_input(name = "wolfInput12", shape = c(inputArr[12]))

#dense layers
wolfMid1 <- wolfInput1 %>%
  layer_dense(name = "wolfMid1", units = 2, activation = 'sigmoid')

wolfMid2 <- wolfInput2 %>%
  layer_dense(name = "wolfMid2", units = 2, activation = 'sigmoid')

wolfMid3 <- wolfInput3 %>%
  layer_dense(name = "wolfMid3", units = 2, activation = 'sigmoid')

wolfMid4 <- wolfInput4 %>%
  layer_dense(name = "wolfMid4", units = 2, activation = 'sigmoid')

wolfMid5 <- wolfInput5 %>%
  layer_dense(name = "wolfMid5", units = 2, activation = 'sigmoid')

wolfMid6 <- wolfInput6 %>%
  layer_dense(name = "wolfMid6", units = 2, activation = 'sigmoid')

wolfMid7 <- wolfInput7 %>%
  layer_dense(name = "wolfMid7", units = 2, activation = 'sigmoid')

wolfMid8 <- wolfInput8 %>%
  layer_dense(name = "wolfMid8", units = 2, activation = 'sigmoid')

wolfMid9 <- wolfInput9 %>%
  layer_dense(name = "wolfMid9", units = 2, activation = 'sigmoid')

wolfMid10 <- wolfInput10 %>%
  layer_dense(name = "wolfMid10", units = 2, activation = 'sigmoid')

wolfMid11 <- wolfInput11 %>%
  layer_dense(name = "wolfMid11", units = 2, activation = 'sigmoid')

wolfMid12 <- wolfInput12 %>%
  layer_dense(name = "wolfMid12", units = 2, activation = 'sigmoid')

listLayer <- c()


#output layer
listLayer <- append(listLayer, wolfMid1)
listLayer <- append(listLayer, wolfMid2)
listLayer <- append(listLayer, wolfMid3)
listLayer <- append(listLayer, wolfMid4)
listLayer <- append(listLayer, wolfMid5)
listLayer <- append(listLayer, wolfMid6)
listLayer <- append(listLayer, wolfMid7)
listLayer <- append(listLayer, wolfMid8)
listLayer <- append(listLayer, wolfMid9)
listLayer <- append(listLayer, wolfMid10)
listLayer <- append(listLayer, wolfMid11)
listLayer <- append(listLayer, wolfMid12)

wolfOutputLayer <- layer_concatenate(listLayer, name='wolfOutputConcat') %>%
layer_dense(units = 3, activation= 'softmax', name = "wolfOutput")

# make the model
model <- keras_model(inputs = c(wolfInput1, wolfInput2, wolfInput3, wolfInput4, wolfInput5, wolfInput6, wolfInput7, wolfInput8, wolfInput9, wolfInput10, wolfInput11, wolfInput12), 
                     outputs = wolfOutputLayer)

#compile the model
model %>% compile(
  optimizer = 'rmsprop',
  loss = 'categorical-crossentropy',
  metrics = c('accuracy')
)

summary(model)

# history <- model %>%
#   fit(
#     x = EXC_train_norm, y = EXC_test_norm,
#     epochs = 30,
#     use_multiprocessing=TRUE,
#     batch_size=30
#   )

plot(history)




