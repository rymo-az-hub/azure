> **Deprecated**: baseline-v1 に統合済み（単体検証用の過去資産）。新規利用は baseline-v1 を使用。

# Key Vault RBAC v2 (Least Privilege)

Key Vault: `kv-plat-dev-45bddcd7-001`  
Scope: `/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kv-plat-dev-45bddcd7-001`

## 迥ｶ諷具ｼ医≠縺ｪ縺溘・邨先棡・・- 縺ゅ↑縺溘・繧ｵ繝悶せ繧ｯ繝ｪ繝励す繝ｧ繝ｳ縺ｫ蟇ｾ縺励※ **Owner** 繧剃ｿ晄戟 竊・RBAC 莉倅ｸ弱・螳滓命蜿ｯ閭ｽ
- KV 繧ｹ繧ｳ繝ｼ繝励↓ Reader 繧剃ｽ懈・縺ｧ縺阪◆ 竊・v2 繧・IaC 縺ｧ騾ｲ繧√※OK

> 縺溘□縺励，LI 縺ｧ菴懊▲縺・role assignment 縺ｯ GUID 蜷搾ｼ医Λ繝ｳ繝繝・峨〒谿九ｊ縺ｾ縺吶・ 
> IaC 縺ｧ縺ｯ `guid(kv.id, principalId, roleId)` 縺ｧ **豎ｺ螳夂噪縺ｪ蜷榊燕**繧剃ｽ懊ｋ縺溘ａ縲・> **蜷後§讓ｩ髯舌′莠碁㍾莉倅ｸ・*縺輔ｌ繧句庄閭ｽ諤ｧ縺後≠繧翫∪縺呻ｼ亥ｮｳ縺ｯ蟆代↑縺・′豎壹＞・峨・> 蜿ｯ閭ｽ縺ｪ繧峨∵ｬ｡遶縺ｧ荳譌ｦ蜑企勁縺励※縺九ｉ IaC 繧帝←逕ｨ縺励※縺上□縺輔＞縲・
---

## 1) 迚・ｻ倥￠・域耳螂ｨ・・ 繝・せ繝育畑 Reader 縺ｮ蜑企勁
縺ゅ↑縺溘′菴懈・縺励◆ Reader 縺ｮ role assignment id:
`/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kv-plat-dev-45bddcd7-001/providers/Microsoft.Authorization/roleAssignments/843b9f81-a559-43c2-b34d-cf28738b9f42`

蜑企勁・域耳螂ｨ・・
```powershell
az role assignment delete --ids "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kv-plat-dev-45bddcd7-001/providers/Microsoft.Authorization/roleAssignments/843b9f81-a559-43c2-b34d-cf28738b9f42"
```

---

## 2) 險ｭ險茨ｼ域怙蟆乗ｨｩ髯舌・蝙具ｼ・### 荳ｻ菴難ｼ・rincipal・・1. Break-glass 邂｡逅・・ｼ域怙蟆丈ｺｺ謨ｰ縲よ勸谿ｵ縺ｯ菴ｿ繧上↑縺・ｼ・2. Secrets 驕狗畑・井ｽ懈・/譖ｴ譁ｰ/蜑企勁・・3. Secrets 蛻ｩ逕ｨ・郁ｪｭ縺ｿ蜿悶ｊ縺ｮ縺ｿ縲ゅい繝励Μ/CI/CD 縺ｮ Managed Identity 遲会ｼ・4. 逶｣譟ｻ/髢ｲ隕ｧ・郁ｨｭ螳壹ｒ隕九ｋ縺縺代ゅョ繝ｼ繧ｿ髱｢縺ｯ隗ｦ繧峨↑縺・ｼ・
### 繝ｭ繝ｼ繝ｫ
- Break-glass: **Key Vault Administrator**
- Secrets 驕狗畑: **Key Vault Secrets Officer**
- Secrets 蛻ｩ逕ｨ: **Key Vault Secrets User**
- 逶｣譟ｻ/髢ｲ隕ｧ: **Reader**・・V 繝ｪ繧ｽ繝ｼ繧ｹ縺ｫ蟇ｾ縺励※・・
**蜴溷援**: 莠ｺ縺ｯ Entra ID 繧ｰ繝ｫ繝ｼ繝励↓莉倅ｸ趣ｼ医Θ繝ｼ繧ｶ繝ｼ逶ｴ謗･莉倅ｸ弱・驕ｿ縺代ｋ・・ 
繧｢繝励Μ/閾ｪ蜍募喧縺ｯ Managed Identity 繧・principalId 縺ｨ縺励※莉倅ｸ弱＠縺ｦOK

---

## 3) 螳溯｣・ｼ・icep・・縺薙・繝輔か繝ｫ繝縺ｮ讒区・:
- `rbac.bicep`
- `rbac.parameters.json`

### 3.1 繝代Λ繝｡繝ｼ繧ｿ邱ｨ髮・`rbac.parameters.json` 縺ｮ驟榊・縺ｫ蟇ｾ雎｡ principal 縺ｮ **objectId** 繧貞・繧後ｋ:

- `kvAdmins`: Break-glass 逕ｨ繧ｰ繝ｫ繝ｼ繝暦ｼ域耳螂ｨ・・- `secretsOfficers`: Secrets 驕狗畑閠・げ繝ｫ繝ｼ繝・- `secretsUsers`: 繧｢繝励Μ/CI/CD 縺ｮ Managed Identity objectId
- `kvReaders`: 逶｣譟ｻ/髢ｲ隕ｧ閠・ｼ亥ｿ・ｦ√↑繧会ｼ・
### 3.2 what-if / deploy
```powershell
az deployment group what-if -g rg-platform-baseline -f rbac.bicep -p rbac.parameters.json
az deployment group create -g rg-platform-baseline -f rbac.bicep -p rbac.parameters.json
```

---

## 4) Evidence・・2・・```
docs/evidence/
  kv-rbac-v2/
    00_what-if.txt
    01_role_assignments_kv.json
    02_role_assignments_sub.txt
```

蜿門ｾ・
```powershell
$ev = "docs/evidence/kv/rbac-v2"
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

## 5) 谺｡縺ｮ繧｢繧ｯ繧ｷ繝ｧ繝ｳ・医％縺薙°繧会ｼ・1) Entra ID 繧ｰ繝ｫ繝ｼ繝暦ｼ医∪縺溘・ MI・峨・ **objectId** 繧呈ｱｺ繧√ｋ  
2) `rbac.parameters.json` 縺ｫ蜿肴丐  
3) what-if 竊・deploy 竊・Evidence 繧貞叙蠕・
