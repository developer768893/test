#
# Cookbook Name:: test
# Recipe:: bh
#
# 
#
# 
#

file "/root/.ssh/config" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "Host *
  IdentityFile ~/.ssh/default.p
  StrictHostKeyChecking no
  "
end

cookbook_file "/usr/bin/dns-r53.sh" do
  only_if { node['machinename'] == "bh1-prod.test.com" }
  source "bh/dns-r53.sh"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/etc/cron.d/dns-r53" do
  only_if { node['machinename'] == "bh1-prod.test.com" }
  content "30 12 2 * * root /usr/local/bin/single.py -c /usr/bin/dns-r53.sh > /tmp/dns.txt"
  mode "0644"
  owner "root"
  group "root"
end





