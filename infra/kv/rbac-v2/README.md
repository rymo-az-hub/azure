# Key Vault RBAC v2 (Least Privilege)

Key Vault: `kv-plat-dev-45bddcd7-001`  
Scope: `/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kv-plat-dev-45bddcd7-001`

## 状態（あなたの結果）
- あなたはサブスクリプションに対して **Owner** を保持 → RBAC 付与は実施可能
- KV スコープに Reader を作成できた → v2 を IaC で進めてOK

> ただし、CLI で作った role assignment は GUID 名（ランダム）で残ります。  
> IaC では `guid(kv.id, principalId, roleId)` で **決定的な名前**を作るため、
> **同じ権限が二重付与**される可能性があります（害は少ないが汚い）。
> 可能なら、次章で一旦削除してから IaC を適用してください。

---

## 1) 片付け（推奨）: テスト用 Reader の削除
あなたが作成した Reader の role assignment id:
`/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kv-plat-dev-45bddcd7-001/providers/Microsoft.Authorization/roleAssignments/843b9f81-a559-43c2-b34d-cf28738b9f42`

削除（推奨）:
```powershell
az role assignment delete --ids "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kv-plat-dev-45bddcd7-001/providers/Microsoft.Authorization/roleAssignments/843b9f81-a559-43c2-b34d-cf28738b9f42"
```

---

## 2) 設計（最小権限の型）
### 主体（Principal）
1. Break-glass 管理者（最小人数。普段は使わない）
2. Secrets 運用（作成/更新/削除）
3. Secrets 利用（読み取りのみ。アプリ/CI/CD の Managed Identity 等）
4. 監査/閲覧（設定を見るだけ。データ面は触らない）

### ロール
- Break-glass: **Key Vault Administrator**
- Secrets 運用: **Key Vault Secrets Officer**
- Secrets 利用: **Key Vault Secrets User**
- 監査/閲覧: **Reader**（KV リソースに対して）

**原則**: 人は Entra ID グループに付与（ユーザー直接付与は避ける）  
アプリ/自動化は Managed Identity を principalId として付与してOK

---

## 3) 実装（Bicep）
このフォルダの構成:
- `rbac.bicep`
- `rbac.parameters.json`

### 3.1 パラメータ編集
`rbac.parameters.json` の配列に対象 principal の **objectId** を入れる:

- `kvAdmins`: Break-glass 用グループ（推奨）
- `secretsOfficers`: Secrets 運用者グループ
- `secretsUsers`: アプリ/CI/CD の Managed Identity objectId
- `kvReaders`: 監査/閲覧者（必要なら）

### 3.2 what-if / deploy
```powershell
az deployment group what-if -g rg-platform-baseline -f rbac.bicep -p rbac.parameters.json
az deployment group create -g rg-platform-baseline -f rbac.bicep -p rbac.parameters.json
```

---

## 4) Evidence（v2）
```
evidence/
  kv-rbac-v2/
    00_what-if.txt
    01_role_assignments_kv.json
    02_role_assignments_sub.txt
```

取得:
```powershell
$ev = "evidence/kv-rbac-v2"
New-Item -ItemType Directory -Force $ev | Out-Null

az deployment group what-if -g rg-platform-baseline -f rbac.bicep -p rbac.parameters.json 2>&1 |
  Out-File "$ev/00_what-if.txt" -Encoding utf8

$kvId = "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kv-plat-dev-45bddcd7-001"
az role assignment list --scope $kvId -o json |
  Out-File "$ev/01_role_assignments_kv.json" -Encoding utf8

az role assignment list --assignee "eeb850f4-8f4c-4daf-a2f2-99cbab6e8184" --scope /subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368 -o table |
  Out-File "$ev/02_role_assignments_sub.txt" -Encoding utf8
```

---

## 5) 次のアクション（ここから）
1) Entra ID グループ（または MI）の **objectId** を決める  
2) `rbac.parameters.json` に反映  
3) what-if → deploy → Evidence を取得
