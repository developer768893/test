#
# Cookbook Name:: test
# Recipe:: couchbase-budget
#
# 
#
# 
#

package "xfsprogs" do
  action :install
end

cookbook_file "/etc/fstab" do
  only_if { node.chef_environment == "production" }
  source "couchbase/fstab"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

bash "couchbase_opt_couchbase" do
  cwd "/tmp"
  not_if do ::File.exists?('/opt/couchbase/') end
  code <<-EOH
    mkfs.xfs -L couchbase /dev/xvdb
    mkdir -p /opt/couchbase/
    mount -a
  EOH
end

%w{couchbase-server-community iftop}.each do |pkg|
  package pkg do
    only_if { node.chef_environment == "production" }
    action :install
  end
end

#single.py singleton script
cookbook_file "/usr/local/bin/single.py" do
  source "chef/single.py"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

cookbook_file "/etc/init.d/disable-thp" do
  source "couchbase/disable-thp"
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0755"
  action :create
  notifies :restart, "service[disable-thp]", :immediately
  notifies :restart, "service[couchbase-server]", :delayed
end

#backup couchbase script
cookbook_file "/opt/tools/backup_couchbase.sh" do
  only_if { node['machinename'] == "couchbase1-prod.test.com" || node['machinename'] == "couchbase1-prod-west.test.com" }
  source "couchbase/backup_couchbase.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/etc/cron.d/backup_couchbase" do
  only_if { node['machinename'] == "couchbase1-prod.test.com" || node['machinename'] == "couchbase1-prod-west.test.com" }
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "0 6 * * * root /usr/local/bin/single.py -c /opt/tools/backup_couchbase.sh >> /opt/tools/backup_couchbase.log 2>&1
  "
end

bash "couchbase_sensu_usermod" do
  cwd "/tmp"
  code <<-EOH
    usermod -G couchbase sensu
  EOH
end

%w{rest-client}.each do |pkg|
  gem_package pkg do
  gem_binary '/opt/sensu/embedded/bin/gem'
  action :install
  end
end

bash "pip_modules" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  easy_install-2.7 pip
  pip2.7 install request
  pip2.7 install pydns
  EOH
end

service "disable-thp" do
  action [ :enable, :start ]
end

service "couchbase-server" do
  action [ :enable, :start ]
end

