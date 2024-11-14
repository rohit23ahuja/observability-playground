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