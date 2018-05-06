#
# Cookbook Name:: test
# Recipe:: chef-server
#
# 
#
# 
#

cookbook_file "/etc/yum.repos.d/chef-server.repo" do
  source "repos/chef-server.repo"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

%w{sensu-plugin sensu-cli}.each do |pkg|
  gem_package pkg do
  gem_binary '/opt/sensu/embedded/bin/gem'
  action :install
  end
end

%w{chef}.each do |pkg|
  gem_package pkg do
  gem_binary '/opt/sensu/embedded/bin/gem'
  version '12.6.0'
  action :install
  end
end

%w{libxml2-devel libffi-devel patch gcc python27-devel chef-server-core nfs-utils}.each do |pkg|
  package pkg do
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

file "/root/.aws/credentials" do
  owner "root"
  group "root"
  mode "0600"
  action :create
  content "[default]
aws_access_key_id = AKIAJPQD2KRAT2JARBTA
aws_secret_access_key = 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
[tags]
aws_access_key_id = AKIAJPQD2KRAT2JARBTA
aws_secret_access_key = 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
[chef]
aws_access_key_id = AKIAJ6RF5DPWKM5KWBXQ
aws_secret_access_key = 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
[bamboo]
aws_access_key_id = AKIAJPVM2SYDGYLPMXWQ
aws_secret_access_key = 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
"
end

#Makes Route53 DNS record updates automatically
cookbook_file "/opt/tools/dns_automater.sh" do
  source "chef/dns_automater.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

cookbook_file "/opt/tools/change.json" do
  source "chef/change.json"
  owner "root"
  group "root"
  mode "0600"
  action :create_if_missing
end

file "/etc/cron.d/dns_automater" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "*/7 * * * * root /usr/local/bin/single.py -c /opt/tools/dns_automater.sh > /opt/tools/dns_automater.log 2>&1
  "
end

#prewarming production clusters for the 12:00AM UTC changeover
cookbook_file "/opt/tools/prewarm_prod_clusters.sh" do
  source "chef/prewarm_prod_clusters.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/etc/cron.d/prewarm_prod_clusters_4amUTC" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "#55 11 * * * root . $HOME/.bash_profile; /usr/local/bin/single.py -c /opt/tools/prewarm_prod_clusters.sh >> /opt/tools/prewarm_prod_clusters.log 2>&1
  "
end

file "/etc/cron.d/prewarm_prod_clusters" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "#50 23 * * * root . $HOME/.bash_profile; /usr/local/bin/single.py -c /opt/tools/prewarm_prod_clusters.sh >> /opt/tools/prewarm_prod_clusters.log 2>&1
  "
end

#metamarkets backfill tool
directory '/opt/indexexchange' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file "/opt/indexexchange/index-exchange-mapper-1.0-jar-with-dependencies.jar" do
  source "chef/index-exchange-mapper-1.0-jar-with-dependencies.jar"
  owner "root"
  group "root"
  mode "0744"
  action :create
end

file "/etc/cron.d/indexexchangemapper" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "0 18 * * 1 root java -jar /opt/indexexchange/index-exchange-mapper-1.0-jar-with-dependencies.jar
  "
end

#metamarkets backfill tool
directory '/opt/metamarkets' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file "/opt/metamarkets/metamarkets-1.0.jar" do
  source "chef/metamarkets-1.0.jar"
  owner "root"
  group "root"
  mode "0744"
  action :create
end

file "/etc/cron.d/metamarkets_listgenerator_tool" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "0 0 * * * root java -cp /opt/metamarkets/metamarkets-1.0.jar com.test.metamarkets.MetamarketsListGenerator -e production
  "
end

#based on current spot prices, adjust autoscaling group subnets
cookbook_file "/opt/tools/autoscaling_subnets.py" do
  source "chef/autoscaling_subnets.py"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/etc/cron.d/autoscaling_subnets" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "*/10 * * * * root /opt/tools/autoscaling_subnets.py >> /opt/tools/autoscaling_subnets.log 2>&1
  "
end

