# Policy Baseline

## Purpose
Platform Landing Zoneとして、最低限のガードレールを提供し、  
セキュリティ・運用性・コスト統制の土台を確立する。

## Where to apply (scope)
- Platform: 共通基盤ルール（監視/診断、タグ、コスト統制）を強制
- Landing zones (Corp/Online): ワークロード向け最小ガードレールを強制
- Sandbox: 制限は緩めるが、コスト統制（Budget/アラート）は強める

> Note: 個人Azure環境の権限制約によりManagement Groupが利用できないため、現状はサブスクリプションスコープで代替実装している。

## Exception policy (how to handle)
- 例外は期限付き（例：30日）で発行し、期限前に棚卸し
- 例外理由・影響範囲・代替案・恒久対応の計画を必須入力
- 例外は「誰が承認し、どこに記録するか」を明確化する（運用プロセスへ）

## Initial Policy Set (v1)
> まずは「事故りやすい／効果が高い」ものから10個に絞る

### 1. Required Tags
- Enforce: Owner, CostCenter, Environment
- Why: コスト追跡/責任分界点の明確化
- Notes: 現状はサブスクリプション一括適用（例外運用は今後実装）

**Implementation (current)**
- Azure Policy Initiative Assignment (subscription scope)
  - `pa-platform-baseline-v1`
- Policy set (initiative)
  - `ps-platform-baseline-v1`
- Included policy definitions (references)
  - Require a tag on resources  
    `/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99`
  - Require a tag on resource groups  
    `/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025`

### 2. Allowed Locations (Region Restriction)
- Enforce: Japan East / Japan West only
- Why: データ所在地、運用統一、コスト見積もり容易化

**Implementation (current)**
- Azure Policy Initiative Assignment (subscription scope)
  - `pa-platform-baseline-v1`
- Policy set (initiative)
  - `ps-platform-baseline-v1`
- Included policy definition (reference)
  - Allowed locations  
    `/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c`
- Parameters (initiative reference)
  - `listOfAllowedLocations = ["japaneast","japanwest"]`

### 3. Budget & Cost Alerts (Subscription level)
- Enforce: 月額上限＋閾値アラート（80/100%）
- Why: 個人環境でも「運用として」必須（コスト暴走の早期検知）

**Implementation (current)**
- ARM deployment (subscription scope)
  - `alz-budget-baseline-v1`
- Budget resource
  - `bg-platform-baseline-v1` (`Microsoft.Consumption/budgets`)
- IaC
  - `infra/platform/cost/budget.bicep`


### 4. Diagnostic Settings for Activity Log
- Enforce: Activity Log → Log Analytics
- Why: 監査/インシデント調査の土台


**Implementation (current)**
- ARM deployment (subscription scope)
  - `alz-activitylog-baseline-v1`
- Diagnostic settings (subscription scope)
  - `ds-activitylog-to-law` (`Microsoft.Insights/diagnosticSettings`)
- Destination
  - Log Analytics workspace `law-platform-baseline` (RG: `rg-platform-monitoring`)
- IaC
  - `infra/platform/monitoring/activitylog-to-law.bicep`
  - `infra/platform/monitoring/log-analytics.bicep` (module)

### 5. Diagnostic Settings for Key Resources
- Enforce: 対象リソースの診断ログをLog Analyticsへ（段階的に拡張）
- Why: 「監視できない」状態を防ぐ

### 6. Public IP Restriction
- Enforce: Public IP の作成を禁止（例外運用あり）
- Why: 露出面削減、事故防止

**Implementation (current)**
- Azure Policy Initiative Assignment (subscription scope)
  - `pa-platform-baseline-v1`
- Policy set (initiative)
  - `ps-platform-baseline-v1`
- Included policy definition (reference)
  - Not allowed resource types  
    `/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749`
- Parameters (initiative reference)
  - `listOfResourceTypesNotAllowed = ["Microsoft.Network/publicIPAddresses"]`
  - `effect = Deny`

### 7. Storage Secure Transfer Required
- Enforce: StorageはHTTPS必須
- Why: 基本的なセキュリティベースライン

