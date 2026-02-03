# Key Vault RBAC v2 Evidence（Private Endpoint / 最小権限）

## 0. 目的
- Key Vault を **Azure RBAC（最小権限）**で運用できることを確認する
- **Private Endpoint 経由**で到達していることを確認する
- 役割差分（Officer と User）により **Get は可 / Set は不可**の動作差分を Evidence として残す

---

## 1. 対象・前提

### 1.1 対象リソース
- Subscription: `Sub-Azure (45bddcd7-c7d9-4492-b899-31f78c4cf368)`
- Key Vault: `kv-plat-dev-45bddcd7-001`
- Key Vault RG: `rg-platform-baseline`
- VNET: `vnet-platform-baseline`（rg: `rg-network-baseline`）
- Private Endpoint IP: `10.10.1.4`
- Workload VM: `vmkvtestdev001`（Private IP: `10.10.2.5`）
- Bastion: `bas-platform-dev-001`（rg: `rg-network-baseline`）
- Bastion Public IP: `pip-bastion-dev-001`

### 1.2 検証対象の主体（Entra ID）
- 主体A（Officer）: `avd@ryosukemwebengoutlook.onmicrosoft.com`
  - RoleAssignments（KV スコープ）: `Key Vault Secrets Officer`（＋必要なら `Key Vault Secrets User`）
- 主体B（User）: `kvsecretsuser01@ryosukemwebengoutlook.onmicrosoft.com`
  - objectId: `bcd1212d-6151-4d27-8865-a1b643242d3e`
  - RoleAssignments（KV スコープ）: `Key Vault Secrets User` のみ

### 1.3 設計方針
- Key Vault への接続は Private Endpoint 前提（VM から DNS/到達性を確認）
- RBAC v2 の最小権限を「主体分離」で検証（Officer と User）
- Bastion のための Public IP はポリシーで deny されるため、**最小緩和（Policy Exemption）**のみ実施

---

## 2. Evidence 取得の全体像（何を証明するか）
1) VM から KV へ **Private Endpoint 経由**で到達できる（DNS と 443）
2) Bastion 経由で VM にログインできる（操作証跡の経路）
3) RBAC により以下が成立する（最小権限の差分）
   - Officer: `set` が **成功**
   - User: `get` が **成功**、`set` が **Forbidden**

---

## 3. Evidence の取得手順（コマンドと期待結果）

> 注意
> - パスワード・秘密値は Evidence に残さない（必要ならマスク）
> - スクショは `docs/evidence/screenshots/kv-rbac-v2/` に保存（推奨）

---

### 3.1 Bastion 接続の成立（VM へ入れる状態）

#### 3.1.1 Policy Exemption（最小緩和）
- initiative `ps-platform-baseline-v1` の参照 `denyResourceTypes-publicip` のみを
- `rg-network-baseline` スコープで Exemption（期限付き）作成

**Evidence（貼付/スクショ）**
- `az policy exemption show` の JSON
  - `scope` が `rg-network-baseline`
  - `policyDefinitionReferenceIds` に `denyResourceTypes-publicip` のみ
  - `expiresOn` が設定されていること

（参考コマンド）
```powershell
$sub="45bddcd7-c7d9-4492-b899-31f78c4cf368"
$rgScope="/subscriptions/$sub/resourceGroups/rg-network-baseline"
az policy exemption show --name ex-allow-publicip-for-bastion --scope $rgScope -o jsonc
```

#### 3.1.2 Public IP / Bastion 作成
**Evidence（貼付/スクショ）**
- Public IP 作成成功（`provisioningState: Succeeded`、タグ付与）
- Bastion 作成（`sku: Standard`、`AzureBastionSubnet`、Public IP の紐付け）

（参考コマンド）
```powershell
az network public-ip show -g rg-network-baseline -n pip-bastion-dev-001 -o jsonc
az network bastion show -g rg-network-baseline -n bas-platform-dev-001 -o jsonc
```

---

### 3.2 Private Endpoint 経由の DNS/到達性（VM 10.10.2.5）

VM（PowerShell）で以下を実行。

#### 3.2.1 DNS
```powershell
$kv="kv-plat-dev-45bddcd7-001.vault.azure.net"
nslookup $kv
```

**期待結果**
- `kv-...vault.azure.net` が `kv-....privatelink.vaultcore.azure.net` に解決
- A レコードが `10.10.1.4` を返す

