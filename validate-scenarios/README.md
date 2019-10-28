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

## Validation

The rest of this section shows how we can validate the requirements above:

* Exec into a Container and get an Alert
* Try to pull from a non-whitelisted Container Registry
* Alert on Kubernetes Version
* Validate Traffic Restriction between Namespaces
* View Chargeback Dashboard
* Validate RBAC via Azure AD Login to a Namespace
* SSL Offloading happens at Ingress Controller
* View Application Telemetry Dashboard
* View Azure Security Center Compliance Dashboard
* Try to create Public IP
* Does the Application Run

## Next Steps

[Thought Leadership](/thought-leadership/README.md)

## Key Links

* ???