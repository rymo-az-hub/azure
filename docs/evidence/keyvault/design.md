# Key Vault baseline v1 - Design

## 1. Purpose / Scope
Key Vault baseline v1 縺ｨ縺励※縲∽ｻ･荳九ｒ IaC + 險ｼ霍｡・・vidence・芽ｾｼ縺ｿ縺ｧ螳滓命縺吶ｋ縲・
- Network・・ublic network access 辟｡蜉ｹ蛹厄ｼ・
- Access Control・・ermission model: Azure RBAC・・
- Diagnostics・・uditEvent 繧・Log Analytics Workspace 縺ｫ騾∽ｿ｡・・
- Tags・・wner / CostCenter / Environment 縺ｮ蠢・亥喧・・
- Evidence・・hat-if / deploy / 險ｭ螳夂｢ｺ隱咲ｵ先棡・・

## 2. Subscription / Region
- Subscription name: Sub-Azure
- Subscription id: 45bddcd7-c7d9-4492-b899-31f78c4cf368
- Location: japaneast

## 3. Resource Placement / Naming
- Resource Group: rg-platform-baseline
- Key Vault name: kvplatbaselinedev001  窶ｻ Key Vault 蜷阪・ 3-24 譁・ｭ励・闍ｱ謨ｰ蟄励・縺ｿ・医ワ繧､繝輔Φ荳榊庄・・
- SKU: standard

## 4. Network Policy
- Public network access: Disabled
- networkAcls:
  - defaultAction: Deny
  - bypass: AzureServices
  - ipRules: none
  - virtualNetworkRules: none

Notes:
- PublicNetworkAccess=Disabled 縺ｮ縺溘ａ縲√ョ繝ｼ繧ｿ繝励Ξ繝ｼ繝ｳ謫堺ｽ懶ｼ・ecret set/get 遲会ｼ峨・
  Private Endpoint + Private DNS 讒区・縺檎┌縺・ｴ蜷医∝渕譛ｬ逧・↓荳榊庄縺ｨ縺ｪ繧九・
- v1 縺ｯ縲檎ｮ｡逅・・繝ｬ繝ｼ繝ｳ縺ｮ繧ｬ繝ｼ繝峨Ξ繝ｼ繝ｫ・狗屮譟ｻ・騎BAC縲阪ｒ蜆ｪ蜈医＠縲・
  Private Endpoint / DNS 縺ｯ v2・域僑蠑ｵ・峨〒蟇ｾ蠢懊☆繧九・

## 5. Access Control Policy (Azure RBAC)
- Permission model: Azure RBAC
- enableRbacAuthorization: true
- accessPolicies: []・・ccess Policy 荳堺ｽｿ逕ｨ・・

Planned Role Assignments (scope = Key Vault):
- admin@ryosukemwebengoutlook.onmicrosoft.com
  - Key Vault Administrator
  - Key Vault Secrets Officer
- avd@ryosukemwebengoutlook.onmicrosoft.com
  - Key Vault Secrets User

## 6. Diagnostics Policy
- Destination:
  - Log Analytics Workspace: law-platform-baseline
  - Resource Group: rg-platform-monitoring
- Categories:
  - Logs: AuditEvent = Enabled
  - Metrics: AllMetrics = Disabled・・1 譁ｹ驥晢ｼ・

## 7. Tag Policy
Required tags:
- Owner
- CostCenter
- Environment

Values (dev):
- Owner: ryosuke
- CostCenter: cc-000
- Environment: dev
