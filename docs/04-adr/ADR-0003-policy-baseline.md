# ADR-0003: Policy baseline approach (start small, prove effectiveness)

## Status
Accepted

## Context
Platform/LZとして、事故を防ぐ最低限のガードレールを短期間で構築し、効果（Deny/準拠）を証跡として残す必要がある。
いきなり多数のPolicyを導入すると、例外運用や影響分析が追いつかず形骸化する。

## Decision
- v1は「事故りやすく、効果が高い」ものに絞って導入する
  - Required tags (resources / resource groups)
  - Allowed locations (Japan East/West)
- 導入は IaC（Bicep）で行い、what-if と Denyログで効果を証跡化する
- 例外運用は方針（期限・記録・承認）を先にdocs化し、実装は段階的に入れる

## Consequences
### Pros
- 小さく始めて、運用に耐える形でスケールできる
- Evidence（Deny）の取得により、採用で刺さる成果物になる

### Cons / Risks
- “10項目全部実装”のような網羅性は短期では担保できない
- DeployIfNotExists/Modify系（診断設定強制など）の実装には追加設計が必要

## Follow-ups
- Storage secure transfer required / Budget / Diagnostic settings を順次追加し、Evidenceを拡充する
- Policy set (Initiative) 化して適用単位を整理する
