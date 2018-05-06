#
# Cookbook Name:: test
# Recipe:: sensu-server
#
# 
#
# 
#

cookbook_file "/etc/cron.daily/tmpwatch" do
  source "cron/tmpwatch"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

cookbook_file "/etc/yum.repos.d/epel.repo" do
  source "repos/epel.repo"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

yum_package "epel-release" do
    action :install
end

%w{libxml2-devel patch python-setuptools java-1.8.0-openjdk gcc unzip rabbitmq-server redis uchiwa gcc ruby-devel libxml2 libxml2-devel libxslt libxslt-devel libcurl-devel patch rpm-build}.each do |pkg|
  package pkg do
    action :install
  end
end

yum_package "test-sensu-config" do
    action :upgrade
    allow_downgrade true
    notifies :restart, "service[sensu-client]", :delayed
    notifies :restart, "service[sensu-server]", :delayed
    notifies :restart, "service[sensu-api]", :delayed
    notifies :restart, "service[rabbitmq-server]", :delayed
    notifies :restart, "service[nginx]", :delayed
end

bash "awscli" do
  user "root"
  cwd "/tmp"
  not_if do ::File.exists?('/usr/bin/aws') end
  code <<-EOH
  easy_install pip
  pip install awscli
  EOH
end

cookbook_file "/etc/sensu/uchiwa.json" do
  source "sensu/uchiwa.json"
  owner "sensu"
  group "sensu"
  mode "0644"
  action :create
end

cookbook_file "/etc/nginx/conf.d/test.conf" do
  source "nginx/test.conf-sensu.test.com"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[nginx]", :delayed
end

%w{sensu-plugins-http digest require em-http-request activesupport amq-protocol amqp async_sinatra aws-sdk-v1 bigdecimal chef childprocess daemons domain_name em-redis-unified em-worker eventmachine ffi http-cookie i18n io-console ipaddress json mail mime-types mini_portile minitest mixlib-cli mixlib-config mixlib-log mixlib-shellout multi_json net netrc nokogiri ohai psych rack rack-protection rake rdoc rest-client sensu sensu-check-helpers sensu-cli sensu-em sensu-extension sensu-extensions sensu-logger sensu-plugin sensu-settings sensu-spawn sensu-transport sinatra systemu test-unit thin thread_safe tilt timeout timeout-extensions tzinfo unf unf_ext uuidtools yajl-ruby net json whois http aws-sdk aws-sdk-v1 net-ping inspec sensu-plugins-aws aws-sdk}.each do |pkg|
  gem_package pkg do
  gem_binary '/opt/sensu/embedded/bin/gem'
  action :install
  end
end

cookbook_file "/etc/logstash/conf.d/sensu" do
  source "logstash/sensu"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[logstash]", :delayed
end

service "logstash" do
  action [ :start ]
end

service "redis" do
  action [ :enable, :start ]
end

service "sensu-client" do
  action [ :enable, :start ]
end

service "rabbitmq-server" do
  action [ :enable, :start ]
end

service "sensu-api" do
  action [ :enable, :start ]
end

service "nginx" do
  action [ :enable, :start ]
end

service "sensu-server" do
  action [ :enable, :start ]
end

service "uchiwa" do
  only_if { node['machinename'] == "sensu1-prod.test.com"}
  action [ :enable, :start ]
end

