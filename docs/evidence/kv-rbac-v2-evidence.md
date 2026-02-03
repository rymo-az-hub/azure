# Key Vault RBAC v2 Evidence・・rivate Endpoint / 譛蟆乗ｨｩ髯撰ｼ・
## 0. 逶ｮ逧・- Key Vault 繧・**Azure RBAC・域怙蟆乗ｨｩ髯撰ｼ・*縺ｧ驕狗畑縺ｧ縺阪ｋ縺薙→繧堤｢ｺ隱阪☆繧・- **Private Endpoint 邨檎罰**縺ｧ蛻ｰ驕斐＠縺ｦ縺・ｋ縺薙→繧堤｢ｺ隱阪☆繧・- 蠖ｹ蜑ｲ蟾ｮ蛻・ｼ・fficer 縺ｨ User・峨↓繧医ｊ **Get 縺ｯ蜿ｯ / Set 縺ｯ荳榊庄**縺ｮ蜍穂ｽ懷ｷｮ蛻・ｒ Evidence 縺ｨ縺励※谿九☆

---

## 1. 蟇ｾ雎｡繝ｻ蜑肴署

### 1.1 蟇ｾ雎｡繝ｪ繧ｽ繝ｼ繧ｹ
- Subscription: `Sub-Azure (45bddcd7-c7d9-4492-b899-31f78c4cf368)`
- Key Vault: `kv-plat-dev-45bddcd7-001`
- Key Vault RG: `rg-platform-baseline`
- VNET: `vnet-platform-baseline`・・g: `rg-network-baseline`・・- Private Endpoint IP: `10.10.1.4`
- Workload VM: `vmkvtestdev001`・・rivate IP: `10.10.2.5`・・- Bastion: `bas-platform-dev-001`・・g: `rg-network-baseline`・・- Bastion Public IP: `pip-bastion-dev-001`

### 1.2 讀懆ｨｼ蟇ｾ雎｡縺ｮ荳ｻ菴難ｼ・ntra ID・・- 荳ｻ菴鄭・・fficer・・ `avd@ryosukemwebengoutlook.onmicrosoft.com`
  - RoleAssignments・・V 繧ｹ繧ｳ繝ｼ繝暦ｼ・ `Key Vault Secrets Officer`・茨ｼ句ｿ・ｦ√↑繧・`Key Vault Secrets User`・・- 荳ｻ菴釘・・ser・・ `kvsecretsuser01@ryosukemwebengoutlook.onmicrosoft.com`
  - objectId: `bcd1212d-6151-4d27-8865-a1b643242d3e`
  - RoleAssignments・・V 繧ｹ繧ｳ繝ｼ繝暦ｼ・ `Key Vault Secrets User` 縺ｮ縺ｿ

### 1.3 險ｭ險域婿驥・- Key Vault 縺ｸ縺ｮ謗･邯壹・ Private Endpoint 蜑肴署・・M 縺九ｉ DNS/蛻ｰ驕疲ｧ繧堤｢ｺ隱搾ｼ・- RBAC v2 縺ｮ譛蟆乗ｨｩ髯舌ｒ縲御ｸｻ菴灘・髮｢縲阪〒讀懆ｨｼ・・fficer 縺ｨ User・・- Bastion 縺ｮ縺溘ａ縺ｮ Public IP 縺ｯ繝昴Μ繧ｷ繝ｼ縺ｧ deny 縺輔ｌ繧九◆繧√・*譛蟆冗ｷｩ蜥鯉ｼ・olicy Exemption・・*縺ｮ縺ｿ螳滓命

---

