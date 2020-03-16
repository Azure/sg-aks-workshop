# Cluster Pre-Provisioning

This section walks us through all the pre-requisite setup before actually provisioning the Azure Kubernetes Service (AKS) cluster. Most organizations have existing virtual networks that they need to deploy into, with networking rules that control ingress and egress traffic.

For the purpose of this workshop we will be using Azure Firewall to control egress traffic destined for the Internet or to simulate going on-prem. Network Security Groups (NSGs) and User-Defined Routes (UDRs) will be used to control North/South traffic in and out of the AKS cluster itself.

## Variable Setup

The variables are pretty straight forward, but please note there are a few words of caution on some of them.

```bash
PREFIX="contosofin" # NOTE: Please make sure PREFIX is unique in your tenant, you must not have any hypens '-' in the value.
RG="${PREFIX}-rg"
LOC="eastus"
NAME="${PREFIX}"
ACR_NAME="${NAME}acr"
VNET_NAME="${PREFIX}vnet"
AKSSUBNET_NAME="${PREFIX}akssubnet"
SVCSUBNET_NAME="contosofinsvcsubnet"
APPGWSUBNET_NAME="${PREFIX}appgwsubnet"
# DO NOT CHANGE FWSUBNET_NAME - This is currently a requirement for Azure Firewall.
FWSUBNET_NAME="AzureFirewallSubnet"
FWNAME="${PREFIX}fw"
FWPUBLICIP_NAME="${PREFIX}fwpublicip"
FWIPCONFIG_NAME="${PREFIX}fwconfig"
FWROUTE_TABLE_NAME="${PREFIX}fwrt"
FWROUTE_NAME="${PREFIX}fwrn"
AGNAME="${PREFIX}ag"
AGPUBLICIP_NAME="${PREFIX}agpublicip"
```

## Create Resource Group

This section leverages the variables from above and creates the initial Resource Group where all of this will be deployed.

**For the SUBID (Azure Subscription ID), be sure to update your Subscription Name. If you do not know it, feel free to copy and paste your ID directly in. We will need the SUBID variable when working with Azure Resource IDs later in the walkthrough.**

```bash
# Get ARM Access Token and Subscription ID - This will be used for AuthN later.
ACCESS_TOKEN=$(az account get-access-token -o tsv --query 'accessToken')
# NOTE: Update Subscription Name
# Use list command to get list of Subscription IDs & Names
az account list -o table
# Set Default Azure Subscription to be Used via Subscription ID
az account set -s <SUBSCRIPTION_ID_GOES_HERE>
# Put Subsc
SUBID=$(az account show -s '<SUBSCRIPTION_NAME_GOES_HERE>' -o tsv --query 'id')
# Create Resource Group
az group create --name $RG --location $LOC
```

## AKS Creation VNET Pre-requisites

This section walks through the Virtual Network (VNET) setup pre-requisites before actually creating the AKS Cluster. One caveat on the subnet sizing below. All subnets were selected as /24 because it made things simple, but that is not a requirement. Please work with your networking teams to size the subnets appropriately for your organization's needs.

Here is a brief description of each of the dedicated subnets leveraging the variables populated from above:

* AKSSUBNET_NAME - This is where the AKS Cluster will get deployed.
* SVCSUBNET_NAME - This is the subnet that will be used for **Kubernetes Services** that are exposed via an Internal Load Balancer (ILB). By doing it this way we do not take away from the existing IP Address space in the AKS subnet that is used for Nodes and Pods.
* APPGWSUBNET_NAME - This subnet is dedicated to Azure Application Gateway v2 which will serve as a Web Application Firewall (WAF).
* FWSUBNET_NAME - This subnet is dedicated to Azure Firewall. **NOTE: The name cannot be changed at this time.**

