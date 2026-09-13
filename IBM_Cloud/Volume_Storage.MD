# IBM Cloud Block Storage

---

## What is IBM Cloud Block Storage?

IBM Cloud Block Storage is **persistent storage** that you attach to Virtual Server Instances (VSIs). It works like a hard disk for your cloud VM.

### Key Points

| Feature | Detail |
|---|---|
| **Persistent** | Data stays even if VM stops or reboots |
| **High Performance** | SSD-based storage |
| **Flexible** | Can be attached and detached |
| **Use Cases** | Databases, apps, backups |

---

## When to Use Block Storage?

| Use Case | Example |
|---|---|
| **Database storage** | MySQL, PostgreSQL |
| **Application data** | App files, logs |
| **Persistent VM disk** | Data surviving reboots |
| **High IOPS workloads** | Real-time transaction systems |

---

## Volume Types

| Volume Type | Description |
|---|---|
| **Boot Volume** | OS disk — auto-created when VSI is provisioned |
| **Data Volume** | Extra storage you manually attach to VSI |

---

## Storage Profiles

| Profile | Description |
|---|---|
| `general-purpose` | Simple use, balanced performance |
| `5iops-tier` | Fixed 5 IOPS per GB |
| `10iops-tier` | Fixed 10 IOPS per GB |
| `custom` | Define your own IOPS manually |
| `sdp` | High performance, up to 32 TB |

---

## IOPS and Throughput Explained

### IOPS (Input/Output Operations Per Second)
- Measures how many **read/write operations** your disk can handle per second

```
3000 IOPS = 3000 small reads/writes per second
```

### Throughput
- Measures the **amount of data transferred** per second (MB/s)

```
100 MB/s = 100 MB of data transferred per second
```

> **Note:** Baseline throughput = IOPS × throughput multiplier.
> Throughput can only be **customized** if the `sdp` profile is selected.

---

## Profile Deep Dive

### 1. General Purpose — "Default / Safe Choice"

**When to use:**
- Small to medium applications
- Web servers, APIs
- Dev/Test environments
- When you don't know exact IOPS requirements

**Characteristics:**
- IOPS scales automatically with volume size
- Balanced performance
- Cost-effective

**Example:** A Node.js / Java API backend with moderate traffic

> Use it when: *"I just need it to work without tuning"*

---

### 2. 5 IOPS Tier / 10 IOPS Tier — "Predictable Performance"

**When to use:**
- Applications with consistent, predictable load
- Simple sizing logic without manual tuning

**Formula:**
```
IOPS = Volume Size (GB) × Tier (5 or 10)
```

**Example:**
```
100 GB volume:
  5 IOPS tier  → 500 IOPS
  10 IOPS tier → 1000 IOPS
```

**Use cases:** Small databases, ERP systems, internal tools

> Use it when: *"I want predictable performance without complexity"*

---

### 3. Custom — "Precision Control"

**When to use:**
- Known IOPS requirements
- Performance-sensitive applications
- High-traffic production systems

**Characteristics:**
- Manually set exact IOPS
- Fine-tuned performance
- Cost-efficient for specific workloads

**Example:** Database needing exactly 8000 IOPS → set custom IOPS

**Use cases:** Production databases, high TPS systems, microservices

> Use it when: *"I know my workload and need precise performance"*

---

### 4. SDP (Scalable Data Path) — "High Performance / Large Scale"

**When to use:**
- Very large volumes (up to **32 TB**)
- High throughput workloads
- Enterprise-scale systems

**Characteristics:**
- High IOPS + high throughput
- Large capacity support
- Customizable throughput (only profile that supports it)

**Example:** Data warehouse, analytics pipeline, video processing

**Use cases:** Big data platforms, AI/ML workloads, backup systems

> Use it when: *"I need massive scale + high performance"*

---

## Quick Comparison

| Profile | Best For | Control | Performance |
|---|---|---|---|
| `general-purpose` | Default apps | Low | Balanced |
| `5/10 iops-tier` | Predictable workloads | Medium | Fixed |
| `custom` | Critical apps | High | Tuned |
| `sdp` | Large-scale systems | High | Very High |

---

## Decision Flow

```
Do you know your IOPS requirement?
│
├── No  → general-purpose
│
└── Yes
    │
    ├── Predictable workload?  → 5 / 10 IOPS tier
    ├── Need fine tuning?      → custom
    └── Large-scale / heavy?   → sdp
```

---

## Notes

- Baseline throughput is determined by **IOPS × throughput multiplier**
- Throughput customization is **only available** with the `sdp` profile
- Volume capacity upgrades are **automatically reflected** at the OS level after upgrade — no manual intervention needed

---

## Mounting a Block Storage Volume on Linux

### Understanding the Device Path

```
/dev/vdb
```

| Part | Meaning |
|---|---|
| `/dev` | Linux directory where all device files live |
| `vd` | Virtual Disk |
| `b` | Second disk (`a` = first, `b` = second, `c` = third) |

> If you see `/dev/vdb1`, `/dev/vdb2` — those are **partitions** of the disk.

---

### Step 1 — Format the Disk

```bash
mkfs.ext4 /dev/vdd
```

### Step 2 — Create Mount Directory

```bash
mkdir /data
```

### Step 3 — Mount the Disk

```bash
mount /dev/vdd /data
```

### Step 4 — Make It Permanent After Reboot

**Get the UUID of the disk:**
```bash
blkid /dev/vdd
```

