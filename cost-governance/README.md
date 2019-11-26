# Cost Governance
Cost Governance is the continuous process of implementing policies to control costs. In the context of Kubernetes, there are a number of ways organizations can control and optimize their costs. These include native Kubernetes tooling to manage and govern resource usage and consumption as well as proactive monitoring and optimize the underlying infrastructure.

In this section we will use [KubeCost](https://kubecost.com/) monitor and govern our AKS clyster cost. Cost allocation can be scoped to a deployment, service, label, pod, and namespace, which will give you flexibility in how you chargeback/showback users of the cluster.

## Setup

Kubecost has already been deployed to the cluster through your cluster-config GitOps repo. We will just need to connect to the UI to get started. Run the following command to port-ford the service to your local machine.

```bash
kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090
```bash

You now can open your browser and point to <http://127.0.0.1:9090> to open the Kubecost UI. In the Kubecost UI you should see a screen like below, so go ahead and select your cluster to view cost allocation information.


???
```

## Next Steps

[Deploy Application](/deploy-app/README.md)

## Key Links

* ???
