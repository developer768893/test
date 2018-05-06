#
# Cookbook Name:: test
# Recipe:: ssui
#
# 
#
# 
#

%w{ruby-devel mysql-devel sqlite-devel redis libxml2-devel libxslt-devel libcurl-devel compat-libffi5 test-cctools nfs-utils}.each do |pkg|
  package pkg do
    action :install
  end
end

cookbook_file "/etc/fstab" do
  source "ssui/fstab"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

bash "ssui-swap" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  if [ -f /root/swapfile ]; then
    echo "/root/swapfile already exists"
    echo 100 > /proc/sys/vm/swappiness
    swapon -a
    mount -a
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

group 'ssui' do
  gid '700'
  append true
end

user 'ssui' do
  comment 'ssui system user for supply side ui ruby process'
  home '/opt/ssui'
  system true
  uid '700'
  gid 'ssui'
  shell '/bin/bash'
end

directory '/sdk-bundler/' do
  owner 'ssui'
  group 'ssui'
  mode '0755'
  action :create
  recursive true
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
  source "nginx/test.conf-platform.test.com"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

cookbook_file "/etc/nginx/conf.d/test.conf" do
  only_if { node.chef_environment == "staging" }
  source "nginx/test.conf-staging-platform.test.com"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

cookbook_file "/etc/nginx/conf.d/test.conf" do
  only_if { node.chef_environment == "development" }
  source "nginx/test.conf-dev-platform.test.com"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

yum_package "test-ssui" do only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-ssui" do only_if { node.chef_environment == "staging" }
    version '307-5013.amzn1'   
    action :install
    allow_downgrade true
end

yum_package "test-ssui" do only_if { node.chef_environment == "production" }
    version '307-5013.amzn1'   
    action :install
    allow_downgrade true
end

#Library files for the SDK bundler service
yum_package "test-android-sdk-bundler" do 
    action :upgrade
    allow_downgrade true
end

yum_package "test-ios-sdk-bundler" do 
    action :upgrade
    allow_downgrade true
end

link '/opt/ssui/sdk-bundler/android/tmp' do
  to '/sdk-bundler/android/tmp'
end

link '/opt/ssui/sdk-bundler/ios/tmp' do
  to '/sdk-bundler/ios/tmp'
end

cookbook_file "/usr/local/rvm/gems/ruby-2.0.0-p353/gems/authlogic-3.6.0/lib/authlogic/regex.rb" do
  source "ruby/regex.rb"
  owner "root"
  group "rvm"
  mode "0644"
  action :create
  notifies :restart, "service[ssui]", :delayed
end

service "nginx" do
  action [ :enable, :start ]
end

service "redis" do
  action [ :enable, :start ]
end

service "ssui" do
  action [ :enable, :start ]
end

