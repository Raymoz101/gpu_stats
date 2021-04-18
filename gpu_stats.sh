#!/bin/bash
# by sz and Raymoz
CheckMinerRunning=0
CheckMinerRunning=$(cat /run/hive/khs)
if (($CheckMinerRunning > 0))
then
WorkerName="" #This worker hostname
InfluxdbIPAddress="" #If running a local InfluxDB, either localhost or the IP where InfluxDB is running
InfluxDataURL="" #Example = "https://us-west-2-1.aws.cloud2.influxdata.com"
Org="" #Org for local InfluxDB Instance
InfluxDataOrg="" #This is your InfluxData Cloud login email
Bucket="" #Bucket for local InfluxDB Instance
AuthToken="" #AuthToken for local InfluxDB Instance
InfluxDataAuthToken="" #InfluxData Cloud AuthToken
nbGPU=($(nvidia-smi -L | cut -f 1 -d : | grep -Eo '[0-9]'))
#echo ${#nbGPU[@]}
for ((gpu=0;gpu<${#nbGPU[@]};gpu++));
do
        #gpu=$(( gpu - 1))
        myGPU=$(nvidia-smi -i "${gpu}" --query-gpu=power.draw,clocks.sm,clocks.mem,clocks.gr,temperature.gpu,utilization.gpu,fan.speed,pstate --format=csv,noheader )
        myPowerDraw=$(echo "${myGPU}" | cut -d ',' -f 1 | grep -Eo '[0-9.]+')
        myClockSm=$(echo "${myGPU}" | cut -d ',' -f 2 | grep -Eo '[0-9.]+')
        myClockMem=$(echo "${myGPU}" | cut -d ',' -f 3 | grep -Eo '[0-9.]+')
        myClockGr=$(echo "${myGPU}" | cut -d ',' -f 4 | grep -Eo '[0-9.]+')
        myTempGPU=$(echo "${myGPU}" | cut -d ',' -f 5 | grep -Eo '[0-9.]+')
        myUtilGPU=$(echo "${myGPU}" | cut -d ',' -f 6 | grep -Eo '[0-9.]+')
        myFanSpeed=$(echo "${myGPU}" | cut -d ',' -f 7 | grep -Eo '[0-9.]+')
        myPState=$(echo "${myGPU}" | cut -d ',' -f 8 | grep -Eo '[0-9.]+')
        #send to InfluxDB
        curl -XPOST "http://${InfluxdbIPAddress}:8086/api/v2/write?org=${Org}&bucket=${Bucket}&precision=s" \
        --header "Authorization: Token ${AuthToken}" \
        --data-binary "${WorkerName},GPU=${gpu} power.draw=${myPowerDraw},clocks.current.sm=${myClockSm},clocks.current.memory=${myClockMem},clocks.current.graphics=${myClockGr},utilization.gpu=${myUtilGPU},temperature.gpu=${myTempGPU},fan.speed=${myFanSpeed},pstate=${myPState}"
		##Copy to InfluxCloud
		curl -XPOST "${InfluxDataURL}/api/v2/write?org=${InfluxDataOrg}&bucket=${Bucket}&precision=s" \
		--header "Authorization: Token ${InfluxDataAuthToken}" \
		--data-binary "${WorkerName},GPU=${gpu} power.draw=${myPowerDraw},clocks.current.sm=${myClockSm},clocks.current.memory=${myClockMem},clocks.current.graphics=${myClockGr},utilization.gpu=${myUtilGPU},temperature.gpu=${myTempGPU},fan.speed=${myFanSpeed},pstate=${myPState}"
done
# Print live hashrate from HiveOS miner and send to InfluxDB, reduces it to 3 digits so as to graph nicely, adjust the last number in the cut command as needed for larger hashrates, ie. 4 if in GHs range
myHashRate=$(cat /run/hive/khs | cut -c1-3)
curl -XPOST "http://${InfluxdbIPAddress}:8086/api/v2/write?org=${Org}&bucket=${Bucket}&precision=s" \
--header "Authorization: Token ${AuthToken}" \
--data-binary "${WorkerName} hashrate=${myHashRate}"
##Copy to InfluxCloud
curl -XPOST "${InfluxDataURL}/api/v2/write?org=${InfluxDataOrg}&bucket=${Bucket}&precision=s" \
--header "Authorization: Token ${InfluxDataAuthToken}" \
--data-binary "${WorkerName} hashrate=${myHashRate}"
# Scrapes live Ethereum profitability, as USD cents per 1Mh per 24 hours and send to InfluxDB
myProfitabilityCentsPerMH=$(curl --silent https://bitinfocharts.com/ethereum/ | sed -n 's/.*id="tdid32">\([^ ]*\).*/\1/p')
curl -XPOST "http://${InfluxdbIPAddress}:8086/api/v2/write?org=${Org}&bucket=${Bucket}&precision=s" \
--header "Authorization: Token ${AuthToken}" \
--data-binary "${WorkerName} CentsPerMH=${myProfitabilityCentsPerMH}"
##Copy to InfluxCloud
curl -XPOST "${InfluxDataURL}/api/v2/write?org=${InfluxDataOrg}&bucket=${Bucket}&precision=s" \
--header "Authorization: Token ${InfluxDataAuthToken}" \
--data-binary "${WorkerName} CentsPerMH=${myProfitabilityCentsPerMH}"
# Multiplies the live profitability per 1Mh by your hashrate, to calculate this workers daily expected revenue, handle the output by awk command so as to cope with a decimal point, then send to InfluxDB
myCurrentDailyProfitability=$(awk -v p=$myProfitabilityCentsPerMH -v h=$myHashRate 'BEGIN {r=p*h; print r}')
curl -XPOST "http://${InfluxdbIPAddress}:8086/api/v2/write?org=${Org}&bucket=${Bucket}&precision=s" \
--header "Authorization: Token ${AuthToken}" \
--data-binary "${WorkerName} CurrentDailyProfitability=${myCurrentDailyProfitability}"
##Copy to InfluxCloud
curl -XPOST "${InfluxDataURL}/api/v2/write?org=${InfluxDataOrg}&bucket=${Bucket}&precision=s" \
--header "Authorization: Token ${InfluxDataAuthToken}" \
--data-binary "${WorkerName} CurrentDailyProfitability=${myCurrentDailyProfitability}"
### Only run below commands on one rig per farm or InfluxDB instance, so as to not be wasteful
# Scrape live Ethereum price in USD
localETHLivePrice=$(curl --silent https://bitinfocharts.com/ethereum/ | sed -n 's/.*<span itemprop="price" style="font-size:22px;">\([^ ]*\).*/\1/p' | cut -d "<" -f1 | sed 's/,//g')
curl -XPOST "http://${InfluxdbIPAddress}:8086/api/v2/write?org=${Org}&bucket=${Bucket}&precision=s" \
--header "Authorization: Token ${AuthToken}" \
--data-binary "${WorkerName} ETHLivePrice=${localETHLivePrice}"
##Copy to InfluxCloud
curl -XPOST "${InfluxDataURL}/api/v2/write?org=${InfluxDataOrg}&bucket=${Bucket}&precision=s" \
--header "Authorization: Token ${InfluxDataAuthToken}" \
--data-binary "${WorkerName} ETHLivePrice=${localETHLivePrice}"
else
        echo "Miner stoppped"
fi