## 2. Evidence 蜿門ｾ励・蜈ｨ菴灘ワ・井ｽ輔ｒ險ｼ譏弱☆繧九°・・1) VM 縺九ｉ KV 縺ｸ **Private Endpoint 邨檎罰**縺ｧ蛻ｰ驕斐〒縺阪ｋ・・NS 縺ｨ 443・・2) Bastion 邨檎罰縺ｧ VM 縺ｫ繝ｭ繧ｰ繧､繝ｳ縺ｧ縺阪ｋ・域桃菴懆ｨｼ霍｡縺ｮ邨瑚ｷｯ・・3) RBAC 縺ｫ繧医ｊ莉･荳九′謌千ｫ九☆繧具ｼ域怙蟆乗ｨｩ髯舌・蟾ｮ蛻・ｼ・   - Officer: `set` 縺・**謌仙粥**
   - User: `get` 縺・**謌仙粥**縲～set` 縺・**Forbidden**

---

## 3. Evidence 縺ｮ蜿門ｾ玲焔鬆・ｼ医さ繝槭Φ繝峨→譛溷ｾ・ｵ先棡・・
> 豕ｨ諢・> - 繝代せ繝ｯ繝ｼ繝峨・遘伜ｯ・､縺ｯ Evidence 縺ｫ谿九＆縺ｪ縺・ｼ亥ｿ・ｦ√↑繧峨・繧ｹ繧ｯ・・> - 繧ｹ繧ｯ繧ｷ繝ｧ縺ｯ `docs/evidence/screenshots/kv-rbac-v2/` 縺ｫ菫晏ｭ假ｼ域耳螂ｨ・・
---

### 3.1 Bastion 謗･邯壹・謌千ｫ具ｼ・M 縺ｸ蜈･繧後ｋ迥ｶ諷具ｼ・
#### 3.1.1 Policy Exemption・域怙蟆冗ｷｩ蜥鯉ｼ・- initiative `ps-platform-baseline-v1` 縺ｮ蜿ら・ `denyResourceTypes-publicip` 縺ｮ縺ｿ繧・- `rg-network-baseline` 繧ｹ繧ｳ繝ｼ繝励〒 Exemption・域悄髯蝉ｻ倥″・我ｽ懈・

**Evidence・郁ｲｼ莉・繧ｹ繧ｯ繧ｷ繝ｧ・・*
- `az policy exemption show` 縺ｮ JSON
  - `scope` 縺・`rg-network-baseline`
  - `policyDefinitionReferenceIds` 縺ｫ `denyResourceTypes-publicip` 縺ｮ縺ｿ
  - `expiresOn` 縺瑚ｨｭ螳壹＆繧後※縺・ｋ縺薙→

・亥盾閠・さ繝槭Φ繝会ｼ・```powershell
$sub="45bddcd7-c7d9-4492-b899-31f78c4cf368"
$rgScope="/subscriptions/$sub/resourceGroups/rg-network-baseline"
az policy exemption show --name ex-allow-publicip-for-bastion --scope $rgScope -o jsonc
```

#### 3.1.2 Public IP / Bastion 菴懈・
**Evidence・郁ｲｼ莉・繧ｹ繧ｯ繧ｷ繝ｧ・・*
- Public IP 菴懈・謌仙粥・・provisioningState: Succeeded`縲√ち繧ｰ莉倅ｸ趣ｼ・- Bastion 菴懈・・・sku: Standard`縲～AzureBastionSubnet`縲￣ublic IP 縺ｮ邏蝉ｻ倥￠・・
・亥盾閠・さ繝槭Φ繝会ｼ・```powershell
az network public-ip show -g rg-network-baseline -n pip-bastion-dev-001 -o jsonc
az network bastion show -g rg-network-baseline -n bas-platform-dev-001 -o jsonc
```

---

### 3.2 Private Endpoint 邨檎罰縺ｮ DNS/蛻ｰ驕疲ｧ・・M 10.10.2.5・・
VM・・owerShell・峨〒莉･荳九ｒ螳溯｡後・
#### 3.2.1 DNS
```powershell
$kv="kv-plat-dev-45bddcd7-001.vault.azure.net"
nslookup $kv
```

**譛溷ｾ・ｵ先棡**
- `kv-...vault.azure.net` 縺・`kv-....privatelink.vaultcore.azure.net` 縺ｫ隗｣豎ｺ
- A 繝ｬ繧ｳ繝ｼ繝峨′ `10.10.1.4` 繧定ｿ斐☆

#### 3.2.2 蛻ｰ驕疲ｧ・・43・・```powershell
Test-NetConnection $kv -Port 443
```

**譛溷ｾ・ｵ先棡**
- `RemoteAddress: 10.10.1.4`
- `TcpTestSucceeded: True`
- `SourceAddress: 10.10.2.5`

---

### 3.3 RBAC v2・域怙蟆乗ｨｩ髯撰ｼ峨・蟾ｮ蛻・Evidence・井ｸｻ菴灘・髮｢・・
#### 3.3.1 繝ｭ繝ｼ繝ｫ蜑ｲ蠖難ｼ・V 繧ｹ繧ｳ繝ｼ繝暦ｼ臥｢ｺ隱搾ｼ医Ο繝ｼ繧ｫ繝ｫ遶ｯ譛ｫ・・```powershell
$kvId = az keyvault show -g rg-platform-baseline -n kv-plat-dev-45bddcd7-001 --query id -o tsv

az role assignment list --scope $kvId `
  --query "[?contains(roleDefinitionName,'Key Vault Secrets')].{role:roleDefinitionName, principalName:principalName, principalId:principalId, principalType:principalType}" `
  -o table
```

**譛溷ｾ・ｵ先棡**
- `avd@...` 縺ｫ `Key Vault Secrets Officer`・茨ｼ句ｿ・ｦ√↑繧・`Key Vault Secrets User`・・- `kvsecretsuser01@...` 縺ｫ `Key Vault Secrets User` 縺ｮ縺ｿ

---

#### 3.3.2 Az PowerShell 縺ｧ縺ｮ謫堺ｽ懶ｼ・M・・蜑肴署・啖M 縺ｫ `Az` 繝｢繧ｸ繝･繝ｼ繝ｫ蟆主・貂医∩縲・
##### A) Officer・・vd@...・峨〒 set 謌仙粥
```powershell
Clear-AzContext -Scope Process -Force
Connect-AzAccount -UseDeviceAuthentication
Get-AzContext
```

**譛溷ｾ・ｵ先棡**
- `Get-AzContext` 縺ｮ `Account` 縺・`avd@ryosukemwebengoutlook.onmicrosoft.com`

Secret 謫堺ｽ懶ｼ・```powershell
$kvName="kv-plat-dev-45bddcd7-001"
$secretName="rbacv2-test-001"

