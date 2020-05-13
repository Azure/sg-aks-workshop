# Governance + Security

This section walks us through the different aspects of governance and security that need to be thought about prior to implementing any solution. To help guide the way, we will be leveraging the [customer scenario](/customer-scenario/README.md) based on Contoso Financials. The scenario describes the customer, along with some background, and wraps up with a list of the requirements that need to be met.

Now that we know the customer scenario and understand what needs to be implemented, let's get started. The majority of this section's content is technology agnostic, as implementation varies from customer to customer. For the purposes of this workshop, we will be focusing on how to implement the solution using Microsoft Azure along with some Open Source Software (OSS) solutions.

## Security Control Lifecycle in the Cloud

One of the first things to understand when talking about Cloud Native Security and Governance is that the cloud can be very dynamic where as most enterprises are used to having relatively stable environments that include both technical preventative and detective controls in place as well as a structured organizational model that aligns with traditional IT functions such as Identity, Networking, machine and VM OS management. The security and compliance team had to work with relatively infrequent changes to the overall structure and infrastructure and the controls and monitoring required to achieve the enterprises security and risk objectives.  With the adopting the cloud and also in adopting dev/ops models, security ends up having to adapt to operate as part of those changes in order to not become an impediment to the business and progress. Much of that includes how to create the right roles and responsibilities (people processes) as well as automation and technical tools such as scanning/testing and infrastructure as code as part of a DevOps pipeline to enable innovation and time to delivery while still ensuring security requirements can be met.

**The temptation and typical path most enterprises take is starting off by doing what they do today. In some aspects, you can but in others, no. The key take-a-way is that if you simply try and do exactly what you are doing today on-prem in the Cloud, you will fail.** Adopting the cloud is an opportunity to update skills, learn, increase the organization's security posture and position security to be an enabler rather than a blocker by streamlining security as part of the development to production process. If you use 10-20-years-old tools and processes, you are simply going to inherit/introduce the same 10-20-years-old security challenges, problems and frustrations to the business. This is your chance to start fresh.

So how is that done? It starts with an understanding of the cloud, what services are available, what controls are available, what visibility is available, how do I operate it, what security tools and governance tools are available and how can I leverage them as part of a process/system so lines of business can be more agile, a modern dev-ops model, and I can ensure that security and compliance requirements can be met.

It's often easiest to start with a framework/lifecycle from a process perspective in both establishing security controls as well as how to manage/operationalize the controls themselves.  For the former, many customers use common security control frameworks and standards such as NIST 800-53, ISO, CIS benchmarks, HIPAA/HITRUST, etc.  These can help establish a comprehensive framework and often guidance to help establish, document, and/or audit security controls and processes.  When it comes to managing/operationalizing security controls, in particular when it comes to things like the Cloud and DevOps, it can be useful to look at a variety of models including SDL processes that include cloud and dev/ops, approaches and models like treating security controls like assets like any others in an organization including lifecycle management (see below).

![Security Control Lifecycle](/governance-security/img/SecurityControlLifecycle.png)

The big take-a-way from the diagram is that security controls should be treated like other important assets in an organization, it should start with Source Control. Similar to how Infrastructure has moved towards Infrastructure as Code and having the ability to recreate resources on-demand, Security needs to start moving in the same direction.

## Next Steps

[Azure Control Setup](/governance-security/CONTROL_SETUP.md)

## Key Links

* [NIST 800-53 Database](https://nvd.nist.gov/800-53)
* [Azure Blueprints for CIS Benchmark](https://azure.microsoft.com/en-ca/blog/new-azure-blueprint-for-cis-benchmark/)
