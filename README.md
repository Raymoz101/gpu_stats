# GPU STATS
GPU Usage statistics (on Linux) for Nvidia Video Cards
## Collect your workers mining stats and scrape live Ethereum price and profitability, then send this to InfluxDB 2.0 to graph and monitor
![Overview](https://i.imgur.com/pIr7JM1.png)

![RIG1](https://i.imgur.com/4jkWoPk.png)

![RIG2](https://i.imgur.com/RJk64wv.png)

![RIG3](https://i.imgur.com/mmhwURX.png)

All stats grab with **nvidia-smi**

### List Cards
`nvidia-smi -L`

### Stats
`nvidia-smi --query-gpu=power.draw,clocks.sm,clocks.mem,clocks.gr,temperature.gpu,utilization.gpu,fan.speed,pstate --format=csv,noheader`

#### Fan speed
`nvidia-smi -i 0 --query-gpu=fan.speed --format=csv,noheader`

_Hash RATE is ONLY if you use HiveOS [https://hiveos.farm]_

### Make sure to replace variables in *gpu_stats.sh* with your own from InfluxDB 2.0
Create or Copy `gpu_stats.sh` from repo into `/usr/local/bin/`
Run `chmod +x /usr/local/bin/gpu_stats.sh`
Push `gpu_stats.cron` in your crontab with `sudo cp gpu_stats.cron /etc/cron.d/gpu_stats` for execution every minute

---
souces:
* http://xcat-docs.readthedocs.io/en/stable/advanced/gpu/nvidia/management.html
* http://cryptomining-blog.com/tag/nvidia-smi/
