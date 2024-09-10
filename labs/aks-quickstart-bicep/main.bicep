var resourceSuffix = uniqueString(subscription().id, resourceGroup().id)

// MARK: AKS params
@description('The name of the Managed Cluster resource.')
param clusterName string

@description('The location of the Managed Cluster resource.')
param clusterLocation string = resourceGroup().location

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(100)
param nodePoolCount int = 1

@description('The size of the Virtual Machine for the node pool.')
param nodePoolVMSize string = 'standard_d2s_v3'

// MARK: AKS resource
resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: clusterLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: resourceSuffix
    agentPoolProfiles: [
      {
        name: 'nodepool'
        count: nodePoolCount
        vmSize: nodePoolVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
  }
}

// MARK: outputs
output controlPlaneFQDN string = aks.properties.fqdn
