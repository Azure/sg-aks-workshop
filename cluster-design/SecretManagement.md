# Secret Management

There are different options for storing, managing and integrating secrets like configuration settings, connection strings and certificates for Kubernetes in Azure we want to compare and validate against different requirements:

1. Using the plain Kubernetes secrets model
2. Using the plain Kubernetes secrets model but encrypt the data in *etcd* using Azure KeyVault and the KMS plugin for Azure Key Vault
3. Using the plain Kubernetes secrets but storing encrypted values in the Kubernetes secrets which are only encrypted at runtime
4. Using Azure KeyVault for storing secrets and certificates and mounting them into a Kubernetes volume using the KeyVault FlexVolume driver.

## Native Kubernetes secrets

While the first option of using Kubernetes native secret management has the obvious advantage of simplified operations it incurs the risk of credential leakage if your cluster is breached or someone with existing cluster access uses his privileges to access to retrieve connections strings and secrets. Therefore this approach requires the lockdown of access to secrets via RBAC and a good way of recycling and upgrading secret information on a regular basis. It assumes that RBAC is turned on and all workloads are deployed into dedicated namespaces, while users and service accounts are configured to use minimal privileges within their scope. Since secrets and certificates should not be part of the normal source control repository it requires an additional process to deploy and upgrade secret values and certificates.

Tradeoffs to be made:

- native Kubernetes secrets are easy to understand and use
- native Kubernetes secrets are compatible with existing ecosystems
- native Kubernetes secretes hard to implement in a secure process involving continuous deployment and upgrading
- native Kubernetes secrets have no audit trail on secret usage

## KMS plugin for Azure KeyVault

The KMS plugin for Azure KeyVault allows encryption of data at rest that is stored in *etcd*. This scenario enabled the encryption of secrets and certificates with an encryption key that is stored in an instance of Azure KeyVault which is under the control of the customer. It ensures that normal Kubernetes objects can be used and does not make any assumptions on implementation patterns for the applications. While AKS ensures encryption at rest of the data in etcd, it does not allow the usage of a customer-managed key. Since AKS does not support the usage of the KMS plugin, this means that the usage of KMS plugin forces the deployment of a cluster on unmanaged IaaS or AKS-Engine, where customers can fully control and own the configuration of etcd.

**For further documentation click [here](https://github.com/Azure/kubernetes-kms)**

Tradeoffs to be made:

- KMS plugin allows to ensure that all configuration data and secrets in *etcd* are encrypted with a customer-managed key
- KMS does not require and changes to the application - native Kubernetes can be used
- KMS plugin is **not** supported with managed AKS
- KMS plugin does not support key rotation scenarios.

## Sealed Secrets

The objective for using sealed secrets is to allow for an automated process to frequently replace secret values in Kubernetes. Therefore the cleartext values are encrypted before deployment into a Kubernetes custom resource and deployed into the right namespaces in the cluster in an encrypted format. After deployment a custom controller will read the encrypted value and create an unencrypted secret within the same namespace that can now be used as expected by the pods. This process allows decoupling of responsibilities and a secure delivery mechanism for the deployment of secrets while ensuring compatibility with the Kubernetes object model.

**For further documentation click [here](https://github.com/bitnami-labs/sealed-secrets)**

Tradeoffs to be made:

- Sealed secrets allows separation of concerns and permissions through an automated process
- Sealed secrets uses automatable tools that are only handling encrypted values
- Sealed secrets requires a custom resource definition and custom tools to handle de/encryption

## Azure KeyVault FlexVolume

The usage of the Azure KeyVault Flexvolume ensures that all secret values are stored outside of the Kubernetes cluster and can be updated through an external process independant of the application deployments. All secret values will be retrieved for each pod after it has successfully authentication to the KeyVault and mounted into a memory drive which will not be persisted inside the cluster. In combination with the AAD Pod Identity this allows for a very fine granular process of granting permissions to individual applications and changing them frequently. Since only memory values can be mounted into a pod this does not allow the usage of environment variables that are injected from Azure KeyVault values.

For further documentation see: [flexvol](https://github.com/Azure/kubernetes-keyvault-flexvol)
After Kubernetes 1.16+ the same behavior will be achievable using the secret store driver: [CSI driver](https://github.com/Azure/secrets-store-csi-driver-provider-azure)

Tradeoffs to be made:

- Azure KeyVault FlexVolume stores secrets outside of the cluster and decouples the deployment of secrets from the application deployment
- Azure KeyVault FlexVolume allows individual permission assignment on pod level through AAD Pod Identity
- Azure KeyVault FlexVolume makes use of memory drive and does not work for environment variables
- Azure KeyVault FlexVolume requires custom resource definitions

## Next Steps

[Cluster Design](/cluster-design/README.md)

## Key Links

- [AKS and Kubernetes Secrets](https://docs.microsoft.com/en-us/azure/aks/concepts-security#kubernetes-secrets)
