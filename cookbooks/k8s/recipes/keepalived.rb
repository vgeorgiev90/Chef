package "keepalived"

template '/etc/keepalived/keepalived.conf' do
  source "keepalived.conf.erb"
  variables(
    endpoint: data_bag_item('k8s', 'info')['endpoint'],
    iface: data_bag_item('k8s', 'info')['interface']
  )
  not_if { ::File.exists?("/etc/keepalived/keepalived.conf") }
end

service "keepalived" do
  action [:enable, :start]
end
