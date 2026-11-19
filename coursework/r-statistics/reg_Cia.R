data_1_
d=data_1_
cor(data_1_)
reg_model<-lm(bse~goldprice, data=data_1_)
summary(reg_model)
d$bse_pred=-31.84028 +0.73541 *d$goldprice
d
#finding  abs error
d$aber=abs(d$bse-d$bse_pred)
d
#mean abs error 
mae=mean(aber)
mae
#Mean absoulte percenatage error 
mape=mean(d$aber/d$bse*100)
d
mape
#the mean absolute percentage error is more than 10% so this prediction based on the gold price only is not favorable now we will check it on the other
data_1_
d=data_1_
cor(data_1_)
reg_model<-lm(bse~., data=data_1_)
summary(reg_model)
d$bse_pred=3855.94420 +0.73541 *d$goldprice + -553.50231*d$inflation + -31.02492*d$gdp
d
#finding  abs error
d$aber=abs(d$bse-d$bse_pred)
d
#mean abs error 
mae=mean(aber)
mae
#Mean absoulte percenatage error 
mape=mean(d$aber/d$bse*100)
d
mape

