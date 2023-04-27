// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

targetScope = 'managementGroup'

@description('The management group scope at which the policy definition exists. DEFAULT VALUE = "alz"')
param parPolicyManagementGroupId string = 'alz'

@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = false

@description('The base parameters to be passed to the policy definition for resource group name, location and tags.')
param parPolicyAssignmentParameters  object = {}

@description('The LZ parameters to be passed to the policy definition.')
param parPolicyAssignmentParametersLZ  object = {}

@description('The Alert Processing parameters to be passed to the policy definition.')
param parPolicAssignmentParametersAlertProcessing  object = {}

// Customer Usage Attribution Id
var varCuaid = 'd87415c4-01ef-4667-af89-0b5adc14af1b'

var varPolicyAssignmentParametersLZ = union(parPolicyAssignmentParameters, parPolicyAssignmentParametersLZ)

var varPolicyAssignmentParametersAlertProcessing = union(parPolicyAssignmentParameters, parPolicAssignmentParametersAlertProcessing)

module Deploy_Alerting_Management '../../infra-as-code/bicep/modules/policy/assignments/policyAssignmentManagementGroup.bicep' = {
  name: '${uniqueString(deployment().name)}-Alerting-LandingZones'
  params: {
    parPolicyAssignmentDefinitionId: '/providers/Microsoft.Management/managementGroups/${parPolicyManagementGroupId}/providers/Microsoft.Authorization/policySetDefinitions/Alerting-LandingZone'
    parPolicyAssignmentDisplayName: 'ALZ Monitoring Alerts for LandingZones'
    parPolicyAssignmentName: 'ALZ-Monitor_LandingZones'
    parPolicyAssignmentDescription: 'Initiative to deploy alerts relevant to the ALZ LandingZones management group'
    parPolicyAssignmentIdentityType: 'SystemAssigned'
    parPolicyAssignmentIdentityRoleDefinitionIds: [
      'b24988ac-6180-42a0-ab88-20f7382dd24c'
    ]
    parPolicyAssignmentParameters: varPolicyAssignmentParametersLZ
  }
}

module Deploy_AlertProcessing_rule '../../infra-as-code/bicep/modules/policy/assignments/policyAssignmentManagementGroup.bicep' = {
  name: '${uniqueString(deployment().name)}-AlertProcessing_rule'
  params: {
    parPolicyAssignmentDefinitionId: '/providers/Microsoft.Management/managementGroups/${parPolicyManagementGroupId}/providers/Microsoft.Authorization/policyDefinitions/Deploy_AlertProcessing_Rule'
    parPolicyAssignmentDisplayName: 'ALZ Monitoring Alert Processing rule'
    parPolicyAssignmentName: 'ALZ-AlertProcessing_rule'
    parPolicyAssignmentDescription: 'Initiative to deploy alert processing rule and action group in each subscription'
    parPolicyAssignmentIdentityType: 'SystemAssigned'
    parPolicyAssignmentIdentityRoleDefinitionIds: [
      'b24988ac-6180-42a0-ab88-20f7382dd24c'
    ]
    parPolicyAssignmentParameters: varPolicyAssignmentParametersAlertProcessing
  }
}

module modCustomerUsageAttribution './CRML/customerUsageAttribution/cuaIdManagementGroup.bicep' = if (!parTelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params //Only to ensure telemetry data is stored in same location as deployment. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  name: 'pid-${varCuaid}-${uniqueString(deployment().location)}'
  params: {}
}