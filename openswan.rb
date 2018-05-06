#
# Cookbook Name:: test
# Recipe:: openswan
#
# 
#
# 
#

%w{openswan iftop fail2ban}.each do |pkg|
  package pkg do
    action :install
  end
end

cookbook_file "/etc/fail2ban/jail.conf" do
  source "fail2ban/jail.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[fail2ban]", :delayed
end

cookbook_file "/etc/sysctl.conf" do
  source "openswan/sysctl.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[network]", :immediately
end

cookbook_file "/etc/ipsec.d/us-east-1-to-us-west-2.conf" do
  only_if { node['machinename'] == "openswan1-prod.test.com" }
  source "openswan/us-east-1-to-us-west-2-1.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[ipsec]", :delayed
end

cookbook_file "/etc/ipsec.secrets" do
  only_if { node['machinename'] == "openswan1-prod.test.com" }
  source "openswan/us-east-1-to-us-west-2-1.secrets"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[ipsec]", :delayed
end

cookbook_file "/etc/ipsec.d/us-west-2-to-us-east-1.conf" do
  only_if { node['machinename'] == "openswan1-prod-west.test.com" }
  source "openswan/us-west-2-to-us-east-1-1.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[ipsec]", :delayed
end

cookbook_file "/etc/ipsec.secrets" do
  only_if { node['machinename'] == "openswan1-prod-west.test.com" }
  source "openswan/us-west-2-to-us-east-1-1.secrets"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[ipsec]", :delayed
end

cookbook_file "/etc/ipsec.d/us-east-1-to-us-west-2.conf" do
  only_if { node['machinename'] == "openswan2-prod.test.com" }
  source "openswan/us-east-1-to-us-west-2-2.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[ipsec]", :delayed
end

cookbook_file "/etc/ipsec.secrets" do
  only_if { node['machinename'] == "openswan2-prod.test.com" }
  source "openswan/us-east-1-to-us-west-2-2.secrets"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[ipsec]", :delayed
end

cookbook_file "/etc/ipsec.d/us-west-2-to-us-east-1.conf" do
  only_if { node['machinename'] == "openswan2-prod-west.test.com" }
  source "openswan/us-west-2-to-us-east-1-2.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[ipsec]", :delayed
end

cookbook_file "/etc/ipsec.secrets" do
  only_if { node['machinename'] == "openswan2-prod-west.test.com" }
  source "openswan/us-west-2-to-us-east-1-2.secrets"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[ipsec]", :delayed
end

cookbook_file "/etc/ipsec.conf" do
  source "openswan/ipsec.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[ipsec]", :delayed
end

bash "iptables" do
not_if 'sudo service iptables status | grep MASQUERADE'
  user "root"
  cwd "/tmp"
  code <<-EOH
      iptables -t nat -A POSTROUTING -j MASQUERADE
  EOH
end

service "network" do
  action [ :enable, :start ]
end

service "ipsec" do
  action [ :enable, :start ]
end

service "fail2ban" do
  action [ :enable, :start ]
end

