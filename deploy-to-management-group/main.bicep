/* The team has started to ask you for new subscriptions on a near-daily basis, and it needs to apply its policies across all of them.

Create a new management group.
Create a new management group-scoped Bicep file.
Add the Azure Policy resources to the file.
Link the policy assignment to the policy definition by manually constructing the resource ID.
Deploy the template and verify the result.

Rather than duplicate the policy definitions and assignments in each subscription, you've decided to put all the team's subscriptions within a management group. You can then apply the policy to the entire management group instead of to each subscription individually. */

targetScope = 'managementGroup'

var policyDefinitionName = 'DenyFandGSeriesVMs'
var policyAssignmentName = 'DenyFandGSeriesVMs'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2024-05-01' = {
  name: policyDefinitionName
  properties: {
    policyType: 'Custom'
    mode: 'All'
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/sku.name'
                like: 'Standard_F*'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/sku.name'
                like: 'Standard_G*'
              }
            ]
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2024-05-01' = {
  name: policyAssignmentName
  properties: {
    policyDefinitionId: policyDefinition.id
  }
}
