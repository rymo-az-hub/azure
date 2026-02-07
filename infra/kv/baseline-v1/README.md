# Key Vault baseline-v1

## 概要
このテンプレートは Key Vault baseline の **正本**です。
含むもの:
- Key Vault
- Private Endpoint
- Private DNS（privatelink.vaultcore.azure.net 等）
- Diagnostic settings -> Log Analytics
- RBAC（Key Vault RBAC）

## デプロイ
例:
az deployment group create -g <rg> -f main.bicep -p main.parameters.json
