# Governance + Security

This section walks us through the different aspects of governance and security that need to be thought about prior to implementing any solution. To help guide the way, we will be leveraging the [customer scenario](/customer-scenario/README.md) based on Contoso Financials. The scenario describes the customer, along with some background, and wraps up with a list of the requirements that need to be met.

Now that we know the customer scenario and understand what needs to be implemented, let's get started. The majority of this section's content is technology agnostic, as implementation varies from customer to customer. For the purposes of this workshop, we will be focusing on how to implement the solution using Microsoft Azure along with some Open Source Software (OSS) solutions.

## Security Control Lifecycle in the Cloud

A primary consideration when discussing the Cloud Native approach to Security and Governance is the dynamic nature of the cloud itself. In traditional enterprises, environments tend to be relatively stable with both preventative and detective technical controls in place.  In addition, the organizational model tends to align with traditional IT functions such as identity, networking and machine/VM OS management; therefore, a security and compliance team would typically handle relatively infrequent changes to the overall infrastructure, controls, and monitoring required to achieve the security and risk objectives of the enterprise.  

With the adoption of the cloud and also the adoption of devops models, security must adapt and evolve in order to support these changes, rather than allowing legacy approaches to impede technical innovation. In order to enable this transformation while maintaining system integrity, the right roles and responsibilities (people and processes) need to be created alongside the adoption of automation and technical tooling such as scanning/testing and infrastructure as code in the devops pipeline.

**Initially, most enterprises start off in this new world by trying to do exactly what they do today. While certain things will remain consistent, many others will require change. Keep in mind: if you try and do exactly what you are doing on-premises today when you move to the the Cloud, you will fail.** 

Migrating to the cloud is an opportunity to learn, update skills, increase an organization's security posture and position security as an enabler-rather than a blocker- through the streamlining of security within the development to production process. If you use 10-20 year old tools and processes, you are simply going to inherit/introduce the same 10-20 year old security challenges, problems and frustrations into your cloud journey. Consider this a chance to start fresh!

So how can we execute on this clean slate? We need to start with an understanding of the following: 
- Cloud fundamentals 
- Availability of services, tools, controls and visibility within the cloud 
- Cloud operations 
- How to integrate services and tools into the devops process that meet security and governance requirements

It's often easiest to start with an existing process framework/lifecycle in order to establish security controls and manage/operationalize the controls themselves. For the former, many customers use common security control frameworks and standards such as NIST 800-53, ISO, CIS benchmarks, HIPAA/HITRUST, etc.  These can help establish a comprehensive framework and often provide guidance on how to establish, document, and/or audit security controls and processes. 

When it comes to managing/operationalizing security controls, especially in relation to the cloud and devops, it can be useful to look at models like SDL processes that treat security controls as if they are traditional organizational assets like lifecycle management (see below).

![Security Control Lifecycle](/governance-security/img/SecurityControlLifecycle.png)

The big takeaway from the diagram is that security controls should be treated like other important assets in an organization; this approach should start with Source Control. Similar to how infrastucture has moved towards Infrastructure-as-Code which enables the creation of resources on demand, security should also be moving in the same direction.

## Next Steps

[Azure Control Setup](/governance-security/CONTROL_SETUP.md)

## Key Links

* [NIST 800-53 Database](https://nvd.nist.gov/800-53)
* [Azure Blueprints for CIS Benchmark](https://azure.microsoft.com/en-ca/blog/new-azure-blueprint-for-cis-benchmark/)
