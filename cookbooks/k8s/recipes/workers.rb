bash 'join' do
  environment ({'TOKEN' => data_bag_item('k8s', 'info')['token'], 'ENDPOINT' => data_bag_item('k8s', 'info')['endpoint']})
  code <<-EOH
    kubeadm join $ENDPOINT:6443 --token $TOKEN --discovery-token-unsafe-skip-ca-verification --ignore-preflight-errors=all
    EOH
  not_if { ::File.exists?("/var/lib/kubelet/config.yaml") }
end

