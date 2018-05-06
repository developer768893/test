#
# Cookbook Name:: test
# Recipe:: dsui
#
# 
#
# 
#

%w{ruby-devel mysql-devel sqlite-devel redis libxml2-devel libxslt-devel libcurl-devel compat-libffi5 ImageMagick}.each do |pkg|
  package pkg do
    action :install
  end
end

cookbook_file "/etc/fstab" do
  source "dsui/fstab"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

bash "dsui-swap" do
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

bash "rvm_bundle_setup" do
  user "root"
  cwd "/tmp"
  not_if do ::File.exists?('/usr/local/rvm/rubies/ruby-2.0.0-p353/bin/gem') end
  code <<-EOH
  yum groupinstall -y 'development tools'
  gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -L get.rvm.io | bash -s stable
  source /etc/profile.d/rvm.sh
  rvm install ruby-2.0.0-p353
  /usr/local/rvm/rubies/ruby-2.0.0-p353/bin/gem install bundle
  EOH
end

user 'dsui' do
  comment 'dsui system user for demand side ui ruby process'
  home '/opt/dsui'
  system true
  shell '/bin/bash'
end

cookbook_file "/etc/nginx/nginx.conf" do
  source "nginx/nginx-default.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

cookbook_file "/etc/nginx/conf.d/test.conf" do
  only_if { node.chef_environment == "production" }
  source "nginx/test.conf-ds.test.com"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

cookbook_file "/etc/nginx/conf.d/test.conf" do
  only_if { node.chef_environment == "staging" }
  source "nginx/test.conf-staging-ds.test.com"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

cookbook_file "/etc/nginx/conf.d/test.conf" do
  only_if { node.chef_environment == "development" }
  source "nginx/test.conf-dev-ds.test.com"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

yum_package "test-dsui" do only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-dsui" do only_if { node.chef_environment == "staging" }
    version '124-4966.amzn1'   
    action :install
    allow_downgrade true
end

yum_package "test-dsui" do only_if { node.chef_environment == "production" }
    version '124-4966.amzn1'   
    action :install
    allow_downgrade true
end

file "/etc/cron.d/production-alerts" do
  action :delete
  not_if { node['machinename'] == "dsui1-prod.test.com" }
end

service "nginx" do
  action [ :enable, :start ]
end

service "redis" do
  action [ :enable, :start ]
end

service "dsui" do
  action [ :enable, :start ]
end

