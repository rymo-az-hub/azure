# Progress Evidence

## Naming
- whatif-<deployName>.json : az deployment group what-if output (json)
- deploy-<deployName>.json : az deployment group show output (json)
- deploy-ops-<deployName>.json : az deployment operation group list output (json)

## What-If noise (expected)
- diagnosticSettings/diag-to-law: logAnalyticsDestinationType and AzurePolicyEvaluationDetails (enabled=false) may appear as diffs
- privateDnsZoneGroups/default: etag/provisioningState/type are server-side properties (noise)