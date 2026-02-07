# Azure platform / Landing Zone learning repo

Hands-on portfolio for Azure Platform / Landing Zone / IaC / operations design.

This repository focuses on **reproducible infrastructure** (IaC) and **verifiable outcomes** (Evidence).

## Structure
- `infra/` : IaC (Bicep/params)
  - `infra/kv/` : **Canonical** Key Vault baselines
    - `pe-v1/` : Key Vault + Private Endpoint baseline
    - `rbac-v2/` : RBAC v2 minimum privilege (role assignments)
    - `_legacy/` : archived templates (reference only)
- `docs/`
  - `docs/evidence/` : verification outputs (CLI/PS outputs, JSON exports)
  - `docs/00-progress/` : day-by-day progress logs and command logs

## Key Vault 窶・quick pointers
- IaC:
  - `infra/kv/pe-v1/`
  - `infra/kv/rbac-v2/`
- Evidence:
  - `docs/evidence/kv-rbac-v2-evidence.md`
  - `docs/evidence/kv/` (what-if outputs, DNS/reachability checks, role assignment exports, etc.)

## Line endings
This repository is normalized to **LF** via `.gitattributes`.

## Docs

- docs/00-context/context.md : 学習環境前提作業方針（このリポジトリの前提条件）
- docs/01-architecture/context.md : アーキテクチャの前提（設計判断の土台）
