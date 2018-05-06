#
# Cookbook Name:: test
# Recipe:: bamboo
#
# 
#
# 
#

cookbook_file "/etc/fstab" do
  source "bamboo/fstab"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

bash "yum_repo_dir" do
  cwd "/tmp"
  not_if do ::File.exists?('/yumrepo') end
  code <<-EOH
   mkdir -p /yumrepo
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

%w{httpd24 mod24_ssl nfs-utils liquibase siege ant pssh postfix rpm-build java-1.8.0-openjdk createrepo mysql56-server java-1.8.0-openjdk-devel docker MySQL-python27 python27-devel xorg-x11-server-Xvfb python35 python35-virtualenv libmemcached-devel zlib-devel libtool automake autoconf gcc-objc clang llvm-devel uuid-devel cmake autogen fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel libcouchbase-devel parallel python36 python36-devel golang test-cctools }.each do |pkg|
  package pkg do
  action :install
  end
end

bash "pip_modules" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  easy_install-2.7 pip
  pip2.7 install pysftp
  pip2.7 install boto
  pip2.7 install ipaddr
  pip2.7 install JayDeBeApi
  pip2.7 install psycopg2
  pip2.7 install sshtunnel
  EOH
end

cookbook_file "/usr/local/bin/protoc" do
  source "bamboo/protoc"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

cookbook_file "/etc/sysconfig/docker" do
  source "docker/docker"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

cookbook_file "/etc/sysconfig/docker-storage" do
  source "docker/docker-storage"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

cookbook_file "/bamboo/.s3cfg" do
  source "bamboo/s3cfg"
  owner "bamboo"
  group "bamboo"
  mode "0600"
  action :create
end

file "/bamboo/.ssh/authorized_keys" do
  owner "bamboo"
  group "bamboo"
  mode "00600"
  action :create
  content "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbR3/xpgYdtMg8hq0tRHMgXIn10mihSqWcGiID0hJwapG5rT2smcVd/qWm+OI1KNkP8zpfqmkp1l7NGB1qguYDtFCNeMNBJz46V6lbBwiCX8kAWdgywHFM+4wCDOqX/Xej6WVsOkIN1czGbApQ9lLDs0oL9k7t4MkmfVD96zvS4Yu7h0ERPHZyVw7t9VDnk1wV9HYD28KUPJ8npHz0Vey/uGr9dEj0vFipjjIVbKFJUG5Jotxr4HjikZl6cGFugTw2YuLxIJSb6Atd5kKb3HMTLDfS5o+92gODm6T42ro0pLri++XA94ESQkiClFBEtbU3pRgqzMWDFUbr22QayYC3 TestChef
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCAYVq7vE7N5ajzKTSkk1ddGfzK5u3l9CCY+UhIMvFcGeaVuY1llOVcdY+jRUpDyPJgtJdId+Kh+1WlrtkcxlWGrnpahm41aPI+T+BINV2dxik942TjZKfUkLWAarv4S+buWaOr1TeCHkghJO8O0KsYlKlIvzP+BGzJul1Aqe7sluhXmpSQGyEp2LBoqFrpbKZcaeQUwyiGkBNhug93O8Wnf3PKQYIpQKrK+zsn6F6x76CKb554nv0b3hy7X0p5IYBLhhj2EwZljxbpdKVYp48sz/Boa400jSHBOtgg/h4B6mgLroPJs3W6gohuKn4lAbI1wIXTIKRs2ONUceSSVLrv TestDefault"
end

file "/bamboo/.ssh/config" do
  manage_symlink_source true
  owner "bamboo"
  group "bamboo"
  mode "0644"
  action :create
  content "Host bitbucket.org
  IdentityFile ~/.ssh/id_rsa
  StrictHostKeyChecking no
Host *
  IdentityFile ~/.ssh/default.p
  StrictHostKeyChecking no
  "
end

directory "/bamboo/.aws/" do
  action :create
  owner "bamboo"
  group "bamboo"
  mode "0755"
