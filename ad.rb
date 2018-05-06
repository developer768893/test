#
# Cookbook Name:: test
# Recipe:: ad server hosts
#
# 
#
# 
#

#REMOVE WHEN #DEV-2096 GOES TO PROD
file "/root/.aws/credentials" do
  owner "root"
  group "root"
  mode "0600"
  action :create
  content "[default]
aws_access_key_id = AKIAJPQD2KRAT2JARBTA
aws_secret_access_key = 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
[tags]
aws_access_key_id = AKIAJPQD2KRAT2JARBTA
aws_secret_access_key = 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
[adserver]
aws_access_key_id = AKIAJWM7VSNPUEQPO7TQ
aws_secret_access_key = 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
[test-system-user]
aws_access_key_id = AKIAJQ5BM7ZVLQZOMT7Q
aws_secret_access_key = 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
  "
end

yum_package "test-adserver" do
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
    notifies :restart, "service[adserver]", :delayed
end

yum_package "test-adserver" do
    only_if { node.chef_environment == "staging" }
    version '1269-10621.amzn1'  
    action :install
    allow_downgrade true
    notifies :restart, "service[adserver]", :delayed
end

yum_package "test-adserver" do
    only_if { node.chef_environment == "alpha" }
    version '1267-10619.amzn1'  
    action :install
    allow_downgrade true
    notifies :restart, "service[adserver]", :delayed
end

yum_package "test-adserver" do
    only_if { node.chef_environment == "production" }
    version '1265-10608.amzn1'  
    action :install
    allow_downgrade true
    notifies :restart, "service[adserver]", :delayed
end

%w{test-adserver-blocklists test-supervisord}.each do |pkg|
  package pkg do
    action :upgrade
  end
end

cookbook_file "/etc/logrotate.d/ad" do
  source "logrotate/ad"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

cookbook_file "/usr/local/bin/logrotate_stdout.sh" do
  source "ad/logrotate_stdout.sh"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/etc/cron.d/logrotate_stdout" do
  content "* 6,12,18 * * * root /usr/local/bin/logrotate_stdout.sh
  "
  mode "0644"
  owner "root"
  group "root"
end

cookbook_file "/opt/tools/adserver_blocklists_restart.sh" do
  source "ad/adserver_blocklists_restart.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/etc/cron.d/adserver_blocklists_restart" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "30 8 * * * root /opt/tools/adserver_blocklists_restart.sh > /dev/null 2>&1
   "
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
end

service "adserver" do
  action [ :enable, :start ]
end

service "supervisord-adserver" do
  action [ :enable, :start ]
end

