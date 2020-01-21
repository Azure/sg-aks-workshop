# Day2 Operations

This section walks us through the key considerations that need to be taken into account when thinking about how to operate AKS after everything is provisioned and running. In this section we will cover the following topic:

- GitOps
- Upgrading Your Cluster
- Resource Management
- Scaling
  - Cluster Scaling
  - Application Scaling
- Daily Monitoring
- Logging
- Alerting
- Backup/DR

We will implement some of the topics throughout this lab where others we will talk about the different approaches you can use for day 2 Operations.

## GitOps Approach For Managing Multiple Clusters
GitOps was popularized by the folks at Weaveworks, and the idea and fundamentals were based on their experience of running Kubernetes in production. GitOps takes the concepts of the software development life cycle and applies them to operations. With GitOps, yourGit repository becomes your source of truth, and your cluster is synchronized to the configured Git repository. For example, if you update a Kubernetes Deployment manifest, those configuration changes are automatically reflected in the cluster state.

By using this method, you can make it easier to maintain multiple clusters that are consistent and avoid configuration drift across the fleet.GitOps allows you to declaratively describe your clusters for multiple environments and drives to maintain that state for the cluster.The practice of GitOps can apply to both application delivery and operations, but in this chapter, we focus on using it to manage clusters and operational tooling. 

Weaveworks Flux was one of the first tools to enable the GitOps approach, and it’s the tool we will use throughout the rest of the chapter. There are many new tools that have been released into the cloud-native ecosystem that are worth a look, such as Argo CD, from the folks at Intuit, which has also been widely adopted for the GitOps approach.

![GitOps](./img/gitops.png)

If you remember back in the __Cluster Provisioning__ section we talked about how we used Flux to bootstrap components when we provisioned the cluster. To demonstrate how the cluster synchronizes with our git repo we will delete one of the namespaces and see how it automatically gets synchronized back to the state that is stored in Github.

First list the namespace to see which ones were configured from our gi repo.

```bash
kubectl get ns
```

Now we'll delete one of the namespaces.

```bash
kubectl delete ns dummy-ns
```

If you run the following command you'll see that the dummy-ns namespace is no longer listed.

```bash
kubectl get ns
```

Now if you watch the namespace you will see it automatically appear after about 1 minutes (Sync time is configurable).

```bash
kubectl get ns -w
```

## Resource Management

One of the important task of day 2 operations is resource management. Resource Management consist of maintaining adequate resources to serve your workloads. Kubernetes provides built in mechanisms to provide both soft and hard limits on CPU and Memory. It's important to understand how these request and limits work as it will ensure you provide adequate resource utilization for your cluster.

__Requests__ are what the container is guaranteed to get. If a container requests a resource then Kubernetes will only schedule it on a node that satisfies the request. __Limits__, on the other hand, ensure a container never goes above a certain configured value. The container is only allowed to go up to this limit, and then it is restricted.

When a container does hit the limit there is different behavior from when it hits a memory limit vs a CPU limit. With a memory limit the container will be killed and you'll see an "Out Of Memory Error". When a CPU limit is hit it will just start throttling the CPU vs restarting the container.

It's also important to understand how Kubernetes assigns QoS classes when scheduling pods, as it hav an effect on pod scheduling and eviction. Below is the different QoS classes that can be assigned when a pod is scheduled:

* **QoS class of Guaranteed:**
   * Every Container in the Pod must have a memory limit and a memory request, and they must be the same.
   * Every Container in the Pod must have a CPU limit and a CPU request, and they must be the same.
  
* **QoS class of Burstable**
  * The Pod does not meet the criteria for QoS class Guaranteed.
  * At least one Container in the Pod has a memory or CPU request.

* **QoS class of Best Effort**
  * For a Pod to be given a QoS class of BestEffort, the Containers in the Pod must not have any memory or CPU limits or requests.

Below shows a diagram depicting QoS based on request and limits.

![QoS](./img/qos.png)

**Failure to set limits for memory on pods can lead to a single pod starving the cluster of memory.**

If you want to ensure every pod get at least a default request/limit, you can set a **LimitRange** on a namespace. If you preform the following command you can see in our cluster we have a LimitRange set on the Dev namespace.

```bash
kubectl get limitrange dev-limit-range -n dev -o yaml
```

You'll see that we have the following defaults:

```yaml
- Request
  - CPU = 250m
  - Memory = 256Mi

- Limit
  - CPU = 500m
  - Memory = 512Mi
```

