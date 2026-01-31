\# Context



\## Objective

Azure特化企業（MSパートナー含む）の Platform / Landing Zone / IaC / 運用設計寄りポジションを想定し、個人Azure環境で「設計意図＋IaC＋証跡」を作成する。



\## Timebox

\- 期間: 6か月

\- 学習/検証環境: 個人Azureサブスクリプション（権限制約あり）



\## Target outcomes (deliverables)

\- Docs: LZ設計（目的・前提・スコープ）、MG/サブスク設計、運用設計（例外・変更・棚卸し）

\- IaC: Bicepでのガードレール（Azure Policy / 監査ログ / コスト統制など）

\- Evidence: what-if / deployment / denyログ等の「効いている証跡」

\- ADR: 意思決定の記録（なぜその設計/実装にしたか）



\## Scope (in)

\- Platform ガードレール

&nbsp; - Azure Policy（タグ、リージョン制限、RG統制、例外運用の設計）

&nbsp; - 監査/可観測性（Activity Log / Diagnostic Settings）

&nbsp; - コスト統制（Budget, alerts）

\- IaC運用

&nbsp; - what-if / deployment / rollback / change log

&nbsp; - ADRで意思決定の透明化



\## Out of scope (not in / later)

\- 本番相当のID基盤（Entra ID設計、PIM、RBAC大規模運用）は後半で扱う

\- 大規模ネットワーク（Hub-Spoke/ER/VPN/Firewall）は段階的に拡張

\- アプリ実装やデータ基盤は主目的ではない（ガードレール検証用の最小構成のみ）



\## Assumptions / constraints

\- 個人環境のため Management Group の作成・参照に制約がある場合がある

&nbsp; - その場合は subscription scope で代替実装し、設計としてのMG案は docs に残す

\- 低コストで運用（不要リソースは即削除）

\- 証跡は docs に残し、再現手順も記録する



