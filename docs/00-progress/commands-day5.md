# Commands Log (2026-02-08)

> 目的: Day5 で実行した主要コマンドの記録（再現性 / Evidence 用）

---

## Repo状態確認（ローカルPC）

```powershell
$repoRoot = (Get-Location).Path
git status
git diff
git log --oneline -5
```

---

## Azure: RG / NIC の location 確認（ローカルPC）

```powershell
az group show -n rg-platform-baseline --query location -o tsv
az network nic show -g rg-platform-baseline -n vmkvdev02-nic --query location -o tsv
```

---

## Azure: VM 作成（Public IP なし / 既存 NIC 利用）

> Note: `japaneast` の Capacity Restrictions により、サイズ変更を複数回試行した。

```powershell
# 失敗例（SkuNotAvailable）
az --% vm create -g rg-platform-baseline -n vmkvdev02 --nics vmkvdev02-nic --image Win2022Datacenter --size Standard_B2s --admin-username localadmin --authentication-type password --admin-password <redacted> --public-ip-address "" --tags CostCenter=cc000 Environment=dev Owner=platform -o jsonc

az --% vm create -g rg-platform-baseline -n vmkvdev02 --nics vmkvdev02-nic --image Win2022Datacenter --size Standard_D2s_v5 --admin-username localadmin --authentication-type password --admin-password <redacted> --public-ip-address "" --tags CostCenter=cc000 Environment=dev Owner=platform -o jsonc

az --% vm create -g rg-platform-baseline -n vmkvdev02 --nics vmkvdev02-nic --image Win2022Datacenter --size Standard_D2as_v5 --admin-username localadmin --authentication-type password --admin-password <redacted> --public-ip-address "" --tags CostCenter=cc000 Environment=dev Owner=platform -o jsonc

# 成功（回避策）
az --% vm create -g rg-platform-baseline -n vmkvdev02 --nics vmkvdev02-nic --image Win2022Datacenter --size Standard_D2s_v4 --admin-username localadmin --authentication-type password --admin-password <redacted> --public-ip-address "" --tags CostCenter=cc000 Environment=dev Owner=platform -o jsonc
```

---

## Azure: VM 作成確認（ローカルPC）

```powershell
az vm show -g rg-platform-baseline -n vmkvdev02 --show-details --query "{name:name, provisioningState:provisioningState, privateIp:privateIps, publicIp:publicIps}" -o jsonc
```

---

## VM 内: PrivateLink 疎通（DNS / 443）

```powershell
$kv = "kv-plat-dev-45bddcd7-001"

nslookup "$kv.vault.azure.net"
Test-NetConnection "$kv.vault.azure.net" -Port 443
```

---

## VM 内: Az PowerShell 導入（Azure CLI 無しのため）

```powershell
# NuGet provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# TLS / PSGallery
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Az modules
Install-Module Az -Scope CurrentUser -Force
Get-Module -ListAvailable Az.Accounts, Az.KeyVault | Select Name, Version | Format-Table -Auto
```

---

## VM 内: ログイン（Device Code）と KV Read/Write

```powershell
Connect-AzAccount -Tenant "0cac0579-b904-40f5-ba88-9384967c64fb" -UseDeviceAuthentication
Set-AzContext -Subscription "45bddcd7-c7d9-4492-b899-31f78c4cf368"

Get-AzContext | Select Account, Subscription, Tenant | Format-List

$kv = "kv-plat-dev-45bddcd7-001"

# Read
Get-AzKeyVaultSecret -VaultName $kv

# Write（Forbidden を期待）
Set-AzKeyVaultSecret -VaultName $kv -Name "evidence-test" -SecretValue (ConvertTo-SecureString "hello" -AsPlainText -Force)
```

---

## VM 内: Role Assignment 裏取り（KV スコープ）

```powershell
(Get-AzADUser -UserPrincipalName "avd@ryosukemwebengoutlook.onmicrosoft.com").Id

$kvId = (Get-AzKeyVault -VaultName "kv-plat-dev-45bddcd7-001").ResourceId
Get-AzRoleAssignment -Scope $kvId |
  Select-Object ObjectId, DisplayName, SignInName, RoleDefinitionName, Scope |
  Sort-Object RoleDefinitionName, SignInName |
  Format-Table -Auto
```

---

## Evidence 配置と README 導線

```powershell
$repoRoot = (Get-Location).Path

New-Item -ItemType Directory -Force (Join-Path $repoRoot "docs\evidence\kv\rbac-v2") | Out-Null

@'
# Evidence: kv rbac-v2

## Index
- 2026-02-08: PrivateLink reachability + RBAC least privilege (Read OK / Write NG)
  - ./2026-02-08-privatelink-rbac-readok-writeforbidden.md
'@ | Set-Content -Encoding utf8 (Join-Path $repoRoot "docs\evidence\kv\rbac-v2\README.md")
```

---

## Git: safecrlf 対応（CRLF -> LF）

```powershell
$repoRoot = (Get-Location).Path
$path = (Resolve-Path (Join-Path $repoRoot "docs\evidence\README.md")).Path
$txt  = Get-Content $path -Raw
$txt  = $txt -replace "`r`n", "`n"
[System.IO.File]::WriteAllText($path, $txt, (New-Object System.Text.UTF8Encoding($false)))
```

---

## Git: add / commit / push

```powershell
git add docs/evidence/README.md docs/evidence/kv/rbac-v2/README.md docs/evidence/kv/rbac-v2/2026-02-08-privatelink-rbac-readok-writeforbidden.md
git commit -m "docs(evidence): add kv rbac-v2 privatelink/read-write evidence"
git push

git show --name-only --oneline -1
git status
```

---

## Azure: クリーンアップ（ローカルPC）

```powershell
az vm delete -g rg-platform-baseline -n vmkvdev02 --yes
az network nic delete -g rg-platform-baseline -n vmkvdev02-nic
az network nsg delete -g rg-platform-baseline -n vmkvdev02-nsg

az vm show -g rg-platform-baseline -n vmkvdev02

az disk list -g rg-platform-baseline -o table
az disk delete -g rg-platform-baseline -n vmkvdev02_OsDisk_1_4ade77e74a1b404cbb700061db4587f8 --yes

az network nic list -g rg-platform-baseline -o table
az resource list -g rg-platform-baseline --query "[].{type:type,name:name}" -o table
```