### 8. Key Vault Soft Delete / Purge Protection
- Enforce: Key Vaultでデータ損失を防ぐ設定
- Why: 誤削除/ランサム対策の基礎

### 9. Allowed VM SKUs (Cost Control)
- Enforce: 許可SKUを限定（高額SKU禁止）
- Why: コスト暴走防止、標準化

### 10. Deny Classic Resources (if applicable)
- Enforce: 旧式/非推奨リソースの禁止（利用する場合は理由を明記）
- Why: 運用品質と将来負債の抑制

## Evidence (Policy Enforcement)

> Consolidation note: Legacy single policy assignments (pa-require-*, pa-allowed-locations, pa-secure-transfer-storage, etc.) were removed after validation.  
> Baseline deny guardrails in this document are enforced via the initiative assignment `pa-platform-baseline-v1` (subscription scope) for consistent evidence and simplified operations.
>
> Note: A built-in Security Center / Defender for Cloud assignment (`SecurityCenterBuiltIn`, audit-focused) may also exist at subscription scope. It is not part of this baseline.

### 0. Evidence summary (current state)

- Enforcement vehicle (baseline deny guardrails):
  - `pa-platform-baseline-v1` (initiative assignment at subscription scope) => `ps-platform-baseline-v1`
- Verified controls in this baseline:
  - [x] Required tags (resources / resource groups) => deny when missing required tags
  - [x] Allowed locations => deny when deploying to a disallowed region
  - [x] Secure transfer (Storage Accounts) => deny when HTTPS-only is disabled
  - [x] Public IP restriction => deny when creating Public IP resources
  - [x] Budget & cost alerts => subscription-level budget with threshold notifications (IaC)
  - [x] Activity Log → Log Analytics => subscription activity logs are queryable in Log Analytics (`AzureActivity`)
- Policy set contents (reference IDs observed):
  - `allowedLocations`
  - `secureTransferStorage`
  - `requireTag-owner` / `requireTag-costcenter` / `requireTag-environment`
  - `requireRgTag-owner` / `requireRgTag-costcenter` / `requireRgTag-environment`
  - `denyResourceTypes-publicip`
- Current subscription-scope assignments (observed):
  - `pa-platform-baseline-v1` => `ps-platform-baseline-v1` (custom initiative; deny guardrails)
  - `SecurityCenterBuiltIn` => `ASC Default (...)` (built-in initiative; audit-focused)

---

### 1. Required Tags (via initiative)

#### Deny (Policy Set): Creating a Resource Group without required tags

**Attempt (command)**

```bash
az group create -n rg-ps-baseline-notags -l japaneast
```

**Result**
- Denied with: `RequestDisallowedByPolicy`
- Triggered assignment:
  - `pa-platform-baseline-v1` (Platform Baseline v1 (subscription))
- Triggered initiative:
  - `ps-platform-baseline-v1` (Platform Baseline v1)
- Policy definition:
  - `Require a tag on resource groups`
  - `/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025`

**Observed behavior**
- Resource group creation is denied when any of the required tags (Owner/CostCenter/Environment) is missing.

#### Allowed: Creating a Resource Group with required tags

**Attempt (command)**

```bash
az group create -n rg-policy-test -l japaneast --tags Owner=Ryosuke CostCenter=000 Environment=dev
```

**Result**
- Succeeded when all required tags were provided.

#### Deny (Policy Set): Creating a VNet without required tags (even when the RG has tags)

**Attempt (command)**

```bash
az network vnet create -g rg-policy-test -n vnet-ps-notags -l japaneast --address-prefixes 10.20.0.0/16
```

**Result**
- Denied with: `RequestDisallowedByPolicy`
- Triggered assignment:
  - `pa-platform-baseline-v1` (Platform Baseline v1 (subscription))
- Triggered initiative:
  - `ps-platform-baseline-v1` (Platform Baseline v1)
- Policy definition:
  - `Require a tag on resources`
  - `/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99`

**Observed behavior**
- Resource creation is denied when any of the required tags (Owner/CostCenter/Environment) is missing, even if the parent resource group is tagged.

---

### 2. Allowed Locations (via initiative)

#### Deny (Policy Set): Creating a VNet in a disallowed region

