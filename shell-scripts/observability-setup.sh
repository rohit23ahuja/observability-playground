#!/bin/bash

version="3.0.0"
arch="linux-amd64"
bin_dir="/usr/local/bin"
nodeexporter_version="1.8.2"
grafana_version="11.3.1"
pushgateway_version="1.10.0"
postgresexporter_version="0.16.0"

update_and_install(){
  yum update -y
  yum install git wget -y
  yum install maven -y
  yum install java-17-amazon-corretto -y
}

install_and_run_pushgateway(){
  cd /tmp/
  wget "https://github.com/prometheus/pushgateway/releases/download/v$1/pushgateway-$1.$2.tar.gz"
  tar -xvf "pushgateway-$1.$2.tar.gz"
  sudo chown -R ec2-user:ec2-user "pushgateway-$1.$2"
  cd "/tmp/pushgateway-$1.$2"
  ./pushgateway &
}

install_and_run_node_exporter(){
  cd /tmp/
  wget "https://github.com/prometheus/node_exporter/releases/download/v$1/node_exporter-$1.$2.tar.gz"
  tar -xvf "node_exporter-$1.$2.tar.gz"
  sudo chown -R ec2-user:ec2-user "node_exporter-$1.$2"
  cd "/tmp/node_exporter-$1.$2"
  ./node_exporter &
}

install_and_run_postgres_exporter(){
  cd /tmp/
  #wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.16.0/postgres_exporter-0.16.0.linux-amd64.tar.gz
  wget "https://github.com/prometheus-community/postgres_exporter/releases/download/v$1/postgres_exporter-$1.$2.tar.gz"
  tar -xvf "postgres_exporter-$1.$2.tar.gz"
  sudo chown -R ec2-user:ec2-user "postgres_exporter-$1.$2"
  sudo nano postgres_exporter.env
  sudo chown -R ec2-user:ec2-user postgres_exporter.env
  cat <<EOF >> postgres_exporter.env
DATA_SOURCE_NAME="postgresql://postgres:WorngPassword@springbatchobservabilitydb.chcgss0c0vxa.us-east-1.rds.amazonaws.com:5432/?sslmode=disable"
#DATA_SOURCE_NAME="postgresql://postgres:WorngPassword@springbatchobservabilitydb.chcgss0c0vxa.us-east-1.rds.amazonaws.com:5432/footballdb?sslmode=disable"
EOF
}

install_and_run_prometheus(){
  cd /tmp/
  wget "https://github.com/prometheus/prometheus/releases/download/v$1/prometheus-$1.$2.tar.gz"
  tar -xvf "prometheus-$1.$2.tar.gz"
  sudo chown -R ec2-user:ec2-user "prometheus-$1.$2"
  cd "/tmp/prometheus-$1.$2"
  cat <<EOF >> prometheus.yml
  # node exporter scraping job.
  - job_name: "nodeexporter"
    static_configs:
      - targets: ['localhost:9100']
EOF
  echo "Added node exporter job"
  cat <<EOF >> prometheus.yml
  # spring batch observability scraping job.
  - job_name: "springbatch"
    honor_labels: true
    static_configs:
      - targets: ['localhost:9091']
EOF
  echo "Added spring batch observability job"
  cat <<EOF >> prometheus.yml
  # postgres exporter scraping job.
  - job_name: "postgresexporter"
    static_configs:
      - targets: ['localhost:9187']
EOF
  echo "Added postgres exporter scraping job"

  ./prometheus &
}

install_and_run_grafana(){
  sudo yum install -y "https://dl.grafana.com/enterprise/release/grafana-enterprise-$1-1.x86_64.rpm"
  sudo systemctl daemon-reload
  sudo systemctl start grafana-server
}

install_application(){
  cd /tmp/
  git clone https://github.com/rohit23ahuja/dev-ra-spring-batch-micrometer.git
  sudo chown -R ec2-user:ec2-user dev-ra-spring-batch-micrometer
  cd dev-ra-spring-batch-micrometer
  mvn clean package
}

update_and_install
echo "packages updated"
install_and_run_pushgateway "$pushgateway_version" "$arch"
install_and_run_node_exporter "$nodeexporter_version" "$arch"
install_and_run_postgres_exporter "$postgresexporter_version" "$arch"
install_and_run_prometheus "$version" "$arch"
install_and_run_grafana "$grafana_version"
#install_application

