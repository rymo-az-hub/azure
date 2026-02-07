> **Deprecated**: baseline-v1 に統合済み（単体検証用の過去資産）。新規利用は baseline-v1 を使用。

# Key Vault Private Endpoint v1 (Closed)

譛ｬ繝・ぅ繝ｬ繧ｯ繝医Μ縺ｯ縲、zure Key Vault 繧・**Private Endpoint 邨檎罰縺ｮ縺ｿ**縺ｧ蛻ｩ逕ｨ縺吶ｋ縺溘ａ縺ｮ v1 繝吶・繧ｹ繝ｩ繧､繝ｳ繧・IaC・・icep・峨〒菴懈・縺励・逶｣譟ｻ/蠑慕ｶ吶℃縺ｫ閠舌∴繧・Evidence 繧呈ｮ九☆縺薙→繧堤岼逧・→縺励∪縺吶・
> v1 縺ｯ **PE-only + Diagnostics + Evidence** 縺ｾ縺ｧ繧貞ｮ御ｺ・＠繧ｯ繝ｭ繝ｼ繧ｺ縺励∪縺吶・ 
> 谺｡縺ｮ繧ｹ繝・ャ繝励・縲桑ey Vault RBAC・域怙蟆乗ｨｩ髯撰ｼ芽ｨｭ險医阪〒縺吶・
---

## 0. Policy 蜑肴署・磯㍾隕・ｼ・譛ｬ繧ｵ繝悶せ繧ｯ繝ｪ繝励す繝ｧ繝ｳ縺ｫ縺ｯ繝昴Μ繧ｷ繝ｼ繧ｻ繝・ヨ **Platform Baseline v1** 縺悟牡繧雁ｽ薙※繧峨ｌ縺ｦ縺翫ｊ縲∽ｻ･荳九′ **deny** 縺輔ｌ縺ｾ縺吶・
- Resource Group 菴懈・譎ゅ↓蠢・医ち繧ｰ縺檎┌縺・- 蜷・Μ繧ｽ繝ｼ繧ｹ菴懈・譎ゅ↓蠢・医ち繧ｰ縺檎┌縺・
### 蠢・医ち繧ｰ
- `Owner`
- `CostCenter`
- `Environment`

縺薙・縺溘ａ縲・*CLI 縺ｧ菴懈・縺吶ｋ RG / 繝ｪ繧ｽ繝ｼ繧ｹ縺ｫ縺ｯ蠢・★ `--tags` 繧剃ｻ倅ｸ・*縺励※縺上□縺輔＞縲・ 
Bicep 蛛ｴ繧・`tags` 繝代Λ繝｡繝ｼ繧ｿ繧貞女縺大叙繧翫√ち繧ｰ蜿ｯ閭ｽ縺ｪ繝ｪ繧ｽ繝ｼ繧ｹ縺ｫ莉倅ｸ弱＠縺ｾ縺吶・
---

## 1. PowerShell 蜑肴署・磯㍾隕・ｼ・譛ｬ README 縺ｮ繧ｳ繝槭Φ繝我ｾ九・ **Windows PowerShell / PowerShell** 繧貞燕謠舌↓縺励※縺・∪縺吶・
- Bash 縺ｮ陦檎ｶ咏ｶ・`\` 縺ｯ PowerShell 縺ｧ縺ｯ菴ｿ縺医∪縺帙ｓ
- PowerShell 縺ｮ陦檎ｶ咏ｶ壹・繝舌ャ繧ｯ繧ｯ繧ｩ繝ｼ繝・`` ` `` 縺ｧ縺・- 1 陦後〒螳溯｡後＠縺ｦ繧０K縺ｧ縺呻ｼ郁ｪ､蟾ｮ縺悟・縺ｫ縺上＞・・
---

## 2. v1 繧ｹ繧ｳ繝ｼ繝暦ｼ井ｽ懊ｋ / 菴懊ｉ縺ｪ縺・ｼ・
### 菴懈・縺輔ｌ繧九Μ繧ｽ繝ｼ繧ｹ
- Key Vault・・BAC enabled / publicNetworkAccess disabled / SoftDelete+PurgeProtection・・- Private Endpoint・・roupId: `vault`・・- Private DNS Zone: `privatelink.vaultcore.azure.net`
- VNet link・・rivate DNS Zone 竊・VNet・・- Private DNS Zone Group・・ 繝ｬ繧ｳ繝ｼ繝芽・蜍穂ｽ懈・・・- Diagnostic Settings・・eyVault `AuditEvent` 竊・Log Analytics・・
### 菴懊ｉ縺ｪ縺・ｼ・1 縺ｧ諢丞峙逧・↓髯､螟厄ｼ・- Managed HSM / HSM / CMK・井ｺ碁㍾證怜捷・・- 蠖ｹ蜑ｲ縺ｮ邏ｰ蛻・喧・域怙蟆乗ｨｩ髯占ｨｭ險医・ v2/RBAC 邱ｨ縺ｧ螳滓命・・- Firewall 縺ｮ Selected networks 驕狗畑・・1 縺ｯ Public access 辟｡蜉ｹ縺ｧ蜑ｲ繧雁・繧奇ｼ・
---

