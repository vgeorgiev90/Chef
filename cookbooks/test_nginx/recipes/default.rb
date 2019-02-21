#
# Cookbook:: test_nginx
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

package "nginx"

service "nginx" do
  action [:enable, :start]
end

file "/usr/share/nginx/html/index.html" do
  content "Chef test nginx"
  owner "root"
  group "root"
  mode "0644"
  action :create
  not_if { ::File.exists?("/usr/share/nginx/html/index.html") }
end
