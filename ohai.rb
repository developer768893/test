#
# Cookbook Name:: test
# Recipe:: ohai
#
# 
#
# 
#

bash "ohai_ec2_metadata_hints" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  if [ ! -f /etc/chef/ohai/hints/ec2.json ]; then
    mkdir -p /etc/chef/ohai/hints/
    touch /etc/chef/ohai/hints/ec2.json
    ohai > /dev/null &2>1
  fi
  EOH
end

