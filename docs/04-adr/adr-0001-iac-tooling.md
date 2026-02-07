# ADR-0001: IaC tooling selection (Bicep + Azure CLI)



## Status

Accepted



## Context

個人Azure環境でPlatform/LZ相当のガードレールを構築し、採用で評価される「再現性・変更管理・証跡」を残す必要がある。

ARMテンプレートは冗長になりやすく、Terraformは状態管理や運用設計まで踏み込む必要がある。



## Decision

\- IaCは Bicep を採用する

\- 実行・検証は Azure CLI（az）を PowerShell から実行する

\- 変更は `what-if` を必須とし、docsに証跡を残す



## Consequences

### Pros

\- Azureネイティブで学習・実装の速度が速い

\- Policy/Diagnostic Settingsなどガバナンス系リソースの表現が自然

\- what-if と deployment 履歴により証跡が残る



### Cons / Risks

\- Terraformのようなマルチクラウド性・状態管理の学習機会は薄い

\- 高度な差分管理は運用手順（what-if/ADR）で補う必要がある



## Alternatives considered

\- Terraform（状態管理・モジュール化は強いが、個人環境での運用負荷が上がる）

\- ARM template（冗長で読みづらく、レビュー効率が下がる）



