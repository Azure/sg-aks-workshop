# Cost Governance

Cost Governance is the continuous process of implementing policies to control costs. In the context of Kubernetes, there are a number of ways organizations can control and optimize their costs. These include native Kubernetes tooling to manage and govern resource usage and consumption as well as proactive monitoring and optimize the underlying infrastructure.

In this section, we will use [KubeCost monitor](https://kubecost.com/) and govern our AKS cluster cost. Cost allocation can be scoped to a deployment, service, label, pod, and namespace, which will give you flexibility in how you chargeback/showback users of the cluster.

## Setup

We will first need to get KubeCost deployed to our cluster. We have the choice to install directly or using the Helm charts as documented [here](https://kubecost.com/install?ref=home).

### Install directly

```bash
# Create Kubecost Namespace
kubectl create namespace kubecost
# Install KubeCost into AKS Cluster
kubectl apply -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/master/kubecost.yaml --namespace kubecost
```

### Install with Helm

```bash
## Helm 2
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm install kubecost/cost-analyzer --namespace kubecost --name kubecost --set kubecostToken="YWxnaWJib25AbWljcm9zb2Z0LmNvbQ==xm343yadf98"
```

```bash
## Helm 3
kubectl create namespace kubecost
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken="YWxnaWJib25AbWljcm9zb2Z0LmNvbQ==xm343yadf98"
```

### Check your deployment

```bash
# After a few minutes check to see that everything is up and running
kubectl get pods -n kubecost
# Connect to the KubeCost Dashboard (UI)
kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090
```

You now can open your browser and point to <http://127.0.0.1:9090> to open the Kubecost UI. In the Kubecost UI you should see a screen like below, so go ahead and select your cluster to view cost allocation information.

## Navigating KubeCost

KubeCost will break down resources into the following categories:

* Monthly Cluster Cost
* Namespace Cost
* Deployment Resource Cost
* Cost Efficiency

You'll see a dashboard like the one below when selecting your cluster

![kubecost-admin](img/cost-admin.png)

If you select __Allocation__ on the left side you can dig down into the namespace cost of your resources. It will show the cost for CPU, Memory, Persistent Volumes, and Network. It gets the data from Azure pricing, but you can also set a custom cost of the resources.

![kubecost-allocation](img/allocation.png)

Now if you select  __Savings__ on the left side you can dig down into cost-saving for underutilized resources. It will give you info back on underutilized nodes, pods, and abandoned resources. It will also identify resource requests that have been overprovisioned within the cluster. You can see a sample below of the overview:

![kubecost-savings](img/savings.png)

Take some time to navigate around the different views and features KubeCost provides.

## Next Steps

[Deploy Application](/deploy-app/README.md)

## Key Links

* [KubeCost](https://kubecost.com/)
