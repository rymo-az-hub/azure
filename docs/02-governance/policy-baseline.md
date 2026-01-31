# Policy Baseline

## Purpose
Platform Landing Zoneとして、最低限のガードレールを提供し、  
セキュリティ運用性コスト統制の土台を確立する。

## Where to apply (scope)
- Platform: 共通基盤ルール（監視/診断、タグ、コスト統制）を強制
- Landing zones (Corp/Online): ワークロード向け最小ガードレールを強制
- Sandbox: 制限は緩めるが、コスト統制（Budget/アラート）は強める

> Note: 個人Azure環境の権限制約によりManagement Groupが利用できないため、現状はサブスクリプションスコープで代替実装している。

## Exception policy (how to handle)
- 例外は期限付き（例：30日）で発行し、期限前に棚卸し
- 例外理由影響範囲代替案恒久対応の計画を必須入力
- 例外は「誰が承認し、どこに記録するか」を明確化する（運用プロセスへ）

## Initial Policy Set (v1)
> まずは事故りやすい効果が高いものから10個に絞る

### 1. Required Tags
- Enforce: Owner, CostCenter, Environment
- Why: コスト追跡/責任分界点の明確化
- Notes: 現状はサブスクリプション一括適用（例外運用は今後実装）

Implementation (current)
- Azure Policy Assignments (subscription scope)
  - pa-require-tag-owner
  - pa-require-tag-costcenter
  - pa-require-tag-environment
- Policy definition
  - Require a tag on resources
  - /providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99

### 2. Allowed Locations (Region Restriction)
- Enforce: Japan East / Japan West only
- Why: データ所在地、運用統一、コスト見積もり容易化

Implementation (current)
- Azure Policy Assignment (subscription scope)
  - pa-allowed-locations
- Policy definition
  - Allowed locations
  - /providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c
- Parameters
  - listOfAllowedLocations = ["japaneast","japanwest"]

### 3. Budget & Cost Alerts (Subscription level)
- Enforce: 月額上限＋閾値アラート（50/80/100%）
- Why: 個人環境でも運用として必須

### 4. Diagnostic Settings for Activity Log
- Enforce: Activity Log  Log Analytics
- Why: 監査インシデント調査の土台

### 5. Diagnostic Settings for Key Resources
- Enforce: 対象リソースの診断ログをLog Analyticsへ（段階的に拡張）
- Why: 監視できない状態を防ぐ

### 6. Public IP Restriction
- Enforce: Public IPの作成/付与を制限（例外運用あり）
- Why: 露出面削減、事故防止

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

### Deny: Creating a VNet without required tags

Attempt (command)

    az network vnet create -g rg-policy-test -n vnet-notags -l japaneast --address-prefixes 10.10.0.0/16

Result
- Denied with: RequestDisallowedByPolicy
- Triggered policy assignments:
  - pa-require-tag-owner
  - pa-require-tag-costcenter
  - pa-require-tag-environment
- Policy definition:
  - Require a tag on resources
  - /providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99

Observed behavior
- Resource creation fails when any of the required tags (Owner/CostCenter/Environment) is missing.

## Roadmap
- v2: ワークロード種別ごとの診断設定拡充、Deny/DeployIfNotExistsの整理
- v3: RBACとセットで例外運用の実装（記録期限棚卸し）まで自動化
