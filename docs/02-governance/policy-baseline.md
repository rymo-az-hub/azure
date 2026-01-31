# Policy Baseline

## Purpose
Platform Landing Zoneとして、最低限のガードレールを提供し、
セキュリティ・運用性・コスト統制の土台を確立する。

## Where to apply (scope)
- Platform: 共通基盤ルール（監視/診断、タグ、コスト統制）を強制
- Landing zones (Corp/Online): ワークロード向け最小ガードレールを強制
- Sandbox: 制限は緩めるが、コスト統制（Budget/アラート）は強める

## Exception policy (how to handle)
- 例外は期限付き（例：30日）で発行し、期限前に棚卸し
- 例外理由・影響範囲・代替案・恒久対応の計画を必須入力
- 例外は「誰が承認し、どこに記録するか」を明確化する（運用プロセスへ）

## Initial Policy Set (v1)
> まずは“事故りやすい・効果が高い”ものから10個に絞る

### 1. Required Tags
- Enforce: Owner, CostCenter, Environment
- Why: コスト追跡/責任分界点の明確化
- Default / Notes: 例外はSandboxのみ許容（期限付き）

### 2. Allowed Locations (Region Restriction)
- Enforce: Japan East / Japan West only (例)
- Why: データ所在地、運用統一、コスト見積もり容易化

### 3. Budget & Cost Alerts (Subscription level)
- Enforce: 月額上限＋閾値アラート（50/80/100%）
- Why: 個人環境でも“運用として”必須

### 4. Diagnostic Settings for Activity Log
- Enforce: Activity Log → Log Analytics
- Why: 監査・インシデント調査の土台

### 5. Diagnostic Settings for Key Resources
- Enforce: 対象リソースの診断ログをLog Analyticsへ（段階的に拡張）
- Why: “監視できない”状態を防ぐ

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

## Roadmap
- v2: ワークロード種別ごとの診断設定拡充、Deny/DeployIfNotExistsの整理
- v3: RBACとセットで“例外運用の実装（記録・期限・棚卸し）”まで自動化
