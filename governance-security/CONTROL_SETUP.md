# Azure Security Controls Setup

In this section we will walk through setting up the overarching security control framework specific to Azure. This section assumes organization security controls have already been established, defining those security controls is outside of the scope of this content. The focus here is on security control implementation specific to Microsoft Azure.

## Azure Security Control Architecture

All security controls in Microsoft Azure start with and build on top of the Azure Resource Manager (ARM) api. As we can see from the diagram below, there is a service in Azure called **Azure Policy** that helps enforce policies regardless of the channel that they come in from.

![Security Control Architecture](/governance-security/img/EnterpriseControlPlaneArchitecture.png)

**This is important because it means organizations do not have to define policies in multiple places which helps to reduce errors when duplicating logic in multiple places.**

## Security Control Governance

One of the key benefits of leveraging a security control framework and architecture is it's incorporation of governance and controls auditing. For Azure, in addition to Azure Policy, this also includes Azure Security Center and its Secure Score & Compliance Dashboard features. Compliance is all about the ability to see how compliant your environment is compared to the security controls that need to be adhered too. In other words, governance observability. The following is a sample screenshot of what a Governance Compliance dashboard could look like.

![Security Control Governance](/governance-security/img/EnterpriseControlPlaneGovernance.png)

## Implementing Security Controls using Security Controls Lifecycle

In the interests of time with respect to the workshop, we are not going to implement every security control as part of a full Azure deployment nor the Azure policies that would be used to audit the environment to ensure those controls are in place.  We are just going to implement a few so you get a feel for the flow of things. Once the process is understood it is just a matter of rising and repeating for additional security controls that align to an organization's needs.

Reading through the Contoso Financials scenario we will be implementing the following to meet requirements from security:

* Log All Cloud API requests for Audit Reporting purposes
* AKS Clusters can only be created in certain regions
* AKS Cluster has IP whitelisting set

Now that we know what controls we need to meet, how do we do that? The next sections will talk through implementing each of these controls.

## Capture Azure Audit Logs (Log All Cloud API requests for Audit Reporting purposes)

For those that are not aware, Azure Audit Logs are captured in something called [Azure Activity Logs](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/activity-logs-overview). The Activity Logs capture all of the Azure Resource Manager (ARM) interactions. The challenge is that the activity logs only have a certain retention lifecycle so we need to get the data out of the Activity Logs into something more permance, for the purposes of this workshop it will be Azure Monitor Logs.

Click [here](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/activity-log-collect) for an article on how to get this setup for an Azure Subscription.

This is a sample screenshot of what it looks like when completed:

![Activity Log Capture](/governance-security/img/ActivityLogCapture.png)

## Enable Azure Security Monitoring (AKS Cluster IP Whitelisting Enabled)

Before we create anything we should be looking to the Cloud Provider as to what they recommend with respect to security monitoring. In the case of Azure this means enabling Azure Security Center so you get visibility in the recommendations provided by the Cloud Provider.

The ability to monitor whether or not an AKS Cluster has IP Whitelisting (Authorized IP Ranges) enabled or it is one such security policy that Azure Security Center checks for.

A word of caution here, not all security controls that an organization wants will be able to be implemented by the Cloud Provider. The key to success here is to look at what is provided so you are not reinventing the wheel, leverage what is there to reduce technical debt. And for the pieces that are not there, you will need to build that out.

Click [here](https://docs.microsoft.com/en-us/azure/security-center/security-center-get-started) for an article on how to enable Security Center Standard for an Azure Subscription.

This is a sample screenshot of what it looks like when completed:

![SecurityCenterStandard](/governance-security/img/SecurityCenterStandard.png)

## Security Enforcment through Azure Policy (AKS Clusters can only be created in certain regions)

Similar to the point above around security, we should be looking to the Cloud Provider to see what they provide with respect to being able to enforce policy. After all, who knows the cloud provider services better than the Cloud Provider. In the case of Azure this means looking at Azure Policy, it is a key part of the Enterprise Control Plane (ECP) that we talked about on the previous page.

The ability to restrict resource creation to only a certain region is just one of many Azure Policies. Here are two links containing samples of what can be done with Azure Policy:

* [Azure Policy Samples](https://docs.microsoft.com/en-us/azure/governance/policy/samples/)
* [Azure Policy Security Samples](https://docs.microsoft.com/en-us/azure/security-center/security-center-policy-definitions)

Again, a word of caution here, not everything can be done with Azure Policy. The key to success here is to look at what is provided so you are not reinventing the wheel, leverage what is there to reduce technical debt. And for the pieces that are not there, you will need to figure out how to do that.

Click [here](https://docs.microsoft.com/en-us/azure/governance/policy/samples/allowed-locations) for how to implement allowed region locations via Azure Policy.

These are sample screenshots of the flow you will go through:

![Azure Policy Definitions](/governance-security/img/PolicyDefinitions.png)

![Assign Policy Definition to Resource](/governance-security/img/AssignPolicy.png)

![Assign Policy Basics](/governance-security/img/AssignPolicyBasics.png)

![Assign Policy Parameters](/governance-security/img/AssignPolicyParameters.png)

![Assign Policy Create](/governance-security/img/AssignPolicyCreate.png)

![Azure Policy Assignments](/governance-security/img/PolicyAssignment.png)

## Wrapping Up

Ok, now that we have the governance and security controls in place we are not ready to start provisioning resources, right? Almost, a few more decisions need to get made if we are looking at rolling out Azure Kubernetes Service (AKS) to our environments.

## Next Steps

[Cluster Design](/cluster-design/README.md)

## Key Links

* [Onboard Azure Subscription to Security Center Standard](https://docs.microsoft.com/en-us/azure/security-center/security-center-get-started)
* [Collect Azure Activty Logs](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/activity-log-collect)
* [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview)
* [Azure Policy for AKS](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/rego-for-aks)
* [Azure Security Center (ASC)](https://docs.microsoft.com/en-us/azure/security-center/security-center-intro)
* [Detecting Threats Targeting Containers with ASC](https://azure.microsoft.com/en-us/blog/detecting-threats-targeting-containers-with-azure-security-center/)
* [Understand Azure Security Center Container Recommendations](https://docs.microsoft.com/en-us/azure/security-center/security-center-container-recommendations)
