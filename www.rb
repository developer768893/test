#
# Cookbook Name:: test
# Recipe:: www
#
# 
#
# 
#

%w{httpd24 mod24_ssl mysql56-server php71 php71-gd php71-mysqlnd php71-common php71-cli php71-mbstring}.each do |pkg|
  package pkg do
    action :install
  end
end

yum_package "test-wordpress" do
    action :upgrade
    allow_downgrade true
end

file "/etc/httpd/conf.d/ssl.conf" do
  action :delete
  notifies :restart, "service[httpd]", :delayed
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

cookbook_file "/etc/httpd/conf.d/www.conf" do
  source "apache/www-secure.conf"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/httpd/conf/httpd.conf" do
  source "apache/www.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

service "httpd" do
  action [ :enable, :start ]
end

service "mysqld" do
  action [ :enable, :start ]
end

