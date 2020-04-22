# Azure Security Controls Setup

In this section, we will walk through setting up the overarching security control framework specific to Azure. This section assumes organizational security controls have already been established; defining those security controls is out-of-scope for this workshop.

## Azure Security Control Architecture

All security controls in Microsoft Azure start with, and build on top of, the Azure Resource Manager (ARM) API. As you can see from the diagram below, there is a service in Azure called **Azure Policy** that helps enforce policies regardless of the origin of said policies.

![Security Control Architecture](/governance-security/img/EnterpriseControlPlaneArchitecture.png)

**Note: This is important because it means organizations do not have to define policies in multiple places.**

## Security Control Governance

One of the key benefits of leveraging a security control framework is its incorporation of governance and controls auditing. For Azure, in addition to Azure Policy, this includes [Azure Security Center](https://docs.microsoft.com/en-us/azure/security-center/security-center-intro) and its [Secure Score & Compliance](https://docs.microsoft.com/en-us/azure/security-center/security-center-secure-score) Dashboard features. Compliance, at its core, is all about governance observability. See the image below for a sample compliance dashboard: 

![Security Control Governance](/governance-security/img/EnterpriseControlPlaneGovernance.png)

## Implementing Security Controls using Security Controls Lifecycle

Within this workshop, we will implement just a subset of the security controls and Azure policies that would be included in a full Azure deployment. Once the process is understood, it is just a matter of rinsing and repeating to implement the additional security controls an organization might require. 

Based on the Contoso Financials scenario, we will be implement the following to meet requirements from security:
* Log All Cloud API requests for Audit Reporting purposes
* Enable AKS Cluster IP Whitelisting 
* AKS Clusters can only be created in certain regions

In the next sections, we will talk through implementing each of these controls.

## Capture Azure Audit Logs (Log all Cloud API requests for Audit Reporting purposes)

Azure Audit Logs are captured in something called [Azure Activity Logs](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/activity-logs-overview). These Activity Logs capture all Azure Resource Manager (ARM) interactions. The challenge is the activity logs only have a certain retention lifecycle. To combat this challenge, we need to export the data out of the Activity Logs into a more persistent storage location. For the purpose of this workshop, we will leverage Azure Monitor Logs.

Click [here](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/activity-log-collect) for a tutorial on how to get this setup for an Azure Subscription.

This is a sample screenshot of what it looks like when completed:

![Activity Log Capture](/governance-security/img/ActivityLogCapture.png)

## Enable Azure Security Monitoring (AKS Cluster IP Whitelisting Enabled)

Before we create anything, we should look to the Cloud Provider for security monitoring best practices and recommendations. Within Azure specifically, we can enable Azure Security Center (ASC) to gain visibility into such recommendations. By leveraging ASC, we can determine whether or not an AKS Cluster has IP Whitelisting (Authorized IP Ranges) enabled.

Note: not all security controls that an organization wants or requires will be implemented by the Cloud Provider. The key is to leverage what is provided to avoid reinventing the wheel, while creating custom controls only when they are unavilable. 

Click [here](https://docs.microsoft.com/en-us/azure/security-center/security-center-get-started) for an article on how to enable Security Center Standard for an Azure Subscription.

This is a sample screenshot of what it looks like when completed:

![SecurityCenterStandard](/governance-security/img/SecurityCenterStandard.png)

## Security Enforcement through Azure Policy (AKS Clusters can only be created in certain regions)

Similar to the point above around security, we should be looking to the Cloud Provider to see what they provide for policy enforcement.  Within Azure, this would mean evaluating Azure Policy; it is a key part of the Enterprise Control Plane (ECP) that we talked about on the previous page.

The ability to restrict resource creation to a specific region is just one of many Azure Policies that are available. The two links below contain more thorough samples of what can be done with Azure Policy:

* [Azure Policy Samples](https://docs.microsoft.com/en-us/azure/governance/policy/samples/)
* [Azure Policy Security Samples](https://docs.microsoft.com/en-us/azure/security-center/security-center-policy-definitions)

Reminder: not everything can be done with Azure Policy. The key is to leverage what is provided to avoid reinventing the wheel, while creating custom controls only when they are unavilable. 

Click [here](https://docs.microsoft.com/en-us/azure/governance/policy/samples/allowed-locations) for guidance on how to implement allowed region locations via Azure Policy.

These are sample screenshots of the flow you will go through:

![Azure Policy Definitions](/governance-security/img/PolicyDefinitions.png)

![Assign Policy Definition to Resource](/governance-security/img/AssignPolicy.png)

![Assign Policy Basics](/governance-security/img/AssignPolicyBasics.png)

![Assign Policy Parameters](/governance-security/img/AssignPolicyParameters.png)

![Assign Policy Create](/governance-security/img/AssignPolicyCreate.png)

![Azure Policy Assignments](/governance-security/img/PolicyAssignment.png)

## Wrapping Up

Ok, now that we have implemented a few security and governance controls, we are ready to start provisioning resources, right? Almost!
A few more decisions need to be made before we roll out Azure Kubernetes Service (AKS) to our environments.

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