end

file "/bamboo/.aws/config" do
  owner "bamboo"
  group "bamboo"
  mode "0755"
  action :create
  content "[default]
output = json
region = us-east-1"
end

file "/bamboo/.aws/credentials" do
  owner "bamboo"
  group "bamboo"
  mode "0755"
  action :create
  content "[default]
aws_access_key_id = AKIAJPVM2SYDGYLPMXWQ
aws_secret_access_key = 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

[terraform]
aws_access_key_id = AKIAJXT2QOWKNTVHTDIQ
aws_secret_access_key = 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
"
end

bash "bamboo-swap" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  if [ -f /bamboo/swapfile ]; then
    echo "/bamboo/swapfile already exists"
    echo 100 > /proc/sys/vm/swappiness
    swapon -a
  else
    dd if=/dev/zero of=/bamboo/swapfile count=60000 bs=1M
    chmod 600 /bamboo/swapfile
    mkswap -L swap /bamboo/swapfile
    swapon -a
  fi
  EOH
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

cookbook_file "/etc/httpd/conf.d/archiva.conf" do
  source "apache/archiva.conf"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/httpd/conf.d/test.conf" do
  source "apache/bamboo.conf"
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

cookbook_file "/etc/init.d/bamboo" do
  source "bamboo/bamboo"
  owner "root"
  group "root"
  mode "0755"
  action :create
  notifies :restart, "service[bamboo]", :delayed
end

cookbook_file "/bamboo/current/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties" do
  source "bamboo/bamboo-init.properties"
  owner "bamboo"
  group "bamboo"
  mode "0644"
  action :create
  notifies :restart, "service[bamboo]", :delayed
end

cookbook_file "/etc/my.cnf" do
  source "bamboo/my.cnf"
  owner "root"
  group "root"
  mode "0664"
  action :create
  notifies :restart, "service[mysqld]", :delayed
end

cookbook_file "/bamboo/bamboo-home/bamboo.cfg.xml" do
  source "bamboo/bamboo.cfg.xml"
  owner "bamboo"
  group "bamboo"
  mode "0664"
  action :create
  notifies :restart, "service[bamboo]", :delayed
end

cookbook_file "/bamboo/current/conf/server.xml" do
  source "bamboo/server.xml"
  owner "bamboo"
  group "bamboo"
  mode "0664"
  action :create
  notifies :restart, "service[bamboo]", :delayed
end

directory "/bamboo/.m2/" do
  action :create
end

cookbook_file "/bamboo/.m2/settings.xml" do
  source "bamboo/settings.xml"
  owner "bamboo"
  group "bamboo"
  mode "0664"
  action :create
end

cookbook_file "/bamboo/current/bin/setenv.sh" do
  source "bamboo/setenv.sh"
  owner "bamboo"
  group "bamboo"
  mode "0644"
  action :create
  notifies :restart, "service[bamboo]", :delayed
end

file "/etc/sudoers.d/bamboo" do
  owner "root"
  group "root"
  mode "0400"
  action :create
  content "bamboo  ALL=(ALL)       NOPASSWD: ALL "
end

bash "docker_system_params" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  sysctl -w net.ipv4.ip_forward=1
  EOH
end

bash "golang-dep" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  if [ ! -f /usr/bin/dep ]; then
    wget -O /usr/bin/dep https://github.com/golang/dep/releases/download/v0.3.2/dep-linux-amd64
    chmod +x /usr/bin/dep
  fi
  EOH
end

service "bamboo" do
  status_command "ps -ef | grep bamboo | grep -v tail | grep java"
  action [ :enable, :start ]
end

service "postfix" do
  action [ :enable, :start ]
end

service "archiva" do
  action [ :enable, :start ]
end

service "mysqld" do
  action [ :enable, :start ]
end

service "httpd" do
  action [ :enable, :start ]
end

service "docker" do
  action [ :enable, :start ]
end
