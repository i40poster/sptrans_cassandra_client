#!/bin/bash
OLDIFS=$IFS
LINES_SPLIT=${SPLIT_LINES:-500}
cd /root

cqlsh cassandra_host < busao_cassandra.cql
echo "Token: ${API_TOKEN_OLHOVIVO}"
echo "Lines: ${SPLIT_LINES}"
echo "${API_TOKEN_OLHOVIVO}" > /root/token.txt
curl -X POST http://api.olhovivo.sptrans.com.br/v0/Login/Autenticar?token=${API_TOKEN_OLHOVIVO} -H "Content-Type: application/text" -H "Content-Length:0" -c /root/login_parser.txt
IFS=","
rm /root/result_routes_ids.txt
rm  /root/routes_table.csv
while read f1 f2
do
        echo "Codigo Route  is : $f1"
        CURRENT_LINE="${f1//\"}"
        echo $CURRENT_LINE
        curl -X GET http://api.olhovivo.sptrans.com.br/v0/Linha/Buscar?termosBusca=$CURRENT_LINE -b /root/login_parser.txt -o /root/result_routes.txt -s
        #NOW=$(cat ~/result_routes.txt| jq '.hr' | tr -d \" )
        cat /root/result_routes.txt
        cat /root/result_routes.txt | jq ".[]" | jq ".CodigoLinha" >> /root/result_routes_ids.txt
        jq -r ".[] as \$line | [ \$line.CodigoLinha, \$line.Letreiro, \$line.Sentido, \$line.DenominacaoTPTS, \$line.DenominacaoTSTP] | @csv"  < /root/result_routes.txt   >> /root/routes_table.csv
        #echo "Month is : $f2"
        #echo "Date  is : $f3"

done < /root/input/routes.txt
echo "Lines: ${SPLIT_LINES}"
cat /root/result_routes_ids.txt | sort -n | uniq > /root/result_routes_ids_clean.txt
split -l $LINES_SPLIT result_routes_ids_clean.txt routes_ids_clean_
ls /root/routes_ids_clean_*
IFS=$OLDIFS

cqlsh cassandra_host --execute="copy Bus.routesInfo(codigolinha, letreiro ,sentido, denominacaotpts, denominacaotstp) from '/root/routes_table.csv' WITH DELIMITER =',' AND HEADER=FALSE ";
