#
# Cookbook Name:: test
# Recipe:: elasticsearch_logstash
#
# 
#
# 
#

%w{java-1.8.0-openjdk java-1.8.0-openjdk-devel }.each do |pkg|
  package pkg do
    action :install
  end
end

template "/etc/fstab" do
  source "elasticsearch/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :elasticsearch_dir     => '/dev/xvdf   /var/lib/elasticsearch ext4 defaults        0   2',
  )
end

bash "var_lib_es" do
  cwd "/tmp"
  code <<-EOH
   if [ ! -f /tmp/es-mount ]; then
     mkfs.ext4 -F /dev/xvdf
     mkdir -p /var/lib/elasticsearch
     mount /var/lib/elasticsearch
     touch /tmp/es-mount
   fi
  EOH
end

yum_package "elasticsearch" do
  version "5.5.2-1"
  action :install
end

directory '/var/lib/elasticsearch' do
  action :create
  recursive true
  mode "0755"
  owner "elasticsearch"
  group "elasticsearch"
end

template "/etc/elasticsearch/elasticsearch.yml" do
  source "elasticsearch/elasticsearch.erb"
  owner "root"
  group "elasticsearch"
  mode "0644"
  action :create
  notifies :restart, "service[elasticsearch]", :delayed
  variables(
    :cluster_name => 'logging_elasticsearch',
    :machinename => node['machinename'],
  )
end

cookbook_file "/etc/elasticsearch/jvm.options" do
  source "elasticsearch/jvm.options"
  owner "root"
  group "elasticsearch"
  mode "0660"
  action :create
  notifies :restart, "service[elasticsearch]", :delayed
end

cookbook_file "/opt/tools/prune_old_indexes.py" do
  source "elasticsearch/prune_old_indexes_logstash.py"
  owner "root"
  group "root"
  mode "0744"
  action :create
end

file "/etc/cron.d/prune_old_indexes" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "0 0 * * * root /opt/tools/prune_old_indexes.py
  "
end

bash "test-health-check-es-index" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    curl -XPUT 'http://localhost:9200/_template/zeroreplicas' -d '{"template":"*","settings":{"number_of_shards":1,"number_of_replicas":0}}'
    curl -s -X PUT "http://localhost:9200/test-health-check/test/1" -d '{"message":"es is alive"}'
  EOH
end

%w{elasticsearch}.each do |pkg|
  gem_package pkg do
  gem_binary '/opt/sensu/embedded/bin/gem'
  action :install
  end
end

service "elasticsearch" do
  action [ :enable, :start ]
end

