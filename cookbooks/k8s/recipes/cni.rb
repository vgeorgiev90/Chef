bash 'pod_network' do
  environment 'RANGE' => data_bag_item('k8s', 'info')['podsubnet']
  code <<-EOH
    kubectl --kubeconfig=/root/.kube/config apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=$RANGE"
    EOH
  not_if "kubectl --kubeconfig=/root/.kube/config get pods --all-namespaces | grep weave 2>/dev/null 1>&2"
end
