# Deploy App

This section walks us through deploying the sample application.

## Web and Worker Image Classification Services

This is a simple SignalR application with two parts. The web front-end is a .NET Core MVC application that serves up a single page that receives messages from the SignalR Hub and displays the results. The back-end worker application retrieves data from Azure Files and processes the image using a TensorFlow model and sends the results to the SignalR Hub on the front-end.

The end result on the front-end should display what type of fruit image was processed by the Tensorflow model. And because it is SignalR there is no browser refreshing needed.

## Container Development

Before we get into setting up the application, let's have a quick discussion on what container development looks like for the customer. No development environment is the same as it is not a one size fits all when it comes to doing development. Computers, OS, languages and IDEs to name a few things are hardly ever the same configuration/setup. And if you through the developer themselves in that mix it is definitely not the same.

As a result, different users work in different ways. The following are just a few of the **innter devops loop** tools that we are seeing in this eco-system, feel free to try any of them out and let us know what you think. And if it hits the mark.

### Tilt

Tilt is a cli tool used for local continuous development of microservice applications. Tilt watches your files for edits with tilt up, and then automatically builds, pushes, and deploys any changes to bring your environment up-to-date in real-time. Tilt provides visibility into your microservices with a command line UI. In addition to monitoring deployment success, the UI also shows logs and other helpful information about your deployments.

Click [here](https://github.com/windmilleng/tilt) for more details and to try it out.

### Telepresence

Telepresence is an open source tool that lets you run a single service locally, while connecting that service to a remote Kubernetes cluster. This lets developers working on multi-service applications to:

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

One of the most important things an organization can do when adopting Containers is good image management hygience. This means that impages should be scanned prior to being deployed to a cluster. **The old saying goes, "Garbage In, Garbage Out", meaning if you deploy unsecure images to the container registry then the cluster will be deploying unsecure and potentially dangerous images.**

* It is critical to scan images for vulnerabilities in your environment. We recommending using a Enterprise grade tool such as [Aqua Security](https://www.aquasec.com/products/aqua-container-security-platform) or [Twistlock](https://www.twistlock.com/why-twistlock) or [SysDig Secure](https://sysdig.com/products/secure/).

* These tools should be integrated into the CI/CD pipeline, Container Registry, and container runtimes to provide end-to-end protection. Review full guidance here: https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-container-image-management

* For the purposes of this workshop we will be using Anchore for some quick testing. https://anchore.com/opensource

* Install anchore with Helm.

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

Engine DB Version: 0.0.11
Engine Code Version: 0.5.1
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

There is an app.yaml file in this directory so either change into this directory or copy the contents of the file to a filename of your choice. Once you have completed the previous step apply the manifest file and you will get the web and worker services deployed into the **dev** namespace.

```bash
# Navigate to deploy-app Directory
cd ../../deploy-app
# Deploy the Application Resources
kubectl apply -f app.yaml
# Display the Application Resources
kubectl get deploy,rs,po,svc,ingress -n dev
```

### File Share Setup

You will notice that some of the pods are not starting up, this is because a secret is missing, the secret to access Azure Files. Please talk to your proctors to get the proper credentials or feel free to setup your own Azure Files and upload the sample fruit images in this repo directory.

**Be careful to take note of the folder name it needs to be in the Azure File Share.**

```bash
# Add Secrets for Worker Back-End
STORAGE_ACCOUNT_NAME=""
STORAGE_ACCOUNT_KEY=""
k create secret generic fruit-secret \
  --from-literal=azurestorageaccountname=<STORAGE_ACCOUNT_NAME> \
  --from-literal=azurestorageaccountkey=<STORAGE_ACCOUNT_KEY> \
  -n dev
# Check to see Worker Pod is now Running
kubectl get deploy,rs,po,svc,ingress -n dev
```

The end results will look something like this.

![Dev Namespace Output](/deploy-app/img/app_dev_namespace.png)

## Test out Application Endpoint

This section will show you how to test and see if the application endpoint is up and running.

```bash
# Exec into Pod and Test Endpoint
kubectl exec -it centos -- /bin/bash
# Inside of the Pod test the Ingress Controller Endpoint
curl 100.64.2.4
# You should have seen the contents of an HTML file dumped out. If not, you will need to troubleshoot.
# Exit out of Pod
exit
```

* Now Test with the WAF Ingress Point

```bash
az network public-ip show -g $RG -n $AGPUBLICIP_NAME --query "ipAddress" -o tsv
```

## Next Steps

[Service Mesh](/service-mesh/README.md)

## Key Links

* [Tilt](https://github.com/windmilleng/tilt)
* [Telepresence](https://telepresene.io)
* [Azure Dev Spaces](https://docs.microsoft.com/en-us/azure/dev-spaces/about)