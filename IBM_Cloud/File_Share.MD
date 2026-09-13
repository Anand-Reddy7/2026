# IBM VPC File Share

---

## What is IBM VPC File Share?

IBM VPC File Share is a **managed NFS-based shared file storage service** within IBM Cloud VPC that allows multiple VSIs to access the same file system simultaneously.

---

## What is a File Share?

Think of it like a **shared network drive** inside your VPC:

```
VSI 1 ──┐
VSI 2 ──┼──► File Share (NFS) ──► /mnt/shared  (same data for all)
VSI 3 ──┘
```

> Unlike Block Storage (one disk → one VSI), a File Share can be **mounted by many VSIs at the same time**.

---

## Block Storage vs File Share vs Object Storage

| Feature | Block Storage | File Share | Object Storage |
|---|---|---|---|
| **Protocol** | iSCSI / virtio | NFS | S3 / HTTP API |
| **Access** | Single VSI | Multiple VSIs | Any app / browser |
| **Use case** | OS disk, DB | Shared files, HPC | Backups, logs, media |
| **Mountable** | ✅ Yes | ✅ Yes | ❌ No (API only) |
| **Performance** | Highest | High | Moderate |
| **Concurrent access** | ❌ No | ✅ Yes | ✅ Yes |

---

## Core Concepts

### 1. File Share
The actual shared storage resource you create.

- Backed by **NFS (Network File System)**
- Lives inside a **VPC zone**
- Has a defined **capacity (GB)** and **performance profile**

---

### 2. Mount Target
A **network endpoint** inside your VPC subnet that VSIs use to connect to the file share.

```
File Share
    └── Mount Target (IP inside your subnet)
            └── VSIs mount via NFS to this IP
```

> You need at least **one mount target per VPC** to access the file share.

---

### 3. File Share Profiles

| Profile | IOPS | Use Case |
|---|---|---|
| `dp2` | Custom IOPS | General purpose, tunable |
| `custom` | Define your own | Performance-sensitive workloads |

---

## How It Works — End to End

```
Step 1: Create a File Share (define size + profile)
           ↓
Step 2: Create a Mount Target (attach to your VPC subnet)
           ↓
Step 3: Get the NFS mount path (e.g., xxx.file.appdomain.cloud)
           ↓
Step 4: Mount on each VSI using NFS
           ↓
Step 5: All VSIs read/write the same shared files
```

---

## Mounting a File Share on Linux

### Step 1 — Install NFS Client

```bash
# RHEL / CentOS
yum install nfs-utils -y

# Ubuntu / Debian
apt install nfs-common -y
```

### Step 2 — Create Mount Directory

```bash
mkdir -p /mnt/shared
```

### Step 3 — Mount the File Share

```bash
mount -t nfs4 <mount_target_ip>:/ /mnt/shared
```

### Step 4 — Verify Mount

```bash
df -h /mnt/shared
```

### Step 5 — Make It Permanent After Reboot

Edit `/etc/fstab`:
```bash
vi /etc/fstab
```

Add this line:
```
<mount_target_ip>:/  /mnt/shared  nfs4  defaults,nofail,sec=sys  0 0
```

Reload all mounts:
```bash
mount -a
```

---

## Security — Accessing File Shares

### Security Group Rules Required

| Direction | Protocol | Port | Purpose |
|---|---|---|---|
| Outbound | TCP | 2049 | NFS traffic to mount target |
| Outbound | UDP | 2049 | NFS traffic to mount target |

> Port **2049** is the standard NFS port.

### Encryption

| Type | Detail |
|---|---|
| **At rest** | Encrypted by default (IBM-managed or Key Protect CRK) |
| **In transit** | Supported via `sec=sys` or encryption in transit option |

---

## File Share — Key Facts

| Property | Detail |
|---|---|
| **Protocol** | NFSv4.1 |
| **Maximum size** | 32 TB |
| **Minimum size** | 10 GB |
| **Zone scope** | Single zone (not cross-zone by default) |
| **Resize** | ✅ Can expand — cannot shrink |
| **Snapshots** | ✅ Supported |
| **Replication** | ✅ Cross-zone replication available |

---

## In LSF Context

File Share is heavily used in IBM Spectrum LSF clusters:

| LSF Use Case | File Share Role |
|---|---|
| **Shared home directories** | `/home` mounted on all nodes |
| **LSF binaries** | Installed once, shared to all nodes |
| **Job input/output data** | Workers read/write shared job data |
| **Application binaries** | Shared across all compute nodes |
| **Checkpoint files** | HPC jobs save state to shared storage |

```
LSF Management Node ──┐
LSF Worker Node 1   ──┼──► File Share (/mnt/lsf)
LSF Worker Node 2   ──┤        ├── /mnt/lsf/home
LSF Worker Node N   ──┘        ├── /mnt/lsf/apps
                               └── /mnt/lsf/data
```

---

## One-line Summary

> IBM VPC File Share = **A shared NFS drive inside your VPC** — create once, mount on many VSIs simultaneously, ideal for HPC and shared workloads like LSF.

-------------------------------------------------------
# IBM VPC File Share — Limitations
-------------------------------------------------------

---

## 1. Zone Scope (No Cross-Zone by Default)

- A file share is created in a **single availability zone**
- VSIs in **other zones cannot mount** it directly
- Cross-zone access requires **replication** (separate feature)

```
Zone 1: File Share ✅ → VSIs in Zone 1 can mount
Zone 2:             ❌ → VSIs in Zone 2 cannot mount directly
```

---

## 2. No Shrinking

- You can **increase** capacity but **cannot decrease** it
- Always plan your size carefully before provisioning

```
10 GB  → 100 GB ✅  (expand allowed)
100 GB → 10 GB  ❌  (shrink NOT allowed)
```

---

## 3. VPC Bound

- A file share **belongs to one VPC**
- VSIs in a **different VPC** cannot access it without extra network setup
- Requires Transit Gateway or VPC peering for cross-VPC access

---

## 4. NFS Only (No SMB/CIFS)

- Only **NFSv4.1** protocol is supported
- **Windows SMB/CIFS** is not supported
- Windows VSIs needing file share have limited options

---

## 5. Not Global (Regional Scope)

- File shares exist within a **specific region and zone**
- No built-in **global replication**
- Cross-region disaster recovery needs manual setup

---

## 6. Performance Limits

| Limit | Value |
|---|---|
| **Maximum size** | 32 TB |
| **Minimum size** | 10 GB |
| **Maximum IOPS** | Depends on profile and size |
| **Throughput cap** | Profile-dependent |

> For very high IOPS workloads, block storage may outperform file share.

---

## 7. Mount Target Limits

| Limit | Detail |
|---|---|
| **Mount targets per share** | Limited per account quota |
| **One mount target per VPC** | Each VPC needs its own mount target |
| **No direct internet mount** | Only accessible within VPC — not from public internet |

---

## 8. No Multi-Region Replication (Native)

- Replication is **cross-zone only** (within same region)
- **Cross-region** replication is not natively supported
- Data must be manually synced across regions

---

## 9. Latency vs Block Storage

- File share (NFS) has **slightly higher latency** than block storage
- Not ideal for **latency-sensitive** workloads like high-frequency trading or real-time databases

```
Block Storage → sub-millisecond latency  ✅  (best for DBs)
File Share    → 1–5ms latency            ⚠️  (good for HPC, shared files)
```

---

## 10. Encryption Key Deletion = Data Loss

- If you use **Key Protect CRK** and delete the root key
- The file share becomes **permanently inaccessible**
- There is **no recovery** after key deletion

---

## Quick Summary Table

| Limitation | Impact |
|---|---|
| **Single zone scope** | Cross-zone VSIs can't mount directly |
| **No shrink** | Must plan size upfront |
| **VPC bound** | Other VPCs need extra network setup |
| **NFS only** | No Windows SMB support |
| **No global replication** | Cross-region DR is manual |
| **Higher latency than block** | Not ideal for real-time databases |
| **Mount target per VPC** | Each VPC needs its own endpoint |
| **Key deletion = data loss** | Careful with Key Protect integration |

---

## In LSF Context — What to Watch Out For

| Scenario | Risk |
|---|---|
| **Multi-zone LSF cluster** | Workers in different zones can't share the same file share |
| **Rapid job growth** | Plan size ahead — can't shrink if over-provisioned |
| **High IOPS checkpoint operations** | Block storage may be better for checkpoint-heavy jobs |
| **Cross-region disaster recovery** | Manual sync needed — no native cross-region replication |