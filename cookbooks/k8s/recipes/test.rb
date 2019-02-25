template '/tmp/cluster-init.yml' do
  source "templates/default/cluster-init.erb"
  variables(
    endpoint: data_bag_item('k8s', 'info')['endpoint'],
    podsubnet: data_bag_item('k8s', 'info')['podsubnet'],
    apisans: data_bag_item('k8s', 'info')['apisans']
  )
end

