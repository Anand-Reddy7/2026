# Resource Group

A resource group is a way to group IBM Cloud resources (like VPCs, VSIs, Object Storage, DNS services, etc.) together for organizational and access-control purposes.

**Why it matters:**

Access Control (IAM) — You assign IAM policies at the resource group level, so users or service IDs/trusted profiles get access to all resources within a group.

Billing & Cost Tracking — Usage costs are tracked per resource group, making it easy to attribute spending to teams, projects, or environments.

Logical Isolation — Separates dev/staging/prod or different project workloads within the same IBM Cloud account.


# Users vs Service IDs vs Trusted Profiles

| Feature | User | Service ID | Trusted Profile |
|---|---|---|---|
| **Represents** | A human (IBMid) | An application or service | A compute resource or federated identity |
| **Authenticates via** | IBMid login / MFA | API key | Compute metadata (no key needed) |
| **Credential** | Password + MFA | API key | None (identity is asserted automatically) |
| **Secret to manage?** | Yes (password) | Yes (API key) | No secret at all |
| **Best for** | Developers, admins | Automated scripts, CI/CD | VSIs, containers, federated users |


