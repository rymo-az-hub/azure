# Commands used on Day 2 (summary) / Day2コマンド一覧

This is a quick reference of the commands used during Day 2 work.
PowerShell is assumed. Azure CLI commands start with `az`.

Day2で使用したコマンドの早見表です。
PowerShell前提。Azure CLIは `az` で始まります。

---

## Azure context / 認証・コンテキスト確認

az account show --query "{name:name,id:id,user:user.name}" -o jsonc

az bicep version

az bicep build --file ".\infra\platform\cost\budget.bicep"

---

## Budget (subscription scope) / 予算 (サブスクスコープ)

# what-if
az deployment sub what-if `
  --name "alz-budget-baseline-v1" `
  --location "japaneast" `
  --template-file ".\infra\platform\cost\budget.bicep" `
  --parameters `
    budgetName="bg-platform-baseline-v1" `
    amount=200 `
    timeGrain="Monthly" `
    startDate="2026-02-01T00:00:00Z" `
    endDate="2030-12-31T00:00:00Z" `
    contactEmail="<mail>" `
    threshold1=80 `
    threshold2=100

# create
az deployment sub create `
  --name "alz-budget-baseline-v1" `
  --location "japaneast" `
  --template-file ".\infra\platform\cost\budget.bicep" `
  --parameters `
    budgetName="bg-platform-baseline-v1" `
    amount=200 `
    timeGrain="Monthly" `
    startDate="2026-02-01T00:00:00Z" `
    endDate="2030-12-31T00:00:00Z" `
    contactEmail="<mail>" `
    threshold1=80 `
    threshold2=100 `
  --query "properties.provisioningState" -o tsv

# verify
az consumption budget show --budget-name "bg-platform-baseline-v1" -o jsonc

---

## Activity Log -> Log Analytics (subscription scope + module) / 監査ログ基盤

# (PowerShell) temp params file for tags (avoid JSON escaping issues)
@'
{
  "tags": {
    "value": {
      "Owner": "Ryosuke",
      "CostCenter": "000",
      "Environment": "dev"
    }
  }
}
'@ | Out-File -Encoding utf8 .\tmp-monitoring-tags.json

# deploy
az deployment sub create `
  --name "alz-activitylog-baseline-v1" `
  --location "japaneast" `
  --template-file ".\infra\platform\monitoring\activitylog-to-law.bicep" `
  --parameters `
    createLogAnalytics=true `
    logAnalyticsRgName="rg-platform-monitoring" `
    logAnalyticsWorkspaceName="law-platform-baseline" `
    location="japaneast" `
    retentionInDays=30 `
    activityLogDiagName="ds-activitylog-to-law" `
    .\tmp-monitoring-tags.json `
  --query "properties.provisioningState" -o tsv

# verify diagnostic settings (subscription)
az monitor diagnostic-settings subscription show --name "ds-activitylog-to-law" -o jsonc
az monitor diagnostic-settings subscription list -o jsonc

# verify workspace
az monitor log-analytics workspace show `
  --resource-group "rg-platform-monitoring" `
  --workspace-name "law-platform-baseline" -o jsonc

# (deeper verification) REST fetch (full properties)
$subId = "<subscriptionId>"
az rest `
  --method get `
  --url "https://management.azure.com/subscriptions/$subId/providers/Microsoft.Insights/diagnosticSettings/ds-activitylog-to-law?api-version=2021-05-01-preview" `
  -o jsonc

---

## Log Analytics (KQL) / ログ流入確認（ポータル）

AzureActivity
| where TimeGenerated > ago(24h)
| project TimeGenerated, OperationNameValue, ActivityStatusValue, ResourceGroup, ResourceId
| order by TimeGenerated desc
| take 5
