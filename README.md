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
        1. HTTPS traffic on TCP port 443 from your ip or from everywhere. 
        2. HTTP traffic on TCP port 80 from your ip or from everywhere.
        3. SSH on port 22 from your ip or from everywhere. 
        4. on TCP port 9090 for prometheus
        5. on TCP port 9100 for prometheus node exporter 
        6. on TCP port 9091 for prometheus push gateway
        7. on TCP port 3000 for grafana
2. create a rsa key pair for ec2 user. This will be used by putty for ssh.
   1. public key is stored on instance. private key stays on your machine.
   2. key pair can be generated in pem or ppk format. ppk works with putty.
   3. provide port 22 for ssh in putty.
   4. provide ppk key downloaded in putty(connection-->ssh-->auth)
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
* https://opeonikute.dev/posts/distributed-tracing-for-batch-workloads -- useful link

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

## Time series data
* a time series is a numeric value that changes over time. each times series has a name and a set of tags that makes up the key for this time series. time series is stored as a column on disk.
* Time series are sampled over specific intervals of time. Example - when building spring-batch-micrometer. we defined scraping job in prometheus. this scraping job is scraping multiple time series from our application like spring_batch_job_active or spring_batch_job_step. from these time series we get stream of samples like 10:15-1; 10:20-2. (timestamp-value)
* a time series in prometheus world is called metric and keys of that metric are called labels.

## Prometheus
* Prometheus is an open source monitoring tool. 
* Prometheus stores all data as time series. Same metric with same label dimensions are stored as stream of timestamped values.
* Prometheus works on pull based model. It needs targets to be configured from which it does collection.
* The target needs to expose an http endpoint. From this endpoint the data needs to be served in a specific format. Format is text based not like json or yaml based.
* metric_name{label_key="label_value"} CurrentValueOfMetric
* Each scrape or pull by prometheus only tracks the current value of each metric or time series.
* Prometheus by default stores data in a local disk.
* Prometheus includes a Time series database. 


### Metric format
Metrics can be exposed to Prometheus using a simple text based format.
Lines are separated by a line feed character. "#" are comments
Example:-
"# HELP counter of cpu time since the machine has started.
node_cpu_seconds_total{cpu="0",job="node-exporter",instance="localhost:9100", mode!="idle"}

| col1 | col2 | col3 | col4 |
| -------- | ------- | -------- | ------- |
| node_cpu_seconds_total | {cpu="0",job="node-exporter",instance="localhost:9100", mode!="idle"} | 23.0 | 1395066363000 |
| metric_name | {label_name_1/key_name_1="value1",label_name_2/key_name_2="value2"} | FloatingPointValue | TimestampInInt64 |

Labels are properties or characterstics or dimensions of a metric and you can use them in a query. Example:-
avg without(label_name_1) (metric_name{label_name_1/key_name_1="value1",label_name_2/key_name_2="value2"})

OpenMetrics is a standardize metric format built off of Prometheus text format.

### Metrics exposition
There are various client libraries that implements Prometheus text based format. https://prometheus.io/docs/instrumenting/clientlibs/ 

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
* count of requests with response time higher than 1 second. this counter will always be going up. so we attach a range to this. count of req with response > 1s in last minute etc. 

### Prometheus metric types
#### Gauges
* represent a measurement that con go up or down like memory usage or disk space
* can plot gauges as it is on a graph.
* they represent latest value of a measurement.
* gas in a tank, temperate in a thermometer. cpu being utilized over time, number of concurrent requests.

#### Counters
* they only ever go up and never down. until the process that is publishing it crashes or restarts.
* counter in itself is rarely used. they are wrapped inside rate, irate, increase methods.
* used for cumulative counting of events. counter of people passing through a given location. it can only increase or be reset to zero when restarted. 
* example - no. of errors encountered in application.

#### Summaries and Histograms
* histograms sample the distribution of metric values by counting of events in configurable "buckets". Example - histograms of batch jobs with their execution time as buckets. Jobs with 10 sec execution time(bucket 1), Jobs with 10-30sec execution time (bucket 2)

