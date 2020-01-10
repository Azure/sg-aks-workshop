# Governance + Security

This section walks us through the different aspects of governance and security that need to be thought about prior to implementing any solution. To help guide the way, we will be leveraging the [customer scenario](/customer-scenario/README.md) based on Contoso Financials. The scenario describes the customer, along with some background, and wraps up with a list of the requirements that need to be met.

Now that we know the customer scenario and understand what needs to get implemented, let's get started. The majority of what is talked about in the rest of this section is technology agnostic with the implementation varying from customer to customer. For the purposes of this workshop we will be focusing on how to implement the solution using Microsoft Azure along with some Open Source Software (OSS) solutions.

## Security Control Lifecycle in the Cloud

TQNOTE:  Are you sure you want to diverge from the SDL practices in our other documentation (https://docs.microsoft.com/en-us/azure/security/develop/secure-dev-overview)?  I would suggest using it as a starting point and then introducing the concept of the Security Control Lifecycle (if you would like to keep it).  I definitely think the concept of Infrastructure as code and the inclusion of controls (preventive and detective) as part of the "code" is really important and a best practice in either approach.

One of the first things to understand when talking about Cloud Native Security and Governance is that the cloud can be very dynamic where as most enterprises are used to having relatively stable environments that include both technical preventative and detective controls in place as well as a structured organizational model that aligns with traditional IT functions such as Identity, Networking, machine and VM OS management.  The security and compliance team had to work with relatively infrequent changes to the overall structure and infrastructure and the controls and monitoring required to achieve the enterprises security and risk obbjectives.  With the adopting the cloud and also in adopting dev/ops models, security ends up having to adapt to operate as part of those changes in order to not become an impedement to the business and progress.  Much of that includes how to create the right roles and responsibilities (people processes) as well as automation and technical tools such as scanning/testing and infrastructure as code as part of a devops pipeline to enable inovation and time to delivery while still ensuring security requirements can be met.


The temptation and typical path most enterprises take is starting off by doing what they do today.  In some aspects, you can but in others, no.  The key take-a-way is that if you simply try and do exactly what you are doing today on-prem in the Cloud, you will fail. Adopting the cloud is an opportunity to update skills, learn, increase the organization's security posture and position security to be an enabler rather than a blocker by streamlining security as part of the development to production process. If you use 10-20 year old tools and processes, you are simply going to inherit/introduce the same 10-20 year old security challenges, problems and frustrations to the business. This is your chance to start fresh.


So how is that done? It starts with a understanding of the cloud, what services are available, what controls are available, what visibility is available, how do I operate it, what security tools and governance tools are available and how can I leverage them as part of a process/system so lines of business can be more agile, a modern dev-ops model, and I can ensure that security and compliance requirements can be met.

It's often easiest to start with a framework/lifecycle from a process perspective in both establishing security controls as well as how to manage/operationalize the controls themselves.  For the former, many customers use common security control frameworks and standards such as NIST 800-53, ISO, CIS benchmarks, HIPAA/HITRUST, etc.  These can help establish a comprehensive framework and often guidance to help establish, document, and/or audit security controls and processes.  When it comes to managing/operationalizing security controls, in particular when it somes to things like the cloud and dev ops, it can be useful to look at a variety of models including SDL processes that include cloud and dev/ops, approaches and models like treating security controls like assets like any others in an organization including lifecycle management (see below).

![Security Control Lifecycle](/governance-security/img/SecurityControlLifecycle.png)

The big take-a-way from the diagram is that security controls should be treated like other important assets in an organization, it starts with Source Control. Similar to how Infrastucture has moved towards Infrastructure as Code and having the ability to recreate resources on demand, Security needs to move in the same direction.


Another approach that has been taken to approach governance and security, in particular as part of cloud adoption, is to look at what has been defined as the "Enterprise Control Plane" or ECP.  ECP is all about the common problems that Enterprises need to solve in order to adopt Public Cloud.


![Enterprise Control Plane](/governance-security/img/EnterpriseControlPlane.png)

How does ECP help me meet those challenges? The following diagram gives a picture of key concepts that are part of structuring an Enterprise Control Plane model.

![Enterprise Control Plane - Why?](/governance-security/img/EnterpriseControlPlaneWhy.png)

## Enterprise Control Plane Architecture

Lastly, the below picture aligns various services in Azure and how they align to an ECP Architecture (for Azure).

![Enterprise Control Plane Architecture?](/governance-security/img/EnterpriseControlPlaneArchitecture.png)

## Enterprise Control Plane Governance

One of the key benefits an Enterprise Control Plane framework approach is it's incorporation of governance and controls auditing.  For Azure, this includes the implementation and use of tools such as Azure Security Center's Secure Score, Azure Policies, Azure security centers compliance dashboards, etc.  Compliance in place is the ability to see how compliant your environment is compared to the security controls that need to be adhered too. In other words, governance observability. The following is a sample screenshot of what a Governance Compliance dashboard could look like.

![Enterprise Control Plane Governance?](/governance-security/img/EnterpriseControlPlaneGovernance.png)

## Implementing Security Controls using Security Controls Lifecycle and ECP

In the interests of time with respect to the workshop, we are not going to implement every security control as part of a full Azure deployment nor the Azure policies that would be used to audit the environment to ensure those controls are in place.  We are just going to implement a few so you get a feel for the flow of things. Once the process is understood it is just a matter of rising and repeating for additional security controls that align to an organization's needs.

Reading through the Contoso Financials scenario we will be implementing the following to meet requirements from security:

* Log All Cloud API requests for Audit Reporting purposes
* AKS Clusters can only be created in certain regions
* AKS Cluster has IP whitelisting set

## Next Steps

[Control Setup](/governance-security/CONTROL_SETUP.md)

## Key Links

* [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview)
* [Azure Policy for AKS](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/rego-for-aks)
* [Azure Security Center (ASC)](https://docs.microsoft.com/en-us/azure/security-center/security-center-intro)
* [Detecting Threats Targeting Containers with ASC](https://azure.microsoft.com/en-us/blog/detecting-threats-targeting-containers-with-azure-security-center/)
* [Understand ASC Container Recommendations](https://docs.microsoft.com/en-us/azure/security-center/security-center-container-recommendations)