```bash
# Create Virtual Network & Subnets for AKS, k8s Services, ACI, Firewall and WAF
az network vnet create \
    --resource-group $RG \
    --name $VNET_NAME \
    --address-prefixes 100.64.0.0/16 \
    --subnet-name $AKSSUBNET_NAME \
    --subnet-prefix 100.64.1.0/24
az network vnet subnet create \
    --resource-group $RG \
    --vnet-name $VNET_NAME \
    --name $SVCSUBNET_NAME \
    --address-prefix 100.64.2.0/24
az network vnet subnet create \
    --resource-group $RG \
    --vnet-name $VNET_NAME \
    --name $APPGWSUBNET_NAME \
    --address-prefix 100.64.3.0/26
az network vnet subnet create \
    --resource-group $RG \
    --vnet-name $VNET_NAME \
    --name $FWSUBNET_NAME \
    --address-prefix 100.64.4.0/26
```

## AKS Creation Azure Firewall Pre-requisites

This section walks through setting up Azure Firewall inbound and outbound rules. The main purpose of the firewall here is to help organizations to set up ingress and egress traffic rules so the AKS Cluster is not just open to the world and cannot reach out to everything on the Internet at the same time.

**NOTE: Completely locking down inbound and outbound rules for AKS is not supported and will result in a broken cluster.**

**NOTE: There are no inbound rules required for AKS to run. The only time an inbound rule is required is to expose a workload/service.**

