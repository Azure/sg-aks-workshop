# Cluster Pre-provisioning

This section walks us through all of the decision that need to get made prior to even creating a cluster. Most organizations have existing virutal networks that they need to deploy into with networking rules that control ingress and egress traffic.

For the purposes of this workshop we will be using Azure Firewall to control egress traffic destined for the Internet or to simulate going on-prem. Network Security Groups (NSGs) and User-Defined Routes (UDRs) will be used to control North/South traffic in and out of the AKS cluster itself.

## Key Links

- [Egress Traffic Requirements for AKS](https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic)
- [Service Principal Requirements for AKS](https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal)
- [AKS Network Concepts](https://docs.microsoft.com/en-us/azure/aks/concepts-network)
- [Configure AKS with Azure CNI](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni)
- [Plan IP Addressing with Azure CNI](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni#plan-ip-addressing-for-your-cluster)
- [Using Multiple Node Pools](https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools)
- [Create nginx Ingress Controller](https://docs.microsoft.com/en-us/azure/aks/ingress-basic)
- [Create HTTPS Ingress Controller](https://docs.microsoft.com/en-us/azure/aks/ingress-tls)