**It can't be stated enough of the importance of request and limits to ensure you cluster is in a healthy state. You can read more on these topics in the **Key Links** at the end of this lab.**

## Scaling Resources

## Logging And Alerts

__Azure Monitor for Containers__ allows you to collect metrics, live logs, and logs for investigative purposes. Monitoring and logging the health and performance of your Azure Kubernetes Service (AKS) cluster is important to ensure that your applications are up and running as expected. It's first important to understand the difference between __Logs__ and __Metrics__. Both serve difference purposes and are components of observability.

* Metrics - Typically a time series of numbers over a specific amount time
* Logs - Used for exploratory analysis of a system or application

In the next section we'll dive into how to view live logs, create log query, and how to create an alert from the query.

## Live Logs

Live logs are nice way to see logs being emitted from STDOUT/STDERR of a container. You can give developers access to the live logging, so they can live debug issues happening with their application. This allows you to limit their exposure to using __kubectl__ for application issues.

To access the live logs you will need to navigate to the Insights section of the AKS Cluster

Portal->Azure Kubernetes Service->Cluster->Insights

[Navigation](./imglivelogsnav.png)

Now in Insights 

### Creating Alerts Based on Log Query

* SSH into Pod


## Metrics

* Low Disk Space
* Disk throttling

## Cluster Upgrade With Node Pools

With nodepools available in AKS, we have the ability to decouple the Control Plane upgrade from the nodes upgrade, and we will start by upgrading our control plane. 

**Note** Before we start, at this stage you should:
1- Be fully capable of spinning up your cluster and restore your data in case of any failure (check the backup and restore section)
2- Know that control plane upgrades don't impact the application as its running on the nodes
3- You know that your risk is a failure on the Control Plane and in case this happened you should go and spin up a new cluster and migrate then open a support case to understand what went wrong.


```shell
$ az aks upgrade -n $clustername -g $rg -k 1.14.8 --control-plane-only
Kubernetes may be unavailable during cluster upgrades.
Are you sure you want to perform this operation? (y/n): y
Since control-plane-only argument is specified, this will upgrade only the control plane to 1.14.8. Node pool will not change. Continue? (y/N): y
{
  "aadProfile": null,
  "addonProfiles": null,
  "agentPoolProfiles": [
    {
      "availabilityZones": null,
      "count": 1,
      "enableAutoScaling": null,
      "enableNodePublicIp": null,
      "maxCount": null,
      "maxPods": 110,
      "minCount": null,
      "name": "node1311",
      "nodeTaints": null,
      "orchestratorVersion": "1.13.11",
      "osDiskSizeGb": 100,
      "osType": "Linux",
      "provisioningState": "Succeeded",
      "scaleSetEvictionPolicy": null,
      "scaleSetPriority": null,
      "type": "VirtualMachineScaleSets",
      "vmSize": "Standard_DS2_v2",
      "vnetSubnetId": null
    }
  ],
  "apiServerAccessProfile": null,
  "dnsPrefix": "aks-nodepo-ignite-2db664",
  "enablePodSecurityPolicy": false,
  "enableRbac": true,
  "fqdn": "aks-nodepo-ignite-2db664-6e9c6763.hcp.westeurope.azmk8s.io",
  "id": "/subscriptions/2db66428-abf9-440c-852f-641430aa8173/resourcegroups/ignite/providers/Microsoft.ContainerService/managedClusters/aks-nodepools-upgrade",
  "identity": null,
  "kubernetesVersion": "1.14.8",
 ....
```

**Note** The Control Plane can support N-2 kubelet on the nodes, which means 1.14 Control Plane supports 1.14,1.12, and 1.11 Kubelet. Kubelet can't be *newer* than the Control Plane. more information can be found [here](https://kubernetes.io/docs/setup/release/version-skew-policy/#kube-apiserver)

Lets add a new node pool with the desired version "1.14.8"

```shell
#Warring confusing parameters :) 
$ az aks nodepool add \
    --cluster-name $clustername \
    --resource-group $rg \
    --name node1418 \
    --node-count $node_count \
    --node-vm-size $vmsize \
    --kubernetes-version 1.14.8

#Lets see how our nodes look like (we should 2 see 2 nodes with different K8s versions)
$ kubectl get nodes 
NAME                               STATUS   ROLES   AGE   VERSION
aks-node1311-64268756-vmss000000   Ready    agent   40m   v1.13.11
aks-node1418-64268756-vmss000000   Ready    agent   75s   v1.14.8
```


