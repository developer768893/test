#
# Cookbook Name:: test
# Recipe:: aws-tags
#
# 
#
# 
#

bash "awscli" do
  user "root"
  cwd "/tmp"
  not_if do ::File.exists?('/usr/bin/aws') end
  code <<-EOH
  easy_install pip
  pip install awscli
  EOH
end

directory "/root/.aws/" do
  action :create
  owner "root"
  group "root"
  mode "0600"
end

template "/root/.aws/config" do
  only_if { node['ec2']['placement_availability_zone'] == "us-west-2a" ||  node['ec2']['placement_availability_zone'] == "us-west-2b"  ||  node['ec2']['placement_availability_zone' ] == "us-west-2c" }
  source "aws-tags/config.erb"
  owner "root"
  group "root"
  mode "0600"
  action :create
  variables(
    :region => "us-west-2"
  )
end

template "/root/.aws/config" do
  only_if { node['ec2']['placement_availability_zone'] == "us-east-1a" ||  node['ec2']['placement_availability_zone'] == "us-east-1b"  ||  node['ec2']['placement_availability_zone' ] == "us-east-1c" ||  node['ec2']['placement_availability_zone'] == "us-east-1d" ||  node['ec2']['placement_availability_zone'] == "us-east-1e" || node['ec2']['placement_availability_zone'] == "us-east-1f"}
  source "aws-tags/config.erb"
  owner "root"
  group "root"
  mode "0600"
  action :create
  variables(
    :region => "us-east-1"
  )
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
[test-system-user]
aws_access_key_id = AKIAJQ5BM7ZVLQZOMT7Q
aws_secret_access_key = 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
"
end

directory "/opt/tools" do
  action :create
  owner "root"
  group "root"
  mode "0777"
end

template "/opt/tools/aws-tags.sh" do
  source "aws-tags/aws-tags.erb"
  owner "root"
  group "root"
  mode "0755"
  action :create
  variables(
    :machinename => node['machinename'],
    :role => node['roles'],
  )
end

file "/etc/cron.d/aws-tags" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "2,22,42 * * * * root /opt/tools/aws-tags.sh
  "
end
