library(stats)
library(dplyr)
library(randomForest)
number = sample(2, nrow(result), replace=TRUE, prob=c(0.7, 0.3))
train = result[number==1,]
test = result[number==2,]
random_model = randomForest(result ~ gre + gpa + rank, data=train)
test$predict_values = predict(random_model, test)
test$predictprob = ifelse(test$predict_values >= 0.5, 1, 0)
tab = table(test$result, test$predictprob)
tab
accuracy = sum(diag(tab)) / sum(tab) * 100
accuracy

