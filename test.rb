#
# Cookbook Name:: test
# Recipe:: test
#
# 
#
# 
#

%w{httpd24 mod24_ssl php56 php56-gd php56-mysqlnd php56-common php56-cli}.each do |pkg|
  package pkg do
    action :install
  end
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

cookbook_file "/etc/httpd/conf.d/test-secure.conf" do
  source "apache/test-secure.conf"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/httpd/conf/httpd.conf" do
  source "apache/test.conf"
  owner "root"
  group "root"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

package "test-test-ui" do
    action :upgrade
end

service "httpd" do
  action [ :enable, :start ]
end