**Attempt (command)**

```bash
az network vnet create -g rg-policy-test -n vnet-badregion -l eastus --address-prefixes 10.23.0.0/16 --tags Owner=Ryosuke CostCenter=000 Environment=dev
```

**Result**
- Denied with: `RequestDisallowedByPolicy`
- Triggered assignment:
  - `pa-platform-baseline-v1` (Platform Baseline v1 (subscription))
- Triggered initiative:
  - `ps-platform-baseline-v1` (Platform Baseline v1)
- Policy definition:
  - `Allowed locations`
  - `/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c`

**Observed behavior**
- VNet creation is denied when the deployment region is outside the allowed locations list, even if required tags are provided.

---

### 3. Secure transfer (Storage Accounts) (via initiative)

#### Deny (Policy Set): Creating a Storage Account with secure transfer disabled (HTTPS-only = false)

**Attempt (command)**

```bash
az storage account create -n st9989336 -g rg-policy-test-storage -l japaneast --sku Standard_LRS --https-only false --tags Owner=Ryosuke CostCenter=000 Environment=dev
```

**Result**
- Denied with: `RequestDisallowedByPolicy`
- Triggered assignment:
  - `pa-platform-baseline-v1` (Platform Baseline v1 (subscription))
- Triggered initiative:
  - `ps-platform-baseline-v1` (Platform Baseline v1)
- Policy definition:
  - `Secure transfer to storage accounts should be enabled`
  - `/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9`
- Policy effect: `Deny`
- Evaluated expression:
  - `properties.supportsHttpsTrafficOnly == false`

**Observed behavior**
- Storage account creation is denied when HTTPS-only (secure transfer) is disabled.

#### Allowed: Creating a Storage Account with secure transfer enabled (HTTPS-only = true)

**Attempt (command)**

```bash
az storage account create -n st4611269 -g rg-policy-test-storage -l japaneast --sku Standard_LRS --https-only true --tags Owner=Ryosuke CostCenter=000 Environment=dev
```

**Result**
- Succeeded  
- Observed properties:
  - `enableHttpsTrafficOnly: true`

**Observed behavior**
- Storage account creation succeeds when HTTPS-only (secure transfer) is enabled.

---

### 4. Public IP Restriction (via initiative)

**Control**
- Initiative assignment (subscription scope): `pa-platform-baseline-v1`
- Policy set (initiative): `ps-platform-baseline-v1`
- Policy definition (built-in): `Not allowed resource types`
  - `/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749`
- Initiative reference parameterization (expected):
  - `listOfResourceTypesNotAllowed = ["Microsoft.Network/publicIPAddresses"]`
  - `effect = Deny`

#### Verified initiative parameterization (denyResourceTypes-publicip)

**Attempt (command)**

```bash
az policy set-definition show --name ps-platform-baseline-v1 --query "policyDefinitions[?policyDefinitionReferenceId=='denyResourceTypes-publicip'].parameters" -o jsonc
```

**Result**
- Confirmed parameters:
  - `effect: Deny`
  - `listOfResourceTypesNotAllowed: ["Microsoft.Network/publicIPAddresses"]`

#### Deny (Policy Set): Creating a Public IP address

**Attempt (command)**

```bash
az network public-ip create -g rg-policy-test -n pip-denied-01 -l japaneast --sku Standard --allocation-method Static --tags Owner=Ryosuke CostCenter=000 Environment=dev
```

**Result**
- Denied with: `RequestDisallowedByPolicy`
- Triggered assignment:
  - `pa-platform-baseline-v1` (Platform Baseline v1 (subscription))
- Triggered initiative:
  - `ps-platform-baseline-v1` (Platform Baseline v1)
- Policy definition:
  - `Not allowed resource types`
  - `/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749`
- Policy definition version (observed in denial):
  - `2.0.0`

**Observed behavior**
- Public IP resource creation is denied even when required tags are provided, because the resource type is explicitly disallowed by the baseline.

**Optional verification**
- The denied resource is not created.

```bash
az network public-ip list -g rg-policy-test -o table
```

---

### 5. Budget & Cost Alerts (IaC)

