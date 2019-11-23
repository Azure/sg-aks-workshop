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

Pull down cluster configuration file and try to execute a command, you should get prompted to authenticate to Azure AD.

```bash
# Grab K8s Config
az aks get-credentials -g $RG -n $PREFIX-aks

# Execute a Command
kubectl get nodes
```

![Azure AD Authentication)](/validate-scenarios/img/aad_authentication.png)

## Validate - Implement Security Least Privilege Principle

* Validate Cluster Reader cannot Create Resources

Authenticate to AKS using the cluster reader credentials and then try and execute a create command.

```bash
# Try to create a pod in the default namespace
kubectl run --generator=run-pod/v1 -it --rm centos2 --image=centos
```

![Cluster Reader)](/validate-scenarios/img/cluster_reader.png)

## Validate - Log Everything for Audit Reporting purposes

* Run log analytics query against AzureActivity table

Go into Azure Monitor for Containers -> Logs and get a summary of activity logs by Resource Provider.

```kusto
AzureActivity
| summarize AggregatedValue = count() by ResourceProvider
```

![Activity Logs Summary by Resource Provider)](/validate-scenarios/img/monitor_logs_activitylogs.png)

![Azure Monitor Logs Activity Log Query)](/validate-scenarios/img/monitor_logs_activity_logs.png)

## Validate - Ensure Security Controls are being met (No Drifting)

* Look at Flux Logs for GitOps style Drift Configuration. As you can see from the screenshot it detects whether something has changed or not.

![Flux Logs)](/validate-scenarios/img/flux_logs.png)

* Delete a resource and see it get re-created. Delete the Production NS and then wait upwards of 5 mins to see that Flux re-creates the resource.

```bash
kubectl delete ns production
kubectl logs -l app=sysdig-falco -n falco -f
```

## Validate - Monitoring and Alerting Events

* View Azure Security Center Compliance Dashboard

![Azure Security Center Compliance Dashboard)](/validate-scenarios/img/asc_compliance_dashboard.png)

* Exec into a Container and get an Alert

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: centos
spec:
  containers:
  - name: centoss
    image: centos
    ports:
    - containerPort: 80
    command:
    - sleep
    - "3600"
EOF
# Check that Pod is Created and then Exec In
kubectl get po -o wide
kubectl exec -it centos -- /bin/bash
curl www.ubuntu.com
exit
```

**Wait a few minutes for the log data to get processed and then go into the Azure Monitor Logs Workspace and execute the following query to see the log entry.**

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

**Similiar to the above we will run the following Azure Monitor queries against the Azure Security Center data to see which Policies are being met from a security perspective.**

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

**Go to the Azure Portal, click on Security Center, then on the Security Solutions blade.**

![Azure Security Center SIEM Integration)](/validate-scenarios/img/asc_security_solutions.png)

## Validate - Deploy into Existing VNET with Ingress and Egress Restrictions

* Validate Traffic In & Out of Cluster (North/South)

```bash
kubectl exec -it centos -- /bin/bash
curl http://superman.com
```

![North/South)](/validate-scenarios/img/north_south.png)

* Validate Traffic Restriction between Namespaces (East/West)

```bash
kubectl exec -it centos -- /bin/bash
curl http://imageclassifierweb.dev.svc.cluster.local
```

![East/West)](/validate-scenarios/img/east_west.png)

## Validate - Resources can only be created in specific regions due to data sovereignty

* Try to create resource outside of allowed region locations

```bash
kubectl exec -it centos -- /bin/bash
az storage account create --sku Standard_LRS --kind StorageV2 --location westus -g notinallowedregions-rg -n niarsa
```

![Create Storage in West US (Not in East US)](/validate-scenarios/img/azure_policy_not_allowed.png)

## Validate - Container Registry Whitelisting

* Try to pull from a non-whitelisted Container Registry

```bash
# Test out Allowed Registry Policy Against production Namespace
kubectl run --generator=run-pod/v1 -it --rm centosprod --image=centos -n production
```

![Gatekeeper Allowed Registries](/validate-scenarios/img/gatekeeper_allowed_registries.png)

## Validate - Ability to Chargeback to Line of Business

* View Chargeback Dashboard

```bash
# Do a port-forward to see Kubecost Dashboard
kubectl port-forward deployment/kubecost-cost-analyzer -n kubecost 9090
# Open in Browser
open "http://localhost:9090"
```

![Sample Kubecost Dashboard](/validate-scenarios/img/kubecost.png)

## Validate - Secrets Mgmt

* Check that there is no sensitive data stored in the container image or in a configuration file in plain text.

* The first place to start is looking at the application manifest file and we can see from looking at it that it is not storing credentials, it simply points to a Azure Key Vault Name.

```yaml
      containers:
      - name: imageclassifierweb
        image: kevingbb/imageclassifierweb:v3
        imagePullPolicy: Always
        env:
        - name: KeyVault__Vault
          valueFrom:
            secretKeyRef:
              name: image-akv-secret
              key: KeyVault__Vault
