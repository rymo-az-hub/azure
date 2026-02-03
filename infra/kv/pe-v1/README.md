# Key Vault Private Endpoint v1 (Closed)

本ディレクトリは、Azure Key Vault を **Private Endpoint 経由のみ**で利用するための v1 ベースラインを IaC（Bicep）で作成し、
監査/引継ぎに耐える Evidence を残すことを目的とします。

> v1 は **PE-only + Diagnostics + Evidence** までを完了しクローズします。  
> 次のステップは「Key Vault RBAC（最小権限）設計」です。

---

## 0. Policy 前提（重要）
本サブスクリプションにはポリシーセット **Platform Baseline v1** が割り当てられており、以下が **deny** されます。

- Resource Group 作成時に必須タグが無い
- 各リソース作成時に必須タグが無い

### 必須タグ
- `Owner`
- `CostCenter`
- `Environment`

このため、**CLI で作成する RG / リソースには必ず `--tags` を付与**してください。  
Bicep 側も `tags` パラメータを受け取り、タグ可能なリソースに付与します。

---

## 1. PowerShell 前提（重要）
本 README のコマンド例は **Windows PowerShell / PowerShell** を前提にしています。

- Bash の行継続 `\` は PowerShell では使えません
- PowerShell の行継続はバッククォート `` ` `` です
- 1 行で実行してもOKです（誤差が出にくい）

---

## 2. v1 スコープ（作る / 作らない）

### 作成されるリソース
- Key Vault（RBAC enabled / publicNetworkAccess disabled / SoftDelete+PurgeProtection）
- Private Endpoint（groupId: `vault`）
- Private DNS Zone: `privatelink.vaultcore.azure.net`
- VNet link（Private DNS Zone → VNet）
- Private DNS Zone Group（A レコード自動作成）
- Diagnostic Settings（KeyVault `AuditEvent` → Log Analytics）

### 作らない（v1 で意図的に除外）
- Managed HSM / HSM / CMK（二重暗号）
- 役割の細分化（最小権限設計は v2/RBAC 編で実施）
- Firewall の Selected networks 運用（v1 は Public access 無効で割り切り）

---

## 3. v1 パラメータ（実環境）
- Subscription: `45bddcd7-c7d9-4492-b899-31f78c4cf368`
- Resource Groups:
  - `rg-platform-baseline`
  - `rg-network-baseline`
- VNet / Subnet:
  - `vnet-platform-baseline`
  - `snet-privatelink`（Private Endpoint 用、`privateEndpointNetworkPolicies=Disabled`）
- Log Analytics Workspace:
  - `law-platform-baseline`
- Key Vault / PE:
  - `kv-plat-dev-45bddcd7-001`
  - `pe-kv-plat-dev-45bddcd7-001`

---

## 4. デプロイ（参考）
v1 はすでにデプロイ済みでクローズしています。  
将来の再現のため、実行コマンドを参考として残します。

```powershell
cd infra/kv-pe-v1

# what-if（ログ保存推奨）
az deployment group what-if -g rg-platform-baseline -f main.bicep -p main.parameters.json

# deploy
az deployment group create -g rg-platform-baseline -f main.bicep -p main.parameters.json
```

---

## 5. Evidence（すでに作成済み）
以下の Evidence ファイルは **既に作成済み**です（本 README はその前提で管理します）。

```
evidence/
  kv-pe-v1/
    00_what-if.txt
    01_kv_settings.json
    02_pe_subnet.txt
    03_pe_connection.json
    04_private_dns_a_record.txt
    05_diag_settings.json
```

※ Evidence は **「生ログ（生 JSON / 生テキスト）」**を保存しています。
Markdown（.md）に整形すると見やすくなりますが、**証跡としては改変余地が少ない生出力の方が強い**ため、この形式にしています。

### 5.1 Evidence 内容（何を証明しているか）
- `00_what-if.txt`：デプロイ前差分（作成対象リソース/設定の予測）
- `01_kv_settings.json`：Key Vault の Public 無効 / RBAC / SoftDelete / PurgeProtection / retention
- `02_pe_subnet.txt`：Private Endpoint が配置された Subnet ID
- `03_pe_connection.json`：Private Link 接続状態（`Approved`）、groupId（`vault`）
- `04_private_dns_a_record.txt`：Private DNS に A レコードが自動作成されたこと（creator metadata）
- `05_diag_settings.json`：`AuditEvent` が `law-platform-baseline` に送信される設定

### 5.2 （任意）Evidence を再生成する場合
将来的に再生成する場合は、以下のコマンドを使います（PowerShell）。
※既に Evidence がある場合は不要です。

```powershell
$ev = "evidence/kv-pe-v1"
New-Item -ItemType Directory -Force $ev | Out-Null

az deployment group what-if -g rg-platform-baseline -f main.bicep -p main.parameters.json 2>&1 `
  | Out-File "$ev/00_what-if.txt" -Encoding utf8

az keyvault show -n kv-plat-dev-45bddcd7-001 -g rg-platform-baseline -o json `
  --query "{name:name, publicNetworkAccess:properties.publicNetworkAccess, enableRbacAuthorization:properties.enableRbacAuthorization, enableSoftDelete:properties.enableSoftDelete, softDeleteRetentionInDays:properties.softDeleteRetentionInDays, enablePurgeProtection:properties.enablePurgeProtection}" `
  | Out-File "$ev/01_kv_settings.json" -Encoding utf8

az network private-endpoint show -n pe-kv-plat-dev-45bddcd7-001 -g rg-platform-baseline `
  --query "subnet.id" -o tsv `
  | Out-File "$ev/02_pe_subnet.txt" -Encoding utf8

az network private-endpoint show -n pe-kv-plat-dev-45bddcd7-001 -g rg-platform-baseline -o json `
  --query "privateLinkServiceConnections[].{name:name, groupIds:groupIds, status:privateLinkServiceConnectionState.status, description:privateLinkServiceConnectionState.description, privateLinkServiceId:privateLinkServiceId}" `
  | Out-File "$ev/03_pe_connection.json" -Encoding utf8

az network private-dns record-set a list -g rg-platform-baseline -z privatelink.vaultcore.azure.net -o table `
  | Out-File "$ev/04_private_dns_a_record.txt" -Encoding utf8

az monitor diagnostic-settings list `
  --resource $(az keyvault show -n kv-plat-dev-45bddcd7-001 -g rg-platform-baseline --query id -o tsv) -o json `
  | Out-File "$ev/05_diag_settings.json" -Encoding utf8
```

---

## 6. v1 クローズ条件（満たしていること）
- Key Vault: `publicNetworkAccess=Disabled`, `enableRbacAuthorization=true`, `SoftDelete/PurgeProtection=true`
- Private Endpoint: `Approved` / `Succeeded`、Subnet が `snet-privatelink`
- Private DNS: `privatelink.vaultcore.azure.net` に A レコードが自動作成
- Diagnostics: `AuditEvent` が `law-platform-baseline` に送信

---

## 7. 次のステップ（v2：Key Vault RBAC 最小権限設計）
v2 では以下を設計・実装します。
- 管理者ロール（運用者）とアプリ/自動化（CI/CD, 監視）を分離
- Key / Secret / Certificate ごとの最小権限
- RBAC の割当単位（Vault スコープ / Resource Group / Subscription）と運用ルール
- Access Review / 期限付き付与（PIM がある場合）
