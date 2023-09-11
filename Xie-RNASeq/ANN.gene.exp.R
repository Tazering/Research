options(stringsAsFactors = F)
library(caret)
library(neuralnet)
##################################################
#load data sets.
load("Response.genes.rank.Rdata")
load("NA.induced.cell.Rdata")
load("GSE102827neuron.activity.scRNAseq.Rdata")

set.seed(12345)
##################################################
# choose 50% of cells in each activation state as training data
EXC_0h_index <- sample(slience_0h_cells,2222)
EXC_1h_index <- sample(early_act_1h_cells,757)
EXC_4h_index <- sample(late_act_4h_cells_v2,865)

EXC_train <- t(data[,which(colnames(data) %in% c(EXC_0h_index,EXC_1h_index,EXC_4h_index))])
EXC_train <- EXC_train[,which(colnames(EXC_train)%in%rownames(EXC_rank))]
EXC_train <- as.data.frame(EXC_train)
EXC_train$class <- 0
EXC_train$class[which(rownames(EXC_train) %in% EXC_1h_index)] <- 0.5
EXC_train$class[which(rownames(EXC_train) %in% EXC_4h_index)] <- 1
###################################################
# remaining 50% as the test data to check the prediction accuracy
EXC_test <- data[,which(colnames(data)%in% c(slience_0h_cells,early_act_1h_cells,late_act_4h_cells_v2))]
EXC_test <- t(EXC_test[,-which(colnames(EXC_test) %in% c(EXC_0h_index,EXC_1h_index,EXC_4h_index))])
EXC_test <- EXC_test[,which(colnames(EXC_test)%in%rownames(EXC_rank))]
EXC_test <- as.data.frame(EXC_test)
##################################################
# normalize before training
normalize <- function(x) { 
  return((x - min(x)) / (max(x) - min(x)))
}
# normalize
EXC_train_norm <- as.data.frame(lapply(EXC_train, normalize))
EXC_test_norm <- as.data.frame(lapply(EXC_test, normalize))

# confirm that the range is now between zero and one
summary(EXC_train_norm$class)
###################################################
# training model

set.seed(12345) # to guarantee repeatable results
concrete_model2 <- neuralnet(formula = class ~Arc+Bdnf+Btg2+Cbln2+Cdkn1a+Cyr61+Dnajb1+Dusp1+
                               Egr1+Egr2+Fos+Fosb+Gadd45b+Inhba+Iqgap2+Junb+Npas4+Nptx2+Nr4a1+
                               Penk+Prkg2+Ptgs2+Rnd3+Scg2,
                             data = EXC_train_norm, hidden =2)
plot(concrete_model2)
##################################################
# check prediction accuracy
# run model on test data
model_results2 <- compute(concrete_model2, EXC_test_norm) 
predicted_strength2 <- model_results2$net.result
# summarize predict results
EXC_result <- as.data.frame(matrix(0.5,nrow(EXC_test),2))
colnames(EXC_result) <- c("predict","real")
rownames(EXC_result) <- rownames(EXC_test)
EXC_result$predict[which(as.numeric(predicted_strength2)<=0.33)] <- 0
EXC_result$predict[which(as.numeric(predicted_strength2)>=0.64)] <- 1
for(i in 1:nrow(EXC_result))
{
  EXC_result[i,2] <- info[which(rownames(info)==rownames(EXC_result)[i]),"stim"]
}
EXC_result$real.class <- 0.5
EXC_result$real.class[which(EXC_result$real == "0h")] <- 0
EXC_result$real.class[which(EXC_result$real == "4h")] <- 1
# check the accuracy
library(ROCR)
library(pROC)
roc <- multiclass.roc(EXC_result$real.class,EXC_result$predict,percent=F)
plot(roc[['rocs']][[1]],xlim=c(1,0),ylim=c(0,1),col="red",cex.axis=1.5,cex.lab=1.5)
lines(roc[['rocs']][[2]],col="blue")
lines(roc[['rocs']][[3]],col="orange")
auc(roc[['rocs']][[1]])
auc(roc[['rocs']][[2]])
auc(roc[['rocs']][[3]])

