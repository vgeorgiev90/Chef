databag for k8s cookbook

token    - Token for kubelet bootstrap format must be: [a-z0-9]{6}\.[a-z0-9]{16} - e.g. abcdef.0123456789abcdef
endpoint - Kubernetes API endpoint (if keepalived/loadbalancer this will be the floating IP)
interface - Interface for keepalived
podsubnet - Subnet for the CNI
apisans   - Additional IP addresses and hostnames for all control plane nodes and LB
primarymaster - IP address of the primary master (the one which will be bootstrap first)
keys - List of public keys(at least one which is part of the key pair specified in files dir) that needs to be distributed to the nodes (the private key that also will be present can be changed in k8s/files/default with name id_rsa)
