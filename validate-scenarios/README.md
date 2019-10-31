# Validate Scenarios

Now that we have implemented everything, let's go back and revisit our requirements and make sure they have been met.

## Requirements

This is a quick recap of the requirements:

* Leverage Existing Identity Mgmt Solution
* Implement Security Least Privilege Principle
* Log Everything for Audit Reporting purposes
* Ensure Security Controls are being met (No Drifting)
* Monitoring and Alerting Events

  * Alert when SSH into Container
  * AKS Cluster has IP whitelisting set

* Integrate with Existing SIEM
* Deploy into Existing VNET with Ingress and Egress Restrictions
* Resources can only be created in specific regions due to data sovereignty
* Container Registry Whitelisting
* Ability to Chargeback to Line of Business
* Secrets Mgmt
* Container Image Mgmt
* Restrict Creation of Public IPs
* Implement & Deploy Image Processing Application
* Easily rollout new versions of Application

The rest of these sections shows how we can validate the requirements above:

## Validate - Leverage Existing Identity Mgmt Solution

* Log into AKS Cluster with Azure AD Credentials

![Azure AD Authentication)](/validate-scenarios/img/aad_authentication.png)

## Validate - Implement Security Least Privilege Principle

* Validate Cluster Reader cannot Create Resources

![Cluster Reader)](/validate-scenarios/img/cluster_reader.png)

## Validate - Log Everything for Audit Reporting purposes

* Run log analytics query against AzureActivity table

```kusto
AzureActivity
| summarize AggregatedValue = count() by ResourceProvider
```

![Activity Logs Summary by Resource Provider)](/validate-scenarios/img/monitor_logs_activitylogs.png)

![Azure Monitor Logs Activity Log Query)](/validate-scenarios/img/monitor_logs_activity_logs.png)

## Validate - Ensure Security Controls are being met (No Drifting)

* Look at Flux Logs for GitOps Style Drifting

![Flux Logs)](/validate-scenarios/img/flux_logs.png)

## Validate - Monitoring and Alerting Events

* View Azure Security Center Compliance Dashboard

![Azure Security Center Compliance Dashboard)](/validate-scenarios/img/asc_compliance_dashboard.png)

* Exec into a Container and get an Alert

```kusto
let startTimestamp = ago(1d);
let ContainerIDs = KubePodInventory
| where TimeGenerated > startTimestamp
| where ClusterId =~ "/subscriptions/${SUBID}/resourceGroups/${RG}/providers/Microsoft.ContainerService/managedClusters/${CLUSTER_NAME}"
| where Name contains "sysdig-falco"
| distinct ContainerID;
ContainerLog
| where ContainerID in (ContainerIDs)
| where LogEntry contains "Notice A shell was spawned"
| project LogEntrySource, LogEntry, TimeGenerated, Computer, Image, Name, ContainerID
| order by TimeGenerated desc
| limit 200
```

![Azure Monitor Logs SSH Query)](/validate-scenarios/img/monitor_logs_ssh.png)

* AKS Cluster missing IP Whitelisting

```kusto
AzureActivity
| where CategoryValue == 'Policy' and Level != 'Informational'
| where ResourceProvider == "Microsoft.ContainerService" 
| extend p=todynamic(Properties)
| extend policies=todynamic(tostring(p.policies))
| mvexpand policy = policies
| summarize resource_count=count() by tostring(policy.policyDefinitionName),tostring(policy.policyDefinitionReferenceId)
```

![Azure Monitor Logs Policy Out of Compliance Query)](/validate-scenarios/img/monitor_logs_outofcompliance.png)

```kusto
// Check for Authorized IP Policy
let policyDefId = '0e246bcf-5f6f-4f87-bc6f-775d4712c7ea';
AzureActivity
| where CategoryValue == 'Policy' and Level != 'Informational'
| where ResourceProvider == "Microsoft.ContainerService"
| extend p=todynamic(Properties)
| extend policies=todynamic(tostring(p.policies))
| mvexpand policy = policies
| where policy.policyDefinitionName in (policyDefId)
| distinct ResourceId
```

![Azure Monitor Logs Authorized IP Query)](/validate-scenarios/img/monitor_logs_authorizedip.png)

## Validate - Integrate with Existing SIEM

* View Azure Security Center Security Solutions

![Azure Security Center SIEM Integration)](/validate-scenarios/img/asc_security_solutions.png)

## Validate - Deploy into Existing VNET with Ingress and Egress Restrictions

* Validate Traffic In & Out of Cluster (North/South)

![North/South)](/validate-scenarios/img/north_south.png)

* Validate Traffic Restriction between Namespaces (East/West)

![East/West)](/validate-scenarios/img/east_west.png)

## Validate - Resources can only be created in specific regions due to data sovereignty

* Try to create resource outside of allowed region locations

![Create Storage in West US (Not in East US)](/validate-scenarios/img/azure_policy_not_allowed.png)

## Validate - Container Registry Whitelisting

* Try to pull from a non-whitelisted Container Registry

???

## Validate - Ability to Chargeback to Line of Business

* View Chargeback Dashboard

## Validate - Secrets Mgmt

* ???

## Validate - Container Image Mgmt

* ???

## Validate - Implement & Deploy Image Processing Application

* Does the Application Run, Visit Public IP

![Running Application)](/validate-scenarios/img/app_running.png)

## Validate - Easily rollout new versions of Application

* ???

## Next Steps

[Thought Leadership](/thought-leadership/README.md)

## Key Links

* [Collect and Analyze Azure Activity Logs](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/activity-log-collect)