### Prometheus mistakes
* avoid cardinality bombs - by not having a label_key which can have a lot of label_values.
* try to aggregator functions where possible. in aggregator functions use relevant labels.
* avoid unscoped metric selector - when using metric name is methods like rate. use labels with metric name.
* in alerts rules not using "for" duration - like an instancedown rule should "for" duration to include that instancedown==true but for last 5 minutes.
* functions like rate, irate and increase are applied over counter time series to determine at what rate that time series is going up or down.
* the above functions take a time range. this time range should not be too small. it should be at least 4 times your scrape interval.
* incorrect functions with metrics - rate,irate,increase methods are only to be used over counter, not over gauge. value of gauge can go up or down but counter only up.
* deriv, predict_liner are applied over gauge to determine how fast a gauge is going up or down.

## Alerting 
### gmail smtp
1. enable 2 step verification for your google account.
2. define a app password from your google account. you may call app as Grafana smtp. copy password.
3. gmail smtp host is : smtp.gmail.com
4. gmail tls port is 587. and ssl port is 467. we will use tls port

### smtp config grafana
1. if grafana was installed using yum package manager.
2. then navigate to /etc/grafana/
3. edit file grafana.ini
4. navigate to section [smtp] in this file. make sure these lines are added/modified. rest lines leave as is
    * enabled = true
    * host = smtp.gmail.com:587
    * user = rohit23ahuja@gmail.com
    * password = wrongpassword
    * skip_verify = true
    * from_address = rohit23ahuja@gmail.com
    * from_name = Grafana

### Contact point
1. Navigate to grafana ui and set up Contact point using defaults.
2. send out a test notification to confirm smtp config is working fine.

### Notification policy
1. define a notification policy in grafana ui.
2. select the contact point.
3. provide label as notify = true.

### Alert over panel
1. Edit the panel, go to alert tab
2. define threshold value.
3. define evaluation behavior - pending period, folder, evaluation group.
4. define label notify=true.
5. provide email summary.

## Postgres exporter
1. https://fatdba.com/2021/03/24/how-to-monitor-your-postgresql-database-using-grafana-prometheus-postgres_exporter/
2. https://medium.com/@murat.bilal/monitoring-postgresql-with-grafana-and-prometheus-in-docker-7fe6a36ef7b1
3. https://www.linkedin.com/pulse/data-driven-database-management-monitoring-postgresql-pankaj-salunkhe/
4. https://www.howtoforge.com/how-to-monitor-postgresql-with-prometheus-and-grafana/
5. https://github.com/prometheus-community/postgres_exporter
6. dashboard id - 9628 (preferred), 6742, 14114, 12485

## Node exporter
* prometheus ui gives a help text about each of the node exporter metrics
* 1860 node exporter full grafana dashboard id. 
* node exporter can publish custom metrics from a file. node-exporter-textfile-collector-script github (https://github.com/prometheus-community/node-exporter-textfile-collector-scripts)
* building the dashboard with essential metrics:- https://www.youtube.com/watch?v=YUabB_7H710

### Node related metrics
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
1. used memory --> node_memory_MemTotal_bytes{instance="",job=""} - node_memory_MemFree_bytes{instance="",job=""}  - node_memory_Cached_bytes{instance="",job=""} - node_memory_Buffers_bytes{instance="",job=""}
2. buffers --> node_memory_Buffers_bytes{instance="",job=""}
3. cached --> node_memory_Cached_bytes{instance="",job=""}
4. free --> node_memory_MemFree_bytes{instance="",job=""}

### network traffic
track received and transmitted network traffic.

## JVM metrics
JMX way :-
* https://blog.devops.dev/collecting-metrics-with-jmx-and-prometheus-in-a-java-application-f4364b459692
* https://www.openlogic.com/blog/prometheus-java-monitoring-and-gathering-data
* https://grafana.com/blog/2020/06/25/monitoring-java-applications-with-the-prometheus-jmx-exporter-and-grafana/
* https://www.robustperception.io/measuring-java-garbage-collection-with-prometheus/

Micrometer way :-
* https://docs.micrometer.io/micrometer/reference/reference/jvm.html
* https://stackoverflow.com/questions/55395769/micrometer-metrics-with-spring-java-no-spring-boot
* https://medium.com/@ruth.kurniawati/detecting-deadlock-with-micrometer-metrics-a8b71ad63cb3
* https://grafana.com/docs/grafana-cloud/monitor-applications/asserts/enable-prom-metrics-collection/runtimes/java/



 