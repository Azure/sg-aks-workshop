# Deploy App

This section walks us through deploying the sample application.

## Web and Worker Image Classification Services

This is a simple SignalR application with two parts. The web front-end is a .NET Core MVC application that serves up a single page that receives messages from the SignalR Hub and displays the results. The back-end worker application retrieves data from Azure Files and processes the image using a TensorFlow model and sends the results to the SignalR Hub on the front-end.

The end result on the front-end should display what type of fruit image was processed by the Tensorflow model. And because it is SignalR there is no browser refreshing needed.

## Container Development

Before we get into setting up the application, let's have a quick discussion on what container development looks like for the customer. No development environment is the same as it is not a one size fits all when it comes to doing development. Computers, OS, languages, and IDEs to name a few things are hardly ever the same configuration/setup. And if you throw the developer themselves in that mix it is definitely not the same.

As a result, different users work in different ways. The following are just a few of the **inner devops loop** tools that we are seeing in this eco-system, feel free to try any of them out and let us know what you think. And if it hits the mark.

### Tilt

Tilt is a CLI tool used for local continuous development of microservice applications. Tilt watches your files for edits with tilt up, and then automatically builds, pushes, and deploys any changes to bring your environment up-to-date in real-time. Tilt provides visibility into your microservices with a command-line UI. In addition to monitoring deployment success, the UI also shows logs and other helpful information about your deployments.

