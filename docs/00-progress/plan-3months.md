# 3か月計画（12週間）— Platform/LZ/IaC/運用設計ポートフォリオ（2026-02-08版）

## 0. 目的（3か月ゴール）
3か月（12週間）で、採用側が「この人は Platform/Landing Zone を運用込みで作れる」と判断できる成果物を揃えます。

- **IaC**：`infra/` に baseline をコード化し、再デプロイ可能であること
- **設計判断**：`docs/04-adr/` に ADR を残し、判断理由が追えること
- **Evidence**：`docs/evidence/` に受入証跡（ログ/スクショ/期待値）を残すこと
- **運用設計**：`docs/03-operations/` に Runbook（障害/変更/権限運用）を残すこと
- **ガバナンス**：Policy set / Exemption の運用まで扱うこと
- **クリーンアップ**：検証リソースの残骸ゼロを徹底すること

---

## 1. リポジトリ（正本）
- Repo：`azure`
- ローカルパス：`C:\Users\Ryosuke.M\source\repos\azure`

> 以後、パスは `$repoRoot = (Get-Location).Path` を起点に `Join-Path` で絶対パス化する方針とします。

---

## 2. 作る baseline（3か月で絞る範囲）
3か月のため「広く浅く」ではなく **4本を深く**に寄せます。

1. **Network baseline**  
   VNet / Subnet（workload/privatelink/bastion）/ Private DNS / Bastion（+ Policy Exemption 運用）
2. **Key Vault baseline v2**  
   PrivateLink / RBAC 最小権限 / Diagnostic Settings / 運用（Runbook）
3. **Storage baseline**  
   Storage Account / PrivateLink / RBAC / Diagnostic Settings（KV と同型で横展開）
4. **Monitoring baseline**  
   Log Analytics / Diagnostic Settings 標準 / Alert（最低限）/ Runbook

---

## 3. Done の定義（各 baseline 共通）
各 baseline は以下を満たしたら「完成」とします。

- `infra/<service>/baseline-v*/` が **WhatIf → Deploy → Destroy** まで再現できる
- `docs/01-architecture/` に構成図（最低 1枚）
- `docs/04-adr/` に ADR（設計判断が説明できる）
- `docs/evidence/<service>/<topic>/` に Evidence（ログ＋スクショ＋期待値）
- `docs/03-operations/` に Runbook（障害/変更/権限運用）

---

## 4. 12週間ロードマップ（週単位）
### Week 1：土台の固定（開発生産性＋再現性）
- repo の導線（README / index）と規約の固定
- 文字コード/改行（UTF-8 BOMなし + LF）運用の標準手順化
- “実行の入口” を 1本化（例：`docs/00-context/how-to-deploy.md`）

**成果物**
- `docs/00-context/` に「デプロイ方法」「命名/規約」「証跡の残し方」の入口ページ

---

### Week 2–3：Network baseline（LZの背骨）
- VNet / Subnet（workload/privatelink/bastion）
- Private DNS（必要ゾーンのみ）
- Bastion（deny → exemption → 作成 → exemption削除）を **運用手順化＋Evidence**

**成果物**
- `infra/platform/...` または `infra/network/...`（構成に合わせる）に baseline
- `docs/evidence/network/...`（または `docs/evidence/platform/...`）に証跡
- ADR：exemption 運用の設計判断（期間/理由/削除/監査）

---

### Week 4–5：Key Vault baseline v2（現状成果を完成品へ）
- PrivateLink / RBAC v2 を IaC と Evidence で固定
- Diagnostic Settings（LAW へ送信）
- 運用（シークレット運用、権限申請、障害時切り分け）

**成果物**
- `infra/kv/baseline-v2/`（または `infra/kv/baseline-v1` の拡張）に完成形
- `docs/evidence/kv/...` に Evidence（既存の `rbac-v2` を基点に拡張）

---

### Week 6–7：Storage baseline（KV の横展開でスピード重視）
- Storage（Public遮断 / PrivateLink）
- RBAC（読み/書き分け）
- Diagnostic Settings（LAW）
- KV と同じ Evidence の型で作る

**成果物**
- `infra/workloads/...` か `infra/platform/...` に配置（方針に合わせて統一）
- `docs/evidence/storage/...` を新設し、Evidence をテンプレ化

---

### Week 8–9：Monitoring baseline（運用設計のコア）
- LAW を中心に Diagnostic Settings 標準（カテゴリ、保持期間、命名）
- 最低限の Alert（例：重要操作 / 失敗の増加 / 接続性）
- Runbook（誰が何を見てどう判断するか）

**成果物**
- `infra/platform/monitoring/` の強化
- `docs/03-operations/` に監視→対応フローを追加

---

### Week 10：Governance（Policy を作品化）
- policy set の意図（何を守るか）を説明可能にする
- Exemption 運用（期間、理由、削除、監査）を手順化
- Evidence（実例：Bastion 作成時の exemption）

**成果物**
- `docs/02-governance/` の体系化
- `docs/evidence/...` に exemption の証跡

---

### Week 11–12：仕上げ（転職で読まれる形へ）
- docs の“読む人目線”の整理（索引、最初に読むページ、リンクの整備）
- 代表 Evidence（KV/Storage/Policy）を見せ場として配置
- 職務経歴書向けの実績 bullets を作成（成果物リンク前提）

**成果物**
- 採用側が 30分で判断できるポートフォリオ導線

---

## 5. 現在地（2026-02-08 時点）
- **Key Vault**：PrivateLink 到達性（DNS/443）と RBAC v2（Read OK / Write NG）を Evidence 化し、repo に格納済み
- **repo 運用**：ディレクトリ整理、ADR/Evidence 導線、文字化け/改行対策を実運用で経験済み

→ Week 1 の多くは既に完了しているため、**Network baseline へ早めに着手できる**状態です。

---

## 6. 運用ルール（互いに忘れないため）
### 私（アシスタント）へのルール
- 私の一人称は「私」とする
- 敬語を使う（私も敬語を使います）
- 作成したファイルは文字化けしていないか確認する
- 文字化けしていた場合は修正する
- リポジトリを把握する
- リポジトリを忘れた場合は確認する
- 進め方は推奨されるものを順番に一つずつやっていく
- 一度に複数の工程を出さない（追加で～は無しで、今やることをやってから追加をやるか聞く）
- `$repoRoot = (Get-Location).Path` → `Join-Path` で絶対パスを癖にする
- マシンサイズは要件がなければ「Standard_D2s_v4」を使う

---

## 7. この計画ファイルの置き場所（推奨）
- `docs/00-context/plan-3months.md`（推奨）
  - “最初に読む” 位置に置くことで、計画と成果物の紐付けが途切れません。
