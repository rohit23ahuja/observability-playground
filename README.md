# Observability Playground
Repo for :-
* Storing my Observability learnings.
* Setting up AWS, EC2.
* Setting up Observability softwares - Prometheus and respective Collectors, Grafana.
* Notes on Linux OS concepts collected while learning node exporter dashboard.
* Notes on Prometheus - concepts, queries, best practices, architecture etc.
* Notes on node exporter, pushgateway
* Notes on grafana.
* Create node exporter dashboard on ec2.
* Run https://github.com/rohit23ahuja/dev-ra-spring-batch-micrometer on ec2.
* Create spring batch dashboard for dev-ra-spring-batch-micrometer.
 
## Setup
### AWS Account
1. set aws console account using your email
2. verify your email
3. provide your card details
4. set up a budget
5. always select ```us-east-1``` as the region.

### EC2 Launch
1. create a security group which:-  
    1. has an outbound rule that allows traffic to go out from your server.
    2. has inbound rules that allows incoming :-
        1. HTTPS traffic on TCP port 443.
        2. HTTP traffic on TCP port 80.
        3. SSH on port 22. 
        4. on TCP port 9090 for prometheus
        5. on TCP port 9100 for prometheus node exporter 
        6. on TCP port 9091 for prometheus push gateway
        7. on TCP port 3000 for grafana
2. create a rsa key pair for ec2 user. This will be used by putty for ssh.
3. select amazon linux 2, architecture 64-bit x86.
4. rest options will be default mostly, falling under aws free tier. 
5. enable assign public ip option is set.
6. Navigate to end of Advanced Details on EC2 launch and provide [download-install.sh](shell-scripts/download-install.sh) as User data.

### RDS Launch
1. Create a security group which :-
   1. has an inbound rule that allows TCP connections from all IPs on postgres port 5432.
   2. This is not ideal but still defining it for testing purposes.
2. Go RDS service, select Postgres engine version.
3. Select Free tier template for your db
4. Provide master password for your db.
5. Attach the created security group to this DB instance.
6. De select enable performance insights to save on unnecessary costs.
7. Allow public access 
8. use pgadmin to test connection to this DB instance from your local machine.

### Installation on EC2
* Based on my limited knowledge of shell scripting have created [download-install.sh](shell-scripts/download-install.sh) 
* This script downloads and installs prometheus, node exporter and grafana on ec2 in /tmp/

### Startup and configuration
### Node Exporter
1. Navigate to node exporter directory in /tmp/
2. to start ```./node_exporter &```
3. Default port for node export is 9100. verify if it is running using ```netstat -tulnvp```
4. If security group in configured correctly, check if metrics are getting exposed. http://EC2PublicIP:9100/metrics

### Prometheus
1. Navigate to node exporter directory in /tmp/
2. remove existing ```prometheus.yml```
3. create new file ```prometheus.yml```
4. Copy contents of file [prometheus.yml](prometheus-config/prometheus.yml) into this file.
5. This file has scraping job of node exporter.
6. Start prometheus server using ```./prometheus &```
7. If security group in configured correctly, check if prometheus ui is accessible at - http://EC2PublicIP:9090/
8. Verify nodeexporter and prometheus are present as target on page - http://EC2PublicIP:9090/targets

### Grafana
1. the ```yum rpm``` command should have installed grafana on vm.
2. run ```sudo systemctl daemon-reload``` and ```sudo systemctl start grafana-server``` to start grafana server.
3. If security group in configured correctly, check if grafana ui is accessible at - http://EC2PublicIP:3000/.
4. to verify if grafana is running, we can also use ```sudo systemctl status grafana-server```.

### SSH to EC2
1. Download and install putty.
2. copy public ip from ec2 and use in hostname field.
3. provide auto login username ```ec2-user``` in section connection-->data.
4. upload rsa key pair created while launching ec2 instance in section connection-->auth-->credentials.

## Reference Links
* Prometheus, Node exporter installation and configuration - https://www.tothenew.com/blog/step-by-step-setup-grafana-and-prometheus-monitoring-using-node-exporter/
* https://jhooq.com/prometheous-grafan-setup/
* Only essential node exporter dashboard from scratch - https://www.youtube.com/watch?v=YUabB_7H710
* https://www.youtube.com/watch?v=nJMRmhbY5hY
* https://www.youtube.com/watch?v=9gj9ys_tZpo
* https://www.youtube.com/watch?v=7gW5pSM6dlU
* https://www.youtube.com/@PromLabs/videos
* https://www.youtube.com/watch?v=jb9j_IYv4cU
* https://www.youtube.com/watch?v=BjyI93c8ltA

## Linux OS Concepts
### CPU
first what is an CPU, so that it is clear what we are monitoring - a machine can contain  
multiple physical processors. each processor can have multiple cores. each core can have  
multiple hyperthreads. this hyperthread is the most granular "single CPU".  
An CPU spends time different kind of things. common example being system mode, user mode,  
iowait mode etc. reference links :-  
https://www.opsdash.com/blog/cpu-usage-linux.html  
https://blog.appsignal.com/2018/03/06/understanding-cpu-statistics.html

### Memory
memory or ram is divided into different parts in linux like - total, used, free, available  
reference links :-  
https://www.linuxatemyram.com/
https://serverfault.com/questions/85470/meaning-of-the-buffers-cache-line-in-the-output-of-free
https://www.baeldung.com/linux/buffer-vs-cache-memory

