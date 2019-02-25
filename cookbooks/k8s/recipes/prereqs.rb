bash 'disable_swap' do
  code <<-EOH
    swapoff -a
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    EOH
end

package %w(docker-ce kubelet kubeadm kubectl)

bash 'hold packages' do
  code <<-EOH
    apt-mark hold docker-ce kubelet kubeadm kubectl
    EOH
end

cookbook_file '/etc/sysctl.d/k8s.conf' do
  source "default/k8s.conf"
end

service 'docker' do
  action [:enable, :start]
end

