#
# Cookbook Name:: test
# Recipe:: nginx
#
# 
#
# 
#

package 'nginx' do
    action :install
end

directory "/etc/nginx/ssl" do
  owner 'root'
  group 'root'
  mode '0400'
  action :create
end

cookbook_file "/etc/nginx/ssl/dhparams.pem" do
  source "nginx/dhparams.pem"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

cookbook_file "/etc/nginx/ssl/test.key" do
  source "nginx/test.key"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

cookbook_file "/etc/nginx/ssl/test.crt" do
  source "nginx/test.crt"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

service "nginx" do
  action [ :enable, :start ]
end

