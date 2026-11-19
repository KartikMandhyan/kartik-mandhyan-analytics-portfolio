#model1
model<-glm(result~gpa,family = binomial(link = logit),data=result)
result$predict<-predict(model,type='response',data=result)
head(result)
result$predictprob<-ifelse(result$predict>=0.5,1,0)
result
tab<-table(result$result,result$predictprob)
tab
accuracy=sum(diag(tab)/sum(tab))*100
accuracy
summary(model)
gpa_filtered <- subset(result, gpa >= 2.5 & gpa <= 3.5)
table(gpa_filtered$result) / nrow(gpa_filtered) * 100


