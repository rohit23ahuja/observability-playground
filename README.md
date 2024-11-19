# observability-playground
repo for storing my observability learnings  
observability pieces :-  

## Node Exporter
### Run and install  
1. Download tarball from page https://prometheus.io/download/#node_exporter.
2. Extract in a directory of your choice on your VM using command ```tar -zxvf node_exporter-***.tar.gz```
3. run node exporter as background process using ```./node_exporter &```

### Verify installation 
1. Default port for node export is 9100. verify if it is running using ```netstat -tulnvp```
2. check if metrics are getting exposed. ```curl http://localhost:9100/metrics```

### aws account set up
1. set aws console account using your email
2. verify your email
3. provide your card details
4. set up a budget

### ec2 launch
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
3. rest options will be default mostly, falling under aws free tier. 
4. enable assign public ip option is set.

### ssh using putty to ec2
1. Download and install putty.
2. provide auto login username ```ec2-user``` in section connection-->data.
3. upload rsa key pair created while launching ec2 instance in section connection-->auth-->credentials.

### prometheus set up on ec2
i followed the steps mentioned on this page - https://www.tothenew.com/blog/step-by-step-setup-grafana-and-prometheus-monitoring-using-node-exporter/  
only changes i did is - used mine ec2 public ip and used latest stable version of prometheus

### prometheus node exporter set up on ec2
i followed the steps mentioned on this page - https://www.tothenew.com/blog/step-by-step-setup-grafana-and-prometheus-monitoring-using-node-exporter/
note - before running wget command for node exporter change directory to /tmp

### grafana set up on ec2
1. installed grafana using rpm package step given on page - https://grafana.com/docs/grafana/latest/setup-grafana/installation/redhat-rhel-fedora/
2. started using systemd method explained on page - https://grafana.com/docs/grafana/latest/setup-grafana/start-restart-grafana/
3. did not made aws route53 entries to avoid paying charges.

### reference links
https://jhooq.com/prometheous-grafan-setup/
https://www.youtube.com/watch?v=YUabB_7H710
https://www.youtube.com/watch?v=nJMRmhbY5hY
https://www.youtube.com/watch?v=9gj9ys_tZpo
https://www.youtube.com/watch?v=7gW5pSM6dlU
https://www.youtube.com/@PromLabs/videos  

### linux os concepts
#### cpu
first what is an CPU, so that it is clear what we are monitoring - a machine can contain  
multiple physical processors. each processor can have multiple cores. each core can have  
multiple hyperthreads. this hyperthread is the most granular "single CPU".  
An CPU spends time different kind of things. common example being system mode, user mode,  
iowait mode etc. reference links :-  
https://www.opsdash.com/blog/cpu-usage-linux.html  
https://blog.appsignal.com/2018/03/06/understanding-cpu-statistics.html

#### memory
memory or ram is divided into different parts in linux like - total, used, free, available  
reference links :-  
https://www.linuxatemyram.com/
https://serverfault.com/questions/85470/meaning-of-the-buffers-cache-line-in-the-output-of-free
https://www.baeldung.com/linux/buffer-vs-cache-memory

### making sense of metrics

#### metric format
node_cpu_seconds_total{cpu="0",job="node-exporter",instance="localhost:9100", mode!="idle"}  
to make sense of above metric
metric_name{label_name_1/key_name_1="value1",label_name_2/key_name_2="value2"}
so labels are properties or characterstics of a metric and you can it in a query
avg without(label_name_1) (metric_name{label_name_1/key_name_1="value1",label_name_2/key_name_2="value2"})

#### cpu utilization
metric name - node_cpu_seconds_total
first read linux os concepts --> cpu
This metric is a counter of cpu time since the machine has been started.  
A Counter means it is always increasing.
counter needs to be wrapped inside a rate or an irate function.  

#### disk space 
we track disk space used and available.

#### memory usage
queries :-  
1. used memory --> node_memory_MemTotal_bytes{instance="",job=""} - node_memory_MemFree_bytes{instance="",job=""}   - node_memory_Cached_bytes{instance="",job=""} - node_memory_Buffers_bytes{instance="",job=""}
2. buffers --> node_memory_Buffers_bytes{instance="",job=""}
3. cached --> node_memory_Cached_bytes{instance="",job=""}
4. free --> node_memory_MemFree_bytes{instance="",job=""}

#### network traffic
track received and transmitted network traffic.

### node exporter dashboard
building the dashboard with essential metrics:-  
https://www.youtube.com/watch?v=YUabB_7H710


 