output_tweets.sh -- Output keyword, tweets with selected keyword, and tweets w/0 selected keyword into 3 different file.
	step 1 - Select the keywords based on certain criterion of hitrate2
	step 2 - Export the tweets containing the selected keyword in step 1, as well as the keyword it contained. Output file 'dw_tweets.txt'
	step 3,4 - Export the tweets not containing the selected keyword. Output file 'tID_wo_dw.txt'
	step 5 - Export the keyword list. Output file 'keywords_DW.txt'

convertformat.r -- Read in 'dw_tweets.txt' and 'tID_wo_dw.txt' and convert the long format file into wide format.

tweet_dw.csv -- example output wide format file.

logistic.r -- read in the wide format file and build the logistic regression model by stepwise selection procedure.