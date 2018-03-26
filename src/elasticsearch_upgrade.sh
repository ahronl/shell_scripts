#!/bin/bash

#tested on master,monitor

######### script global params need to review before running
version=5.6.8
#########

echo "################"
echo "reading current envirionment stats"

stats=$(curl -XGET 'http://localhost:9200')

echo $stats

cluster_name=$(sed "s/^\(\"\)\(.*\)\1\$/\2/g" <<< $(echo $stats | jq '.cluster_name'))
prev_version=$(sed "s/^\(\"\)\(.*\)\1\$/\2/g" <<< $(echo $stats | jq '.version.number'))
url="http://localhost:9200"

echo "prev version: $prev_version"
echo "cluster_name: $cluster_name"
echo "version: $version"

echo "stoping elasticsearch"
service elasticsearch stop
echo "elasticsearch stopped"

echo "######## - uninstall all plugins"
plugins=$(/usr/share/elasticsearch/bin/elasticsearch-plugin list)

for X in $plugins 
do
   echo "$X"
   /usr/share/elasticsearch/bin/elasticsearch-plugin remove $X  
done

echo "######## - done removing all plugins"

echo "######## - dowinloading elasticsearch version: $version"

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$version.rpm
rpm -U elasticsearch-$version.rpm
\rm elasticsearch-$version.rpm

echo "######## - done install elasticsearch version: $version"

echo "######## - install all plugins: $plugins"

for X in $plugins 
do
  echo "install plugin: $X"
  /usr/share/elasticsearch/bin/elasticsearch-plugin install $X --batch   
done

echo "####### - set deprication log name"
mv /var/log/elasticsearch/"$cluster_name"_deprecation.log /var/log/elasticsearch/"$cluster_name"_deprecation_"$prev_version".log

echo "###### - set elasticsearch config replace type:ec2 with zen.hosts_provider: ec2"
sed -i 's/\(.*type: ec2.*\)/  zen.hosts_provider: ec2/g' "/etc/elasticsearch/elasticsearch.yml"

echo "######## - start elasticsearch"
service elasticsearch start

echo "######## - Please check that Elasticsearch is running"

echo "to check health please run"
echo "curl -XGET 'localhost:9200/_cat/health?pretty'"
