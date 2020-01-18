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

## GitOps

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

It can't be stated enough of the importance of request and limits to ensure you cluster is in a healthy state. You can read more on these topics in the **Key Links** at the end of this lab.

## Metrics Alerts

* Low Disk Space
* Disk throttling 

## Scaling with Keda

## Logging Alerts

* SSH into Pod
* Disk Full
* 

## Backup/DR

* Velero

## Next Steps

[Validate Scenarios](/validate-scenarios/README.md)

## Key Links

* ???
