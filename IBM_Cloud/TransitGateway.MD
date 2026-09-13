# IBM Cloud Transit Gateway — Advantages & Limitations

---

## Advantages

### 1. Centralized Network Hub

- Single point to connect **all your VPCs, classic infra, and on-premises**
- No messy point-to-point peering between every VPC pair

```
Without TGW (n VPCs = n×(n-1)/2 peering connections):
4 VPCs = 6 peering connections  ❌ complex

With TGW:
4 VPCs = 4 connections to one hub ✅ clean
```

---

### 2. Global Routing (Cross-Region)

- Connect VPCs across **different IBM Cloud regions**
- Single Transit Gateway handles multi-region connectivity
- Example: us-south ↔ ca-tor ↔ eu-de — all through one TGW

---

### 3. Supports Multiple Network Types

| Network | Supported |
|---|---|
| **VPC (Gen 2)** | ✅ Yes |
| **Classic Infrastructure** | ✅ Yes |
| **Direct Link (on-premises)** | ✅ Yes |
| **Power Systems Virtual Server** | ✅ Yes |

---

### 4. Fully Managed Service

- IBM manages the **underlying infrastructure**
- No routers, switches, or hardware to maintain
- High availability built-in — IBM's SLA covers it

---

### 5. Simple Scalability

- Adding a new VPC? Just **add one connection** to existing TGW
- No changes needed to existing VPC configurations
- Scales to many connections without redesigning the network

---

### 6. Redundant and Highly Available

- Built with **redundancy by default**
- No single point of failure in the TGW itself
- Connections are resilient across IBM Cloud's backbone

---

### 7. Centralized Route Management

- All routes visible in **one place** (Routes tab in TGW)
- Easy to audit and troubleshoot traffic flow
- BGP support for dynamic routing with on-premises

---

### 8. Prefix Filtering

- Control **which CIDRs are advertised** between connections
- Prevent specific subnets from being reachable across connections
- Useful for security segmentation

---

### 9. Works with Direct Link

- On-premises networks connected via **Direct Link** can reach all VPCs through TGW
- No need for a separate Direct Link per VPC

```
On-Premises
    │
    │ Direct Link
    ▼
Transit Gateway
    ├── VPC A
    ├── VPC B
    └── VPC C
All reachable from on-premises via single Direct Link ✅
```

---

### 10. Fast Provisioning

- Transit Gateway and connections can be set up in **minutes**
- No physical hardware procurement or long lead times

---

## Limitations

### 1. No Overlapping CIDRs

- All connected networks **must have unique, non-overlapping IP ranges**
- If two VPCs have the same CIDR, the connection will be rejected

```
VPC A: 10.0.0.0/16
VPC B: 10.0.0.0/16  ❌ rejected — overlapping
VPC B: 10.1.0.0/16  ✅ allowed — unique
```

---

### 2. No Built-in Firewall / Security Filtering

- Transit Gateway **just routes traffic** — it has no firewall capability
- Cannot block specific ports or protocols between VPCs
- You must rely on **Security Groups and ACLs** inside each VPC

---

### 3. Connection and Gateway Limits

| Resource | Default Limit |
|---|---|
| **Connections per gateway** | 10 (soft limit, can request increase) |
| **Gateways per account** | Limited (quota-based) |
| **Prefix filters per connection** | 10 |

---

### 4. Global Routing Costs More

- **Local routing** — cheaper, same region only
- **Global routing** — extra charge for cross-region data transfer
- High-volume cross-region traffic can get **expensive**

```
Local data transfer:   Lower cost  ✅
Global data transfer:  Higher cost ⚠️ (billed per GB)
```

---

### 5. No Transitive Routing Between External Networks

- Two Direct Link connections **cannot route through TGW to reach each other**
- On-prem A → TGW → On-prem B is **not supported**

```
On-Prem A → TGW → VPC       ✅ supported
On-Prem A → TGW → On-Prem B ❌ not supported
```

---

### 6. Route Propagation Delay

- When a new connection is added or a route changes
- It takes **a few minutes** for routes to propagate across all connections
- Brief connectivity gaps possible during changes

---

### 7. No Traffic Encryption

- Transit Gateway does **not encrypt traffic** between VPCs
- Traffic travels over IBM's private backbone (not public internet)
- For encryption, you need **VPN or application-level TLS**

---

### 8. Single Region Home Location

- The Transit Gateway itself is created in **one home region**
- Though it supports global routing, the control plane is in one region
- If that region has an outage, TGW management may be affected

---

### 9. Cannot Connect VPCs Across Accounts (Natively)

- VPCs must belong to the **same IBM Cloud account**
- Cross-account VPC connectivity requires additional setup

---

### 10. No QoS / Traffic Prioritization

- Cannot prioritize certain types of traffic over others
- All traffic treated equally — no bandwidth guarantees per connection

---

## Advantages vs Limitations — Summary Table

| | Advantages | Limitations |
|---|---|---|
| **Connectivity** | Hub-and-spoke, clean | No overlapping CIDRs |
| **Scope** | Global cross-region | Global costs more |
| **Security** | Prefix filtering | No built-in firewall |
| **Management** | Fully managed, simple | Connection limits apply |
| **Routing** | Centralized, BGP support | Transitive external routing not supported |
| **Performance** | IBM backbone, fast | Route propagation delay |
| **Encryption** | Private backbone | No traffic encryption |
| **Scalability** | Easy to add connections | Quota limits per account |

---

## When to Use vs When NOT to Use

### Use Transit Gateway When
- Connecting **3 or more VPCs**
- Need **cross-region** VPC connectivity
- Have **on-premises + cloud** hybrid setup via Direct Link
- Want **centralized route management**
- Need to connect **classic + VPC** infrastructure