## 3. v1 繝代Λ繝｡繝ｼ繧ｿ・亥ｮ溽腸蠅・ｼ・- Subscription: `45bddcd7-c7d9-4492-b899-31f78c4cf368`
- Resource Groups:
  - `rg-platform-baseline`
  - `rg-network-baseline`
- VNet / Subnet:
  - `vnet-platform-baseline`
  - `snet-privatelink`・・rivate Endpoint 逕ｨ縲～privateEndpointNetworkPolicies=Disabled`・・- Log Analytics Workspace:
  - `law-platform-baseline`
- Key Vault / PE:
  - `kv-plat-dev-45bddcd7-001`
  - `pe-kv-plat-dev-45bddcd7-001`

---

## 4. 繝・・繝ｭ繧､・亥盾閠・ｼ・v1 縺ｯ縺吶〒縺ｫ繝・・繝ｭ繧､貂医∩縺ｧ繧ｯ繝ｭ繝ｼ繧ｺ縺励※縺・∪縺吶・ 
蟆・擂縺ｮ蜀咲樟縺ｮ縺溘ａ縲∝ｮ溯｡後さ繝槭Φ繝峨ｒ蜿り・→縺励※谿九＠縺ｾ縺吶・
```powershell
cd infra/kv-pe-v1

# what-if・医Ο繧ｰ菫晏ｭ俶耳螂ｨ・・az deployment group what-if -g rg-platform-baseline -f main.bicep -p main.parameters.json

# deploy
az deployment group create -g rg-platform-baseline -f main.bicep -p main.parameters.json
```

---

## 5. Evidence・医☆縺ｧ縺ｫ菴懈・貂医∩・・莉･荳九・ Evidence 繝輔ぃ繧､繝ｫ縺ｯ **譌｢縺ｫ菴懈・貂医∩**縺ｧ縺呻ｼ域悽 README 縺ｯ縺昴・蜑肴署縺ｧ邂｡逅・＠縺ｾ縺呻ｼ峨・
```
docs/evidence/
  kv-pe-v1/
    00_what-if.txt
    01_kv_settings.json
    02_pe_subnet.txt
    03_pe_connection.json
    04_private_dns_a_record.txt
    05_diag_settings.json
```

窶ｻ Evidence 縺ｯ **縲檎函繝ｭ繧ｰ・育函 JSON / 逕溘ユ繧ｭ繧ｹ繝茨ｼ峨・*繧剃ｿ晏ｭ倥＠縺ｦ縺・∪縺吶・Markdown・・md・峨↓謨ｴ蠖｢縺吶ｋ縺ｨ隕九ｄ縺吶￥縺ｪ繧翫∪縺吶′縲・*險ｼ霍｡縺ｨ縺励※縺ｯ謾ｹ螟我ｽ吝慍縺悟ｰ代↑縺・函蜃ｺ蜉帙・譁ｹ縺悟ｼｷ縺・*縺溘ａ縲√％縺ｮ蠖｢蠑上↓縺励※縺・∪縺吶・
### 5.1 Evidence 蜀・ｮｹ・井ｽ輔ｒ險ｼ譏弱＠縺ｦ縺・ｋ縺具ｼ・- `00_what-if.txt`・壹ョ繝励Ο繧､蜑榊ｷｮ蛻・ｼ井ｽ懈・蟇ｾ雎｡繝ｪ繧ｽ繝ｼ繧ｹ/險ｭ螳壹・莠域ｸｬ・・- `01_kv_settings.json`・哮ey Vault 縺ｮ Public 辟｡蜉ｹ / RBAC / SoftDelete / PurgeProtection / retention
- `02_pe_subnet.txt`・啀rivate Endpoint 縺碁・鄂ｮ縺輔ｌ縺・Subnet ID
- `03_pe_connection.json`・啀rivate Link 謗･邯夂憾諷具ｼ・Approved`・峨“roupId・・vault`・・- `04_private_dns_a_record.txt`・啀rivate DNS 縺ｫ A 繝ｬ繧ｳ繝ｼ繝峨′閾ｪ蜍穂ｽ懈・縺輔ｌ縺溘％縺ｨ・・reator metadata・・- `05_diag_settings.json`・啻AuditEvent` 縺・`law-platform-baseline` 縺ｫ騾∽ｿ｡縺輔ｌ繧玖ｨｭ螳・
### 5.2 ・井ｻｻ諢擾ｼ右vidence 繧貞・逕滓・縺吶ｋ蝣ｴ蜷・蟆・擂逧・↓蜀咲函謌舌☆繧句ｴ蜷医・縲∽ｻ･荳九・繧ｳ繝槭Φ繝峨ｒ菴ｿ縺・∪縺呻ｼ・owerShell・峨・窶ｻ譌｢縺ｫ Evidence 縺後≠繧句ｴ蜷医・荳崎ｦ√〒縺吶・
```powershell
$ev = "docs/evidence/kv/kv-pe-v1"
New-Item -ItemType Directory -Force $ev | Out-Null

az deployment group what-if -g rg-platform-baseline -f main.bicep -p main.parameters.json 2>&1 `
  | Out-File "$ev/00_what-if.txt" -Encoding utf8

