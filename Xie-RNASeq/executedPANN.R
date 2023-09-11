##install.packages("remotes")
##remotes::install_github("rstudio/tensorflow")
options(stringsAsFactors = F)
library(tensorflow)
##install_tensorflow(version = "2.0.0b1")
#run data

tf_config()
print("x")
library(tensorflow)
##install.packages("keras")
library(keras)
library(neuralnet)

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

# confirm that the range is now between zero and one
summary(EXC_train_norm$class)

#input_      = Input(shape=5)
#c1Input <- data.matrix(EXC_train, rownames.force = true) #57

rm(model)



input1 <- layer_input(shape = 57)
input2  <- layer_input(shape = 64)
input3  <- layer_input(shape = 56)
input4  <- layer_input(shape = 59)
input5  <- layer_input(shape = 56)
input6  <- layer_input(shape = 57)
input7  <- layer_input(shape = 70)
input8  <- layer_input(shape = 62)
input9  <- layer_input(shape = 23)
input10 <- layer_input(shape = 58)
input11 <- layer_input(shape = 28)
input12 <- layer_input(shape = 19)

#cat_layer   = Dense(4*3, activation='sigmoid', name='cat')(input_)
#TODO adjust # of nodes
cat_layer1 <- input1 %>% layer_dense(2, activation='sigmoid', name='cat1')
cat_layer2 <- input2 %>% layer_dense(2, activation='sigmoid', name='cat2')
cat_layer3 <- input3 %>% layer_dense(2, activation='sigmoid', name='cat3')
cat_layer4 <- input4 %>% layer_dense(2, activation='sigmoid', name='cat4')
cat_layer5 <- input5 %>% layer_dense(2, activation='sigmoid', name='cat5')
cat_layer6 <- input6 %>% layer_dense(2, activation='sigmoid', name='cat6')
cat_layer7 <- input7 %>% layer_dense(2, activation='sigmoid', name='cat7')
cat_layer8 <- input8 %>% layer_dense(2, activation='sigmoid', name='cat8')
cat_layer9 <- input9 %>% layer_dense(2, activation='sigmoid', name='cat9')
cat_layer10 <- input10 %>% layer_dense(2, activation='sigmoid', name='cat10')
cat_layer11 <- input11 %>% layer_dense(2, activation='sigmoid', name='cat11')
cat_layer12 <- input12 %>% layer_dense(2, activation='sigmoid', name='cat12')

#list_of_subcat_layers = c()
listLayer <- c()


#for idx, i in enumerate([2,4,3]):
final_subcat  = Dense(i, activation = 'softmax')(cat_layer[,idx*4:(idx+1)*4])
list_of_subcat_layers.append(final_subcat)
final_subcat <- layer_dense(cat_layer1, 2, activation= 'softmax')
list_subcat <- append(list_subcat,final_subcat)
list_subcat <- append(list_subcat,cat_layer2)

listLayer <- append(listLayer, cat_layer1)
listLayer <- append(listLayer, cat_layer2)
listLayer <- append(listLayer, cat_layer3)
listLayer <- append(listLayer, cat_layer4)
listLayer <- append(listLayer, cat_layer5)
listLayer <- append(listLayer, cat_layer6)
listLayer <- append(listLayer, cat_layer7)
listLayer <- append(listLayer, cat_layer8)
listLayer <- append(listLayer, cat_layer9)
listLayer <- append(listLayer, cat_layer10)
listLayer <- append(listLayer, cat_layer11)
listLayer <- append(listLayer, cat_layer12)


subcat_output = concatenate(list_of_subcat_layers, name='subcat')
outputLayer <- layer_concatenate(listLayer, name='outputLayer') %>%
layer_dense(units = 3, activation= 'softmax')
#
model_subcat  <- keras_model(inputs = c(input1,input2, input3, input4, input5, input6, input7, input8, input9, input10, input11, input12), outputs = outputLayer)
model_subcat %>% compile(loss = 'categorical_crossentropy', loss_weights=NULL, metrics=c('accuracy'), optimizer='rmsprop')
summary(model_subcat)



