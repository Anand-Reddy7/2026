# IBM Cloud Dedicated Host — Tutorial

---

## What is a Dedicated Host?

A **Dedicated Host** in IBM Cloud is a **single-tenant physical server** that allows you to run Virtual Server Instances (VSIs) on hardware dedicated **only to your organization**.

### Key Benefits

| Benefit | Description |
|---|---|
| **Licensing Compliance** | Bring Your Own License (BYOL) for software like Windows, SQL Server |
| **Security Isolation** | No other customer shares your hardware |
| **Predictable Performance** | No noisy-neighbor effect from other tenants |
| **Host-level Control** | You decide which VSIs are placed on which host |

---

## What is a Single-Tenant Physical Server?

A **single-tenant physical server** means the entire physical machine is dedicated to **only one customer (tenant)**.

- The physical CPU, memory, and hardware are reserved **only for your organization**
- No other IBM Cloud customer can run workloads on that same server
- You control which Virtual Server Instances (VSIs) are placed on that hardware

---

## Simple Analogy

### Shared Cloud (Multi-Tenant)
> Think of an **apartment building**

```
Apartment Building (Shared Physical Server)
├── Customer A
├── Customer B
└── Customer C
```
- Multiple customers share the same physical server
- Resources are shared
- Other tenants exist on the same infrastructure
- This is how **normal cloud VMs** work

---

### Dedicated Host (Single-Tenant)
> Think of **owning the entire house**

```
Your Own House (Dedicated Host)
├── Your VM 1
├── Your VM 2
└── Your VM 3
```
- Only **your company** uses the hardware
- No sharing with outsiders
- Full control over occupancy and usage

---

## Architecture Overview

```
IBM Cloud VPC
│
├── Dedicated Host
│     ├── VSI 1
│     ├── VSI 2
│     └── VSI 3
│
└── Public Gateway / Subnet / Security Groups
```

The **Dedicated Host** provides the physical compute capacity, while **multiple VSIs** can run on top of it.

---

## Why Do Companies Use Dedicated Hosts?

### Common Use Cases

| Use Case | Description |
|---|---|
| **Security Isolation** | Regulatory compliance requiring physical separation |
| **License Compliance** | BYOL for Oracle, Windows, SQL Server, SAP |
| **Stable Performance** | No resource contention from other tenants |
| **High-Performance Workloads** | Predictable CPU and memory throughput |
| **Enterprise Applications** | SAP, Databases, AI/ML, HPC workloads |

### Real-World Examples
- Databases (Oracle, DB2)
- SAP HANA
- AI / ML training workloads
- HPC clusters
- **IBM Spectrum LSF clusters**

---

## Billing — Important to Know

> **Q: If I create a Dedicated Host with `bx2a-host-228x912` profile but do not fully use the CPU and RAM, will I still be charged for the full host?**

**A: Yes.**

In IBM Cloud Dedicated Hosts:

- Billing is based on the **full physical host capacity**, not actual resource usage
- Even if only a small portion of CPU or memory is used, the **entire host is reserved** exclusively for your organization
- Since it is a single-tenant dedicated server, unused resources **cannot be shared** with other customers
- Charges apply for the **complete host profile** regardless of utilization

```
Host Profile: bx2a-host-228x912
├── 228 vCPUs  → billed fully even if you use 10 vCPUs
└── 912 GB RAM → billed fully even if you use 100 GB RAM
```

---

## Dedicated Host vs Shared VSI

| Feature | Shared VSI | Dedicated Host |
|---|---|---|
| **Tenancy** | Multi-tenant | Single-tenant |
| **Hardware isolation** | ❌ No | ✅ Yes |
| **BYOL support** | Limited | ✅ Full support |
| **Performance predictability** | Variable | ✅ Consistent |
| **Cost** | Pay per VSI | Pay for full host |
| **Best for** | General workloads | Regulated / licensed / HPC |

---

## In LSF Context

IBM Spectrum LSF clusters benefit from Dedicated Hosts because:

- **HPC workloads** require consistent, uncontended CPU and memory
- **Licensing** — LSF itself and any licensed software on nodes can use BYOL
- **Security** — Cluster nodes are physically isolated from other tenants
- **Performance** — No noisy-neighbor interference during large parallel jobs



# IBM Cloud Dedicated Host — Limitations

---

## 1. Full Host Billing (No Partial Billing)

- You are billed for the **entire physical host** regardless of how much you use
- Unused CPU and RAM are **wasted cost** — cannot be shared or reclaimed

