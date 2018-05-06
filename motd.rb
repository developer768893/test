#
# Cookbook Name:: test
# Recipe:: motd
#
# 
#
# 
#

file "/etc/cron.d/update-motd" do
  action :delete
end

#because this file breaks our custom /etc/motd
file "/etc/yum/pluginconf.d/update-motd.conf" do
  content ''
end

link '/etc/motd' do
  action :delete
  only_if 'test -L /etc/motd'
end

template "/etc/motd" do
  only_if { node.chef_environment == "development" }
  source "ssh/motd.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :machinename => node['machinename'],
    :cpu => node['cpu']['total'],
    :memory => node['memory']['total'][0..-3].to_i / 1024 ,
    :role => node['roles'],
    :environment => 'development',
    :uptime => node['uptime'],
    :region => node['ec2']['placement_availability_zone'],
  )
end

template "/etc/motd" do
  only_if { node.chef_environment == "staging" }
  source "ssh/motd.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :machinename => node['machinename'],
    :cpu => node['cpu']['total'],
    :memory => node['memory']['total'][0..-3].to_i / 1024 ,
    :role => node['roles'],
    :environment => 'staging',
    :uptime => node['uptime'],
    :region => node['ec2']['placement_availability_zone'],
  )
end

template "/etc/motd" do
  only_if { node.chef_environment == "alpha" }
  source "ssh/motd.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :machinename => node['machinename'],
    :cpu => node['cpu']['total'],
    :memory => node['memory']['total'][0..-3].to_i / 1024 ,
    :role => node['roles'],
    :environment => 'alpha',
    :uptime => node['uptime'],
    :region => node['ec2']['placement_availability_zone'],
  )
end

template "/etc/motd" do
  only_if { node.chef_environment == "production" }
  source "ssh/motd.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :machinename => node['machinename'],
    :cpu => node['cpu']['total'],
    :memory => node['memory']['total'][0..-3].to_i / 1024 ,
    :role => node['roles'],
    :environment => 'production',
    :uptime => node['uptime'],
    :region => node['ec2']['placement_availability_zone'],
  )
end

