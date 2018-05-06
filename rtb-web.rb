#
# Cookbook Name:: test
# Recipe:: rtb-web
#
# 
#
# 
#

%w{httpd-tools python-setuptools java-1.8.0-openjdk-headless }.each do |pkg|
  package pkg do
  action :install
 end
end

yum_package "test-jetty-9" do
    action :upgrade
    allow_downgrade true
end

yum_package "test-rtb-web" do
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-rtb-web" do
    only_if { node.chef_environment == "staging" }
version '76-261.amzn1'  
    action :install
    allow_downgrade true
end

yum_package "test-rtb-web" do
    only_if { node.chef_environment == "production" }
version '76-261.amzn1'  
    action :install
    allow_downgrade true
end

execute "install-epel-repo" do
  command "yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"
  action :run
  not_if do ::File.exists?('/etc/yum.repos.d/epel.repo') end
end

cookbook_file "/etc/nginx/conf.d/test.conf" do
  only_if { node['machinename'] == "rtb-web1-dev.test.com" }
  source "nginx/test.conf-rtb-web-dev"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

cookbook_file "/etc/nginx/conf.d/test.conf" do
  only_if { node['machinename'] == "rtb-web1-stage.test.com" }
  source "nginx/test.conf-rtb-web-stage"
  owner "root"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

cookbook_file "/etc/nginx/conf.d/test.conf" do
  only_if { node['machinename'] == "rtb-web1-prod.test.com" }
  source "nginx/test.conf-rtb-web-prod"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

execute "htpasswd-create-rtb-web-dev-login" do
  command "htpasswd -bc /etc/nginx/.htpasswd test_rtb-web Vx4dX2SrfjN686dPMqPi2zQGE"
  action :run
  not_if do ::File.exists?('/etc/nginx/.htpasswd') end
end

service "nginx" do
  action [ :enable, :start ]
end

service "jetty" do
  action [ :enable, :start ]
end
