# Service Mesh

This section talks a bit about what a Service Mesh is, but what is a Service Mesh, and **do we need one?**

A service mesh is a dedicated infrastructure layer that controls service-to-service communication over a network. It provides a method in which separate parts of an application can communicate with each other. Service meshes appear commonly in concert with cloud-based applications, containers and microservices

## Do I need a Service Mesh

The short answer is **no**. I know that statement in itself can cause quite a conflict depending on the crowd you are in. We highly encourage users to really understand their requirements, and at the same time really understand what capabiliteis does the platform you are using provide. In this case the platform(s) are Azure and Kubernetes, AKS.

So why that guidance? Simply put, if you don't have to add complexity then don't add it. Every time a new tool or technology is added it means more technical debt you have to incur as it needs to be managed, maintained and operationalized. In some cases that is fairly straight forward, and in other cases not so much. But why add it in the first place. Make sure you are doing it for the right reasons and not due to **hype**.

Now we will get down off the soapbox.

## Service Mesh Overview & Typical Reasons

So why even have a Service Mesh in the workshop, after all the statement above was about keeping it simple? That is true, but we also wanted to provide a perspective around Service Mesh when it comes to Governance and Security and where we think it might come into play.

Here are a few of the common reasons we hear from users as to why they need Service Mesh:

### mTLS between Services

This is usually near the top of the list. Some of the questions we typically ask are do you do this today? The typical response is no, so why all of a sudden then? Which the typical response is to improve security. Ahhh, now we are getting somewhere. Instead of relying on infrastructure to secure your service, what about having the service do it? This way no matter where the service/code goes, IaaS, PaaS, in a Container, Serverless, **security travels with the application versus depending on something to be implemented.**

### East/West Traffic Enforcement

It is definitely important to be able to govern and secure which services can talk to which services, but you don't need a Service Mesh for that. In the majority of cases this requirement can be met by simply **using NetworkPolicy which is built right into kubernetes itself.**

### Service Observability

Again, we would not argue that service observability is not important, but do you need a Service Mesh for that? Similar to the mTLS argument above, what about if this was just baked into the service itself so that no matter where or how the service got deployed the observability would travel with it? There are a number of application telemetry tools out there, they are not all the same though. So evaluate the tools against your organization's requirements and find the best fit. **The key is to use one as having one in place is better than none at all.**

## Linkerd

So you did not buy into the statements above, or maybe your organization has bought into some of the hype, or maybe there is a valid reason. Whichever it happens to be, there are a number of Service Meshes out there, which one is right for our organization? We are not going to get into a comparision or breakdown of all the different Service Meshes out there, that is an evaluation your organization will have to do, and make sure it is against requirements.

For the purposes of this workshop we will be demonstrating Linkerd as we have found it straight forward, easy to use, and able to get it up in minutes.

**Click [here](https://linkerd.io/2/getting-started/) to get the linkerd cli installed if you have not already.**

**Click [here](https://linkerd.io/2/reference/architecture/)for an architectural overview.**

### Quick Dive into Linkerd

The first thing we will check is to make sure linkerd is running correctly, this is done by checking the control plane and namespaces for any errors using the linkerd cli.

```bash
# Check Version
linkerd version

# Check Control Plane
linkerd check

# Check Linkerd Proxies in dev Namespace
linkerd check --proxy -n dev
```

Assuming the control plane and proxies (data plane) are working as expected let's dive into a few of the basics and take a look at some of the data.

```bash
# Look at Metrics Captured by Linkerd in dev Namespace
linkerd stat deploy -n dev

# Look at Individual Routes for a Service in dev Namespace
linkerd routes svc/imageclassifierweb -n dev

# Look at Top Traffic in dev Namespace
linkerd top deploy -n dev

# Look at Live Traffic in dev Namespace
linkerd tap deploy -n dev

# Look at Edge Traffic and whether it is Secured via mTLS
linkerd edges po -n dev
```

### Linkerd Dashboard

For those visual folks in the crowd, Linkerd also provides a dashboard where you can gain additional insights into your cluster and how services are interacting.

```bash
linkerd dashboard
```

## Next Steps

[Validate Scenarios](/validate-scenarios/README.md)

## Key Links

* ???