**Control**
- Resource type: `Microsoft.Consumption/budgets`
- Budget name: `bg-platform-baseline-v1`
- Scope: subscription (`/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368`)
- Time grain: `Monthly`
- Amount: `200.0`
- Notifications (Actual GreaterThan): `80%`, `100%`
- Recipient: `risuke.fxpad@gmail.com`
- Time period: `2026-02-01T00:00:00Z` → `2030-12-31T00:00:00Z`

**Attempt (command)**

```powershell
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
    contactEmail="risuke.fxpad@gmail.com" `
    threshold1=80 `
    threshold2=100 `
  --query "properties.provisioningState" -o tsv
```

**Result**
- Deployment result: `Succeeded`

```text
Succeeded
```

- Budget details were verified via CLI

```powershell
az consumption budget show --budget-name "bg-platform-baseline-v1" -o jsonc
```

```json
{
  "amount": "200.0",
  "category": "Cost",
  "currentSpend": {
    "amount": "0.0",
    "unit": "JPY"
  },
  "id": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Consumption/budgets/bg-platform-baseline-v1",
  "name": "bg-platform-baseline-v1",
  "notifications": {
    "actual_GreaterThan_100_Percent": {
      "contactEmails": [
        "risuke.fxpad@gmail.com"
      ],
      "contactGroups": [],
      "contactRoles": [],
      "enabled": true,
      "operator": "GreaterThan",
      "threshold": "100.0"
    },
    "actual_GreaterThan_80_Percent": {
      "contactEmails": [
        "risuke.fxpad@gmail.com"
      ],
      "contactGroups": [],
      "contactRoles": [],
      "enabled": true,
      "operator": "GreaterThan",
      "threshold": "80.0"
    }
  },
  "timeGrain": "Monthly",
  "timePeriod": {
    "endDate": "2030-12-31T00:00:00Z",
    "startDate": "2026-02-01T00:00:00Z"
  },
  "type": "Microsoft.Consumption/budgets"
}
```

**Observed behavior**
- Budget is created at subscription scope and is configured to notify at 80%/100% of actual spend.
- The CLI output shows `currentSpend.unit` as `JPY`, indicating the billing/spend reporting unit in this subscription context.


---

### 6. Activity Log → Log Analytics (IaC)

**Control**
- Resource type: `Microsoft.Insights/diagnosticSettings` (subscription scope)
- Diagnostic settings name: `ds-activitylog-to-law`
- Destination: Log Analytics workspace `law-platform-baseline`
- Resource group: `rg-platform-monitoring`
- Location: `japaneast`
- Required tags (enforced): `Owner`, `CostCenter`, `Environment`

**Attempt (command)**

```powershell
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
```

**Result**
- Deployment result: `Succeeded`

```text
Succeeded
```

- Diagnostic settings were verified via CLI

```powershell
az monitor diagnostic-settings subscription show --name "ds-activitylog-to-law" -o jsonc
```

- Workspace was verified via CLI

```powershell
az monitor log-analytics workspace show `
  --resource-group "rg-platform-monitoring" `
  --workspace-name "law-platform-baseline" -o jsonc
```

- Logs were confirmed in Log Analytics (KQL)

```kusto
AzureActivity
| where TimeGenerated > ago(24h)
| project TimeGenerated, OperationNameValue, ActivityStatusValue, ResourceGroup, ResourceId
| order by TimeGenerated desc
| take 5
```

**Observed behavior**
- Subscription Activity Log が Log Analytics の `AzureActivity` に取り込まれ、操作履歴（デプロイ/診断設定作成/Workspace作成など）がクエリ可能になった。
- IaC によりログ基盤（最低限）が再現可能になり、監査/調査のスタート地点を確立できた。
---


### Appendix: Legacy evidence (before consolidation)

> The following evidence was captured while validating individual policy assignments (pre-initiative).  
> After validation, these assignments were removed and replaced by the initiative-only approach.

- `pa-require-tag-*` (Require a tag on resources)
- `pa-require-rg-tag-*` (Require a tag on resource groups)
- `pa-secure-transfer-storage` (Secure transfer required for Storage Accounts)
