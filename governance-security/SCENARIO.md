# Governance + Security Scenario

This section sets up and captures the scenario that we will be walking through over the next 2 days.

ContosoFinancial, a large Financial Services organization, provides banking and online services to its customers around the world. ContosoFinancial has 3 physical locations around the world (1 North America, 1 Western Europe, 1 Singapore) with each physical location connected to Azure via Express Route. They are also divided into 5 major line of business, each with their own cost center.

ContosoFinancial is a mature Azure customer with the majority of their existing workloads spanning their on-prem datacenters and Cloud, mostly leveraging IaaS VMs today. They are looking to take the next step in their Azure journey and achieve a greater level of agility and flexibility through the adoption of Microservices and Containers. They also recognize that there is huge momentum in the industry towards containers and Kubernetes as the container orchestrator. They want to take advantage of that momentum while at the same time look to see if they can reduce some of the management and operations overhead that currently exists with their IaaS VMs today. This is the main reason that ContosoFinancial is looking at Azure Kubernetes Service (AKS) as it aligns to their container strategy vision and is also a managed service which will help them reduce some of their existing technical debt around management and operations.

## Background

* Global Presence – Their customer base exists around the world so they will need presence in multiple countries/locations.
* High Availability – The customer workloads need to be highly available so that their customers are able to access their services such as online banking at anytime. They would like to know how they can handle scenarios where critical services/infrastructure in a particular region is unavailable for extended periods of time.
* Identity – ContosoFinancial is an existing O365 user today so they rely heavily on Azure AD for RBAC.
* Logging – The customer is currently using Log Analytics for their IaaS VM workloads and would like to continue to use that going forward for AKS if possible.
* Monitoring – ContosoFinancial uses DataDog today on*prem and would like to continue to use that with AKS so they have a single pane of glass. If we are recommending an alternative, help them understand how that migration is going to work.
* Alerting – ContosoFinancial would like to setup alerts so that key systems and components are monitored and reported upon when not functioning as expected. What are those key metrics?
* SIEM Integration – Security information needs to flow into QRadar, ContosoFinancial’s existing SIEM tool.
* Audit Reporting – In order to meet their regulatory needs, ContosoFinancial needs an audit of all requests made to AKS.
* Container Registry – Currently use Artifactory today for storing container images.
* Cost Mgmt – How does chargeback to the 5 different lines of business work?
* On-prem Connectivity – Although ContosoFinancial has moved a large majority of their workloads to the Cloud, there is still connectivity back to on-prem required. Connectivity back to on-prem requires getting IPs whitelisted to access certain services, as well as cert-based AuthN.
* Secrets Mgmt – ConstoFinancial uses Azure Key Vault today for storing secrets, certs and keys for disk encryption for example. What is the recommended way to expose sensitive information to the running containers?
* Certificate Authority (CA) – The desire is to leverage ContosoFinancials own CA when possible.
* Existing Azure Network – ConstosoFinancial has adopted a hub and spoke VNET architecture aligned to Virtual Data Center (VDC).
* On-prem to Cloud Connectivity with Express Route (ER) – Address space 10.0.0.0/16 is currently used on-premises and extended out to Azure through ER. ContosFinancial would like to use Azure CNI, but foresee a problem with running out of IP space.
* Share Clusters – ContosoFinancial wants to share a cluster out to multiple parties so need to be able to carve the resources up into logical buckets and assign RBAC permissions (RBAC & Namespace Setup).
* Container Registry – ContosoFinancial is currently partial to Artifactory as their container image repository as it provides the ability to have a single store that can be segmented via AuthZ using RBAC.
* Container Scanning – ContosoFinancial needs to be able to scan images as part of their DevOps pipeline along with scanning images at runtime for potential threats.
* Package Management – Looking for a process or tool to be able to easily deploy services to multiple environments.
* No Public IPs – ContosoFinancial does not want any public endpoints such as control plane endpoints or ssh access to any of the nodes. The only exception to this requirement is Public IPs for public facing workloads such as mobile app API backends.
* Blue/Green Deployments – ContosoFinancial wants to know the recommended practices with respect to AKS around doing blue/green deployment.
* Phased Rollouts – ContosoFinancial  wants to know the how to implement blue/green deployment with phased rollouts and rollback capabilities?

## Requirements

* Leverage Existing Identity Mgmt Solution
* Implement Security Least Privilege Principle
* Log Everything for Audit Reporting purposes
* Ensure Security Controls are being met (No Drifting)
* Monitoring and Alerting for SecurityEvents

  * Alert when SSH into Container
  * AKS Cluster has IP whitelisting set

* Integrate with Existing SIEM
* Deploy into Existing VNET with Ingress and Egress Restrictions
* Resources can only be created in specific regions due to data sovereignty
* Container Registry Whitelisting
* Ability to Chargeback to Line of Business
* Secrets Mgmt
* Container Image Mgmt
* Implement & Deploy Image Processing Application
* Easily rollout new versions of Application

## Next Steps

[Return to Governance and Security Setup](governance-security/README.md)

## Key Links

* ???
