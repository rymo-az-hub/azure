\# Management Group hierarchy and Subscription separation



\## Purpose

ガードレール（Policy / 監査 / コスト統制）をスケールさせるための適用単位を定義し、責任分界と例外運用を成立させる。



\## Target design (ideal: with Management Groups)



\### Management Group hierarchy (proposal)



Tenant Root Group

└─ mg-platform

├─ mg-landingzones-corp

├─ mg-landingzones-online

└─ mg-sandbox





\### Rationale

\- mg-platform

&nbsp; - 目的: 共通基盤の統制（監査、診断設定、タグ規約、コスト統制の土台）

&nbsp; - 影響範囲が大きいので変更管理を厳格にする（ADR/レビュー必須）

\- mg-landingzones-corp / mg-landingzones-online

&nbsp; - 目的: ワークロード向け最小ガードレール（リージョン、タグ、公開系制限など）

&nbsp; - Corp/Onlineでネットワークや公開面の前提が異なるため分割

\- mg-sandbox

&nbsp; - 目的: 検証自由度を確保しつつ、コスト暴走だけは抑止（Budget/Alert強化）

&nbsp; - 例外は多くなる前提なので期限付き例外運用を徹底



\## Subscription separation (proposal)



\### Subscriptions

\- sub-platform

&nbsp; - 役割: Log Analytics / 監査・運用基盤（必要に応じて）

&nbsp; - 統制: 最も厳格（変更管理/例外最小）

\- sub-landingzone-corp

&nbsp; - 役割: 社内系ワークロード（閉域前提）

\- sub-landingzone-online

&nbsp; - 役割: インターネット公開を含むワークロード

\- sub-sandbox

&nbsp; - 役割: 検証用（ただしBudgetは強制）



\### Rationale

\- 課金・責任・アクセス制御（RBAC）・例外の単位として subscription が最も扱いやすい

\- Onlineは公開面・セキュリティ要件が強く、Corpと混ぜると例外が増えるため分離

\- Sandboxは自由度を確保する代わりに、コスト統制を強化して事故を抑止



\## Current implementation (personal Azure constraint)

\- Management Groupが利用できない（権限/テナント制約）ため、

&nbsp; 現状は subscription scope に Azure Policy を直接割り当てて代替実装している。

\- ただし、上記MG/サブスク設計は「本来のLZ設計」として docs と ADR に残し、

&nbsp; 実装は段階的に理想形へ寄せる。



