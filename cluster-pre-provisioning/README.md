# Cluster Pre-Provisioning

This section walks us through all the pre-requisite setup before actually provisioning the AKS cluster.

## Variable Setup

The variables are pretty straight forward, but please note there are a few words of caution on some of them.

```bash
PREFIX="wr"
RG="${PREFIX}-rg"
LOC="eastus"
NAME="${PREFIX}20191007"
ACR_NAME="${NAME}acr"
VNET_NAME="${PREFIX}vnet"
AKSSUBNET_NAME="${PREFIX}akssubnet"
SVCSUBNET_NAME="${PREFIX}svcsubnet"
ACISUBNET_NAME="${PREFIX}acisubnet"
# DO NOT CHANGE FWSUBNET_NAME - This is currently a requirement for Azure Firewall.
FWSUBNET_NAME="AzureFirewallSubnet"
APPGWSUBNET_NAME="${PREFIX}appgwsubnet"
WORKSPACENAME="${PREFIX}k8slogs"
IDENTITY_NAME="${PREFIX}identity"
FWNAME="${PREFIX}fw"
FWPUBLICIP_NAME="${PREFIX}fwpublicip"
FWIPCONFIG_NAME="${PREFIX}fwconfig"
FWROUTE_TABLE_NAME="${PREFIX}fwrt"
FWROUTE_NAME="${PREFIX}fwrn"
AGNAME="${PREFIX}ag"
AGPUBLICIP_NAME="${PREFIX}agpublicip"
```

## Create Resource Group

This section leverages the variables from above and creates the initial Resoruce Group where all of this will be deployed.

**For the SUBID (Azure Subscription ID), be sure to update your Subscription Name. If you do not know it, feel free to copy and paste your ID directly in. We will need the SUBID variable when working with Azure Resource IDs later in the walkthrough.**

```bash
# Get ARM Access Token and Subscription ID - This will be used for AuthN later.
ACCESS_TOKEN=$(az account get-access-token -o tsv --query 'accessToken')
# NOTE: Update Subscription Name
SUBID=$(az account show -s '<SUBSCRIPTION_NAME_GOES_HERE>' -o tsv --query 'id')
# Create Resource Group
az group create --name $RG --location $LOC
```

## AKS Creation VNET Pre-requisites

This section walks through the Virtual Network (VNET) setup pre-requisites before actually creating the AKS Cluster. One caveat on the subnet sizing below. All subnets were selected as /24 because it made things simple, but that is not a requirement. Please work with your networking teams to size the subnets appropriately for your organizations needs.

Here is a brief description of each of the dedicated subnets leveraging the variables populated from above:

* AKSSUBNET_NAME - This is where the AKS Cluster will get deployed.
* SVCSUBNET_NAME - This is the subnet that will be used for **Kubernetes Services** that are exposed via an Internal Load Balancer (ILB). By doing it this way we do not take away from the existing IP Address space in the AKS subnet that is used for Nodes and Pods.
* ACISUBNET_NAME - Although not part of this particular setup, this is for setting up Private Virtual Nodes and allowing Azure Container Instance (ACI) to be part of the same VNET. If you are interested in how to get this setup please reach out.
* FWSUBNET_NAME - This subnet is dedicated to Azure Firewall. **NOTE: The name cannot be changed at this time.**
* APPGWSUBNET_NAME - This subnet is dedicated to Azure Application Gateway v2 which will serve a dual purpose. It will be used as a Web Application Firewall (WAF) as well as an Ingress Controller. **NOTE: Azure App Gateway v2 is in preview at this time.**

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
    --name $ACISUBNET_NAME \
    --address-prefix 100.64.3.0/24
az network vnet subnet create \
    --resource-group $RG \
    --vnet-name $VNET_NAME \
    --name $FWSUBNET_NAME \
    --address-prefix 100.64.4.0/24
az network vnet subnet create \
    --resource-group $RG \
    --vnet-name $VNET_NAME \
    --name $APPGWSUBNET_NAME \
    --address-prefix 100.64.5.0/24
