# Control Setup

In this section we will walk through setting up the overarching security controls that we want in place regardless of technology.

## Quick recap of Security Controls to be Implemented

Just a quick refresher so you don't have to navigate between pages:

* Log All Cloud API requests for Audit Reporting purposes
* AKS Cluster has IP whitelisting set
* AKS Clusters can only be created in certain regions

Now that we know what controls we need to meet, how do we do that? The next sections will talk through implementing each of these controls.

## Capture Azure Audit Logs (Log All Cloud API requests for Audit Reporting purposes)

For those that are not aware, Azure Audit Logs are captured in something called Azure Activity Logs. The Activity Logs capture all of the Azure Resource Manager (ARM) interactions. The challenge is that the activity logs only have a certain retention lifecycle so we need to get the data out of the Activity Logs into something more permance, for the purposes of this workshop it will be Azure Monitor Logs.

Click [here](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/activity-log-collect) for an article on how to get this setup for an Azure Subscription.

This is a sample screenshot of what it looks like when completed:

![Activity Log Capture](/governance-security/img/ActivityLogCapture.png)

## Enable Azure Security Monitoring (AKS Cluster IP Whitelisting Enabled)

Before we create anything we should be looking to the Cloud Provider as to what they recommend with respect to security monitoring. In the case of Azure this means enabling Azure Security Center so you get visibility in the recommendations provided by the Cloud Provider.

The ability to monitor whether or not an AKS Cluster has IP Whitelisting (Authorized IP Ranges) enabled or it is one such security policy that Azure Security Center checks for.

A word of caution here, not all security controls that an organization wants will be able to be implemented by the Cloud Provider. The key to success here is to look at what is provided so you are not reinventing the wheel, leverage what is there to reduce technical debt. And for the pieces that are not there, you will need to build that out.

Click [here](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/activity-log-collect) for an article on how to enable Security Center Standard for an Azure Subscription.

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

![Azure Policy Assignments](/governance-security/img/PolicyAssignments.png)

## Wrapping Up

Ok, now that we have the governance and security controls in place we are not ready to start provisioning resources, right? Almost, a few more decisions need to get made if we are looking at rolling out Azure Kubernetes Service (AKS) to our environments.

## Next Steps

[Cluster Pre-Provisioning](/cluster-pre-provisioning/README.md)

## Key Links

* [Onboard Azure Subscription to Security Center Standard](https://docs.microsoft.com/en-us/azure/security-center/security-center-get-started)
* [Collect Azure Activty Logs](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/activity-log-collect)
* [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview)
* [Azure Policy for AKS](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/rego-for-aks)
* [Azure Security Center (ASC)](https://docs.microsoft.com/en-us/azure/security-center/security-center-intro)
* [Detecting Threats Targeting Containers with ASC](https://azure.microsoft.com/en-us/blog/detecting-threats-targeting-containers-with-azure-security-center/)
* [Understand Azure Security Center Container Recommendations](https://docs.microsoft.com/en-us/azure/security-center/security-center-container-recommendations)
* [Enable Kubernetes Logs](https://docs.microsoft.com/en-us/azure/aks/view-master-logs)
