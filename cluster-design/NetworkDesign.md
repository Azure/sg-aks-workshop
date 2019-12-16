# Secure Network Design for AKS cluster

## Network Topology
The key design decisions for network topology are the following:
- Preventing undesired acces to the AKS API Server through the network
- Adding an NSG on the worker nodes subnet to prevent SSH access from other internal networks
- Adding a dedicated subnet for internal ingress load balancers


## Lockdown of API Server
There are two options for preventing undesired access to the AKS API Server:
- API Server Whitelisting: https://docs.microsoft.com/en-us/azure/aks/api-server-authorized-ip-ranges
- API Server using Private Link: https://docs.microsoft.com/en-gb/azure/aks/private-clusters

## Lockdown of Ingress and Egress Traffic
The following options for locking down ingress and egress traffic are available:
- Forcing the egress traffic through an firewall appliance like Azure Firewall on a network level
- Deploying an ingress controller with an integrated Web Application firewall like AppGateway on a network level
- Using a service mesh for locking down egress on a container level
- Using cillium to lock down egress traffic on a container level
