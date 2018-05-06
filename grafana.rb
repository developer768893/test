#
# Cookbook Name:: test
# Recipe:: grafana
#
# 
#
# 
#

%w{initscripts fontconfig}.each do |pkg|
  package pkg do
    action :install
    end
end

yum_package "grafana" do
    action :install
    notifies :restart, "service[grafana-server]", :delayed
  end

cookbook_file "/etc/grafana/grafana.ini" do
  source "grafana/grafana.ini"
  owner "root"
  group "grafana"
  mode "0640"
  action :create
  notifies :restart, "service[grafana-server]", :delayed
end

cookbook_file "/etc/nginx/conf.d/test.conf" do
  source "nginx/test.conf-grafana"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

service "grafana-server" do
  action [ :enable, :start ]
end
