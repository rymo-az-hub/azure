# ADR-0002: Management Group hierarchy strategy (design vs implementation)



## Status

Accepted (design), Deferred (implementation)



## Context

本来のAzure Landing ZoneではManagement Group階層で統制をスケールさせる。

一方、個人Azure環境ではMG作成/参照に権限制約があり、実装ができない可能性がある。



## Decision

\- 設計としてはMG階層（platform / landingzones corp-online / sandbox）を採用する

\- 実装は現状 subscription scope に代替し、MG前提の設計は docs に残す



## Consequences

### Pros

\- LZとしての設計意図（適用単位/責任分界/例外運用）を説明できる

\- 個人環境制約があっても手を止めずに成果物を出せる



### Cons / Risks

\- MGスコープの実装検証（policy assignment at MG）ができない

\- 将来的にMGを使える環境で再検証が必要



## Follow-ups

\- MGが利用できる環境が確保でき次第、MGスコープへの移植を行い、証跡を追加する



