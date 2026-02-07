targetScope = 'resourceGroup'

@description('Existing Key Vault name')
param keyVaultName string

@description('Optional: objectIds for break-glass administrators (should be small, ideally a group)')
param kvAdmins array = []

@description('Optional: objectIds for secrets operators (create/update/delete secrets)')
param secretsOfficers array = []

@description('Optional: objectIds for secrets readers (get/list secrets) - app MI / CI/CD MI / runtime identities')
param secretsUsers array = []

@description('Optional: objectIds for read-only viewers of the Key Vault resource (control-plane visibility only)')
param kvReaders array = []

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Role definition IDs (built-in)
var roleKvAdmin = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483') // Key Vault Administrator
var roleSecretsOfficer = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7') // Key Vault Secrets Officer
var roleSecretsUser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
var roleReader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7') // Reader

// NOTE:
// - Microsoft.Authorization/roleAssignments does NOT reliably support tags across API versions.
// - To avoid deployment failure, we do not set tags on roleAssignment resources.

resource raKvAdmins 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalId in kvAdmins: {
  name: guid(kv.id, principalId, roleKvAdmin)
  scope: kv
  properties: {
    roleDefinitionId: roleKvAdmin
    principalId: principalId
  }
}]

resource raSecretsOfficers 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalId in secretsOfficers: {
  name: guid(kv.id, principalId, roleSecretsOfficer)
  scope: kv
  properties: {
    roleDefinitionId: roleSecretsOfficer
    principalId: principalId
  }
}]

resource raSecretsUsers 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalId in secretsUsers: {
  name: guid(kv.id, principalId, roleSecretsUser)
  scope: kv
  properties: {
    roleDefinitionId: roleSecretsUser
    principalId: principalId
  }
}]

resource raKvReaders 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalId in kvReaders: {
  name: guid(kv.id, principalId, roleReader)
  scope: kv
  properties: {
    roleDefinitionId: roleReader
    principalId: principalId
  }
}]
