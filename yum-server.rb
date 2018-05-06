#
# Cookbook Name:: test
# Recipe:: yum repo servers
#
# 
#
# 
#

template "/etc/fstab" do
  source "yum-server/production-fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  only_if { node.chef_environment == "production" }
  variables(
    :placement_availability_zone => node['ec2']['placement_availability_zone'],
  )
end

bash "yum_repo_dir" do
  cwd "/tmp"
  not_if do ::File.exists?('/var/www/yumrepo') end
  code <<-EOH
   mkdir -p /var/www/yumrepo
   mount -a
  EOH
end

#single.py singleton script
cookbook_file "/usr/local/bin/single.py" do
  source "chef/single.py"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

%w{httpd24 mod24_ssl rpm-build createrepo nfs-utils }.each do |pkg|
  package pkg do
  action :install
  end
end

cookbook_file "/root/.s3cfg" do
  source "bamboo/s3cfg"
  owner "root"
  group "root"
  mode "0600"
  action :create
end

cookbook_file "/etc/pki/tls/certs/dhparams.pem" do
  source "apache/dhparams.pem"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

file "/etc/httpd/conf.d/ssl.conf" do
  action :delete
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/pki/tls/certs/test.crt" do
  source "apache/test.crt"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/pki/tls/private/test.key" do
  source "apache/test.key"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/httpd/conf/httpd.conf" do
  source "apache/yumrepo.conf"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

service "httpd" do
  action [ :enable, :start ]
end

