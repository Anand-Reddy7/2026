# CITI Bank used LSF for below
One of our clients is a major global investment bank. They use the IBM HPC cluster on IBM Cloud to run their overnight risk calculations — Monte Carlo simulations across millions of financial instruments. The key requirement for them was SLA compliance — all risk jobs must complete within a strict overnight window before markets open. LSF's priority queuing and fair-share scheduling ensures their critical risk jobs always get compute resources first. We deployed the cluster on IBM Cloud VPC, integrated with their existing network via Transit Gateway, and the whole environment was provisioned through our Terraform automation.

## Key technical points to add:
```
Strict SLA windows (overnight batch)
Priority queue configuration in LSF
Private connectivity (Transit Gateway / Direct Link) to their on-prem network
Security compliance — Trusted Profiles, no stored API keys, encrypted storage
```

# Marvel (Media & Entertainment)
We have a client in the entertainment industry — a major Hollywood studio. They use the HPC cluster for their CGI rendering pipeline. A single photorealistic frame can take hours to render, and a film has over 100,000 frames. LSF distributes each frame as a separate job across hundreds of compute nodes. What makes the cloud deployment valuable for them is the burst capability — they don't need peak capacity 365 days a year. During production crunch, they scale up to hundreds of VSIs. After the film ships, they scale back down. With on-prem HPC, they'd have to buy hardware for peak load and have it sit idle otherwise. Our cloud solution with LSF Resource Connector gives them elastic scale.

# Cadence (EDA — Electronic Design Automation)

We have a client in the semiconductor/EDA space. They use LSF to manage chip verification workloads. When designing a modern processor with billions of transistors, you can't physically test every scenario — you run millions of simulation jobs. LSF schedules these across the cluster, manages the EDA tool licenses (which are extremely expensive), and ensures simulation results are collected and reported. The LSF license scheduling feature is critical here — Cadence tools like Spectre or Virtuoso cost thousands of dollars per token. LSF ensures no job starts without a license available, and licenses are never wasted sitting idle while jobs wait in queue."





# Final Answer

```
I've worked on deployments for clients across multiple industries. In financial services, we have a global bank running overnight risk calculations — Monte Carlo simulations that must complete within strict regulatory windows, and their production cluster runs well over 1,000 worker VSIs to meet those overnight SLA windows. In media and entertainment, we have a major Hollywood studio running CGI rendering pipelines where LSF distributes frame rendering across hundreds of GPU nodes. In the semiconductor space, we work with an EDA company running chip verification simulations — LSF's license scheduling is critical there because EDA tools cost thousands per license token, and they run their workloads on 500 bare metal nodes for the raw, dedicated compute power that chip verification demands.

Across all of them, the common pattern is: massive parallel compute workloads that are too large for a single machine, strict time or cost constraints, and the need for shared high-performance storage that all nodes can access simultaneously. That's exactly what LSF and Spectrum Scale are designed for.

Our client onboarding process always starts with a Proof of Concept (POC). Before committing to a full production deployment, we set up a smaller cluster with the client, run their actual workloads against it, and validate performance, features, and integration with their existing systems. If the client is satisfied — with the performance, the scale, and the features — we proceed to deploy the full production cluster. If during the POC they identify gaps or need capabilities that aren't available out of the box, we evaluate feasibility and implement those features before going to production. This approach reduces risk for the client and ensures the solution is production-ready before we scale it up.

My specific contribution is the cloud delivery layer — I build and maintain the Terraform automation that lets these clients deploy a production-ready HPC cluster on IBM Cloud in hours, not weeks, through a catalog tile. They fill in their parameters, and our automation handles the VPC, networking, security, LSF configuration, and Scale setup end to end.
```

# Why Bare Metal for Cadence?"
EDA workloads like chip verification are extremely sensitive to compute consistency. Virtual machines share underlying hardware and can have noisy-neighbor effects — unpredictable latency spikes that can corrupt timing-sensitive simulations. Bare metal nodes give dedicated, predictable performance with no hypervisor overhead. For a client like Cadence where a single simulation run can take days, you cannot afford variability. That's why they chose 500 bare metal nodes over VSIs.


# What Happens During the POC?"
During the POC we deploy a representative cluster — maybe 10–20% of the final size — and run the client's real workloads on it. We measure job throughput, scheduling latency, storage I/O performance, and check that all their tooling integrates with LSF correctly. We also validate security and network connectivity requirements. If they need a feature that isn't available — say a custom LSF job submission wrapper, a specific autoscaling policy, or integration with their internal ticketing system — we assess feasibility, build it, and include it in the POC validation before signing off on the full deployment.



# Why Single-Zone Architecture Decision ?

```
"Originally, our HPC cluster was designed to span two availability zones — the idea was to get higher availability and resilience. Worker nodes were distributed across both zones, and the LSF management nodes could failover between zones.

However, in practice we ran into significant latency and throughput issues. HPC workloads — especially tightly-coupled parallel jobs like CFD simulations, molecular dynamics, or seismic processing — require nodes to communicate with each other very frequently and very fast during job execution. When nodes are in different availability zones, they communicate over the inter-zone network link, which introduces latency of around 1–2 milliseconds compared to sub-millisecond latency within the same zone.

For loosely-coupled workloads like rendering or Monte Carlo simulations — where each job runs independently — that latency doesn't matter. But for tightly-coupled MPI jobs where hundreds of nodes are constantly exchanging data with each other during computation, that extra latency compounds at scale. A job running across 500 nodes with frequent inter-node communication was taking significantly longer than it should, and the inter-zone bandwidth was also becoming a bottleneck for large data transfers.

We also realized that HPC clusters are fundamentally different from web applications when it comes to availability design. A web app benefits from multi-zone because you want HTTP requests to keep flowing if one zone goes down. But an HPC job that's mid-execution cannot simply failover to another zone — the job has to restart from the last checkpoint. So the high availability benefit we expected from two zones wasn't actually realized in practice for running jobs.

Based on this analysis, we made the architectural decision to move to a single availability zone deployment. All nodes — management, login, static compute, and dynamic compute — are co-located in the same zone, on the same high-speed backbone network. This gave us lower latency, higher throughput, and better MPI job performance. For availability, we handle it differently — LSF checkpointing, job requeue policies, and management node redundancy within the same zone.

The learning here was that HPC architecture is not the same as traditional cloud application architecture. Best practices from web-scale systems don't always translate to HPC workloads."


```

## Summary
```
We initially deployed across two availability zones for high availability, but discovered that inter-zone latency was killing performance for tightly-coupled MPI workloads. HPC jobs need sub-millisecond inter-node communication — the inter-zone link couldn't deliver that at scale. We moved to single-zone, solved the latency and throughput issues, and handle availability through LSF-level redundancy and job requeue policies instead.
```

## But What About High Availability Now?

```
Good question. Since we're in a single zone, we handle availability at the software level rather than the infrastructure level. LSF management nodes run in active-passive mode — if the primary fails, the secondary takes over the job queue. For compute nodes, LSF has built-in job requeue — if a compute node goes down mid-job, LSF automatically requeues the job to run on another node. For checkpointed jobs, it restarts from the last checkpoint rather than from scratch. We also use IBM Cloud's SLA for the zone itself — IBM guarantees zone-level availability. So the trade-off is: we accept zone-level failure risk in exchange for the performance characteristics that HPC workloads actually need.
```