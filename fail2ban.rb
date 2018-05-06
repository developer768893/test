#
# Cookbook Name:: test
# Recipe:: fail2ban
#
# 
#
# 
#

package "fail2ban" do
    action :install
end

cookbook_file "/etc/fail2ban/jail.conf" do
  source "fail2ban/jail.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[fail2ban]", :delayed
end

service "fail2ban" do
  action [ :enable, :start ]
end

