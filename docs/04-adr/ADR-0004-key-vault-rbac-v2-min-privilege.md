# ADR-0003: Key Vault authorization model — use Azure RBAC (v2) with least-privilege separation

- Status: Proposed
- Date: 2026-02-07
- Scope: `rg-platform-baseline` / Key Vault `kv-plat-dev-45bddcd7-001`
- Related evidence: `docs/evidence/kv-rbac-v2-evidence.md`

---

## Context

Azure Key Vault supports two authorization models for data-plane operations (secrets/keys/certificates):

1) **Access policies** (legacy model)
2) **Azure RBAC** (`enableRbacAuthorization = true`)

This repo is building a baseline aligned to a Landing Zone mindset:
- Central policy-driven governance
- Standardized role assignments and separation of duties
- Consistent evidence capture and reproducibility (IaC-first)

We also want to validate that **Private Endpoint** is used and that data-plane permissions behave as expected under least privilege.

---

## Decision

We will use **Azure RBAC authorization (v2)** for Key Vault data-plane, and implement **least-privilege separation**:

- Set `enableRbacAuthorization = true`
- Disable public network access (`publicNetworkAccess = Disabled`) and access Key Vault via Private Endpoint where required
- Assign **only the minimal built-in Key Vault roles** needed per persona (split by duties)
  - Example split used in validation:
    - Operator / Officer: `Key Vault Secrets Officer` (can set/delete/manage secrets)
    - Reader / App user: `Key Vault Secrets User` (can get/list secrets; cannot set/delete)

We will capture the behavior as evidence (allowed/denied) using deterministic commands and HTTP response headers that also confirm PrivateLink.

---

## Rationale

- **Consistency with ARM/IaC & governance**: RBAC aligns with the same control plane model used across Azure resources, making policy/role assignment management consistent.
- **Separation of duties**: RBAC roles allow clear persona-based access (e.g., read-only vs. manage) without mixing operational privileges.
- **Auditable evidence**: We can validate expected allow/deny outcomes (200/403) while also confirming the network path (PrivateLink) from response headers.
- **Future-proofing**: RBAC is the recommended model for many enterprise governance patterns; it integrates naturally with Azure AD identities and standard role assignment operations.

---

## Implementation notes

### IaC

- Ensure the Key Vault resource has:
  - `properties.enableRbacAuthorization = true`
  - `properties.publicNetworkAccess = Disabled`
  - `properties.enablePurgeProtection = true`
  - `properties.softDeleteRetentionInDays` set to baseline value (e.g., 90)

### Role assignments

- Scope role assignments at **Key Vault resource scope** (not subscription-wide).
- Create dedicated principals for validation (and later for workloads), e.g. `KV Secrets User 01`.

### Evidence

- Evidence file must show:
  - Who is the principal used for each step
  - Role assignment(s) at KV scope
  - Allowed operations (200 OK) for `get/list`
  - Denied operations (403 ForbiddenByRbac) for `set/delete` when using the limited role
  - Headers showing `x-ms-keyvault-network-info` includes `conn_type=PrivateLink`

---

## Consequences

### Positive
- Clear and maintainable access control aligned with Azure governance.
- Easy to reason about and document least-privilege behavior (allow/deny).
- Matches enterprise patterns and simplifies future integration with policy initiatives.

### Negative / tradeoffs
- RBAC changes may take time to propagate compared to access policies; tests must allow for eventual consistency.
- Role selection can be subtle (built-in roles differ by capabilities); validation must be explicit.

---

## References

- Evidence: `docs/evidence/kv-rbac-v2-evidence.md`
- Commands log: `docs/logs/commands-day3.md` (role assignment + secret operation checks)
