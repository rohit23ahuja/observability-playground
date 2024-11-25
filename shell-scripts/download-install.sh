#!/bin/bash

version="3.0.0"
arch="linux-amd64"
bin_dir="/usr/local/bin"
nodeexporter_version="1.8.2"
grafana_version="11.3.1"

yum update -y
yum install git wget -y
cd /tmp/

wget "https://github.com/prometheus/node_exporter/releases/download/v$nodeexporter_version/node_exporter-$nodeexporter_version.$arch.tar.gz"
tar -xvf "node_exporter-$nodeexporter_version.$arch.tar.gz"
sudo chown -R ec2-user:ec2-user "node_exporter-$nodeexporter_version.$arch"

wget "https://github.com/prometheus/prometheus/releases/download/v$version/prometheus-$version.$arch.tar.gz"
tar -xvf "prometheus-$version.$arch.tar.gz"
sudo chown -R ec2-user:ec2-user "prometheus-$version.$arch"

sudo yum install -y "https://dl.grafana.com/enterprise/release/grafana-enterprise-$grafana_version-1.x86_64.rpm"