```

## AKS Creation Azure Firewall Pre-requisites

This section walks through setting up Azure Firewall inbound and outbound rules. The main purpose of the firewall here is to help organizations to setup ingress and egress traffic rules so the AKS Cluster is not just open to the world and cannot reach out to everythign on the Internet at the same time.

**NOTE: Completely locking down inbound and outboudn rules for AKS is not supported and will result in a broken cluster.**

**NOTE: There are no inbound rules required for AKS to run. The only time an inbound rule is required is to expose a workload/service.**

It starts with creating a Public IP address and then gets into creating the Azure Firewall along with all of the Network (think ports and protocols) and Application (think egress traffic based on FQDNs) rules. If you want to lock down destination IP Addresses on some of the firewall rules you will have to use the destination IP Addresses for the datacenter region you are deploying into due to how AKS communicates with the managed control plane. The list of IP Addresses per region in XML format can be found and downloaded by clicking [here](https://www.microsoft.com/en-us/download/details.aspx?id=56519).

**NOTE: Azure Firewall, like other Network Virtual Appliances (NVAs), can be costly so please take note of that when deploying and if you intend to leave everythign running.**

```bash
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
# TCP - * - * - 22
# TCP - * - * - 443
# If you want to lock down destination IP Addresses you will have to use the destination IP Addresses for the datacenter region you are deploying into, see note from above.
# For Example: East US DC Destination IP Addresses: 13.68.128.0/17,13.72.64.0/18,13.82.0.0/16,13.90.0.0/16,13.92.0.0/16,20.38.98.0/24,20.39.32.0/19,20.42.0.0/17,20.185.0.0/16,20.190.130.0/24,23.96.0.0/17,23.98.45.0/24,23.100.16.0/20,23.101.128.0/20,40.64.0.0/16,40.71.0.0/16,40.76.0.0/16,40.78.219.0/24,40.78.224.0/21,40.79.152.0/21,40.80.144.0/21,40.82.24.0/22,40.82.60.0/22,40.85.160.0/19,40.87.0.0/17,40.87.164.0/22,40.88.0.0/16,40.90.130.96/28,40.90.131.224/27,40.90.136.16/28,40.90.136.32/27,40.90.137.96/27,40.90.139.224/27,40.90.143.0/27,40.90.146.64/26,40.90.147.0/27,40.90.148.64/27,40.90.150.32/27,40.90.224.0/19,40.91.4.0/22,40.112.48.0/20,40.114.0.0/17,40.117.32.0/19,40.117.64.0/18,40.117.128.0/17,40.121.0.0/16,40.126.2.0/24,52.108.16.0/21,52.109.12.0/22,52.114.132.0/22,52.125.132.0/22,52.136.64.0/18,52.142.0.0/18,52.143.207.0/24,52.146.0.0/17,52.147.192.0/18,52.149.128.0/17,52.150.0.0/17,52.151.128.0/17,52.152.128.0/17,52.154.64.0/18,52.159.96.0/19,52.168.0.0/16,52.170.0.0/16,52.179.0.0/17,52.186.0.0/16,52.188.0.0/16,52.190.0.0/17,52.191.0.0/18,52.191.64.0/19,52.191.96.0/21,52.191.104.0/27,52.191.105.0/24,52.191.106.0/24,52.191.112.0/20,52.191.192.0/18,52.224.0.0/16,52.226.0.0/16,52.232.146.0/24,52.234.128.0/17,52.239.152.0/22,52.239.168.0/22,52.239.207.192/26,52.239.214.0/23,52.239.220.0/23,52.239.246.0/23,52.239.252.0/24,52.240.0.0/17,52.245.8.0/22,52.245.104.0/22,52.249.128.0/17,52.253.160.0/24,52.255.128.0/17,65.54.19.128/27,104.41.128.0/19,104.44.91.32/27,104.44.94.16/28,104.44.95.160/27,104.44.95.240/28,104.45.128.0/18,104.45.192.0/20,104.211.0.0/18,137.116.112.0/20,137.117.32.0/19,137.117.64.0/18,137.135.64.0/18,138.91.96.0/19,157.56.176.0/21,168.61.32.0/20,168.61.48.0/21,168.62.32.0/19,168.62.160.0/19,191.233.16.0/21,191.234.32.0/19,191.236.0.0/18,191.237.0.0/17,191.238.0.0/18
# Add the Azure Firewall extension to Azure CLI in case you do not already have it.
az extension add --name azure-firewall
# Create the Outbound Network Rule from Worker Nodes to Control Plane
az network firewall network-rule create -g $RG -f $FWNAME --collection-name 'aksfwnr' -n 'ssh' --protocols 'TCP' --source-addresses '*' --destination-addresses '*' --destination-ports 9000 443 --action allow --priority 100
az network firewall network-rule create -g $RG -f $FWNAME --collection-name 'aksfwnr2' -n 'dns' --protocols 'UDP' --source-addresses '*' --destination-addresses '*' --destination-ports 53 --action allow --priority 200
# Cosmos DB Only
az network firewall network-rule create -g $RG -f $FWNAME --collection-name 'aksfwnr4' -n 'cosmosdb' --protocols 'TCP' --source-addresses '*' --destination-addresses '*' --destination-ports 10255 --action allow --priority 400
# Add Application FW Rules
# *eastus.azmk8s.io,k8s.gcr.io,storage.googleapis.com,*auth.docker.io,*cloudflare.docker.io,*registry-1.docker.io,*.azurecr.io
# az network firewall application-rule create -g $RG -f $FWNAME --collection-name 'aksfwar' -n 'AKS' --source-addresses '*' --protocols 'http=80' 'https=443' --target-fqdns 'k8s.gcr.io' 'storage.googleapis.com' '*eastus.azmk8s.io' '*auth.docker.io' '*cloudflare.docker.io' '*cloudflare.docker.com' '*registry-1.docker.io' '*.ubuntu.com' '*azurecr.io' '*blob.core.windows.net' '*mcr.microsoft.com' '*cdn.mscr.io' --action allow --priority 100
az network firewall application-rule create -g $RG -f $FWNAME --collection-name 'aksfwar' -n 'AKS' --source-addresses '*' --protocols 'http=80' 'https=443' --target-fqdns '*.hcp.eastus.azmk8s.io' 'aksrepos.azurecr.io' '*blob.core.windows.net' 'mcr.microsoft.com' '*cdn.mscr.io' 'management.azure.com' 'login.microsoftonline.com' 'api.snapcraft.io' '*auth.docker.io' '*cloudflare.docker.io' '*cloudflare.docker.com' '*registry-1.docker.io' '*.ubuntu.com' 'packages.microsoft.com' 'dc.services.visualstudio.com' '*.opinsights.azure.com' '*.monitoring.azure.com' 'gov-prod-policy-data.trafficmanager.net' 'apt.dockerproject.org' 'nvidia.github.io' '*.azurecr.io' --action allow --priority 100
az network firewall application-rule create -g $RG -f $FWNAME --collection-name 'aksfwar2' -n 'AKS' --source-addresses '*' --protocols 'http=80' 'https=443' --target-fqdns 'k8s.gcr.io' 'storage.googleapis.com' --action allow --priority 200
# Associate AKS Subnet to FW
az network vnet subnet update -g $RG --vnet-name $VNET_NAME --name $AKSSUBNET_NAME --route-table $FWROUTE_TABLE_NAME
# OR if you know the Subnet ID and would prefer to do it that way.
#az network vnet subnet show -g $RG --vnet-name $VNET_NAME --name $AKSSUBNET_NAME --query id -o tsv
#SUBNETID=$(az network vnet subnet show -g $RG --vnet-name $VNET_NAME --name $AKSSUBNET_NAME --query id -o tsv)
#az network vnet subnet update -g $RG --route-table $FWROUTE_TABLE_NAME --ids $SUBNETID
```

## AKS Creation Service Principal Pre-requisites

This section walks through creatiing a Service Principal which will be used by AKS to create the cluster resources. It is this Service Principal that actually creates the underlying Azure Resources such as VMs, Storage, Load Balancers, etc. used by AKS. If you grant to few permissions it will not be able to create the AKS Cluster. If you grant too much then the Security Prinicple of Least Privilege is not being followed. If you have an existing Service Principal feel free to leverage that.

The key permission that is being granted to the Service Princiapl below is to the Virtual Network so it can create resources inside of the network.

```bash
# Create SP and Assign Permission to Virtual Network
az ad sp create-for-rbac -n "${PREFIX}sp" --skip-assignment
# Take the SP Creation output from above command and fill in Variables accordingly
APPID="<SERVICE_PRINCIPAL_APPID_GOES_HERE>"
PASSWORD="<SERVICEPRINCIPAL_PASSWORD_GOES_HERE>"
VNETID=$(az network vnet show -g $RG --name $VNET_NAME --query id -o tsv)
# Assign SP Permission to VNET
az role assignment create --assignee $APPID --scope $VNETID --role Contributor
```

## AKS Creation Azure Monitor for Containers Pre-requisites

All that is being done in this section is to setup a Log Analytics Workspace for AKS to help with monitoring, logging and troubleshooting down the road. If you create one ahead of time you get to control the name of the workspace and where it goes.

You also have the option of using an existing Log Analytics workspace or you can have AKS create one automatically for you. For the purposes of this walkthrough we are going to focus on creating one ahead of time so we have control over its lifecycle independent of the AKS Cluster.

```bash
# Create Log Analytics Workspace
az group deployment create -n $WORKSPACENAME -g $RG \
  --template-file azuredeploy-loganalytics.json \
  --parameters workspaceName=$WORKSPACENAME \
  --parameters location=$LOC \
  --parameters sku="Standalone"
# Set Workspace ID
WORKSPACEIDURL=$(az group deployment list -g $RG -o tsv --query '[].properties.outputResources[0].id')
```
