#!/bin/bash

# This script up loads the Twitter data the Teradata DB.
#
# Written by: Hong-Chin Lin
# Date: 2014-09-23

tStart=`date`
echo $0 started at $tStart.


TERADATA="1700"
USER_PWD="xyan0,N3pf79e5yt"
SERVER="TDAdhoc.intra.searshc.com"
PERM_DB="L2_MRKTGANLYS_T"

rm -f keywords_DW.txt
rm -f dw_tweets.txt
rm -f tID_wo_dw.txt
	
bteq <<EOF > bteq.log
.LOGON ${SERVER}/${USER_PWD};
.SET WIDTH 1024

-----------------------------------------------------------------------------
----STEP 1 SELECT KEYWORDS WITH HITRATE2 >=2.4 AS CRITERION
------------------------------------------------------------------------------
DROP TABLE SHC_WORK_TBLS.D5_XY_DWKEYWORD;
CREATE TABLE shc_work_tbls.d5_xy_DWkeyword AS (
	SELECT UNIQUE WORD FROM shc_work_tbls.d5_hc_tweet_word_freq_dishwasher
	WHERE hitrate2 >=2.4 )
WITH DATA PRIMARY INDEX(WORD);
COLLECT STATS  shc_work_tbls.d5_xy_DWkeyword INDEX(WORD);

------------------------------------------------------------------------------
----STEP 2 EXPORT THE TWEETS WITH KEYWORDS SELECTED IN STEP 1
------------------------------------------------------------------------------

.EXPORT RESET
.EXPORT FILE dw_tweets.txt

SELECT 
	CAST(tID AS VARCHAR(6))||'|'||
    CAST(WORD AS VARCHAR(20))||'|'||
	CAST(PI AS CHAR(1))
FROM shc_work_tbls.d5_hc_tweet_word_dishwasher
WHERE WORD IN (SELECT WORD FROM shc_work_tbls.d5_xy_dwkeyword)
GROUP BY 1;


--------------------------------------------------------------------------------
----STEP 3 SELECT THE TID OF THE TWEETS INCLUDING KEYWORDS
-------------------------------------------------------------------------------

DROP TABLE SHC_WORK_TBLS.D5_XY_TID;
CREATE TABLE SHC_WORK_TBLS.D5_XY_TID AS (
	SELECT 
		 tID
		,WORD	 
		,PI
	FROM shc_work_tbls.d5_hc_tweet_word_dishwasher
	WHERE WORD IN (SELECT WORD FROM shc_work_tbls.d5_xy_dwkeyword)
	GROUP BY 1,2,3)
WITH DATA PRIMARY INDEX(tID);
COLLECT STATS  shc_work_tbls.d5_xy_TID INDEX(tID);


------------------------------------------------------------------------------------
----STEP 4 EXPORT THE TID OF THE TWEETS W/O KEYWORDS
------------------------------------------------------------------------------------

.EXPORT RESET
.EXPORT FILE tID_wo_dw.txt

SELECT TID, PI
FROM shc_work_tbls.d5_hc_tweet_word_dishwasher
WHERE TID NOT IN (SELECT TID FROM SHC_WORK_TBLS.D5_XY_TID)
GROUP BY 1,2;


------------------------------------------------------------------------------
-----STEP 5 EXPORT KEYWORDS
------------------------------------------------------------------------------

.EXPORT RESET
.EXPORT FILE keywords_DW.txt

select unique word from shc_work_tbls.d5_hc_tweet_word_freq_dishwasher
where hitrate2 >=2.4 ;



	.LOGOFF;

EOF
	RC=$?
	echo bteq RC: $RC
	if [ $RC -gt 10 ];
	then
		echo $0 failed.  Return Code: $RC
		exit 1
	else
		echo $0 completed.
		sed '1,2d' dw_tweets.txt > tmp.txt; mv tmp.txt dw_tweets.txt
		sed '2d' keywords_DW.txt > tmp.txt; mv tmp.txt keywords_DW.txt
		sed '2d' tID_wo_dw.txt > tmp.txt; mv tmp.txt tID_wo_dw.txt
	fi
	#


tEnd=`date`
echo $0 started at $tStart.
echo $0 ended at $tEnd.


#
# The End
