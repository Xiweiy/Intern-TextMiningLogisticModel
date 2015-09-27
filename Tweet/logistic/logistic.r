#setwd("C:/Xiwei/projects/tweet_mining/logmodel")
library(dplyr)
#d = read.csv("tweet_patio.csv")
d = read.csv("tweet_dw.csv")

d2 = d[,-1]
prob = runif(nrow(d2))
dtrain = d2[prob<0.7, ]
dtest = d2[prob >= 0.7,]
write.csv(dtrain,'dtrain_data.csv')
write.csv(dtest,'dtest_data.csv')
dtrain = dtrain[,-2]; dtest = dtest[,-2]

reg = glm( PI ~., data = dtrain, family = "binomial")
#print(summary(reg))

stepwise = step(reg, direction = 'both')

dtrain$predprob <- predict(stepwise, newdata = dtrain,type = "response")
dtest$predprob <- predict(stepwise, newdata = dtest,type = "response")

dtrain = dtrain[order(dtrain$predprob, decreasing=T),]
dtest = dtest[order(dtest$predprob, decreasing=T),]
dtrain$decile = ceiling((1:nrow(dtrain))*10/nrow(dtrain))
dtest$decile = ceiling((1:nrow(dtest))*10/nrow(dtest))

decile_train = dtrain %>% group_by(decile) %>% summarize(PI = sum(PI), COUNT = n())
decile_test = dtest %>% group_by(decile) %>% summarize(PI = sum(PI), COUNT = n())

write.csv(decile_train,file="decile_train_patio.csv",row.names=FALSE,quote=FALSE);
write.csv(decile_test,file="decile_valid_patio.csv",row.names=FALSE,quote=FALSE);
print(summary(stepwise))

