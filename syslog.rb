#
# Cookbook Name:: test
# Recipe:: syslog
#
# 
#
# 
#

#For sensu to be able to read these files.
cookbook_file "/etc/logrotate.d/syslog" do
  source "logrotate/syslog"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

file '/var/log/messages' do
  group "sensu"
  mode "0640"
end

file '/var/log/secure' do
  group "sensu"
  mode "0640"
end

service "rsyslog" do
  action [ :enable, :start ]
end

