#!/bin/bash
# $1 - filename
#Today defines the name of the database, data is rodated dayly.
TIMEZONE=":America/Sao_Paulo"
TODAY=$(TZ=$TIMEZONE date +%Y%m%d)
TODAY_DB="dv2_$TODAY"
NOW_EPOCH=$(date +%s)
#COUCH_DB=http://couchdb:5984

#create DB if donot exist.
#curl -X PUT $COUCH_DB/$TODAY_DB
#do login:
echo "${1}" >> log_run_busao.txt
DATA=/root/RAM
HOME=/root
LOGS=/root

API_TOKEN_OLHOVIVO=$(cat $HOME/token.txt)
#echo "API_TOKEN_OLHOVIVO: $API_TOKEN_OLHOVIVO: " >> $LOGS/log_run_busao.txt
curl -X POST http://api.olhovivo.sptrans.com.br/v0/Login/Autenticar?token=${API_TOKEN_OLHOVIVO} -H "Content-Type: application/text" -H "Content-Length:0" -c $DATA/raw_${1}_loginV2.txt

##By bus line code:
echo $TODAY_DB
cd $DATA/
rm $DATA/raw_${1}_result.csv
NOW="BLANK"
HR_CONVERTED=0
while read CURRENT_LINE; do
  echo $CURRENT_LINE
	#get line  infomration and save it on result.txt
		LINE=$CURRENT_LINE
		#echo $LINE
		curl -X GET http://api.olhovivo.sptrans.com.br/v0/Posicao?codigoLinha=$LINE -b $DATA/raw_${1}_loginV2.txt -o $DATA/raw_${1}_result.txt -s
    echo "$(cat $DATA/raw_${1}_result.txt)"
		#How is the time of the collection
    # if removed due to file could start with bad bus reading like metro
    #if [ "$NOW" = "BLANK" ]
    #  then
		    NOW=$(cat $DATA/raw_${1}_result.txt | jq '.hr' | tr -d \" )
        HR_CONVERTED=$(TZ=$TIMEZONE date --date "$TODAY $NOW" +%s)
    #fi
    jq  --arg HR_CONVERTED $HR_CONVERTED --arg TODAY $TODAY --arg LINE $CURRENT_LINE --arg NOW $NOW_EPOCH -r ".vs[] as \$reading | [ \$TODAY + \"-\" + .hr + \"-\" + \$reading.p,\$TODAY, .hr,  \$reading.p, \$reading.px, \$reading.py, \$LINE, \$NOW, \$HR_CONVERTED] | @csv" < $DATA/raw_${1}_result.txt >> $DATA/raw_${1}_result.csv
		#save data
	  #echo $NOW
	  #cat ~/result.txt
		#curl -X PUT -H "Content-Type: application/json" $COUCH_DB/$TODAY_DB/"$NOW-$LINE" -d @/root/raw_${1}_result.txt -s

done <$HOME/$1
#cat $HOME/raw_${1}_result.csv | wc -l >> $LOGS/log_run_busao.txt
cqlsh cassandra_host --execute="copy Bus.readings(key, day ,hr, p, px, py, codigolinha, collectedEpoch, hr_converted) from '$DATA/raw_${1}_result.csv' WITH DELIMITER =',' AND HEADER=FALSE ";
DATA_COUNT=$(cat $DATA/raw_${1}_result.csv | wc -l)
cqlsh cassandra_host --execute="insert into Bus.reading_total(collected_epoch,file,count) values ($NOW_EPOCH,'${1}',$DATA_COUNT);";
echo "End run - converted:`date` - ${1} - ${NOW} - $DATA_COUNT" >> $LOGS/log_run_busao.txt
