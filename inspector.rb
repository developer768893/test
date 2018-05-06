#
# Cookbook Name:: test
# Recipe:: amazon inspector
#
# 
#
# 
#

bash "aws_inspector" do
  user "root"
  cwd "/tmp"
  not_if do ::File.exists?('/opt/aws/awsagent/bin/awsagent') end
  code <<-EOH
  curl -O https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install
  bash install 
  EOH
end

service "awsagent" do
  action [ :enable, :start ]
end

