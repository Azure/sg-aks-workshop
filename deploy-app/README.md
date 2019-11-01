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

## Deploy Application

There is an app.yaml file in this directory so either change into this directory or copy the contents of the file to a filename of your choice. Once you have completed the previous step apply the manifest file and you will get the web and worker services deployed into the **dev** namespace.

```bash
kubectl apply -f app.yaml
kubectl get deploy,rs,po,svc,ingress -n dev
```

### File Share Setup

You will notice that some of the pods are not starting up, this is because a secret is missing, the secret to access Azure Files. Please talk to your proctors to get the proper credentials or feel free to setup your own Azure Files and upload the sample fruit images in this repo directory.

**Be careful to take note of the folder name it needs to be in the Azure File Share.**

```bash
# Add Secrets for Worker Back-End
STORAGE_ACCOUNT_NAME=""
STORAGE_ACCOUNT_KEY=""
k create secret generic fruit-secret --from-literal=azurestorageaccountname=<STORAGE_ACCOUNT_NAME> --from-literal=azurestorageaccountkey=<STORAGE_ACCOUNT_KEY>

```

The end results will look something like this.

![Dev Namespace Output](/deploy-app/img/app_dev_namespace.png)

## Next Steps

[Service Mesh](/service-mesh/README.md)

## Key Links

* [Tilt](https://github.com/windmilleng/tilt)
* [Telepresence](https://telepresene.io)
* [Azure Dev Spaces](https://docs.microsoft.com/en-us/azure/dev-spaces/about)