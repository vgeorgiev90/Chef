template '/root/cluster-init.yml' do
  source "cluster-init.erb"
  variables(
    endpoint: data_bag_item('k8s', 'info')['endpoint'],   
    pod_subnet: data_bag_item('k8s', 'info')['podsubnet'], 
    api_sans: data_bag_item('k8s', 'info')['apisans']     
  )
end

token = data_bag_item('k8s', 'info')['token']

bash 'master_init' do
  code <<-EOH
    kubeadm init --config=/root/cluster-init.yml --token=#{token} --ignore-preflight-errors=all
    EOH
  not_if { ::File.exists?("/etc/kubernetes/manifests/kube-apiserver.yaml") }
end

bash 'print_join_command' do
  code <<-EOH
    kubeadm token create --print-join-command
    EOH
end

bash 'admin_config' do
  code <<-EOH
    mkdir ~/root/.kube
    cp /etc/kubernetes/admin.conf /root/.kube/config
    EOH
  not_if { ::File.exists?("/root/.kube/config") }
end

