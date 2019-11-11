# Post Provisioning

This section walks us through steps that need to get performed after the cluster has been provisioned. These steps can easily be automated as part of a pipeline, but are explicitly pulled out here for visibility.

## Test Post Configuration

This is a quick test to make sure that Pods can be created and the Ingress Controller default backend is setup correctly.

```bash
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
# Exit out of Pod
exit
```

## Setup ACR Permissions

This section sets up the connection between AKS and Azure Container Registry (ACR).

```bash
# Setup ACR Permissions
CLIENT_ID=$(az aks show --resource-group $RG --name $NAME --query "servicePrincipalProfile.clientId" --output tsv)
# Get the ACR registry resource id
ACR_ID=$(az acr show --name $ACR_NAME --resource-group "MC_${RG}_${PREFIX}-aks_${LOC}" --query "id" --output tsv)
# Create role assignment
echo $CLIENT_ID
echo $ACR_ID
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID
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

## OPA and Gatekeeper Policy Setup

In this section we will setup the AKS specific policies we want to enforce. To recap, for our given scenario that means:

* Registry Whitelisting

```bash
# Allowed Repos Constraint Template
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

## Next Steps

[Cost Governance](/cost-governance/README.md)

## Key Links

* ???
