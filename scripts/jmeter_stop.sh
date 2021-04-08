#!/usr/bin/env bash
#Script writtent to stop a running jmeter master test
#Kindly ensure you have the necessary kubeconfig

working_dir=`pwd`

master_pod=`kubectl get po -n jmeter | grep jmeter-master | awk '{print $1}'`

kubectl -n jmeter exec -ti $master_pod bash /jmeter/apache-jmeter-5.3/bin/stoptest.sh
