# Commands used on Day 3 (summary) / Day3コマンド一覧（2026-02-03）

PowerShell 前提。Azure CLI は `az`、VM 内は Az PowerShell を使用。

---

## Azure context / 認証・コンテキスト確認

# subscription 確認
az account show --query "{name:name,id:id,user:user.name,tenantId:tenantId}" -o jsonc

# policy assignment（subscription）
az policy assignment list --scope "/subscriptions/<subId>" -o table

# kv resource id
$kvId = az keyvault show -g rg-platform-baseline -n kv-plat-dev-45bddcd7-001 --query id -o tsv

---

## Policy Exemption（Public IP deny の最小緩和）

# exemption 確認
$rgScope="/subscriptions/<subId>/resourceGroups/rg-network-baseline"
az policy exemption show --name ex-allow-publicip-for-bastion --scope $rgScope -o jsonc

---

## Public IP / Bastion 作成

# Public IP
az network public-ip create `
  -g rg-network-baseline `
  -n pip-bastion-dev-001 `
  --sku Standard `
  --allocation-method Static `
  --location japaneast `
  --tags Owner=platform CostCenter=cc000 Environment=dev

# AzureBastionSubnet
az network vnet subnet create `
  -g rg-network-baseline `
  --vnet-name vnet-platform-baseline `
  -n AzureBastionSubnet `
  --address-prefixes 10.10.3.0/26

# Bastion
az network bastion create `
  -g rg-network-baseline `
  -n bas-platform-dev-001 `
  --vnet-name vnet-platform-baseline `
  --public-ip-address pip-bastion-dev-001 `
  --location japaneast `
  --tags Owner=platform CostCenter=cc000 Environment=dev

# 状態確認
az network bastion show -g rg-network-baseline -n bas-platform-dev-001 --query "{state:provisioningState, sku:sku.name, scale:scaleUnits}" -o jsonc

---

## VM からの DNS/到達性（Private Endpoint）

# VM 内 PowerShell
$kv="kv-plat-dev-45bddcd7-001.vault.azure.net"
nslookup $kv
Test-NetConnection $kv -Port 443

---

## VM 内：Az PowerShell 導入 & ログイン

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Az -Scope CurrentUser -Repository PSGallery -Force -AllowClobber
Import-Module Az

Connect-AzAccount -UseDeviceAuthentication
Get-AzContext

---

## Key Vault RBAC（割当確認・逆引き）

# ローカル：KV スコープの RoleAssignment（Key Vault Secrets*）
az role assignment list --scope $kvId `
  --query "[?contains(roleDefinitionName,'Key Vault Secrets')].{role:roleDefinitionName, principalName:principalName, principalId:principalId, principalType:principalType}" `
  -o table

# ローカル：signed-in user oid
az ad signed-in-user show --query "{upn:userPrincipalName, oid:id}" -o jsonc

---

## 追加ユーザー作成 & Secrets User 付与（主体分離）

$newUpn="kvsecretsuser01@ryosukemwebengoutlook.onmicrosoft.com"
az ad user create --display-name "KV Secrets User 01" --user-principal-name $newUpn --password "<tempPw>" --force-change-password-next-sign-in true

$newOid = az ad user show --id $newUpn --query id -o tsv

az role assignment create --assignee-object-id $newOid --assignee-principal-type User `
  --role "Key Vault Secrets User" --scope $kvId

az role assignment list --scope $kvId --assignee-object-id $newOid `
  --query "[].{role:roleDefinitionName,principalId:principalId,scope:scope}" -o table

---

## Secret 操作（Officer 成功 / User 失敗の差分）

# VM 内（Officer または User でログイン後）
$kvName="kv-plat-dev-45bddcd7-001"
$secretName="rbacv2-test-001"

# get（成功）
Get-AzKeyVaultSecret -VaultName $kvName -Name $secretName | Select-Object Name, Updated, Id

# set（Officer は成功 / Secrets User は Forbidden）
Set-AzKeyVaultSecret -VaultName $kvName -Name $secretName `
  -SecretValue (ConvertTo-SecureString "hello-from-vm" -AsPlainText -Force)

---

## クリーンアップ（コスト最適化）

# Bastion / Public IP / Exemption / 追加ユーザー
az network bastion delete -g rg-network-baseline -n bas-platform-dev-001
az network public-ip delete -g rg-network-baseline -n pip-bastion-dev-001
az policy exemption delete --name ex-allow-publicip-for-bastion --scope $rgScope
az ad user delete --id kvsecretsuser01@ryosukemwebengoutlook.onmicrosoft.com

# VM と残骸（NIC/NSG/Disk）
az vm delete -g rg-platform-baseline -n vmkvtestdev001 --yes
az network nic delete -g rg-platform-baseline -n nic-vmkvtestdev001
az network nsg delete -g rg-platform-baseline -n nsg-vmkvtestdev001
az disk delete -g rg-platform-baseline -n vmkvtestdev001_OsDisk_1_<guid> --yes

# 残リソース確認（RG）
az resource list -g rg-platform-baseline --query "[].{type:type,name:name}" -o table
az resource list -g rg-network-baseline --query "[].{type:type,name:name}" -o table

---

## LAW / Diagnostic settings（取り込み停止）

# LAW 設定確認
az monitor log-analytics workspace show -g rg-platform-baseline -n law-platform-baseline --query "{retentionInDays:retentionInDays,sku:sku.name}" -o jsonc

# 使用量（0 Bytes を確認）
az monitor log-analytics workspace list-usages -g rg-platform-baseline -n law-platform-baseline -o table

# Key Vault 診断設定（存在確認 → 削除）
$kvId = az keyvault show -g rg-platform-baseline -n kv-plat-dev-45bddcd7-001 --query id -o tsv
az monitor diagnostic-settings list --resource $kvId -o table
az monitor diagnostic-settings delete --name diag-to-law --resource $kvId