**Edit `/etc/fstab`:**
```bash
vi /etc/fstab
```

**Add this line:**
```
UUID=a02637c1-e610-46cc-8d80-08b8abb35fb4  /data  ext4  defaults,nofail  0 0
```

**Reload all mounts:**
```bash
mount -a
```

---

### Optional — Partition the Disk

```bash
fdisk /dev/vdd
```

> Use `fdisk` to create partitions on the disk before formatting if needed.


# AWS EBS (Elastic Block Store) — Limitations

---

## 1. Single AZ Bound

- An EBS volume exists in **one Availability Zone only**
- Cannot be directly attached to an EC2 instance in a **different AZ**

```
AZ us-east-1a: EBS Volume ✅ → EC2 in us-east-1a can attach
AZ us-east-1b:             ❌ → EC2 in us-east-1b cannot attach directly
```

---

## 2. One Instance Attachment (Most Volume Types)

- By default, an EBS volume can be attached to **only one EC2 instance** at a time
- **EBS Multi-Attach** is available only for `io1` / `io2` volumes and has its own restrictions

```
EBS gp2/gp3 → One EC2 only           ❌ (no sharing)
EBS io1/io2 → Multi-Attach possible  ✅ (limited support)
```

---

## 3. No Shrinking

- You can **increase** volume size but **cannot decrease** it
- Applies to both size and IOPS

```
100 GB → 500 GB ✅ (expand allowed)
500 GB → 100 GB ❌ (shrink NOT allowed)
```

---

## 4. Performance Limits

| Volume Type | Max IOPS | Max Throughput | Max Size |
|---|---|---|---|
| `gp2` | 16,000 IOPS | 250 MB/s | 16 TB |
| `gp3` | 16,000 IOPS | 1,000 MB/s | 16 TB |
| `io1` | 64,000 IOPS | 1,000 MB/s | 16 TB |
| `io2` | 256,000 IOPS | 4,000 MB/s | 64 TB |
| `st1` (HDD) | 500 IOPS | 500 MB/s | 16 TB |
| `sc1` (HDD) | 250 IOPS | 250 MB/s | 16 TB |

---

## 5. No Cross-Region Replication (Native)

- EBS volumes are **region-specific**
- To replicate cross-region, you must:
  1. Take a **snapshot**
  2. Copy the snapshot to another region
  3. Restore from snapshot in target region

```
Region us-east-1 → Snapshot → Copy → Region us-west-2  (manual process)
```

---

## 6. Snapshot Limitations

- First snapshot is a **full copy** — can be slow and costly
- Subsequent snapshots are **incremental**
- Restoring from a snapshot has **initial I/O latency** (lazy loading)
- Snapshots stored in **S3** but not directly accessible — only through EBS

---

## 7. EBS Multi-Attach Restrictions

Even with `io1` / `io2` Multi-Attach enabled:

| Restriction | Detail |
|---|---|
| **Max instances** | Up to 16 EC2 instances |
| **Same AZ only** | All instances must be in the same AZ |
| **Linux only** | Windows is not supported |
| **Cluster-aware FS required** | Must use GFS2 or OCFS2 — not ext4/xfs |

---

## 8. Cost — Provisioned Even When Unused

- You are billed for the **full provisioned size** even if the volume is empty or idle
- A 1 TB volume sitting unused still costs the same as one under full load

---

## 9. Boot Volume Limitations

- Root/boot volumes **cannot be detached** from a running instance
- Must **stop the instance** before detaching the boot volume

---

## 10. IOPS to Volume Size Ratio Limits

| Volume Type | Max IOPS per GB |
|---|---|
| `gp2` | 3 IOPS/GB (max 16,000) |
| `gp3` | Independent of size |
| `io1` | 50 IOPS/GB |
| `io2` | 500 IOPS/GB |

> For `gp2`, a small volume (e.g., 10 GB) gives only 30 IOPS — volume must be large enough to achieve desired IOPS.

---

## 11. Encryption Limitations

- Encryption must be set **at creation time** — cannot encrypt an existing unencrypted volume
- To encrypt an existing volume:
  1. Take a snapshot of the unencrypted volume
  2. Copy the snapshot with encryption enabled
  3. Restore as a new encrypted volume

---

## Quick Summary Table

| Limitation | Impact |
|---|---|
| **Single AZ** | Cannot attach to instances in other AZs |
| **Single instance (most types)** | No shared access like NFS |
| **No shrinking** | Must plan size upfront |
| **No native cross-region replication** | Manual snapshot copy needed |
| **Multi-Attach restrictions** | Only io1/io2, same AZ, Linux only |
| **Snapshot restore latency** | Initial I/O is slow (lazy loading) |
| **Billed when idle** | Cost even if not in use |
| **Boot volume non-detachable** | Instance must be stopped first |
| **Encryption at creation only** | Cannot encrypt existing volume directly |

---

## EBS vs IBM Cloud Block Storage — Quick Comparison

| Feature | AWS EBS | IBM Cloud Block Storage |
|---|---|---|
| **Single AZ** | ✅ Yes | ✅ Yes |
| **Multi-attach** | io1/io2 only | ❌ Not supported |
| **Max size** | 64 TB (io2) | 32 TB (sdp) |
| **Shrink** | ❌ No | ❌ No |
| **Encryption** | At creation only | ✅ Default + Key Protect |
| **Snapshots** | ✅ Yes | ✅ Yes |
| **Cross-region replication** | Manual (snapshot copy) | Manual |