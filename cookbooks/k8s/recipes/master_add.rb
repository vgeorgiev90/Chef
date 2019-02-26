
bash 'get_certs' do
  environment 'IP' => data_bag_item('k8s', 'info')['primarymaster']
  code <<-EOH
    mkdir -p /etc/kubernetes/pki /etc/kubernetes/pki/etcd /root/.kube
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /root/.ssh/k8s root@$IP:/etc/kubernetes/pki/ca.* /etc/kubernetes/pki/.
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /root/.ssh/k8s root@$IP:/etc/kubernetes/pki/sa.* /etc/kubernetes/pki/.
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /root/.ssh/k8s root@$IP:/etc/kubernetes/pki/front-proxy-ca.* /etc/kubernetes/pki/.
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /root/.ssh/k8s root@$IP:/etc/kubernetes/pki/etcd/ca.* /etc/kubernetes/pki/etcd/.
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /root/.ssh/k8s root@$IP:/etc/kubernetes/admin.conf /root/.kube/config
    EOH
  not_if { ::File.exists?("/etc/kubernetes/manifests/kube-apiserver.yaml") }
end

bash 'join' do
  environment ({'TOKEN' => data_bag_item('k8s', 'info')['token'], 'ENDPOINT' => data_bag_item('k8s', 'info')['endpoint']})
  code <<-EOH
    kubeadm join $ENDPOINT --token $TOKEN --discovery-token-unsafe-skip-ca-verification --ignore-preflight-errors=all --experimental-control-plane
    EOH
  not_if { ::File.exists?("/etc/kubernetes/manifests/kube-apiserver.yaml") }
end
