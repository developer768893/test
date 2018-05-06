#
# Cookbook Name:: test
# Recipe:: DMP api
#
# 
#
# 
#

%w{httpd24 mod24_ssl python-setuptools java-1.8.0-openjdk java-1.8.0-openjdk-devel }.each do |pkg|
  package pkg do
    action :install
  end
end

user 'dmp' do
  comment 'dmp system user for ad server'
  system true
  shell '/bin/false'
end

yum_package "test-dmp" do 
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-dmp" do
    only_if { node.chef_environment == "staging" }
version '1269-10621.amzn1'  
    action :install
    allow_downgrade true
end

yum_package "test-dmp" do
    only_if { node.chef_environment == "production" }
version '1265-10608.amzn1'  
    action :install
    allow_downgrade true
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

cookbook_file "/etc/httpd/conf.d/dmp.conf" do
  source "apache/dmp-secure.conf"
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

cookbook_file "/etc/httpd/conf/httpd.conf" do
  source "apache/dmp.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

#remove this when we move to tomcat, cause it is a hack for crappy jetty.
file "/etc/cron.d/jetty-log-clean" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "0 * * * * root /bin/rm `find /usr/share/jetty/logs/ -atime 1 | grep log` > /dev/null 2>&1
   "
end

#dmp neustar sync api
service "httpd" do
  action [ :enable, :start ]
end

service "jetty" do
  action [ :enable, :start ]
end

