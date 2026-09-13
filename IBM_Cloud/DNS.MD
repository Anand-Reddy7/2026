

## IBM Cloud DNS Service

IBM Cloud DNS Service is a **managed, private DNS resolution service** that allows resources within IBM Cloud VPCs to resolve domain names without exposing DNS traffic to the public internet.

### Two Types of DNS in IBM Cloud

| Feature | IBM Cloud DNS Services (Private) | Public DNS |
|---|---|---|
| **Visibility** | VPC-internal only | Internet-facing |
| **Use case** | Internal hostname resolution | Public domain resolution |
| **Managed by** | IBM Cloud DNS Service | External registrar / public resolvers |
| **Custom zones** | ✅ Yes | ✅ Yes |
| **Traffic stays private** | ✅ Yes | ❌ No |

### Core Concepts

#### DNS Zone
- A **logical container** for DNS records (A, CNAME, PTR, etc.).
- Example: `lsf-cluster.internal` — all LSF nodes resolve each other using this zone.

#### Permitted Network
- A **VPC that is allowed** to use a DNS zone.
- Must explicitly attach a VPC to a DNS zone before its resources can resolve names in that zone.

#### Custom Resolver
- A **DNS server deployed inside your VPC subnet** that handles DNS queries.
- Think of it as a **reception desk inside your building** — queries never need to leave the VPC.
- Forwards queries to IBM Cloud DNS, on-premises DNS, or public DNS depending on rules.

```
LSF Worker Node
  │
  │  "What is the IP of lsf-mgmt01.lsf.internal?"
  ▼
Custom Resolver (sitting at 10.0.0.4 inside your subnet)
  │
  ├── "lsf.internal"  → IBM Cloud DNS   → returns 10.0.1.5   ✅
  ├── "corp.ibm.com"  → On-prem DNS     → returns 9.x.x.x    ✅
  └── "google.com"    → Public DNS      → returns 142.x.x.x  ✅
```

#### Custom Resolver Location
- The **subnet + IP** where the custom resolver is deployed.
- Deploy 2+ locations for **high availability**.

### Without vs With Custom Resolver

| Situation | Without Custom Resolver | With Custom Resolver |
|---|---|---|
| Resolve `lsf.internal` | ❌ Doesn't work | ✅ Works |
| Resolve on-prem hostname | ❌ Doesn't work | ✅ Works (forwarded) |
| Resolve `google.com` | ✅ Works (public) | ✅ Works |
| Traffic stays private | ❌ No guarantee | ✅ Yes |

### Terraform Resources for DNS

| Terraform Resource | Purpose |
|---|---|
| `dns_zone.tf` | Creates the private DNS zone (e.g., `lsf.internal`) |
| `dns_permitted_network.tf` | Attaches the LSF VPC to the DNS zone |
| `dns_custom_resolver.tf` | Creates a custom resolver inside the VPC |
| `dns_custom_resolver_location.tf` | Pins the resolver to a specific subnet/IP |

---

## 4. DNS Zone Record Types

### Quick Reference Table

| Record | Maps | Example Use |
|---|---|---|
| **A** | Hostname → IPv4 | VSI, server registration |
| **AAAA** | Hostname → IPv6 | IPv6 VSIs |
| **CNAME** | Hostname → Hostname | Aliases, load balancer names |
| **PTR** | IP → Hostname | Reverse DNS, node verification |
| **MX** | Domain → Mail server | Email routing |
| **TXT** | Domain → Text | SPF, domain ownership proof |
| **NS** | Zone → Name server | DNS delegation |
| **SOA** | Zone → Admin info | Zone management metadata |
| **SRV** | Service → Host + Port | LDAP, Kerberos discovery |

### Record Details

#### A Record (Address Record)
Maps a **hostname → IPv4 address**
```
mgmt01.lsf.internal   →  10.0.1.5
worker01.lsf.internal →  10.0.2.10
```
> Most used record. Every server/VSI gets one.

#### AAAA Record (IPv6 Address Record)
Maps a **hostname → IPv6 address**
```
mgmt01.lsf.internal  →  2001:db8::1
```
> Same as A record but for IPv6.

#### CNAME Record (Canonical Name / Alias)
Maps a **hostname → another hostname**
```
lsf-master.internal  →  mgmt01.lsf.internal
```
> Like a nickname. `lsf-master` is just an alias for `mgmt01`.
> ⚠️ Cannot point to an IP directly, only to another hostname.

#### PTR Record (Pointer Record — Reverse DNS)
Maps an **IP address → hostname** (opposite of A record)
```
10.0.1.5  →  mgmt01.lsf.internal
```
> Used for reverse lookups. LSF uses this to verify node identities.

#### MX Record (Mail Exchange)
Maps a **domain → mail server hostname**
```
lsf.internal  →  mail.lsf.internal (priority 10)
```
> Only needed if you handle email for the domain.

#### TXT Record (Text Record)
Stores **arbitrary text** for a domain
```
lsf.internal  →  "v=spf1 include:ibm.com ~all"
```
> Used for domain verification, SPF, DKIM, ownership proofs.

#### NS Record (Name Server)
Tells which **DNS servers are authoritative** for a zone
```
lsf.internal  →  ns1.ibmdns.com
```
> Automatically managed by IBM Cloud DNS Service.