oneLayer <- c(1:5)
neuronTest2 <- c(1:25)
for(i in 1:5){
  set.seed(12345)
  concrete_model2 <- neuralnet(formula = class ~Arc+Bdnf+Btg2+Cbln2+Cdkn1a+Cyr61+Dnajb1+Dusp1+
                                 Egr1+Egr2+Fos+Fosb+Gadd45b+Inhba+Iqgap2+Junb+Npas4+Nptx2+Nr4a1+
                                 Penk+Prkg2+Ptgs2+Rnd3+Scg2,
                               data = EXC_train_norm, hidden = i, lifesign = "full", threshold = 0.05)
  ##################################################
  # check prediction accuracy
  # run model on test data
  model_results2 <- compute(concrete_model2, EXC_test_norm)
  predicted_strength2 <- model_results2$net.result
  # summarize predict results
  EXC_result <- as.data.frame(matrix(0.5,nrow(EXC_test),2))
  
  colnames(EXC_result) <- c("predict","real")
  rownames(EXC_result) <- rownames(EXC_test)
  
  EXC_result$predict[which(as.numeric(predicted_strength2)<=0.33)] <- 0
  EXC_result$predict[which(as.numeric(predicted_strength2)>=0.64)] <- 1
  for(j in 1:nrow(EXC_result))
  {
    EXC_result[j,2] <- info[which(rownames(info)==rownames(EXC_result)[j]),"stim"]
  }
  EXC_result$real.class <- 0.5
  EXC_result$real.class[which(EXC_result$real == "0h")] <- 0
  EXC_result$real.class[which(EXC_result$real == "4h")] <- 1
  # check the accuracy
  roc <- multiclass.roc(EXC_result$real.class,EXC_result$predict,percent=F)
  
  oneLayer[i] <- (auc(roc[['rocs']][[1]])+auc(roc[['rocs']][[2]])+auc(roc[['rocs']][[3]]))
  print(oneLayer)
}


for(x in 1:5){
  for(y in 1:5){
    set.seed(12345)
    concrete_model2 <- neuralnet(formula = class ~Arc+Bdnf+Btg2+Cbln2+Cdkn1a+Cyr61+Dnajb1+Dusp1+
                                   Egr1+Egr2+Fos+Fosb+Gadd45b+Inhba+Iqgap2+Junb+Npas4+Nptx2+Nr4a1+
                                   Penk+Prkg2+Ptgs2+Rnd3+Scg2,
                                 data = EXC_train_norm, hidden = c(x,y), lifesign = "full", threshold = 0.05)
    ##################################################
    # check prediction accuracy
    # run model on test data
    model_results2 <- compute(concrete_model2, EXC_test_norm)
    predicted_strength2 <- model_results2$net.result
    # summarize predict results
    EXC_result <- as.data.frame(matrix(0.5,nrow(EXC_test),2))
    
    colnames(EXC_result) <- c("predict","real")
    rownames(EXC_result) <- rownames(EXC_test)
    
    EXC_result$predict[which(as.numeric(predicted_strength2)<=0.33)] <- 0
    EXC_result$predict[which(as.numeric(predicted_strength2)>=0.64)] <- 1
    for(j in 1:nrow(EXC_result))
    {
      EXC_result[j,2] <- info[which(rownames(info)==rownames(EXC_result)[j]),"stim"]
    }
    EXC_result$real.class <- 0.5
    EXC_result$real.class[which(EXC_result$real == "0h")] <- 0
    EXC_result$real.class[which(EXC_result$real == "4h")] <- 1
    # check the accuracy
    roc <- multiclass.roc(EXC_result$real.class,EXC_result$predict,percent=F)
    
    neuronTest[y+((x-1)*5)] <- (auc(roc[['rocs']][[1]])+auc(roc[['rocs']][[2]])+auc(roc[['rocs']][[3]]))
    print(neuronTest)
  }
  
}

rm()