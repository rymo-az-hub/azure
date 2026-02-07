# Key Vault baseline v2 Evidence — PrivateLink reachability + RBAC least privilege (Read OK / Write NG)

## Goal
- Verify `publicNetworkAccess=Disabled` blocks non-PrivateLink access paths
- Verify PrivateLink-based reachability from a workload subnet VM
- Verify RBAC least-privilege behavior: **Secrets Read allowed / Secrets Write denied**

---

## Target resources
- **Key Vault**: `kv-plat-dev-45bddcd7-001`  
  - `publicNetworkAccess = Disabled`  
  - `enableRbacAuthorization = true`
- **VNet**: `vnet-platform-baseline` (RG: `rg-network-baseline`)  
  - Subnets: `snet-privatelink`, `snet-workload`, `AzureBastionSubnet`

---

## Verification environment
- **Temporary VM**: `vmkvdev02` (RG: `rg-platform-baseline`)  
  - Private IP: `10.10.2.4`  
  - Public IP: none  
  - Access: via Bastion
- **Authenticated principal (Azure PowerShell in VM)**
  - Account: `avd@ryosukemwebengoutlook.onmicrosoft.com`
  - ObjectId: `eeb850f4-8f4c-4daf-a2f2-99cbab6e8184`
  - Subscription: `45bddcd7-c7d9-4492-b899-31f78c4cf368`
  - Tenant: `0cac0579-b904-40f5-ba88-9384967c64fb`

---

## 1. Local PC access is blocked (Public path blocked)
### Action
- Execute `az keyvault secret show/set` from local PC (non-PrivateLink path)

### Expected
- Access is blocked with `ForbiddenByConnection` (or equivalent) because only PrivateLink is allowed

### Result
- `ForbiddenByConnection` observed  
→ Public access path is blocked as expected

---

## 2. DNS resolves to PrivateLink (VM)
### Action (inside VM)
```powershell
$kv = "kv-plat-dev-45bddcd7-001"
nslookup "$kv.vault.azure.net"
```

### Expected
- `*.vault.azure.net` resolves via CNAME to `privatelink.vaultcore.azure.net`
- DNS returns the **private endpoint IP**

### Result (captured)
- `Name:    kv-plat-dev-45bddcd7-001.privatelink.vaultcore.azure.net`
- `Address: 10.10.1.4`
- `Aliases: kv-plat-dev-45bddcd7-001.vault.azure.net`

→ DNS is correctly routing to PrivateLink and resolving to PE private IP `10.10.1.4`

---

## 3. TCP 443 reachability via PrivateLink (VM)
### Action (inside VM)
```powershell
Test-NetConnection "$kv.vault.azure.net" -Port 443
```

### Expected
- `RemoteAddress` is `10.10.1.4` (PE)
- `TcpTestSucceeded : True`

### Result (captured)
- `RemoteAddress    : 10.10.1.4`
- `RemotePort       : 443`
- `SourceAddress    : 10.10.2.4`
- `TcpTestSucceeded : True`

→ PrivateLink path to Key Vault is reachable from workload subnet VM

---

## 4. RBAC least privilege verification (Read OK / Write NG)
### 4.1 Role assignments at Key Vault scope
#### Action (inside VM)
```powershell
$kvId = (Get-AzKeyVault -VaultName "kv-plat-dev-45bddcd7-001").ResourceId
Get-AzRoleAssignment -Scope $kvId |
  Select-Object ObjectId, DisplayName, SignInName, RoleDefinitionName, Scope |
  Sort-Object RoleDefinitionName, SignInName |
  Format-Table -Auto
```

#### Result (captured; key rows)
- `eeb850f4-8f4c-4daf-a2f2-99cbab6e8184` (`avd@ryosukemwebengoutlook.onmicrosoft.com`)
  - `Key Vault Secrets User` (KV scope)
  - `Owner` (KV scope)  
- `mi-kv-secrets-officer-dev`
  - `Key Vault Secrets Officer` (KV scope)

> This evidence focuses on **data-plane secrets operations**. The write attempt below is evaluated against
> `Microsoft.KeyVault/vaults/secrets/setSecret/action` and was **denied with “Assignment: (not found)”**, proving
> that the principal lacks the required data-plane permission to set secrets under the current configuration.

---

### 4.2 Secrets Read — success
#### Action (inside VM)
```powershell
$kv = "kv-plat-dev-45bddcd7-001"
Get-AzKeyVaultSecret -VaultName $kv
```

#### Expected
- Read succeeds for a principal with `Key Vault Secrets User`

#### Result (captured)
- Secret `rbacv2-test-001` retrieved successfully

→ Read is permitted as expected

---

### 4.3 Secrets Write — denied by RBAC (Forbidden)
#### Action (inside VM)
```powershell
Set-AzKeyVaultSecret -VaultName $kv -Name "evidence-test" -SecretValue (ConvertTo-SecureString "hello" -AsPlainText -Force)
```

#### Expected
- Write should be denied for a principal with read-only (Secrets User) permissions

#### Result (captured; key fields)
- `Operation returned an invalid status code 'Forbidden'`
- `Action: 'Microsoft.KeyVault/vaults/secrets/setSecret/action'`
- `Assignment: (not found)`
- `DenyAssignmentId: null`

→ The write operation is denied by **RBAC (no assignment granting setSecret/action)**, not by network connectivity

---

## Conclusion
- Local PC access is blocked, validating **Public path is disabled**
- VM DNS and TCP results show **PrivateLink-only reachability** (PE IP `10.10.1.4`, TCP 443 success)
- RBAC least privilege works as intended:
  - **Secrets Read** is allowed (successful `Get-AzKeyVaultSecret`)
  - **Secrets Write** is denied (Forbidden with explicit `setSecret/action` and `Assignment: (not found)`)

---

## Cleanup (A: delete temporary VM)
Run from local PC (where Azure CLI is available):

```powershell
az vm delete -g rg-platform-baseline -n vmkvdev02 --yes
az network nic delete -g rg-platform-baseline -n vmkvdev02-nic
az network nsg delete -g rg-platform-baseline -n vmkvdev02-nsg

# Optional: check for leftovers
az disk list -g rg-platform-baseline -o table
az network nic list -g rg-platform-baseline -o table
az vm list -g rg-platform-baseline -o table
```
