# GPU STATS
GPU Usage statistics (on Linux) for Nvidia Video Cards

Forked from: https://github.com/ts-sz/gpu_stats (Last updated 2018)


Collect your workers mining stats, scrape live Ethereum price and profitability, then send this to InfluxDB 2.0 to graph and monitor.

![Overview](https://i.imgur.com/pIr7JM1.png)

![RIG1](https://i.imgur.com/4jkWoPk.png)

![RIG2](https://i.imgur.com/RJk64wv.png)

![RIG3](https://i.imgur.com/mmhwURX.png)

All stats grab with **nvidia-smi**

### List Cards
`nvidia-smi -L`

### Stats
`nvidia-smi -i 0 --query-gpu=power.draw,clocks.sm,clocks.mem,clocks.gr,temperature.gpu,utilization.gpu,fan.speed,pstate --format=csv,noheader`

#### Fan speed
`nvidia-smi -i 0 --query-gpu=fan.speed --format=csv,noheader`

_Hashrate is ONLY if you use HiveOS [https://hiveos.farm]_

### Get started with InfluxDB

Linux Install - https://docs.influxdata.com/influxdb/v2.0/get-started/?t=Linux

Docker Install - https://docs.influxdata.com/influxdb/v2.0/get-started/?t=Docker


(No need to run Telegraf agent steps, template JSON included in repo for dashboards, import these as a starting point)

Setup - https://www.influxdata.com/blog/getting-started-with-influxdb-2-0-scraping-metrics-running-telegraf-querying-data-and-writing-data/

### One template of a worker dashboard and Farm Overview included, with different worker names and bucker/org names the cells will break, edit the .json files in Notepad do a find replace and this will work.

### Make sure to replace variables in *gpu_stats.sh* with your own from InfluxDB 2.0
Create or Copy `gpu_stats.sh` from repo into `/usr/local/bin/`

Run `chmod +x /usr/local/bin/gpu_stats.sh`

Push `gpu_stats.cron` into your crontab with `sudo cp gpu_stats.cron /etc/cron.d/gpu_stats` for execution every minute

---
souces:
* http://xcat-docs.readthedocs.io/en/stable/advanced/gpu/nvidia/management.html
* http://cryptomining-blog.com/tag/nvidia-smi/