TEST TEST TEST, in whatever way you need to test to verify that your application will run on the new node pool, normally you will spin up a test version of your application, if things are in order then proceed to 8.

Deploy your application, different options are available 

* Migrate off the old nodes using cordon and drain 

```shell
#deploy a new version of your application on the new nodes, you can target the new node  pool using the "agentpool=" label which was added from AKS
$ kubectl get nodes --show-labels
NAME                               STATUS   ROLES   AGE   VERSION    LABELS
aks-node1311-64268756-vmss000000   Ready    agent   57m   v1.13.11   agentpool=node1311,...
aks-node1418-64268756-vmss000000   Ready    agent   17m   v1.14.8    agentpool=node1418,...
```

#open another shell and run the below script to see the impact of the upgrade process
$ while true;do curl -I 51.145.184.112 2>/dev/null | head -n 1 | cut -d$' ' -f2;  done
200
200
...

Deploy the new app, we will change the name only and keep the labels and add node affinity

```bash
$ kubectl apply -f myapp-v2.yaml
```

Check if the pods are running, note that all the new pods are in the new node

```bash
kubectl get pods -o wide
```

```bash
NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE                               NOMINATED NODE   READINESS GATES
myapp-v1-7bc994fccc-4wg8c   1/1     Running   0          51m   10.244.0.11   aks-node1311-64268756-vmss000000   <none>           <none>
myapp-v1-7bc994fccc-6q65q   1/1     Running   0          51m   10.244.0.10   aks-node1311-64268756-vmss000000   <none>           <none>
myapp-v1-7bc994fccc-g5jjz   1/1     Running   0          51m   10.244.0.8    aks-node1311-64268756-vmss000000   <none>           <none>
myapp-v1-7bc994fccc-zpdw6   1/1     Running   0          51m   10.244.0.9    aks-node1311-64268756-vmss000000   <none>           <none>
myapp-v2-9c8b897c7-bdtpk    1/1     Running   0          25s   10.244.1.4    aks-node1418-64268756-vmss000000   <none>           <none>
myapp-v2-9c8b897c7-dc6bc    1/1     Running   0          25s   10.244.1.3    aks-node1418-64268756-vmss000000   <none>           <none>
myapp-v2-9c8b897c7-kg56v    1/1     Running   0          25s   10.244.1.2    aks-node1418-64268756-vmss000000   <none>           <none>
myapp-v2-9c8b897c7-pwfx2    1/1     Running   0          25s   10.244.1.5    aks-node1418-64268756-vmss000000   <none>           <none> 
```

Check the endpoints, note now we have 8 instead of 4

```bash
kubectl get endpoints myapp

NAME    ENDPOINTS                                                 AGE
myapp   10.244.0.10:80,10.244.0.11:80,10.244.0.8:80 + 5 more...   18m
```

Delete the old version of your application

```bash
kubectl delete -f myapp-v1.yaml
```

Check the pods, you should only see the v2.

```bash
kubectl get pods -o wide

NAME                       READY   STATUS    RESTARTS   AGE    IP           NODE                               NOMINATED NODE   READINESS GATES
myapp-v2-9c8b897c7-bdtpk   1/1     Running   0          4m1s   10.244.1.4   aks-node1418-64268756-vmss000000   <none>           <none>
myapp-v2-9c8b897c7-dc6bc   1/1     Running   0          4m1s   10.244.1.3   aks-node1418-64268756-vmss000000   <none>           <none>
myapp-v2-9c8b897c7-kg56v   1/1     Running   0          4m1s   10.244.1.2   aks-node1418-64268756-vmss000000   <none>           <none>
myapp-v2-9c8b897c7-pwfx2   1/1     Running   0          4m1s   10.244.1.5   aks-node1418-64268756-vmss000000   <none>           <none>
```

You're good to cordon and drain the old node pool 

```bash
kubectl delete -f myapp-v1.yaml
deployment.apps "myapp-v1" deleted
```

```bash
kubectl drain aks-node1311-64268756-vmss000000 --ignore-daemonsets  --delete-local-data
```

You should see only 200s responses from the curl script running, now you  can exit the script

* Deploy your application with a new service, then switch the endpoints in your DNS
* you may not care about a slight down time, then you just cordon and drain the nodes


## Backup/DR

* Velero

## Next Steps

[Validate Scenarios](/validate-scenarios/README.md)

## Key Links

* ???
