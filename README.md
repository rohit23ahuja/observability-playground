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
 