```

* The next step is to look inside the container to see if there is any configuration information.

```bash
# Exec into Web Container for Example
kubectl get pods -n dev
# Grab Pod Name and use to exec into Pod
kubectl exec -it imageclassifierweb-754f6d7b56-cx4hk -c imageclassifierweb /bin/sh
# OR
kubectl exec -it $(k get po -l=app=imageclassifierweb -o jsonpath="{.items[0].metadata.name}") /bin/sh
# Once inside of Pod Look Around
ls -al
# Exit Out
exit
```

![Secrets in Container](/validate-scenarios/img/secrets_exec.png)

* Check for Sensitive values in Key Vault

```bash
# Look at Secret Value in Key Vault
az keyvault secret show --name "AppSecret" --vault-name "contosofinakv"
```

![AppSecret in Key Vault](/validate-scenarios/img/secrets_akv.png)

![AppSecret in App](/validate-scenarios/img/secrets_app.png)

* So how does the secret get into the application then? Great question, it relies on Azure AD Pod Identity, or what we like to call Managed Pod Identity. Click [here](https://github.com/Azure/aad-pod-identity) for more details.

## Validate - Container Image Mgmt

* Check that container images in ACR are passing image scanning policy check.

```bash
# Wait for all images to be "analyzed"
anchore-cli image list

# Check for Active Subscriptions
anchore-cli subscription list

# Get Policies
anchore-cli policy list

# Evaluate against Policy (Pass or Fail)
anchore-cli evaluate check $ACR_NAME/imageclassifierweb:v1
anchore-cli evaluate check $ACR_NAME/imageclassifierworker:v1
```

![Anchore Pass or Fail](/validate-scenarios/img/anchore_scan.png)

## Validate - Implement & Deploy Image Processing Application

* Does the Application Run, Visit Public IP

![Running Application)](/validate-scenarios/img/app_running.png)

## Validate - Easily rollout new versions of Application

* Ensure the app successfully rolls out a new version of the application and does not cause any downtime.

```bash
# Check Deployment History
kubectl rollout history deploy imageclassifierweb -n dev
# Apply a new version of the application
kubectl apply -f appv3msi.yaml
# Watch the Rollout
kubectl rollout status deploy imageclassifierweb -n dev
# Check Deployment History Again
kubectl rollout history deploy imageclassifierweb -n dev
```

![Deployment Rollout](/validate-scenarios/img/rollout_app.png)

* Test the app to make sure it continues to work.

## Next Steps

[Thought Leadership](/thought-leadership/README.md)

## Key Links

* [Collect and Analyze Azure Activity Logs](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/activity-log-collect)
* [How to setup Azure Monitor for Container Alerts](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-alerts)
* [How to query logs from Azure Monitor for Containers](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-log-search)
* [How to update Azure Monitor for Containers to Enable Metrics](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-update-metrics)