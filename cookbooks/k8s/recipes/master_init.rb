template '/root/cluster-init.yml' do
  source "cluster-init.erb"
  variables(
    endpoint: data_bag_item('k8s', 'info')['endpoint'],   
    podsubnet: data_bag_item('k8s', 'info')['podsubnet'], 
    apisans: data_bag_item('k8s', 'info')['apisans'],
    token: data_bag_item('k8s', 'info')['token']
  )
end

bash 'master_init' do
  code <<-EOH
    kubeadm init --config=/root/cluster-init.yml --ignore-preflight-errors=all
    EOH
  not_if { ::File.exists?("/etc/kubernetes/manifests/kube-apiserver.yaml") }
end

bash 'admin_config' do
  code <<-EOH
    mkdir /root/.kube
    cp /etc/kubernetes/admin.conf /root/.kube/config
    EOH
  not_if { ::File.exists?("/root/.kube/config") }
end

