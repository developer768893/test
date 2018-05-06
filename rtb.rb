#
# Cookbook Name:: test
# Recipe:: rtb 
#
# 
#
# 
#

yum_package "test-rtb" do
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
    notifies :restart, "service[rtb]", :delayed
end

yum_package "test-rtb" do
    only_if { node.chef_environment == "staging" }
    version '549-2076.amzn1'  
    action :install
    allow_downgrade true
    notifies :restart, "service[rtb]", :delayed
end

yum_package "test-rtb" do
    only_if { node.chef_environment == "alpha" }
    version '547-2074.amzn1'  
    action :install
    allow_downgrade true
    notifies :restart, "service[rtb]", :delayed
end

yum_package "test-rtb" do
    only_if { node.chef_environment == "production" }
    version '545-2062.amzn1'  
    action :install
    allow_downgrade true
    notifies :restart, "service[rtb]", :delayed
end

yum_package "test-supervisord" do
    action :upgrade
end

cookbook_file "/opt/tools/cloudwatch-java-memory.py" do
  source "telegraf/cloudwatch-java-memory.py"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/etc/cron.d/cloudwatch_java_memory" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "* * * * * root /usr/local/bin/single.py -c /opt/tools/cloudwatch-java-memory.py >> /opt/tools/cloudwatch-java-memory.log 2>&1
  "
end

file "/opt/tools/cloudwatch-java-memory.log" do
  mode "0666"
  owner "sensu"
  group "sensu"
  action :touch
end

service "dspmockservice" do
  only_if { node.chef_environment == "development" || node.chef_environment == "staging"}
  action [ :enable, :start ]
end

service "rtb" do
  action [ :enable, :start ]
end

service "supervisord-rtb" do
  action [ :enable, :start ]
end

