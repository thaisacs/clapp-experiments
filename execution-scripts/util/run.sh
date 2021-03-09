#!/bin/bash

arg_parse() {
  efs_ip=${args[0]}
  dest=${args[1]}
  type_vm=${args[2]}
  num_vm=${args[3]}
  bench_name=${args[4]}
  len=${args[5]}
}

init_cluster() {
  cluster=cluster-${bench_name}-${type_vm}-${num_vm}x
  clapp cluster start $cluster --extra "efs_ip=${efs_ip}"
  cluster_id=$(clapp cluster list | grep id | cut -d' ' -f2)
}

args=("$@")

arg_parse
init_cluster

results_dir=${dest}/experimental_results/${type_vm}-${num_vm}
results=node-*/home/ubuntu/PI-Bench/ECP-Proxy-Apps/exp-results/*

for ((i=0; i<len; i++)); do
  clapp cluster action ${cluster_id} ${bench_name}-group run --extra "num_n=${num_vm}"
done

clapp cluster action ${cluster_id} ${bench_name}-group fetch-results --extra "dir=${dest}/execution-scripts"

mkdir ${results_dir}
mv ${results} ${results_dir}

clapp cluster stop ${cluster_id}