```
Host: bx2a-host-228x912
├── 228 vCPUs  → using only 20?  Still billed for 228 ❌
└── 912 GB RAM → using only 100? Still billed for 912 ❌
```

---

## 2. Fixed Profile (No Resize)

- Once a dedicated host is created with a profile, **you cannot resize it**
- To change the profile, you must:
  1. Migrate all VSIs off the host
  2. Delete the host
  3. Create a new host with the desired profile

---

## 3. Single Zone Placement

- A dedicated host lives in **one availability zone only**
- VSIs on that host are **tied to that zone**
- No cross-zone failover for the host itself

```
Zone us-south-1: Dedicated Host ✅
Zone us-south-2:                 ❌ Cannot move host across zones
```

---

## 4. VSI Profile Compatibility

- VSIs placed on a dedicated host must use **compatible profiles**
- Not all VSI profiles work on all dedicated host profiles
- Mixing incompatible VSI families on one host is **not allowed**

```
Host: bx2-host → Only bx2 family VSIs allowed
                 ❌ Cannot place cx2 or mx2 VSIs on it
```

---

## 5. No Live Migration Between Hosts

- VSIs **cannot be live-migrated** from one dedicated host to another
- Migration requires **stopping the VSI**, moving it, then restarting

---

## 6. No Auto-Scaling

- Dedicated hosts do **not support auto-scaling**
- You must manually provision additional hosts and VSIs
- Not suitable for workloads that need rapid elastic scaling

---

## 7. Limited Availability in Some Regions / Zones

- Not all dedicated host profiles are available in **every region or zone**
- Specific high-performance profiles (like `bx2a`) may have **limited inventory**
- You may face capacity constraints in busy zones

---

## 8. No Automatic HA / Failover

- If the physical host has a hardware failure, IBM will attempt to recover it
- But there is **no automatic failover** to another dedicated host
- You must plan your own HA using multiple dedicated hosts

```
Host A fails ──► VSIs go down        ❌
                 No automatic move to Host B
                 Manual intervention required
```

---

## 9. Placement Group Limitations

- Dedicated hosts can be part of placement groups but with restrictions
- **Power spread** placement groups have limits on how many hosts can be placed

---

## 10. Higher Cost vs Shared VSI

- Dedicated hosts cost **significantly more** than equivalent shared VSIs
- Only justified when you have:
  - BYOL licensing requirements
  - Strict regulatory isolation needs
  - High-density VSI placement needs

```
Shared VSI (bx2-8x32):     ~$X/month
Dedicated Host (bx2-host):  ~$10-20X/month (full host)
```

---

## 11. No Spot / Preemptible Pricing

- Dedicated hosts are **always on-demand pricing**
- No discounted spot or preemptible options available
- No reservation discounts (unlike AWS Reserved Instances)

---

## 12. VSI Count Limited by Host Capacity

- Total VSIs on a host are limited by the **host's vCPU and RAM**
- Once the host is full, no more VSIs can be placed on it

```
Host: 228 vCPUs, 912 GB RAM
├── 20x bx2-8x32 VSIs = 160 vCPUs, 640 GB RAM
└── Remaining: 68 vCPUs, 272 GB RAM
    └── Can only fit VSIs within remaining capacity
```

---

## Quick Summary Table

| Limitation | Impact |
|---|---|
| **Full host billing** | Pay for unused CPU/RAM |
| **No resize** | Must delete and recreate to change profile |
| **Single zone** | No cross-zone failover |
| **VSI profile compatibility** | Only matching VSI families allowed |
| **No live migration** | VSI must be stopped to move hosts |
| **No auto-scaling** | Manual capacity management |
| **Limited regional availability** | Capacity may not always be available |
| **No automatic HA** | Must plan redundancy manually |
| **Higher cost** | Only justified for BYOL/compliance |
| **No spot pricing** | Always full on-demand price |
| **VSI count capped** | Limited by host vCPU and RAM |

---

## When NOT to Use a Dedicated Host

| Scenario | Use Shared VSI Instead |
|---|---|
| Variable / unpredictable workloads | ✅ Shared VSI scales better |
| Short-lived dev/test environments | ✅ Much cheaper |
| No BYOL licensing requirement | ✅ No benefit to dedicated |
| Need auto-scaling | ✅ Shared VSI supports it |
| Budget-sensitive projects | ✅ Shared VSI is far cheaper |