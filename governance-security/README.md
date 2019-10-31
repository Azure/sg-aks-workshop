# Governance + Security

This section walks us through the different aspects of governance and security that need to be thought about prior to implementing any solution. To help guide the way, we have created a customer scenario based on an organization called Contoso Financials. The scenario describes the customer, along with some background, and wraps up with a list of the requirements that need to be met.

Click [here](SCENARIO.md) to read the customer scenario.

Now that you have read the customer scenario and understand what needs to get implemented, let's get started. The majority of what is talked about in the rest of this section is technology agnostic with the implementation varying from customer to customer. For the purposes of this workshop we will be focusing on how to implement the solution using Microsoft Azure along with some Open Source Software (OSS) solutions.

## Security Control Lifecycle in the Cloud

One of the first things to understand when talking about Cloud Native Security and Governance is that your security control lifecycle follows the same lifecycle it does today on-prem.

So I just do the same thing I am doing today, right? In some cases yes, and in other cases no. The key take-a-way is that if you simply try and do exactly what you are doing today on-prem in the Cloud, you will fail. Take this opportunity to update skills, learn, and increase the organization's security posture. If you use 10-20 year old tools, you are simply going to inherit/introduce the same 10-20 year old security challenges and problems, this is your chance to start fresh.

So how is that done? It starts with a refresher of the Security Control Lifecycle:

![Security Control Lifecycle](/governance-security/img/SecurityControlLifecycle.png)

The big take-a-way from the diagram is that security controls should be treated like other important assets in an organization, it starts with Source Control. Similar to how Infrastucture has moved towards Infrastructure as Code and having the ability to recreate resources on demand, Security needs to move in the same direction.

## Enterprise Control Plane

Now that we know the importance the security control lifecycle plays in the bigger picture, the next thing to tackle is the Enterprise Control Plane (ECP). What is ECP you ask? ECP is all about the common problems that Enterprises need to solve in order to adopt Public Cloud.

![Enterprise Control Plane](/governance-security/img/EnterpriseControlPlane.png)

Ok, great! I know what my common challenges are, but how does ECP help me meet those challenges. Great question, take a look at the following diagram to get a feeling of how ECP can help you hit the ground running versus always starting every project from scratch.

![Enterprise Control Plane - Why?](/governance-security/img/EnterpriseControlPlaneWhy.png)

## Enterprise Control Plane Architecture

Now that I know why I want to adopt an Enterprise Control Plane (ECP) framework, what does that look like on Azure?

![Enterprise Control Plane Architecture?](/governance-security/img/EnterpriseControlPlaneArchitecture.png)

## Enterprise Control Plane Governance

One of the key benefits of putting an Enterprise Control Plane framework in place is the ability to see how compliant your environment is compared to the security controls that need to be adhered too. In other words, governance observability. The following is a sample screenshot of what a Governance Compliance dashboard could look like.

![Enterprise Control Plane Governance?](/governance-security/img/EnterpriseControlPlaneGovernance.png)

## Implementing Security Controls using Security Controls Lifecycle and ECP

In the interests of time with respect to the workshop, we are not going to implement every security control, just a few so you get a feel for the flow of things. Once the process is understood it is just a matter of rising and repeating for additional security controls that align to an organization's needs.

Reading through the Contoso Financials scenario we will be implementing the following requirements via security controls:

* Log All Cloud API requests for Audit Reporting purposes
* AKS Clusters can only be created in certain regions
* AKS Cluster has IP whitelisting set

## Next Steps

[Control Setup](governance-security/CONTROL_SETUP.md)

## Key Links

* [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview)
* [Azure Policy for AKS](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/rego-for-aks)
* [Azure Security Center (ASC)](https://docs.microsoft.com/en-us/azure/security-center/security-center-intro)
* [Detecting Threats Targeting Containers with ASC](https://azure.microsoft.com/en-us/blog/detecting-threats-targeting-containers-with-azure-security-center/)
* [Understand ASC Container Recommendations](https://docs.microsoft.com/en-us/azure/security-center/security-center-container-recommendations)
