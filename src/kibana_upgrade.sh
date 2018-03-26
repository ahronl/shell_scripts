version=5.6.8
echo "######## - stopping kibana"
service kibana stop

plugins=$(/usr/share/kibana/bin/kibana-plugin list)

echo "####### - remove all plugins: $plugins"

for X in $plugins 
do
   plugin=$(cut -d "@" -f 1 <<< $X)
   echo "$plugin"
   /usr/share/kibana/bin/kibana-plugin remove $plugin
done

echo "######## - upgrade kibana"
wget https://artifacts.elastic.co/downloads/kibana/kibana-$version-x86_64.rpm
sha1sum kibana-$version-x86_64.rpm 
rpm -U kibana-$version-x86_64.rpm
\rm kibana-$version-x86_64.rpm

echo "####### - install x-pack plugin"
/usr/share/kibana/bin/kibana-plugin install x-pack   

echo "######## - start kibana"
service kibana start

echo "check kibana with curl -I http://localhost:5601/status"