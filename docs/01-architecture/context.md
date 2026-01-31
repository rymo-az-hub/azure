# Context

## Goal
Azure特化企業（MSパートナー含む）における Platform / Landing Zone / IaC / 運用設計 寄りポジションを想定し、
CAF/ALZ思想に沿った Platform Landing Zone を IaC で構築・継続運用できることを示す。

## Target Operating Model (Simplified)
- Platform: 管理グループ階層、Policy/RBAC、監視・ログ基盤、共通基盤の責任を持つ
- Workload: Landing zones配下でアプリ/VM等をデプロイし、ガードレールに従う
- Ops: 監視、一次切り分け、変更管理、例外運用を回す

## Requirements
### Functional
- 管理グループ階層の定義と適用
- Policy baseline（最低限のガードレール）
- RBACモデル（分掌・最小権限・緊急時の扱い）
- 監視基盤（ログ集約・基本アラート）
- IaCでデプロイ・更新（再現性）

### Non-Functional
- 低コスト維持（高額NW機器は実装しない/設計のみ）
- 変更容易性（PR/レビュー/ロールバック前提）
- 例外運用（期限付き例外・棚卸し）

## Constraints
- 個人Azure環境（サブスク数・予算に制約）
- Workloadは最小構成で“証跡”を作る

## Scope
### In
- Platform Landing Zone（MG/Policy/RBAC/Monitoring）
- 1つのWorkload（小さいワークロードでガードレールの効き方を示す）
- 運用設計（監視/インシデント/変更/例外）

### Out (for now)
- vWAN / Azure Firewall 等の高コスト構成（必要なら設計で補足）
- 大規模組織固有の実装（思想は説明する）

## Deliverables
- docs/* 設計書・Runbook・ADR
- infra/* IaC
- CI/CD（plan/apply）(WIP)
