#
# Cookbook Name:: test
# Recipe:: kibana
#
# 
#
# 
#

%w{httpd-tools java-1.8.0-openjdk test-kibana}.each do |pkg|
  package pkg do
    action :install
  end
end

cookbook_file "/etc/nginx/conf.d/test.conf" do
  source "nginx/test.conf-kibana"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

execute "htpasswd-create-kibana-login" do
  command "htpasswd -bc /etc/nginx/.htpasswd test_kibana 2adYo86pybrU6iFK"
  action :run
  not_if do ::File.exists?('/etc/nginx/.htpasswd') end
end

template "/etc/kibana/kibana.yml" do
  source "kibana/kibana.erb"
  owner "kibana"
  group "kibana"
  mode "0644"
  action :create
  notifies :restart, "service[kibana]", :delayed
  variables(
    :cluster_url => 'http://es-logs-prod.test.com:9200',
  )
end

service "kibana" do
  action [ :enable, :start ]
end

service "nginx" do
  action [ :enable, :start ]
end