az keyvault show -n kv-plat-dev-45bddcd7-001 -g rg-platform-baseline -o json `
  --query "{name:name, publicNetworkAccess:properties.publicNetworkAccess, enableRbacAuthorization:properties.enableRbacAuthorization, enableSoftDelete:properties.enableSoftDelete, softDeleteRetentionInDays:properties.softDeleteRetentionInDays, enablePurgeProtection:properties.enablePurgeProtection}" `
  | Out-File "$ev/01_kv_settings.json" -Encoding utf8

az network private-endpoint show -n pe-kv-plat-dev-45bddcd7-001 -g rg-platform-baseline `
  --query "subnet.id" -o tsv `
  | Out-File "$ev/02_pe_subnet.txt" -Encoding utf8

az network private-endpoint show -n pe-kv-plat-dev-45bddcd7-001 -g rg-platform-baseline -o json `
  --query "privateLinkServiceConnections[].{name:name, groupIds:groupIds, status:privateLinkServiceConnectionState.status, description:privateLinkServiceConnectionState.description, privateLinkServiceId:privateLinkServiceId}" `
  | Out-File "$ev/03_pe_connection.json" -Encoding utf8

az network private-dns record-set a list -g rg-platform-baseline -z privatelink.vaultcore.azure.net -o table `
  | Out-File "$ev/04_private_dns_a_record.txt" -Encoding utf8

az monitor diagnostic-settings list `
  --resource $(az keyvault show -n kv-plat-dev-45bddcd7-001 -g rg-platform-baseline --query id -o tsv) -o json `
  | Out-File "$ev/05_diag_settings.json" -Encoding utf8
```

---

## 6. v1 繧ｯ繝ｭ繝ｼ繧ｺ譚｡莉ｶ・域ｺ縺溘＠縺ｦ縺・ｋ縺薙→・・- Key Vault: `publicNetworkAccess=Disabled`, `enableRbacAuthorization=true`, `SoftDelete/PurgeProtection=true`
- Private Endpoint: `Approved` / `Succeeded`縲ヾubnet 縺・`snet-privatelink`
- Private DNS: `privatelink.vaultcore.azure.net` 縺ｫ A 繝ｬ繧ｳ繝ｼ繝峨′閾ｪ蜍穂ｽ懈・
- Diagnostics: `AuditEvent` 縺・`law-platform-baseline` 縺ｫ騾∽ｿ｡

---

## 7. 谺｡縺ｮ繧ｹ繝・ャ繝暦ｼ・2・哮ey Vault RBAC 譛蟆乗ｨｩ髯占ｨｭ險茨ｼ・v2 縺ｧ縺ｯ莉･荳九ｒ險ｭ險医・螳溯｣・＠縺ｾ縺吶・- 邂｡逅・・Ο繝ｼ繝ｫ・磯°逕ｨ閠・ｼ峨→繧｢繝励Μ/閾ｪ蜍募喧・・I/CD, 逶｣隕厄ｼ峨ｒ蛻・屬
- Key / Secret / Certificate 縺斐→縺ｮ譛蟆乗ｨｩ髯・- RBAC 縺ｮ蜑ｲ蠖灘腰菴搾ｼ・ault 繧ｹ繧ｳ繝ｼ繝・/ Resource Group / Subscription・峨→驕狗畑繝ｫ繝ｼ繝ｫ
- Access Review / 譛滄剞莉倥″莉倅ｸ趣ｼ・IM 縺後≠繧句ｴ蜷茨ｼ・
