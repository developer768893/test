#
# Cookbook Name:: test
# Recipe:: cacheupdater
#
# 
#
# 
#

%w{java-1.8.0-openjdk}.each do |pkg|
  package pkg do
    action :install
  end
end

cookbook_file "/etc/fstab" do
  source "cacheupdater/fstab"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

bash "cacheupdater-swap" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  if [ -f /root/swapfile ]; then
    echo "/root/swapfile already exists"
    echo 100 > /proc/sys/vm/swappiness
    swapon -a
  else
    dd if=/dev/zero of=/root/swapfile bs=1k count=4000000
    chmod 600 /root/swapfile
    mkswap /root/swapfile
    swapon -a
  fi
  EOH
end

yum_package "test-adserver" do
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-adserver" do
    only_if { node.chef_environment == "staging" }
    version '1269-10621.amzn1'  
    action :install
    allow_downgrade true
end

yum_package "test-adserver" do
    only_if { node.chef_environment == "alpha" }
    version '1267-10619.amzn1'  
    action :install
    allow_downgrade true
end

yum_package "test-adserver" do
    only_if { node.chef_environment == "production" }
    version '1265-10608.amzn1'  
    action :install
    allow_downgrade true
end

service "cacheupdater" do
   action [ :enable, :start ]
end