#tag ebs snapshots created by Cloudwatch Rules
cookbook_file "/opt/tools/tag_aws_snapshots.sh" do
  source "chef/tag_aws_snapshots.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/etc/cron.d/tag_aws_snapshots" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "0 13 * * * root /opt/tools/tag_aws_snapshots.sh >> /opt/tools/tag_aws_snapshots.log 2>&1
  "
end

#Remove a node as a chef client and node
cookbook_file "/opt/tools/prune_chef.sh" do
  source "chef/prune_chef.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

#remove node from sensu
cookbook_file "/opt/tools/prune_sensu.sh" do
  source "chef/prune_sensu.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

#Have chef try to resurrect a node that is not communicating with the chef-server
cookbook_file "/opt/tools/resurrect_chef_node_fast.sh" do
  source "chef/resurrect_chef_node_fast.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

cookbook_file "/opt/tools/resurrect_chef_client_slow.sh" do
  source "chef/resurrect_chef_client_slow.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

cookbook_file "/opt/tools/resurrect_chef_node_slow.sh" do
  source "chef/resurrect_chef_node_slow.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

cookbook_file "/opt/tools/resurrect_chef_node.py" do
  source "chef/resurrect_chef_node.py"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

#Prune old ebs snapshots created by Cloudwatch Rules
cookbook_file "/opt/tools/prune_ebs_snapshots.sh" do
  source "chef/prune_ebs_snapshots.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/etc/cron.d/prune_ebs_snapshots" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "55 9 * * * root /usr/local/bin/single.py -c /opt/tools/prune_ebs_snapshots.sh >> /opt/tools/prune_ebs_snapshots.log 2>&1
  "
end

file "/etc/cron.d/resurrect_chef_node_fast" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "* * * * * root /usr/local/bin/single.py -c /opt/tools/resurrect_chef_node_fast.sh >> /opt/tools/resurrect_chef_node.log 2>&1
  "
end

file "/etc/cron.d/resurrect_chef_client_slow" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "* * * * * root /usr/local/bin/single.py -c /opt/tools/resurrect_chef_client_slow.sh >> /opt/tools/resurrect_chef_node.log 2>&1
  "
end

file "/etc/cron.d/resurrect_chef_node_slow" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "* * * * * root /usr/local/bin/single.py -c /opt/tools/resurrect_chef_node_slow.sh >> /opt/tools/resurrect_chef_node.log 2>&1
  "
end

cookbook_file "/etc/chef/knife.rb" do
  source "chef/knife.rb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :run, "execute[chef-server-ctl-reconfigure]", :delayed
end

execute "install-knife-ec2" do
  command "/opt/chef/embedded/bin/gem install knife-ec2"
  not_if "/opt/chef/embedded/bin/gem list knife-ec2 -i"
  action :run
end

cookbook_file "/etc/opscode/chef-server.rb" do
  source "chef/chef-server.rb"
  owner "root"
  group "root"
  mode "0640"
  action :create
  notifies :run, "execute[chef-server-ctl-reconfigure]", :delayed
end

cookbook_file "/var/opt/opscode/nginx/ca/chef.test.com.crt" do
  source "nginx/test.crt"
  owner "opscode"
  group "opscode"
  mode "0600"
  action :create
  notifies :run, "execute[chef-server-ctl-reconfigure]", :delayed
end

cookbook_file "/var/opt/opscode/nginx/ca/chef.test.com.key" do
  source "nginx/test.key"
  owner "opscode"
  group "opscode"
  mode "0600"
  action :create
  notifies :run, "execute[chef-server-ctl-reconfigure]", :delayed
end

bash "redis_system_params" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  sysctl -w vm.overcommit_memory=1
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
  sysctl -w net.core.somaxconn=65535
  echo 16000 > /proc/sys/net/ipv4/tcp_max_syn_backlog
  EOH
end

cookbook_file "/etc/chef/admin.pem" do
  source "chef/admin.pem"
  owner "root"
  group "root"
  mode "0444"
  action :create
end

execute 'chef-server-ctl-reconfigure' do
  command '/opt/opscode/bin/chef-server-ctl reconfigure'
  action :nothing
end