## Prometheus
### Metric format
node_cpu_seconds_total{cpu="0",job="node-exporter",instance="localhost:9100", mode!="idle"}  
to make sense of above metric
metric_name{label_name_1/key_name_1="value1",label_name_2/key_name_2="value2"}
so labels are properties or characterstics of a metric and you can it in a query
avg without(label_name_1) (metric_name{label_name_1/key_name_1="value1",label_name_2/key_name_2="value2"})

### cpu utilization
metric name - node_cpu_seconds_total
first read linux os concepts --> cpu
This metric is a counter of cpu time since the machine has been started.  
A Counter means it is always increasing.
counter needs to be wrapped inside a rate or an irate function.  

### disk space 
we track disk space used and available.

### memory usage
queries :-  
1. used memory --> node_memory_MemTotal_bytes{instance="",job=""} - node_memory_MemFree_bytes{instance="",job=""}   - node_memory_Cached_bytes{instance="",job=""} - node_memory_Buffers_bytes{instance="",job=""}
2. buffers --> node_memory_Buffers_bytes{instance="",job=""}
3. cached --> node_memory_Cached_bytes{instance="",job=""}
4. free --> node_memory_MemFree_bytes{instance="",job=""}

### network traffic
track received and transmitted network traffic.

### node exporter dashboard
building the dashboard with essential metrics:-  
https://www.youtube.com/watch?v=YUabB_7H710

### notes from video - https://www.youtube.com/watch?v=STVMGrYIlfg

### prometheus data model
* a time series is a numeric value that changes over time. each times series has a name  
and a set of tags that makes up the key for this time series. time series is stored as  
a column on disk.
* Time series are sampled over specific intervals of time. 
* when building spring-batch-micrometer. we defined scraping job in prometheus. this scraping job is scraping multiple time series from our application like spring_batch_job_active or spring_batch_job_step. from these time series we get stream of samples like 10:15-1; 10:20-2. (timestamp-value)
* a time series in prometheus world is called metric and keys of that metric are called labels.

### metrics transfer format
* prometheus operates on pull based format. the service needs to expose an http endpoint.
* from this endpoint the data needs to be served in a specific format. 
* format is text based not like json or yaml based.
* metric_name{label_key="label_value"} CurrentValueOfMetric
* Each scrape or pull by prometheus only tracks the current value of each metric or time series.

### PromQL
* data stored by prometheus can be used alerting, dashboarding or ad-hoc debugging.
* to query data stored PromQL is used.
* Example - Below metric gives count http requests since the server was started labelled by path, status, method
* http_request_total{path="/foo", status="500",method="GET"} 233
* http_request_total{path="/foo", status="200",method="GET"} 602
* http_request_total{path="/bar", status="200",method="GET"} 1002
* http_request_total{path="/bar", status="500",method="GET"} 101
* now to get count of http requests with status 500 across all paths and method. we can do:-
* http_request_total{status="500"}
* The above gives the current value across all metrics. This is an absolute count. But a more interesting statistic will be how many 500 errors are occurring per second over a time range. So that we can understand the behavior of our system better. so you can query like:-
* rate(http_request_total{status="500"}[5m])
* all you can add dimensions to your query by considering only certain labels and ignoring the rest.
* sum by (path) (rate(http_requests_total{status="500"} [5m])) - this gives us per path total requests rate with status 500.
* now we may want to know the percentage of 500 statuses for each path. specially those paths who have 500 statuses for more than 5% of the total requests received. you can do :-
* sum by (path) (rate(http_requests_total{status="500"} [5m])) /
* sum by (path) (rate(http_requests_total [5m]))
* Multiplyby100ToGetAnPercentage 100
* > 5
* promql cheat sheet - https://promlabs.com/promql-cheat-sheet/

### Prometheus metric types
#### Gauges
* represent a measurement that con go up or down like memory usage or disk space
* can plot gauges as it is on a graph
#### Counters
* they only ever go up and never down. until the process that is publishing it crashes or restarts.
* counter in itself is rarely used. they are wrapped inside rate, irate, increase methods.
#### summaries and histograms

### node exporter
* prometheus ui gives a help text about each of the node exporter metrics
* 1860 node exporter full grafana dashboard id. 
* node exporter can publish custom metrics from a file. node-exporter-textfile-collector-script github (https://github.com/prometheus-community/node-exporter-textfile-collector-scripts)

### prometheus mistakes
* avoid cardinality bombs - by not having a label_key which can have a lot of label_values.
* try to aggregator functions where possible. in aggregator functions use relevant labels.
* avoid unscoped metric selector - when using metric name is methods like rate. use labels with metric name.
* in alerts rules not using "for" duration - like an instancedown rule should "for" duration to include that instancedown==true but for last 5 minutes.
* functions like rate, irate and increase are applied over counter time series to determine at what rate that time series is going up or down.
* the above functions take a time range. this time range should not be too small. it should be at least 4 times your scrape interval.
* incorrect functions with metrics - rate,irate,increase methods are only to be used over counter, not over gauge. value of gauge can go up or down but counter only up.
* deriv, predict_liner are applied over gauge to determine how fast a gauge is going up or down.

 