Click [here](https://github.com/windmilleng/tilt) for more details and to try it out.

### Telepresence

Telepresence is an open-source tool that lets you run a single service locally, while connecting that service to a remote Kubernetes cluster. This lets developers working on multi-service applications to:

1. Do fast local development of a single service, even if that service depends on other services in your cluster. Make a change to your service, save, and you can immediately see the new service in action.
2. Use any tool installed locally to test/debug/edit your service. For example, you can use a debugger or IDE!
3. Make your local development machine operate as if it's part of your Kubernetes cluster. If you've got an application on your machine that you want to run against a service in the cluster -- it's easy to do.

Click [here](https://www.telepresence.io/reference/install) for more details and to try it out.

### Azure Dev Spaces

Azure Dev Spaces is a rapid, iterative Kubernetes development experience for teams in Azure Kubernetes Service (AKS) clusters. You can collaborate with your team in a shared AKS cluster. Azure Dev Spaces also allows you to test all the components of your application in AKS without replicating or mocking up dependencies. You can iteratively run and debug containers directly in AKS with minimal development machine setup.

Click [here](https://docs.microsoft.com/en-us/azure/dev-spaces/quickstart-team-development) for more details and to try it out.

## Push Images to Azure Container Registry (ACR)

This section grabs the container images from Docker Hub and then pushes them to the Azure Container Registry that was created.

```bash
# Pull Images from Docker Hub to Local Workstation
docker pull kevingbb/imageclassifierweb:v1
docker pull kevingbb/imageclassifierworker:v1

# Authenticate to ACR
az acr list -o table
az acr login -g $RG -n ${PREFIX}acr

# Push Images to ACR
docker tag kevingbb/imageclassifierweb:v1 ${PREFIX}acr.azurecr.io/imageclassifierweb:v1
docker tag kevingbb/imageclassifierworker:v1 ${PREFIX}acr.azurecr.io/imageclassifierworker:v1
docker push ${PREFIX}acr.azurecr.io/imageclassifierweb:v1
docker push ${PREFIX}acr.azurecr.io/imageclassifierworker:v1
```

## Image Vulnerability Scanning and Management

One of the most important things an organization can do when adopting Containers is good image management hygiene. This means that images should be scanned prior to being deployed to a cluster. **The old saying goes, "Garbage In, Garbage Out", meaning if you deploy unsecure images to the container registry then the cluster will be deploying unsecure and potentially dangerous images.**

* It is critical to scan images for vulnerabilities in your environment. We recommending using a Enterprise-grade tool such as [Aqua Security](https://www.aquasec.com/products/aqua-container-security-platform) or [Twistlock](https://www.twistlock.com/why-twistlock) or [SysDig Secure](https://sysdig.com/products/secure/).

* These tools should be integrated into the CI/CD pipeline, Container Registry, and container runtimes to provide end-to-end protection. Review full guidance here: [https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-container-image-management](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-container-image-management)

* For the purposes of this workshop we will be using Anchore for some quick testing. [https://anchore.com/opensource](https://anchore.com/opensource)

* Install **Anchore** with Helm.

```bash
# Check Helm Client Version (Assumes >= v3.0.0)
helm version
# Install Anchore
kubectl create namespace anchore
helm install anchore stable/anchore-engine --namespace anchore
# Check Status
helm status anchore --namespace anchore
helm list --namespace anchore
# Ensure all Pods are running
kubectl get po -n anchore
```

> Note: It may take a few minutes for all of the pods to start and for the CVE data to be loaded into the database.

* Exec into the analyzer pod to access the CLI

```bash
# Once all of the Pods are Running and the CVE Data is Loaded
kubectl get pod -l app=anchore-demo-anchore-engine -l component=analyzer -n anchore
# Sample Output
NAME                                                   READY   STATUS    RESTARTS   AGE
anchore-demo-anchore-engine-analyzer-974d7479d-7nkgp   1/1     Running   0          2h
```

```bash
# Before Exec'ing into Pod, Grab these Variables (Needed Later)
echo APPID=$APPID
echo PASSWORD=$PASSWORD
echo ACR_NAME=${PREFIX}acr.azurecr.io
# Now Exec into Pod
kubectl exec -it $(kubectl get po -l app=anchore-anchore-engine -l component=analyzer -n anchore -o jsonpath='{.items[0].metadata.name}') -n anchore bash
```

* Set env variables to configure CLI (while exec'd into pod)

```bash
ANCHORE_CLI_USER=admin
ANCHORE_CLI_PASS=foobar
ANCHORE_CLI_URL=http://anchore-anchore-engine-api.anchore.svc.cluster.local:8228/v1/
```

* Check status (while exec'd into pod)

```bash
# Execute Status Command
anchore-cli system status
# Sample Output
Service catalog (anchore-demo-anchore-engine-catalog-5fd7c96898-xq5nj, http://anchore-demo-anchore-engine-catalog:8082): up
Service analyzer (anchore-demo-anchore-engine-analyzer-974d7479d-7nkgp, http://anchore-demo-anchore-engine-analyzer:8084): up
Service apiext (anchore-demo-anchore-engine-api-7866dc7fcc-nk2l7, http://anchore-demo-anchore-engine-api:8228): up
Service policy_engine (anchore-demo-anchore-engine-policy-578f59f48d-7bk9v, http://anchore-demo-anchore-engine-policy:8087): up
Service simplequeue (anchore-demo-anchore-engine-simplequeue-5b5b89977c-nzg8r, http://anchore-demo-anchore-engine-simplequeue:8083): up

Engine DB Version: 0.0.12
Engine Code Version: 0.6.0
```

* Connect Anchore to ACR (you will need to set these variables since they are not in the container profile)

```bash
# Grab Echoed Variables from Above
APPID=...
PASSWORD=...
ACR_NAME=...
# Add ACR to Anchore Registry List
anchore-cli registry add --registry-type docker_v2 $ACR_NAME $APPID $PASSWORD
# Sample Output
Registry: youracr.azurecr.io
User: 59343209-9d9e-464d-8508-068a3d331fb9
Type: docker_v2
Verify TLS: True
Created: 2019-11-11T17:56:05Z
Updated: 2019-11-11T17:56:05Z
```

* Add our images and check for issues

```bash
# Add Images to Scan List
anchore-cli image add $ACR_NAME/imageclassifierweb:v1
anchore-cli image add $ACR_NAME/imageclassifierworker:v1
```

* Wait for Images to be "Analyzed" (Last Column Status). This will take a few mins so be patient.

```bash
# Wait for all images to be "analyzed"
anchore-cli image list

# View results (there are none in these images thankfully)
anchore-cli image vuln $ACR_NAME/imageclassifierweb:v1 all
anchore-cli image vuln $ACR_NAME/imageclassifierworker:v1 all

# Show OS Packages
anchore-cli image content $ACR_NAME/imageclassifierweb:v1 os
anchore-cli image content $ACR_NAME/imageclassifierworker:v1 os
```

* Add the repositories to the watch list so that each time a new image is added it will be automatically scanned.

```bash
# Add Repositories to Watch List
anchore-cli repo add $ACR_NAME/imageclassifierweb --lookuptag v1
anchore-cli repo add $ACR_NAME/imageclassifierworker --lookuptag v1
anchore-cli repo list

# Check for Active Subscriptions
anchore-cli subscription list

# Activate Vulnerability Subscription
#anchore-cli subscription activate SUBSCRIPTION_TYPE SUBSCRIPTION_KEY
anchore-cli subscription activate vuln_update $ACR_NAME/imageclassifierweb:v1
anchore-cli subscription activate vuln_update $ACR_NAME/imageclassifierworker:v1

# Check for Activation
anchore-cli subscription list
```

* Take a look at the policies that Anchore puts into place by default and see if the images pass the policy.

```bash
# Working with Policies
# Get Policies
anchore-cli policy list
anchore-cli policy get 2c53a13c-1765-11e8-82ef-23527761d060 --detail

# Evaluate against Policy (Pass or Fail)
anchore-cli evaluate check $ACR_NAME/imageclassifierweb:v1
anchore-cli evaluate check $ACR_NAME/imageclassifierworker:v1

# Sample Output
Image Digest: sha256:6340b28aac68232d28e5ff1c0a425176408ce85fdb408fba1f0cecba87aec062
Full Tag: contosofinacr.azurecr.io/imageclassifierworker:v1
Status: pass
Last Eval: 2019-11-27T22:19:27Z
Policy ID: 2c53a13c-1765-11e8-82ef-23527761d060

# Exit out of Container
exit
```

* Explore Anchore API via UI

```bash
# Test out Anchore API to get a Feel for Automation (Requires New Command Line)
kubectl port-forward svc/anchore-anchore-engine-api -n anchore 8228:8228
open "http://localhost:8228/v1/ui/"
```

## Deploy Application

There is an app.yaml file in this directory so either change into this directory or copy the contents of the file to a filename of your choice. Once you have completed the previous step, apply the manifest file and you will get the web and worker services deployed into the **dev** namespace.

```bash
# Navigate to deploy-app Directory
cd ../../deploy-app
# Deploy the Application Resources
kubectl apply -f app.yaml
# Display the Application Resources
kubectl get deploy,rs,po,svc,ingress -n dev
```

### File Share Setup

You will notice that some of the pods are not starting up, this is because an Azure File Share is missing and the secret to access Azure Files. 

Create an Azure Storage account in your resource group. 
```bash
# declare the share referenced above.
SHARE_NAME=fruit

# az storage creation for app.
STORAGE_ACCOUNT=${PREFIX}storage 

# create storage account
az storage account create -g $RG -n $STORAGE_ACCOUNT

# create an azure files share to contain fruit images
az storage share create --name $SHARE_NAME --account-name $STORAGE_ACCOUNT

# get the key
STORAGE_KEY=$(az storage account keys list -g $RG -n $STORAGE_ACCOUNT --query "[0].value")

# create a secret
kubectl create secret generic fruit-secret \
  --from-literal=azurestorageaccountname=$STORAGE_ACCOUNT \
  --from-literal=azurestorageaccountkey=$STORAGE_KEY \
  -n dev
```

From the Azure portal upload all the contents of the ./deploy-app/fruit/ directory.
![Upload fruit directory](/deploy-app/img/upload_images.png)

```bash
# Check to see Worker Pod is now Running
kubectl get deploy,rs,po,svc,ingress,secrets -n dev
```

The end result will look something like this.

![Dev Namespace Output](/deploy-app/img/app_dev_namespace.png)

## Test out Application Endpoint

This section will show you how to test and see if the application endpoint is up and running.

```bash
# Exec into Pod and Test Endpoint
kubectl exec -it centos -- /bin/bash
# Inside of the Pod test the Ingress Controller Endpoint (Tensorflow in the page Title)
curl -sSk 100.64.2.4 | grep -i 'TensorFlow'
# You should have seen the contents of an HTML file dumped out. If not, you will need to troubleshoot.
# Exit out of Pod
exit
```

* Now Test with the WAF Ingress Point

```bash
az network public-ip show -g $RG -n $AGPUBLICIP_NAME --query "ipAddress" -o tsv
```

## Adding in Secrets Mgmt

This section will take a look at the same application, but add in some more capabilities and storing the sensitive information to turn on those capabilities securely.

Here is a small list of things that will be added:

* Health Checks via Liveness and Readiness Probes.
* Application Instrumentation with Instrumentation Key securely stored in Azure Key Vault (AKV).
* Add a Title to the App with that Title stored in AKV for illustration purposes only.

When dealing with secrets we typically need to store some type of bootstrapping credential(s) or connection string to be able to access the secure store.

**What if there was another way?**

There is, it is called AAD Pod Identity, or Managed Pod Identity. We are going to assign an Azure Active Directory Identity to a running Pod which will automatically grab an Azure AD backed Token which we can then use to securely access Azure Key Vault.

**Pretty Cool!**

### Create Azure Key Vault (AKV) & Secrets

* In this section we will create the secrets backing store which will be Azure Key Vault and populate it with the secrets information.

```bash
# Create Azure Key Vault Instance
az keyvault create -g $RG -n ${PREFIX}akv -l $LOC --enabled-for-template-deployment true
# Retrieve Application Insights Instrumentation Key
az resource show \
    --resource-group $RG \
    --resource-type "Microsoft.Insights/components" \
    --name ${PREFIX}-ai \
    --query "properties.InstrumentationKey" -o tsv
INSTRUMENTATION_KEY=$(az resource show -g $RG --resource-type "Microsoft.Insights/components" --name ${PREFIX}-ai --query "properties.InstrumentationKey" -o tsv)
# Populate AKV Secrets
az keyvault secret set --vault-name ${PREFIX}akv --name "AppSecret" --value "MySecret"
az keyvault secret show --name "AppSecret" --vault-name ${PREFIX}akv
az keyvault secret set --vault-name ${PREFIX}akv --name "AppInsightsInstrumentationKey" --value $INSTRUMENTATION_KEY
az keyvault secret show --name "AppInsightsInstrumentationKey" --vault-name ${PREFIX}akv
```

### Create Azure AD Identity

* Now that we have AKV and the secrets setup, we need to create the Azure AD Identity and permissions to AKV.

```bash
# Create Azure AD Identity
AAD_IDENTITY="contosofinidentity"
az identity create -g $RG -n $AAD_IDENTITY -o json
# Sample Output
{
  "clientId": "CLIENTID",
  "clientSecretUrl": "https://control-eastus.identity.azure.net/subscriptions/SUBSCRIPTION_ID/resourcegroups/contosofin-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/contosofinidentity/credentials?tid=TID&aid=AID",
  "id": "/subscriptions/SUBSCRIPTION_ID/resourcegroups/contosofin-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/contosofinidentity",
  "location": "eastus",
  "name": "contosofinidentity",
  "principalId": "PRINCIPALID",
  "resourceGroup": "contosofin-rg",
  "tags": {},
  "tenantId": "TENANT_ID",
  "type": "Microsoft.ManagedIdentity/userAssignedIdentities"
}
# Grab PrincipalID & ClientID & TenantID from Above
AAD_IDENTITY_PRINCIPALID=$(az identity show -g $RG -n $AAD_IDENTITY --query "principalId" -o tsv)
AAD_IDENTITY_CLIENTID=$(az identity show -g $RG -n $AAD_IDENTITY --query "clientId" -o tsv)
AAD_TENANTID=$(az identity show -g $RG -n $AAD_IDENTITY --query "tenantId" -o tsv)
echo $AAD_IDENTITY_PRINCIPALID
echo $AAD_IDENTITY_CLIENTID
echo $AAD_TENANTID
# Assign AKV Permissions to Azure AD Identity
az role assignment create \
    --role Reader \
    --assignee $AAD_IDENTITY_PRINCIPALID \
    --scope /subscriptions/$SUBID/resourcegroups/$RG
# Grant AAD Identity access permissions to AKS Cluster SP
az role assignment create \
    --role "Managed Identity Operator" \
    --assignee $APPID \
    --scope /subscriptions/$SUBID/resourcegroups/$RG/providers/Microsoft.ManagedIdentity/UserAssignedIdentities/$AAD_IDENTITY
```

* Now that we have the Azure AD Identity setup, the next step is to set up the access policy (RBAC) in AKV to allow or deny certain permissions to the data.

```bash
# Setup Access Policy (Permissions) in AKV
az keyvault set-policy \
    --name ${PREFIX}akv \
    --secret-permissions list get \
    --object-id $AAD_IDENTITY_PRINCIPALID
```

### Create Azure AD Identity Resources in AKS

* Now that we have all the Azure AD Identity and AKS Cluster SP permissions setup. The next step is to setup and configure the AAD Pod Identities in AKS.

```bash
# Create AAD Identity
cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: akv-identity
  namespace: dev
  annotations:
    aadpodidentity.k8s.io/Behavior: namespaced
spec:
  type: 0
  ResourceID: /subscriptions/$SUBID/resourcegroups/$RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$AAD_IDENTITY
  ClientID: $AAD_IDENTITY_CLIENTID
EOF
# Create AAD Identity Binding
cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: akv-identity-binding
  namespace: dev
spec:
  AzureIdentity: akv-identity
  Selector: bind-akv-identity
EOF
# Take a look at AAD Resources
kubectl get azureidentity,azureidentitybinding -n dev
```

### Deploy Updated Version of Application which accesses AKV

* Now that the bindings are set up, we are ready to test it out by deploying our application and see if it is able to read everything it needs from AKV.

**NOTE: It is the following label, configured via above, that determines whether or not the Identity Controller tries to assign an AzureIdentity to a specific Pod.**

metadata:
  labels:
    **aadpodidbinding: bind-akv-identity**
  name: my-pod

```bash
# Remove Existing Application
kubectl delete -f app.yaml

# Pull Images from Docker Hub to Local Workstation
docker pull kevingbb/imageclassifierweb:v3
docker pull kevingbb/imageclassifierworker:v3

# Push Images to ACR
docker tag kevingbb/imageclassifierweb:v3 ${PREFIX}acr.azurecr.io/imageclassifierweb:v3
docker tag kevingbb/imageclassifierworker:v3 ${PREFIX}acr.azurecr.io/imageclassifierworker:v3
docker push ${PREFIX}acr.azurecr.io/imageclassifierweb:v3
docker push ${PREFIX}acr.azurecr.io/imageclassifierworker:v3

# Create Secret for Name of Azure Key Vault for App Bootstrapping
kubectl create secret generic image-akv-secret \
  --from-literal=KeyVault__Vault=${PREFIX}akv \
  -n dev

# Deploy v3 of the Application
kubectl apply -f appv3msi.yaml

# Check to see that AAD Pod Identity was Assigned (You should see 2)
kubectl get AzureAssignedIdentities -n dev

# Display the Application Resources
kubectl get deploy,rs,po,svc,ingress,secrets -n dev
```

* Once the pods are up and running, check via the WAF Ingress Point

```bash
# Get Public IP Address of Azure App Gateway
az network public-ip show -g $RG -n $AGPUBLICIP_NAME --query "ipAddress" -o tsv
```

## Next Steps

[Day 2 Operations](/day2-operations/README.md)

## Key Links

* [Tilt](https://github.com/windmilleng/tilt)
* [Telepresence](https://telepresence.io)
* [Azure Dev Spaces](https://docs.microsoft.com/en-us/azure/dev-spaces/about)