It starts with creating a Public IP address and then gets into creating the Azure Firewall along with all of the Network (think ports and protocols) and Application (think egress traffic based on FQDNs) rules. If you want to lock down destination IP Addresses on some of the firewall rules you will have to use the destination IP Addresses for the datacenter region you are deploying into due to how AKS communicates with the managed control plane. The list of IP Addresses per region in XML format can be found and downloaded by clicking [here](https://www.microsoft.com/en-us/download/details.aspx?id=56519).

**NOTE: Azure Firewall, like other Network Virtual Appliances (NVAs), can be costly so please take note of that when deploying and if you intend to leave everything running.**

```bash
# Add the Azure Firewall extension to Azure CLI in case you do not already have it.
az extension add --name azure-firewall
# Create Public IP for Azure Firewall
az network public-ip create -g $RG -n $FWPUBLICIP_NAME -l $LOC --sku "Standard"
# Create Azure Firewall
az network firewall create -g $RG -n $FWNAME -l $LOC
# Configure Azure Firewall IP Config - This command will take several mins so be patient.
az network firewall ip-config create -g $RG -f $FWNAME -n $FWIPCONFIG_NAME --public-ip-address $FWPUBLICIP_NAME --vnet-name $VNET_NAME
# Capture Azure Firewall IP Address for Later Use
FWPUBLIC_IP=$(az network public-ip show -g $RG -n $FWPUBLICIP_NAME --query "ipAddress" -o tsv)
FWPRIVATE_IP=$(az network firewall show -g $RG -n $FWNAME --query "ipConfigurations[0].privateIpAddress" -o tsv)
# Validate Azure Firewall IP Address Values - This is more for awareness so you can help connect the networking dots
echo $FWPUBLIC_IP
echo $FWPRIVATE_IP
# Create UDR & Routing Table for Azure Firewall
az network route-table create -g $RG --name $FWROUTE_TABLE_NAME
az network route-table route create -g $RG --name $FWROUTE_NAME --route-table-name $FWROUTE_TABLE_NAME --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address $FWPRIVATE_IP --subscription $SUBID

# Add Network FW Rules
# TCP - * - * - 9000
# TCP - * - * - 443
# If you want to lock down destination IP Addresses you will have to use the destination IP Addresses for the datacenter region you are deploying into, see note from above.
# For Example: East US DC Destination IP Addresses: 13.68.128.0/17,13.72.64.0/18,13.82.0.0/16,13.90.0.0/16,13.92.0.0/16,20.38.98.0/24,20.39.32.0/19,20.42.0.0/17,20.185.0.0/16,20.190.130.0/24,23.96.0.0/17,23.98.45.0/24,23.100.16.0/20,23.101.128.0/20,40.64.0.0/16,40.71.0.0/16,40.76.0.0/16,40.78.219.0/24,40.78.224.0/21,40.79.152.0/21,40.80.144.0/21,40.82.24.0/22,40.82.60.0/22,40.85.160.0/19,40.87.0.0/17,40.87.164.0/22,40.88.0.0/16,40.90.130.96/28,40.90.131.224/27,40.90.136.16/28,40.90.136.32/27,40.90.137.96/27,40.90.139.224/27,40.90.143.0/27,40.90.146.64/26,40.90.147.0/27,40.90.148.64/27,40.90.150.32/27,40.90.224.0/19,40.91.4.0/22,40.112.48.0/20,40.114.0.0/17,40.117.32.0/19,40.117.64.0/18,40.117.128.0/17,40.121.0.0/16,40.126.2.0/24,52.108.16.0/21,52.109.12.0/22,52.114.132.0/22,52.125.132.0/22,52.136.64.0/18,52.142.0.0/18,52.143.207.0/24,52.146.0.0/17,52.147.192.0/18,52.149.128.0/17,52.150.0.0/17,52.151.128.0/17,52.152.128.0/17,52.154.64.0/18,52.159.96.0/19,52.168.0.0/16,52.170.0.0/16,52.179.0.0/17,52.186.0.0/16,52.188.0.0/16,52.190.0.0/17,52.191.0.0/18,52.191.64.0/19,52.191.96.0/21,52.191.104.0/27,52.191.105.0/24,52.191.106.0/24,52.191.112.0/20,52.191.192.0/18,52.224.0.0/16,52.226.0.0/16,52.232.146.0/24,52.234.128.0/17,52.239.152.0/22,52.239.168.0/22,52.239.207.192/26,52.239.214.0/23,52.239.220.0/23,52.239.246.0/23,52.239.252.0/24,52.240.0.0/17,52.245.8.0/22,52.245.104.0/22,52.249.128.0/17,52.253.160.0/24,52.255.128.0/17,65.54.19.128/27,104.41.128.0/19,104.44.91.32/27,104.44.94.16/28,104.44.95.160/27,104.44.95.240/28,104.45.128.0/18,104.45.192.0/20,104.211.0.0/18,137.116.112.0/20,137.117.32.0/19,137.117.64.0/18,137.135.64.0/18,138.91.96.0/19,157.56.176.0/21,168.61.32.0/20,168.61.48.0/21,168.62.32.0/19,168.62.160.0/19,191.233.16.0/21,191.234.32.0/19,191.236.0.0/18,191.237.0.0/17,191.238.0.0/18
# Create the Outbound Network Rule from Worker Nodes to Control Plane
az network firewall network-rule create -g $RG -f $FWNAME --collection-name 'aksfwnr1' -n 'ssh' --protocols 'TCP' --source-addresses '*' --destination-addresses '*' --destination-ports 9000 443 --action allow --priority 100
az network firewall network-rule create -g $RG -f $FWNAME --collection-name 'aksfwnr2' -n 'dns' --protocols 'UDP' --source-addresses '*' --destination-addresses '*' --destination-ports 53 --action allow --priority 200
az network firewall network-rule create -g $RG -f $FWNAME --collection-name 'aksfwnr3' -n 'gitssh' --protocols 'TCP' --source-addresses '*' --destination-addresses '*' --destination-ports 22 --action allow --priority 300
az network firewall network-rule create -g $RG -f $FWNAME --collection-name 'aksfwnr4' -n 'fileshare' --protocols 'TCP' --source-addresses '*' --destination-addresses '*' --destination-ports 445 --action allow --priority 400

# Add Application FW Rules
# Required AKS FW Rules
# https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic#required-ports-and-addresses-for-aks-clusters

# Single F/W Rule
az network firewall application-rule create -g $RG -f $FWNAME \
 --collection-name 'AKS' \
 --action allow \
 --priority 100 \
 -n 'required' \
 --source-addresses '*' \
 --protocols 'http=80' 'https=443' \
 --target-fqdns 'aksrepos.azurecr.io' '*blob.core.windows.net' 'mcr.microsoft.com' '*cdn.mscr.io' 'management.azure.com' 'login.microsoftonline.com' 'ntp.ubuntu.com' 'packages.microsoft.com' 'acs-mirror.azureedge.net' '*.hcp.eastus.azmk8s.io' '*.tun.eastus.azmk8s.io' 'security.ubuntu.com' '*archive.ubuntu.com' 'changelogs.ubuntu.com' 'nvidia.github.io' 'us.download.nvidia.com' 'apt.dockerproject.org' 'dc.services.visualstudio.com' '*.ods.opinsights.azure.com' '*.oms.opinsights.azure.com'  '*.microsoftonline.com' '*.monitoring.azure.com' '*auth.docker.io' '*cloudflare.docker.io' '*cloudflare.docker.com' '*registry-1.docker.io' 'apt.dockerproject.org' 'gcr.io' 'storage.googleapis.com' '*.quay.io' 'quay.io' '*.cloudfront.net' '*.azurecr.io' '*.gk.azmk8s.io' 'raw.githubusercontent.com' 'gov-prod-policy-data.trafficmanager.net' 'api.snapcraft.io' '*.github.com' '*.vault.azure.net' '*.azds.io'

# Associate AKS Subnet to FW
az network vnet subnet update -g $RG --vnet-name $VNET_NAME --name $AKSSUBNET_NAME --route-table $FWROUTE_TABLE_NAME
# OR if you know the Subnet ID and would prefer to do it that way.
#az network vnet subnet show -g $RG --vnet-name $VNET_NAME --name $AKSSUBNET_NAME --query id -o tsv
#SUBNETID=$(az network vnet subnet show -g $RG --vnet-name $VNET_NAME --name $AKSSUBNET_NAME --query id -o tsv)
#az network vnet subnet update -g $RG --route-table $FWROUTE_TABLE_NAME --ids $SUBNETID
```

## AKS Creation Service Principal Pre-requisites

This section walks through creating a Service Principal which will be used by AKS to create the cluster resources. It is this Service Principal that actually creates the underlying Azure resources such as VMs, Storage, Load Balancers, etc. used by AKS. If you grant to few permissions it will not be able to create the AKS Cluster. If you grant too much then the Security Principle of Least Privilege is not being followed. If you have an existing Service Principal feel free to leverage that.

The key permission that is being granted to the Service Principal below is to the Virtual Network so it can create resources inside of the network.

```bash
# Create SP and Assign Permission to Virtual Network
az ad sp create-for-rbac -n "${PREFIX}sp" --skip-assignment
# ********************************************************************************
# Take the SP Creation output from above command and fill in Variables accordingly
# ********************************************************************************
APPID="<SERVICE_PRINCIPAL_APPID_GOES_HERE>"
PASSWORD="<SERVICEPRINCIPAL_PASSWORD_GOES_HERE>"
VNETID=$(az network vnet show -g $RG --name $VNET_NAME --query id -o tsv)
# Assign SP Permission to VNET
az role assignment create --assignee $APPID --scope $VNETID --role Contributor
# View Role Assignment
az role assignment list --assignee $APPID --all -o table
```

## Create Public IP Address for Azure Application Gateway

This section walks through creating a Public IP address for use with a Web Application Firewall (WAF). For the purposes of this workshop, we will be using Azure Application Gateway as the WAF and it will be created as part of the AKS provisioning process.

```bash
# Create Public IP for use with WAF (Azure Application Gateway)
az network public-ip create -g $RG -n $AGPUBLICIP_NAME -l $LOC --sku "Standard"
```

## Next Steps

[Cluster Provisioning](/cluster-provisioning/README.md)

## Key Links

* [Egress Traffic Requirements for AKS](https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic)
* [Service Principal Requirements for AKS](https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal)
* [AKS Network Concepts](https://docs.microsoft.com/en-us/azure/aks/concepts-network)
* [Configure AKS with Azure CNI](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni)
* [Plan IP Addressing with Azure CNI](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni#plan-ip-addressing-for-your-cluster)
* [Using Multiple Node Pools](https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools)
* [Create nginx Ingress Controller](https://docs.microsoft.com/en-us/azure/aks/ingress-basic)
* [Create HTTPS Ingress Controller](https://docs.microsoft.com/en-us/azure/aks/ingress-tls)
* [Integrate ILB with Firewall](https://docs.microsoft.com/en-us/azure/firewall/integrate-lb)
