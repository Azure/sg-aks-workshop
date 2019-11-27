# Post Provisioning

This section walks us through steps that need to get performed after the cluster has been provisioned. These steps can easily be automated as part of a pipeline, but are explicitly pulled out here for visibility.

## Test Post Configuration

This is a quick test to make sure that Pods can be created and the Ingress Controller default backend is setup correctly.

* First we need to grab AKS cluster credentials so we can access the api-server endpoint and run some commands.
* Second we will do a quick check via get nodes.
* Lastly, we will spin up a Pod, exec into it, and test our F/W rules.

```bash
# List out AKS Cluster(s) in a Table
az aks list -o table
# Get Cluster Admin Credentials
az aks get-credentials -g $RG -n $PREFIX-aks --admin
# Check Nodes
kubectl get nodes
# Test via a Pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: centos
spec:
  containers:
  - name: centos
    image: centos
    ports:
    - containerPort: 80
    command:
    - sleep
    - "3600"
EOF
# Check if Pod is Running
kubectl get po -o wide
# Once Pod is Running exec into the Pod
kubectl exec -it centos -- /bin/bash
# Inside of the Pod test the Ingress Controller Endpoint
curl 100.64.2.4
# This should be blocked by F/W
curl www.superman.com
# Exit out of Pod
exit
```

## Setup ACR Permissions

This section sets up the connection between AKS and Azure Container Registry (ACR).

```bash
# List Azure Container Registries (ACR) in a Table
az acr list -o table
# Setup ACR Permissions
CLIENT_ID=$(az aks show --resource-group $RG --name ${PREFIX}-aks --query "servicePrincipalProfile.clientId" --output tsv)
# Get the ACR registry resource id
ACR_ID=$(az acr show --name ${PREFIX}acr --resource-group $RG --query "id" --output tsv)
# Look at Configuration Settings
echo $CLIENT_ID
echo $ACR_ID
# Create role assignment
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID
# View Service Principal Permissions
az role assignment list --assignee $CLIENT_ID --all -o table
```

## Setup Cluster Metrics

This section enables capture of metrics for the AKS cluster to be able to create items like notifications/alerts when key criteria is exceeded.

```bash
# Add Metrics
az aks show -g $RG -n $PREFIX-aks --query 'id' -o tsv
az role assignment create --assignee $APPID --scope $(az aks show -g $RG -n $PREFIX-aks --query 'id' -o tsv) --role "Monitoring Metrics Publisher"
# Add Log Analytics Reader
az role assignment create --assignee $APPID --scope $(az aks show -g $RG -n $PREFIX-aks --query 'id' -o tsv) --role "Log Analytics Reader"
# Check Permissions associated with the Service Principal
az role assignment list --assignee $APPID --all -o table
```

## Find Public IP of AKS api-server Endpoint

This section shows how to find the Public IP (PIP) of the AKS cluster to be able to add it to firewalls for IP whitelisting purposes.

```bash
# Get API-Server IP
kubectl get endpoints --namespace default kubernetes
```

## Find Public IP of Azure Application Gateway used for WAF

This setion shows how to find the Public IP Address of the Azure Application Gateway which is used as a WAF and the Ingress point for workloads into the Cluster.

```bash
# Retrieve the Public IP Address of the App Gateway.
az network public-ip show -g $RG -n $AGPUBLICIP_NAME --query "ipAddress" -o tsv
```

## OPA and Gatekeeper Policy Setup

In this section we will setup the AKS specific policies we want to enforce. To recap, for our given scenario that means:

* Registry Whitelisting

```bash
# Create Allowed Repos Constraint Template
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/agilebank/templates/k8sallowedrepos_template.yaml

# Install Constraint Based on Template
cat <<EOF | kubectl apply -f -
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sAllowedRepos
metadata:
  name: prod-repo-is-kevingbb
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    namespaces:
      - "production"
  parameters:
    repos:
      - "kevingbb"
EOF

# Look at Created Resources
# Check Resources
kubectl get crd | grep gatekeeper
kubectl get constrainttemplate,k8sallowedrepos,config -n gatekeeper-system

# Test out Allowed Registry Policy Against production Namespace
kubectl run --generator=run-pod/v1 -it --rm centosprod --image=centos -n production

# Try again with Image from kevingbb
kubectl run --generator=run-pod/v1 bobblehead --image=kevingbb/khbobble -n production

# What did you notice with the last command? The main image got pulled, but the sidecar images did not :).

# Try again in default Namespace
kubectl run --generator=run-pod/v1 -it --rm centosdefault --image=centos -n default
# Test out Connectivity
curl 100.64.2.4
# Exit out of Pod
exit
```

## Setup Flow Logs and Traffic Analytics

This section walks us through setting up flow logs on the Network Security Groups (NSGs) as well as Traffic Analytics to gain additional insights.

To enable the NSG flow logs and Traffic Analytics, please follow this online Tutorial:

[Flow Logs and Traffic Analytics Prerequisites](https://docs.microsoft.com/en-us/azure/network-watcher/traffic-analytics#prerequisites)

**Here is a list of some of the key items that can be monitored for with Traffic Analytics:**

* View Ports and VMs Receiving Traffic from the Internet
* Find Traffic Hot Spots
* Visualize Traffic Distribution by Geography
* Visualize Traffic Distribution by Virtual Networks
* Visualize Trends in NSG Rule Hits

For more details on usage scenarios click [here](https://docs.microsoft.com/en-us/azure/network-watcher/traffic-analytics#usage-scenarios).

## Next Steps

[Cost Governance](/cost-governance/README.md)

## Key Links

* [Patch Management with Kured](https://docs.microsoft.com/en-us/azure/aks/node-updates-kured)
* [Azure Traffic Analytics](https://docs.microsoft.com/en-us/azure/network-watcher/traffic-analytics)