Set-AzKeyVaultSecret -VaultName $kvName -Name $secretName `
  -SecretValue (ConvertTo-SecureString "hello-from-vm" -AsPlainText -Force)

Get-AzKeyVaultSecret -VaultName $kvName -Name $secretName | Select-Object Name, Updated, Id
```

**譛溷ｾ・ｵ先棡**
- `Set-AzKeyVaultSecret` 縺梧・蜉溘＠縲～Version` 縺梧鴛縺・・縺輔ｌ繧・- `Updated` 縺梧峩譁ｰ縺輔ｌ繧・
##### B) Secrets User・・vsecretsuser01@...・峨〒 get 謌仙粥 / set Forbidden
```powershell
Clear-AzContext -Scope Process -Force
Connect-AzAccount -UseDeviceAuthentication
Get-AzContext
```

**譛溷ｾ・ｵ先棡**
- `Get-AzContext` 縺ｮ `Account` 縺・`kvsecretsuser01@ryosukemwebengoutlook.onmicrosoft.com`

get・域・蜉滂ｼ会ｼ・```powershell
$kvName="kv-plat-dev-45bddcd7-001"
$secretName="rbacv2-test-001"

Get-AzKeyVaultSecret -VaultName $kvName -Name $secretName | Select-Object Name, Updated, Id
```

set・・orbidden・会ｼ・```powershell
Set-AzKeyVaultSecret -VaultName $kvName -Name $secretName `
  -SecretValue (ConvertTo-SecureString "should-fail-from-secrets-user" -AsPlainText -Force)
```

**譛溷ｾ・ｵ先棡**
- `Get-AzKeyVaultSecret` 縺ｯ謌仙粥
- `Set-AzKeyVaultSecret` 縺ｯ `Forbidden`
  - Action: `Microsoft.KeyVault/vaults/secrets/setSecret/action`
  - Caller oid: `bcd1212d-6151-4d27-8865-a1b643242d3e`
  - `DenyAssignmentId: null`・域・遉ｺ deny 縺ｧ縺ｯ縺ｪ縺乗ｨｩ髯蝉ｸ崎ｶｳ・・
---

## 4. Evidence 繝√ぉ繝・け繝ｪ繧ｹ繝茨ｼ亥ｮ御ｺ・擅莉ｶ・・- [ ] DNS・啻vault.azure.net` 竊・`privatelink.vaultcore.azure.net` 繧堤｢ｺ隱・- [ ] 443・啻RemoteAddress=10.10.1.4` / `TcpTestSucceeded=True`
- [ ] Bastion 邨檎罰縺ｧ VM 繝ｭ繧ｰ繧､繝ｳ蜿ｯ閭ｽ
- [ ] Officer・售ecret `set` 謌仙粥・・ersion/Updated 縺檎｢ｺ隱阪〒縺阪ｋ・・- [ ] User・售ecret `get` 謌仙粥
- [ ] User・售ecret `set` 縺・Forbidden・・ction 縺ｨ Caller oid 縺瑚ｨ倬鹸縺輔ｌ縺ｦ縺・ｋ・・- [ ] 繝ｭ繝ｼ繝ｫ蜑ｲ蠖難ｼ・V 繧ｹ繧ｳ繝ｼ繝暦ｼ峨・荳隕ｧ縺梧ｮ九▲縺ｦ縺・ｋ
- [ ] Exemption・域怙蟆冗ｷｩ蜥後・譛滄剞莉倥″・峨・ JSON 縺梧ｮ九▲縺ｦ縺・ｋ

---

## 5. 迚・ｻ倥￠・域耳螂ｨ・・- Exemption 縺ｮ譛滄剞蛻ｰ譚･蜑阪↓蜑企勁縺ｾ縺溘・螟ｱ蜉ｹ繧堤｢ｺ隱・- Bastion / Public IP 繧貞炎髯､・井ｸ崎ｦ√↑繧会ｼ・- 讀懆ｨｼ逕ｨ繝ｦ繝ｼ繧ｶ繝ｼ・・vsecretsuser01・峨ｒ蜑企勁・磯°逕ｨ縺ｧ荳崎ｦ√↑繧会ｼ・
・亥盾閠・ｼ壹Θ繝ｼ繧ｶ繝ｼ蜑企勁・・```powershell
az ad user delete --id kvsecretsuser01@ryosukemwebengoutlook.onmicrosoft.com
```