### Do NOT Use Transit Gateway When
- Connecting only **2 VPCs in same region** → use VPC peering (cheaper)
- Need **firewall / traffic inspection** between VPCs → use a virtual firewall appliance
- **Budget is very tight** and cross-region data transfer is high volume
- Need **cross-account** VPC connectivity → requires extra architecture

---

## One-line Summary

> IBM Cloud Transit Gateway = **The central hub of your IBM Cloud network** — connects everything cleanly, scales easily, but needs careful CIDR planning and is not a replacement for firewalls.



# Cross-Account VPC Connectivity on IBM Cloud

There is **no native direct VPC-to-VPC peering across accounts** in IBM Cloud.
But there are **3 working approaches**:

---

## Option 1 — Direct Link (Recommended for Enterprise)

Connect both accounts via **Direct Link** through a shared network provider.

```
Account A                    Account B
├── VPC A                    ├── VPC B
└── Direct Link ────────────► └── Direct Link
        │                              │
        └──── Shared Network Provider ─┘
              (Equinix, Megaport, etc.)
```

### How It Works
- Both accounts set up Direct Link to the **same colocation provider**
- Traffic routes through the provider's network between accounts
- Completely private — never touches public internet

### Pros & Cons

| | |
|---|---|
| ✅ Highly secure | ❌ Expensive |
| ✅ High performance | ❌ Complex setup |
| ✅ Private backbone | ❌ Requires physical colocation |

---

## Option 2 — VPN Gateway (Most Practical)

Set up a **VPN tunnel** between a VPN Gateway in each account's VPC.

```
Account A (us-south)              Account B (ca-tor)
┌──────────────────┐              ┌──────────────────┐
│   VPC A          │              │   VPC B          │
│   10.0.0.0/16    │              │   10.1.0.0/16    │
│                  │              │                  │
│  VPN Gateway ────┼──── IPSec ───┼──► VPN Gateway   │
│  (public IP)     │   Tunnel     │   (public IP)    │
└──────────────────┘              └──────────────────┘
```

### Steps — Account A Setup

```
IBM Cloud Console (Account A)
→ VPC Infrastructure
→ VPNs → Site-to-site gateways
→ Create VPN Gateway

Name:    vpn-account-a
VPC:     vpc-a
Subnet:  your subnet
Mode:    Policy-based
```

### Steps — Account B Setup

```
IBM Cloud Console (Account B)
→ VPC Infrastructure
→ VPNs → Site-to-site gateways
→ Create VPN Gateway

Name:    vpn-account-b
VPC:     vpc-b
Subnet:  your subnet
Mode:    Policy-based
```

### Create VPN Connection — Account A → Account B

```
VPN Gateway (Account A)
→ Connections → Create connection

Name:            conn-to-account-b
Peer gateway IP: <Account B VPN Gateway Public IP>
Preshared key:   <same key on both sides>
Local subnets:   10.0.0.0/16
Peer subnets:    10.1.0.0/16
```

### Create VPN Connection — Account B → Account A

```
VPN Gateway (Account B)
→ Connections → Create connection

Name:            conn-to-account-a
Peer gateway IP: <Account A VPN Gateway Public IP>
Preshared key:   <same key as Account A>
Local subnets:   10.1.0.0/16
Peer subnets:    10.0.0.0/16
```

### Expected Status After Setup

```
Account A VPN → Status: Active ✅
Account B VPN → Status: Active ✅

VSI in VPC A can now ping VSI in VPC B ✅
```

### Pros & Cons

| | |
|---|---|
| ✅ Works across accounts | ❌ Encrypted overhead (slight latency) |
| ✅ Relatively easy to set up | ❌ Public IPs exposed (VPN endpoints) |
| ✅ Cost-effective | ❌ Bandwidth limited by VPN gateway |
| ✅ No colocation needed | ❌ Manual key management |

---

## Option 3 — Jump Host / Bastion (Simple but Limited)

Place a **Bastion/Jump Host** with a floating IP in each account and route traffic through it.

```
Account A                    Account B
├── VPC A                    ├── VPC B
│   └── VSI A                │   └── VSI B
│   └── Bastion A ──────────►│   └── Bastion B
│       (Floating IP)        │       (Floating IP)
```

> This is only practical for **SSH access** — not for full network connectivity between services.

---

## Comparison of All Options

| Option | Security | Performance | Cost | Complexity |
|---|---|---|---|---|
| **Direct Link** | ✅ Highest | ✅ Best | ❌ Expensive | ❌ High |
| **VPN Gateway** | ✅ Good | ✅ Good | ✅ Moderate | ✅ Medium |
| **Jump Host** | ⚠️ Limited | ⚠️ Limited | ✅ Cheapest | ✅ Low |

---

## Recommended Approach — VPN Gateway

For most use cases, **VPN Gateway (Option 2)** is the best balance:

```
Step 1 → Create VPN Gateway in Account A VPC
Step 2 → Create VPN Gateway in Account B VPC
Step 3 → Exchange Public IPs between both accounts
Step 4 → Create VPN connections on both sides (same preshared key)
Step 5 → Update Security Groups to allow traffic from peer CIDR
Step 6 → Test connectivity with ping
```

---

## Important Notes

| Note | Detail |
|---|---|
| **CIDRs must not overlap** | Same rule as Transit Gateway |
| **Same preshared key on both sides** | Must match exactly |
| **Security groups** | Must allow inbound from peer CIDR |
| **Both connections must be active** | One-sided config will not work |
| **IKE and IPSec policies** | Must match on both sides |