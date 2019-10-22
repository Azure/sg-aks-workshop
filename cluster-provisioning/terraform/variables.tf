variable "prefix" {
  description = "A prefix used for all resources"
}

variable "location" {
  default     = "Central US"
  description = "The Azure Region in which all resources will be provisioned in"
}

variable "kubernetes_version" {
  default     = "1.14.6"
  description = "The version of Kubernetes you want deployed to your cluster. Please reference the command: az aks get-versions --location eastus -o table"
}

variable "client_id" {
  description = "The Client ID for the Service Principal to use for this Managed Kubernetes Cluster"
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal to use for this Managed Kubernetes Cluster"
}

variable "public_ssh_key_path" {
  description = "The Path at which your Public SSH Key is located. Defaults to ~/.ssh/id_rsa.pub"
  default     = "~/.ssh/id_rsa.pub"
}

variable "address_space" {
  default = "172.20.0.0/16"
  description = "The IP address CIDR block to be assigned to the entride Azure Virtual Network. If connecting to another peer or to you On-Premises netwokr this CIDR block MUST NOT overlap with existing BGP learned routes"
}

variable "subnet" {
  default = "172.20.0.0/20"
  description = "The IP address CIDR block to be assigned to the subnet that AKS nodes and Pods will ge their IP addresses from. This is a subset CIDR of the vnetIPCIDR"
}

variable "admin_username" {
  default = "azureuser"
  description = "The username assigned to the admin user on the OS of the AKS nodes if SSH access is ever needed"
}
variable "agent_count" {
  default = "4"
  description = "The starting number of Nodes in the AKS cluster"
}

variable "vm_size" {
  default = "Standard_E2s_v3"
  description = "The Node type and size based on Azure VM SKUs Reference: az vm list-sizes --location eastus -o table"
}
variable "os_disk_size_gb" {
  default = 30
  description = "The Agent Operating System disk size in GB. Changing this forces a new resource to be created."
  
}


variable "max_pods" {
  default = 30
  description = "The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
}

variable "pool_type" {
  default = "VirtualMachineScaleSets"
  description = "Uses VMSS as the backing scale set"
  
}

variable "network_plugin" {
  default = "azure"
  description = "Can either be azure or kubenet. azure will use Azure subnet IPs for Pod IPs. Kubenet you need to use the pod-cidr variable below"
}

variable "network_policy" {
  default = "calico"
  description = "Uses calico by default for network policy"
}

variable "azure_subnet_id" {
  default = "/subscriptions/xxxxxx-xxxxxx-xxxx/resourceGroups/tf-sg/providers/Microsoft.Network/virtualNetworks/tfsg/subnets/cluster"
  description = "Subnet ID for virtual network where aks will be deployed"
}
variable "pod_cidr" {
  default = "172.23.0.0/16"
  description = "Only use if kubenet is assigned as the network plugin. It will be divided into a /24 for each node and will be the space assigned for POD IPs on each node. A Rout Table will be created by Azure, but it must be assigned to the AKS subnet upon completion of deployment to complete install"
}

variable "service_cidr" {
  default = "172.21.0.0/16"
  description = "The IP address CIDR block to be assigned to the service created inside the Kubernetes cluster. If connecting to another peer or to you On-Premises network this CIDR block MUST NOT overlap with existing BGP learned routes"
}

variable "dns_service_ip" {
  default = "172.21.0.10"
  description = "The IP address that will be assigned to the CoreDNS or KubeDNS service inside of Kubernetes for Service Discovery. Must start at the .10 or higher of the svc-cidr range"
}

variable "docker_bridge_cidr" {
  default = "172.22.0.1/16"
  description = "The IP address CIDR block to be assigned to the Docker container bridge on each node. If connecting to another peer or to you On-Premises network this CIDR block SHOULD NOT overlap with existing BGP learned routes"
}
variable "github_organization" {
  description = "Name of the Github Organisation"
}

variable "github_repository_name" {
  description = "Name of the Github repository for Flux"
}

variable "github_token" {
  description = "github token to authenticate"
  
}