#### 3.2.2 到達性（443）
```powershell
Test-NetConnection $kv -Port 443
```

**期待結果**
- `RemoteAddress: 10.10.1.4`
- `TcpTestSucceeded: True`
- `SourceAddress: 10.10.2.5`

---

### 3.3 RBAC v2（最小権限）の差分 Evidence（主体分離）

#### 3.3.1 ロール割当（KV スコープ）確認（ローカル端末）
```powershell
$kvId = az keyvault show -g rg-platform-baseline -n kv-plat-dev-45bddcd7-001 --query id -o tsv

az role assignment list --scope $kvId `
  --query "[?contains(roleDefinitionName,'Key Vault Secrets')].{role:roleDefinitionName, principalName:principalName, principalId:principalId, principalType:principalType}" `
  -o table
```

**期待結果**
- `avd@...` に `Key Vault Secrets Officer`（＋必要なら `Key Vault Secrets User`）
- `kvsecretsuser01@...` に `Key Vault Secrets User` のみ

---

#### 3.3.2 Az PowerShell での操作（VM）
前提：VM に `Az` モジュール導入済み。

##### A) Officer（avd@...）で set 成功
```powershell
Clear-AzContext -Scope Process -Force
Connect-AzAccount -UseDeviceAuthentication
Get-AzContext
```

**期待結果**
- `Get-AzContext` の `Account` が `avd@ryosukemwebengoutlook.onmicrosoft.com`

Secret 操作：
```powershell
$kvName="kv-plat-dev-45bddcd7-001"
$secretName="rbacv2-test-001"

Set-AzKeyVaultSecret -VaultName $kvName -Name $secretName `
  -SecretValue (ConvertTo-SecureString "hello-from-vm" -AsPlainText -Force)

Get-AzKeyVaultSecret -VaultName $kvName -Name $secretName | Select-Object Name, Updated, Id
```

**期待結果**
- `Set-AzKeyVaultSecret` が成功し、`Version` が払い出される
- `Updated` が更新される

##### B) Secrets User（kvsecretsuser01@...）で get 成功 / set Forbidden
```powershell
Clear-AzContext -Scope Process -Force
Connect-AzAccount -UseDeviceAuthentication
Get-AzContext
```

**期待結果**
- `Get-AzContext` の `Account` が `kvsecretsuser01@ryosukemwebengoutlook.onmicrosoft.com`

get（成功）：
```powershell
$kvName="kv-plat-dev-45bddcd7-001"
$secretName="rbacv2-test-001"

Get-AzKeyVaultSecret -VaultName $kvName -Name $secretName | Select-Object Name, Updated, Id
```

set（Forbidden）：
```powershell
Set-AzKeyVaultSecret -VaultName $kvName -Name $secretName `
  -SecretValue (ConvertTo-SecureString "should-fail-from-secrets-user" -AsPlainText -Force)
```

**期待結果**
- `Get-AzKeyVaultSecret` は成功
- `Set-AzKeyVaultSecret` は `Forbidden`
  - Action: `Microsoft.KeyVault/vaults/secrets/setSecret/action`
  - Caller oid: `bcd1212d-6151-4d27-8865-a1b643242d3e`
  - `DenyAssignmentId: null`（明示 deny ではなく権限不足）

---

## 4. Evidence チェックリスト（完了条件）
- [ ] DNS：`vault.azure.net` → `privatelink.vaultcore.azure.net` を確認
- [ ] 443：`RemoteAddress=10.10.1.4` / `TcpTestSucceeded=True`
- [ ] Bastion 経由で VM ログイン可能
- [ ] Officer：Secret `set` 成功（Version/Updated が確認できる）
- [ ] User：Secret `get` 成功
- [ ] User：Secret `set` が Forbidden（Action と Caller oid が記録されている）
- [ ] ロール割当（KV スコープ）の一覧が残っている
- [ ] Exemption（最小緩和・期限付き）の JSON が残っている

---

## 5. 片付け（推奨）
- Exemption の期限到来前に削除または失効を確認
- Bastion / Public IP を削除（不要なら）
- 検証用ユーザー（kvsecretsuser01）を削除（運用で不要なら）

（参考：ユーザー削除）
```powershell
az ad user delete --id kvsecretsuser01@ryosukemwebengoutlook.onmicrosoft.com
```