#### SOA Record (Start of Authority)
Contains **administrative info** about the DNS zone
```
Zone: lsf.internal
Admin: hostmaster@lsf.internal
Serial: 2026010101
```
> Auto-created with every DNS zone. You rarely touch this.

#### SRV Record (Service Record)
Maps a **service → hostname + port**
```
_ldap._tcp.lsf.internal  →  ldap.lsf.internal  port 389
```
> Used by services like LDAP, Kerberos, SIP to discover endpoints.

### In LSF Context — Records You'll See Most
```
A   record  →  Register every LSF node (mgmt, worker, storage)
PTR record  →  Reverse lookup for node identity verification
CNAME       →  Alias like "lsf-master" pointing to active mgmt node
SRV         →  If LDAP/Kerberos auth is configured for LSF users
```


## Plan Details ( Standard DNS )
- Up to 10 zones per instance
- Up to 10 VPC networks per zone
- 3500 DNS records per zone
- 1 million DNS queries included
- One DNS zone included per account

-----------------------------------------------------------------------
# Old Content 
-----------------------------------------------------------------------
# IBM Cloud DNS – Beginner Guide

---

## What is DNS?

DNS (Domain Name System) translates human-readable domain names into IP addresses.

| Humans Use | Computers Use |
|---|---|
| `example.com` | `192.168.1.1` |

> DNS acts like the **phonebook of the internet**

---

## What is IBM Cloud DNS?

IBM Cloud DNS Services is a **managed, global DNS service** provided by IBM.

### It Helps You
- Manage domain names
- Route traffic to applications
- Improve performance and availability
- Protect against attacks (like DDoS)

### Why Use IBM Cloud DNS?

| Feature | Detail |
|---|---|
| **Easy to Manage** | UI + API support |
| **High Performance** | Global resolution |
| **Secure** | DNSSEC support |
| **Highly Available** | Distributed system |

---

## Types of DNS Services

### 1. Public DNS
- Used for **internet-facing** domains
- Accessible from **anywhere**

**Flow:**
```
User → Internet → Public Resolver → IBM DNS → Public IP → Server
```

---

### 2. Private DNS
- Used **inside a VPC** (Virtual Private Cloud)
- **Not** accessible from the internet

**Flow:**
```
App → VPC Resolver → Private DNS Zone → Private IP → Internal Server
```

**Example:**
```
db.internal.local → 10.0.0.10
```

| | Private DNS |
|---|---|
| Works inside VPC | ✅ Yes |
| Accessible from internet | ❌ No |

---

## Why Private DNS is Important

| Reason | Detail |
|---|---|
| **Internal Communication** | Use names instead of hardcoded IPs |
| **Decoupling Infrastructure** | Change IP without changing app config |
| **Security** | Not exposed to the public internet |
| **Hybrid Cloud Support** | Works with on-prem + cloud environments |

---

## DNS Record Types

### A Record
Maps **domain → IPv4 address**
```
example.com → 192.168.1.1
```

### AAAA Record
Maps **domain → IPv6 address**
```
example.com → 2001:db8::1
```

### PTR Record (Reverse DNS)
Maps **IP → domain**
```
192.168.1.1 → example.com
```

### CNAME Record
Maps **one domain → another domain**
```
www.example.com → example.com
```

### Quick Summary

| Record | Maps | Use |
|---|---|---|
| **A** | Hostname → IPv4 | Server registration |
| **AAAA** | Hostname → IPv6 | IPv6 servers |
| **PTR** | IP → Hostname | Reverse lookup |
| **CNAME** | Hostname → Hostname | Aliases |

---

## Custom Resolver

A **Custom Resolver** is a DNS component in IBM Cloud DNS Services that lets you control how DNS queries are routed inside your VPC.

> Think of it as a **DNS traffic controller** inside your VPC — you control where each query goes.

### What It Decides

- Where a DNS query should go
- Whether to:
  - Resolve **locally** (IBM DNS zones)
  - **Forward** to another DNS server (on-prem, other cloud)

---

### Why Do We Need a Custom Resolver?

By default, IBM Cloud provides a VPC DNS resolver that:

| Capability | Default VPC Resolver |
|---|---|
| Resolves private zones attached to VPC | ✅ Yes |
| Resolves public domains | ✅ Yes |
| Forwards to external DNS (on-prem) | ❌ No |
| Handles hybrid DNS routing | ❌ No |

### When to Use Custom Resolver

- Integrating with **on-premises DNS**
- Working in **hybrid cloud** environments
- Using **multi-cloud** setups
- Needing **conditional DNS forwarding** rules

---

## Custom Resolver — High Availability Rules

> ⚠️ **Important Limits to Know**

| Rule | Detail |
|---|---|
| **Max locations per resolver** | 3 locations (same or different subnets) |
| **Min locations for HA** | 2 resolver locations required |
| **Subnet placement** | Same subnet or different subnets |

> To achieve **high availability**, always configure a minimum of **two resolver locations**.

---

## Final Summary

| Concept | Description |
|---|---|
| **DNS** | Translates names to IPs |
| **IBM Cloud DNS** | Managed DNS service |
| **Public DNS** | Internet-facing domain resolution |
| **Private DNS** | Internal VPC communication only |
| **Custom Resolver** | Controls and forwards DNS queries inside VPC |
| **HA Requirement** | Minimum 2 resolver locations |