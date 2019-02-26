bash 'install_helm' do
  code <<-EOH
    wget https://storage.googleapis.com/kubernetes-helm/helm-v2.13.0-rc.2-linux-amd64.tar.gz -P /root
    tar -xzf /root/helm-v2.13.0-rc.2-linux-amd64.tar.gz -C /root
    cp /root/linux-amd64/helm /usr/local/bin && chmod +x /usr/local/bin/helm
    rm /root/helm* -rf && rm /root/linux-* -rf
    EOH
  not_if "ls /usr/local/bin/helm 2>/dev/null 1>&2"
end


bash 'tiller_init' do
  code <<-EOH
    kubectl --kubeconfig=/root/.kube/config create serviceaccount tiller --namespace kube-system
    kubectl --kubeconfig=/root/.kube/config create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account=tiller --kubeconfig=/root/.kube/config
    EOH
  not_if "kubectl --kubeconfig=/root/.kube/config get pods --all-namespaces | grep tiller 2>/dev/null 1>&2"
end
