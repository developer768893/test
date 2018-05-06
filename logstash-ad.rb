#
# Cookbook Name:: test
# Recipe:: logstash
#
# 
#
# 
#

cookbook_file "/etc/yum.repos.d/logstash.repo" do
  source "repos/logstash.repo"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

execute 'rpm_import_logstash_key' do
  command 'rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch '
  action :run
  ignore_failure true
  not_if "rpm -q gpg-pubkey --qf '%{summary}' | grep elasticsearch"
end

yum_package "logstash" do
  action :install
  ignore_failure true
  notifies :restart, "service[logstash]", :delayed
end

execute "logstash-range-plugin" do
  command "export JAVA_HOME=/usr ; /opt/logstash/bin/plugin install logstash-filter-range && touch /opt/logstash/installed_logstash_filter_range "
  action :run
  ignore_failure true
  not_if '[ -f /opt/logstash/installed_logstash_filter_range ] ' 
  notifies :restart, "service[logstash]", :delayed
end

template "/etc/sysconfig/logstash" do
  source "logstash.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[logstash]", :delayed
end

cookbook_file "/etc/init.d/logstash" do
  source "logstash/logstash.init"
  owner "root"
  group "root"
  mode "06775"
  action :create
  notifies :restart, "service[logstash]", :delayed
end

cookbook_file "/etc/logstash/conf.d/ad" do
  source "logstash/ad"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[logstash]", :delayed
end

cookbook_file "/etc/logrotate.d/logstash" do
  source "logrotate/logstash"
  owner "root"
  group "root"
  mode "0664"
  action :create
  notifies :restart, "service[logstash]", :delayed
end

file "/etc/logstash/test" do
  action :delete
end

service "logstash" do
  action [ :start ]
  ignore_failure true
end

