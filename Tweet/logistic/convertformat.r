setwd("C:/Xiwei/projects/tweet_mining/logmodel")
library(reshape2)
tweets = read.csv("dw_tweets.txt", sep ='|')[,1:3]
colnames(tweets) = c("tID", 'word', 'PI')
#tweets$tweet = as.character(tweets$tweet)
#keyword = read.csv('keywords_dw.txt', header=T)

tweets$value = 1
tweetcast = dcast(tweets, tID + PI ~ word, fun.aggregate = sum)
colnum = ncol(tweetcast)

tidwo = read.table("tID_wo_dw.txt", header =T)
tidwo[,3:colnum]= 0
colnames(tidwo) = colnames(tweetcast)

dwdata = rbind(tweetcast, tidwo)
write.csv(dwdata, file = 'tweet_dw.csv', row.names=F)
