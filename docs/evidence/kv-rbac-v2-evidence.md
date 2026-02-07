# Key Vault RBAC v2 evidence (Secrets User) — 2026-02-07

> Note: For evidence, prefer `curl -D - -o /dev/null` to avoid JSON truncation breaking Markdown.

## 1) IMDS reachable (VM is on Azure)

```bash
curl -sS -D - -o /dev/null \
  -H "Metadata:true" \
  "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | head
```

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Server: IMDS/150.870.65.1854
x-ms-request-id: b41646f2-40fc-44bf-ac9a-8a3b5c23a41b
Date: Sat, 07 Feb 2026 11:04:46 GMT
Content-Length: 2604
```

## 2) Acquire Key Vault access token via Managed Identity

```bash
TOKEN=$(curl -sS -H "Metadata:true" \
  "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
```

## 3) Secrets list — allowed (200 OK) + PrivateLink confirmed

```bash
curl -sS -D - -o /dev/null \
  -H "Authorization: Bearer $TOKEN" \
  "https://${KV_FQDN}/secrets?api-version=7.4"
```

```
HTTP/1.1 200 OK
Cache-Control: no-cache
Pragma: no-cache
Content-Type: application/json; charset=utf-8
Expires: -1
x-ms-keyvault-region: japaneast
x-ms-request-id: 3279307a-dc47-4cfa-9d9b-bc82ae19a699
x-ms-keyvault-service-version: 1.9.3019.1
x-ms-keyvault-network-info: conn_type=PrivateLink;private_endpoint=/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.Network/privateEndpoints/pe-kv-plat-dev-45bddcd7-001;addr=10.10.1.5;act_addr_fam=InterNetworkV6;
x-ms-keyvault-rbac-assignment-id: 3ab898c2e3f059ada9ac42f3b4ed6fb1
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000;includeSubDomains
Date: Sat, 07 Feb 2026 11:07:18 GMT
Content-Length: 232
```

## 4) Secret get — allowed (200 OK) + PrivateLink confirmed

```bash
curl -sS -D - -o /dev/null \
  -H "Authorization: Bearer $TOKEN" \
  "https://${KV_FQDN}/secrets/rbacv2-test-001?api-version=7.4"
```

```
HTTP/1.1 200 OK
Cache-Control: no-cache
Pragma: no-cache
Content-Type: application/json; charset=utf-8
Expires: -1
x-ms-keyvault-region: japaneast
x-ms-request-id: 45258d7a-7ca5-4d51-8096-996d84c8bc76
x-ms-keyvault-service-version: 1.9.3019.1
x-ms-keyvault-network-info: conn_type=PrivateLink;private_endpoint=/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.Network/privateEndpoints/pe-kv-plat-dev-45bddcd7-001;addr=10.10.1.5;act_addr_fam=InterNetworkV6;
x-ms-keyvault-rbac-assignment-id: 3ab898c2e3f059ada9ac42f3b4ed6fb1
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000;includeSubDomains
Date: Sat, 07 Feb 2026 11:07:33 GMT
Content-Length: 261
```

## 5) Secret delete — denied (403 ForbiddenByRbac expected)

```bash
curl -sS -i \
  -H "Authorization: Bearer $TOKEN" \
  -X DELETE \
  "https://${KV_FQDN}/secrets/rbacv2-test-001?api-version=7.4" | head -n 30
```

```
HTTP/1.1 403 Forbidden
Cache-Control: no-cache
Pragma: no-cache
Content-Type: application/json; charset=utf-8
Expires: -1
x-ms-keyvault-region: japaneast
x-ms-request-id: cc63219e-3d2a-41c6-83fd-ba568aa31e1e
x-ms-keyvault-service-version: 1.9.3019.1
x-ms-keyvault-network-info: conn_type=PrivateLink;private_endpoint=/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.Network/privateEndpoints/pe-kv-plat-dev-45bddcd7-001;addr=10.10.1.5;act_addr_fam=InterNetworkV6;
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000;includeSubDomains
Date: Sat, 07 Feb 2026 11:07:48 GMT
Content-Length: 794

{"error":{"code":"Forbidden","message":"Caller is not authorized to perform action on resource.\r\n...\r\nAction: 'Microsoft.KeyVault/vaults/secrets/delete'\r\n...","innererror":{"code":"ForbiddenByRbac"}}}
```

## 6) Secret set (create/update) — denied (403 ForbiddenByRbac expected)

```bash
curl -sS -D - -o /dev/null \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X PUT \
  -d '{"value":"hello-from-mi"}' \
  "https://${KV_FQDN}/secrets/test-secret?api-version=7.4"
```

```
HTTP/1.1 403 Forbidden
Cache-Control: no-cache
Pragma: no-cache
Content-Type: application/json; charset=utf-8
Expires: -1
x-ms-keyvault-region: japaneast
x-ms-request-id: 1d4751d9-b10e-4036-ae74-bf0ab80db322
x-ms-keyvault-service-version: 1.9.3019.1
x-ms-keyvault-network-info: conn_type=PrivateLink;private_endpoint=/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.Network/privateEndpoints/pe-kv-plat-dev-45bddcd7-001;addr=10.10.1.5;act_addr_fam=InterNetworkV6;
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000;includeSubDomains
Date: Sat, 07 Feb 2026 11:07:59 GMT
Content-Length: 800
```

---

## 7) Secrets Officer (user-assigned MI) — allowed set/delete (200 OK)

### 7.1 Role assignment on Key Vault scope
From the management workstation (Azure CLI):

```powershell
$kv = "kv-plat-dev-45bddcd7-001"
$kvId = az keyvault show -n $kv -g rg-platform-baseline --query id -o tsv
az role assignment list --scope $kvId --query "[].{principal:principalId, role:roleDefinitionName}" -o table
```

Expected / observed (excerpt):

- `621f3586-6b13-4f09-a0c2-111f7bb2b256` — **Key Vault Secrets Officer**
- `fb36d03b-e3b0-4a80-a74a-9765b1182130` — **Key Vault Secrets User** (and also Officer in the earlier state)

### 7.2 Acquire token for the user-assigned MI via IMDS (`msi_res_id`)
On the VM (`vmkvdev01`), use the **User Assigned Managed Identity resource ID**:

- User-assigned MI resource ID:  
  `/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourcegroups/rg-platform-baseline/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-kv-secrets-officer-dev`
- `clientId`: `7d9b9ddf-4da8-4589-a703-ea8b7e311069`
- `principalId` (objectId / oid): `621f3586-6b13-4f09-a0c2-111f7bb2b256`

```bash
KV_NAME="kv-plat-dev-45bddcd7-001"
KV_FQDN="${KV_NAME}.vault.azure.net"

MI_RES_ID="/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourcegroups/rg-platform-baseline/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-kv-secrets-officer-dev"
ENC_MI_RES_ID=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=""))' "$MI_RES_ID")

