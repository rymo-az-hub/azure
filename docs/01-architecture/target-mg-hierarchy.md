# Target Management Group Hierarchy

## Diagram

```text
Tenant Root
├─ Platform
│  ├─ Management
│  ├─ Connectivity
│  └─ Identity
├─ Landing zones
│  ├─ Corp
│  └─ Online
└─ Sandbox

## Rationale
- Platform: 共通基盤（監視/ログ、ネットワーク、ID）を集約し、ガードレールを一貫適用する
- Landing zones: ワークロードを分離し、責任分界点（Platform vs Workload）を明確化する
- Sandbox: 例外や実験を許容し、本番相当領域を汚さずに検証できる（ただしコスト統制は強くする）

## High-level Attachment Strategy
- Platform 配下: 監視・診断設定・タグなど共通基盤ルールを強制
- Landing zones 配下: ワークロード向け最低限ガードレール（リージョン制限等）
- Sandbox: 制限を緩める代わりに Budget/アラートでコスト暴走を抑止
