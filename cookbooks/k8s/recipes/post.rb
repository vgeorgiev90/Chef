bash 'deploy_weave_scope' do
  code <<-EOH
    kubectl --kubeconfig=/root/.kube/config apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
    EOH
  not_if "kubectl --kubeconfig=/root/.kube/config get namespaces | grep weave 2>/dev/null 1>&2"
end

bash 'deploy_ingress' do
  code <<-EOH
    kubectl --kubeconfig=/root/.kube/config apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
    kubectl --kubeconfig=/root/.kube/config apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml
    EOH
  not_if "kubectl --kubeconfig=/root/.kube/config get namespaces | grep ingress-nginx 2>/dev/null 1>&2"
end
