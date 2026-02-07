# Commands used on Day 4 (summary) / Day4コマンド一覧（2026-02-07）

PowerShell 前提。主に Git によるリポジトリ整理（差分ノイズ排除・命名統一・正本一本化）。

---

## 状態確認 / Working tree の把握

git status
git diff

---

## ZIP上書き後の差分ノイズ対策（必要分だけ stage → restore）

# 例：必要な変更だけ add
git add README.md
git add infra/kv/pe-v1/main.bicep
git add infra/kv/_legacy/

# それ以外の差分を破棄（stage済みは保持）
git restore .
git status

---

## IaC 正本の統一（infra/kv を canonical に）

# 存在確認
Test-Path .\infra\keyvault

# 旧ディレクトリ削除（Git管理下）
git rm -r infra/keyvault

# commit / push（例）
git commit -m "Make infra/kv canonical, archive legacy keyvault, and align KV diagnostics"
git push

---

## Evidence の重複削除（README.txt を削除）

git rm docs/evidence/README.txt
git commit -m "Remove duplicate evidence README.txt"
git push

---

## ADR 命名統一（adr- → ADR-）

git mv docs/04-adr/adr-0001-iac-tooling.md docs/04-adr/ADR-0001-iac-tooling.md
git mv docs/04-adr/adr-0002-management-group-hierarchy.md docs/04-adr/ADR-0002-management-group-hierarchy.md

git status
git commit -m "Clean up ADR naming (ADR- prefix)"
git push

---

## Docs導線 + ADRルール + .editorconfig（再発防止）

git add README.md docs/04-adr/ADR-0000-template.md .editorconfig
git commit -m "Add docs links, ADR status/numbering rules, and .editorconfig"
git push