RESP=$(curl -sS -H "Metadata:true"   "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net&msi_res_id=${ENC_MI_RES_ID}")

TOKEN=$(echo "$RESP" | python3 -c 'import sys,json; j=json.load(sys.stdin); print(j.get("access_token",""))')
test -n "$TOKEN" && echo "TOKEN OK" || echo "TOKEN MISSING"
```

Expected / observed: `TOKEN OK`

### 7.3 Secret set + delete via Key Vault data-plane (RBAC)
```bash
NAME="officer-secret-$(date +%s)"

echo "=== PUT $NAME ==="
curl -sS -i   -H "Authorization: Bearer $TOKEN"   -H "Content-Type: application/json"   -X PUT   -d '{"value":"hello-from-officer-mi"}'   "https://${KV_FQDN}/secrets/${NAME}?api-version=7.4"

echo
echo "=== DELETE $NAME ==="
curl -sS -i   -H "Authorization: Bearer $TOKEN"   -X DELETE   "https://${KV_FQDN}/secrets/${NAME}?api-version=7.4"
```

Expected / observed:

- PUT: `HTTP/1.1 200 OK`
- DELETE: `HTTP/1.1 200 OK`
- Response headers include:
  - `x-ms-keyvault-network-info: conn_type=PrivateLink; ...`
  - `x-ms-keyvault-rbac-assignment-id: ...`
  - `CallerIPAddress: 10.10.1.5`

### 7.4 Note: soft-delete conflict when reusing a deleted name (expected)
After a secret is deleted (recoverable), attempting to create the same name again returns:

- `HTTP/1.1 409 Conflict`
- `ObjectIsDeletedButRecoverable`

This is expected behavior with soft delete. Use a unique name for repeated tests (as above), or recover/purge the deleted secret.

## 8) Diagnostic settings — AuditEvent to Log Analytics confirmed

From Azure CLI:

```bash
kv="kv-plat-dev-45bddcd7-001"
kvId=$(az keyvault show -n $kv -g rg-platform-baseline --query id -o tsv)
az monitor diagnostic-settings list --resource "$kvId" -o jsonc
```

Observed (excerpt):

- Diagnostic setting name: `diag-to-law`
- `workspaceId`: `/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.OperationalInsights/workspaces/law-platform-baseline`
- Logs:
  - `AuditEvent`: `enabled: true`
  - `AzurePolicyEvaluationDetails`: `enabled: false`
- Metrics:
  - `AllMetrics`: `enabled: false`

## 9) Log Analytics (LAW) — AuditEvent records show RBAC decision + PrivateLink

In Log Analytics (workspace: `law-platform-baseline`), the exported results include:

- For **Secrets User MI** (`oid=fb36d03b-e3b0-4a80-a74a-9765b1182130`):
  - `SecretGet` → `ResultType=Success` (200)
  - `SecretSet` / `SecretDelete` → `ResultType=Forbidden` (403) with `Assignment: (not found)` and `isRbacAuthorized_b=false`
- For **Secrets Officer user-assigned MI** (`appid=7d9b9ddf-4da8-4589-a703-ea8b7e311069`, `oid=621f3586-6b13-4f09-a0c2-111f7bb2b256`):
  - `SecretSet` / `SecretDelete` → `ResultType=Success` (200) and `isRbacAuthorized_b=true`
- `privateEndpointId_s` is present, showing the call path is **PrivateLink**.

Recommended KQL to re-run:

```kusto
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where Category == "AuditEvent"
| where Resource == "KV-PLAT-DEV-45BDDCD7-001"
| where OperationName in ("SecretGet","SecretSet","SecretDelete","Authentication")
| project TimeGenerated, OperationName, ResultType, httpStatusCode_d, identity_claim_appid_g, identity_claim_oid_g,
          CallerIPAddress, requestUri_s, isRbacAuthorized_b, privateEndpointId_s, tlsVersion_s
| order by TimeGenerated desc
```


## Appendix: Why Markdown breaks when you copy/paste terminal output

- `curl -i ... | head -n N` truncates JSON bodies mid-stream, leaving `{` / `[` unclosed.
- When pasted into Markdown (especially inside an existing code fence), it can “escape” the fence and corrupt the document.

**Rule:** Prefer either:
- capture headers only: `curl -sS -D - -o /dev/null ...` (and record the HTTP status), or
- save the full response body to a file and pretty-print it: `curl -sS ... -o resp.json && jq . resp.json`
