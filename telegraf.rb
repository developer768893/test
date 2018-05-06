#
# Cookbook Name:: test
# Recipe:: telegraf
#
# 
#
# 
#

%w{tcpdump telegraf}.each do |pkg|
  package pkg do
    action :upgrade
  end
end

cookbook_file "/usr/local/bin/single.py" do
  source "chef/single.py"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

bash "telegraf_assign_role_env" do
  cwd "/tmp"
  code <<-EOH
   if [ -f /var/chef/role ]; then
     export CHEF_ROLE=`cat /var/chef/role | cut -d',' -f 1 | cut -c2-`
     env | grep CHEF_ROLE
   fi
  EOH
end

ruby_block 'get_main_role_attr' do
  block do
    require 'mixlib/shellout'
    rolecmd = Mixlib::ShellOut.new("cat /var/chef/role | cut -d',' -f 1 | cut -c2-")
    rolecmd.run_command
    rolecmd.error!
    node.normal['mainrole'] = rolecmd.stdout
  end
end

template "/etc/telegraf/telegraf.conf" do
  only_if { node['ec2']['placement_availability_zone'].chop == "us-west-2" }
  source "telegraf/telegraf-west.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :instanceid => node['ec2']['instance_id'],
    :role => node['mainrole'],
    :region => "us-west-2",
  )
  notifies :restart, "service[telegraf]", :delayed
end

template "/etc/telegraf/telegraf.conf" do
  source "telegraf/telegraf.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :instanceid => node['ec2']['instance_id'],
    :role => node['mainrole'],
    :environment => "production",
    :region => "us-east-1",
  ) if node['ec2']['placement_availability_zone'].chop == "us-east-1" && node.chef_environment == "production"
  variables(
    :role => node['mainrole'],
    :environment => "alpha",
    :region => "us-east-1",
  ) if node.chef_environment == "alpha"
  notifies :restart, "service[telegraf]", :delayed
end

cookbook_file "/usr/bin/telegraf-billable-bandwidth.sh" do
  source "telegraf/telegraf-billable-bandwidth.sh"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

cookbook_file "/etc/cron.d/telegraf-billable-bandwidth" do
  source "telegraf/telegraf-billable-bandwidth"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

service "telegraf" do
  action [ :enable, :start ]
  ignore_failure true
end
