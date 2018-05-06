#
# Cookbook Name:: test
# Recipe:: rtb-bidder
#
# 
#
# 
#

package "java-1.7.0-openjdk" do
  action :remove
end

%w{httpd24 mod24_ssl python-setuptools java-1.8.0-openjdk-headless java-1.8.0-openjdk-devel }.each do |pkg|
  package pkg do
  action :install
 end
end

yum_package "test-rtb-bidder" do
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-rtb-bidder" do
    only_if { node.chef_environment == "staging" }
version '1020-2792.amzn1'  
    action :install
    allow_downgrade true
end

yum_package "test-rtb-bidder" do
    only_if { node.chef_environment == "production" }
version '1020-2792.amzn1'  
    action :install  
    allow_downgrade true
end

yum_package "test-rtb-bidder" do
    only_if { node.chef_environment == "alpha" }
version '286-1074.amzn1'  
    action :install
    allow_downgrade true
end

package "test-rtb-bidder-blocklists" do
    action :upgrade
end

cookbook_file "/etc/logrotate.d/httpd" do
  source "logrotate/httpd"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

cookbook_file "/etc/logstash/conf.d/rtb-bidder" do
  action :delete
  notifies :restart, "service[logstash]", :delayed
  not_if { node['machinename'] == "ip-10-0-24-101" }
end

cookbook_file "/etc/logstash/conf.d/rtb-bidder" do
  source "logstash/rtb-bidder"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[logstash]", :delayed
  only_if { node['machinename'] == "ip-10-0-24-101" }
end

cookbook_file "/etc/pki/tls/certs/dhparams.pem" do
  source "apache/dhparams.pem"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/pki/tls/certs/test.crt" do
  source "apache/test.crt"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/pki/tls/private/test.key" do
  source "apache/test.key"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/httpd/conf/httpd.conf" do
  source "apache/bidder.conf"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/httpd/conf.d/bidder.conf" do
  source "apache/bidder-secure.conf"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

file "/etc/httpd/conf.d/ssl.conf" do
  action :delete
  notifies :restart, "service[httpd]", :delayed
end

service "httpd" do
  action [ :enable, :start ]
end

service "jetty" do
  action [ :enable, :start ]
end

service "dspmockservice" do
  action [ :enable, :start ]
end

