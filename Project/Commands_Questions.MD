# Submit job requesting 2 GPUs
bsub -gpu "num=2" ./gpu_job.sh	

# Submit a job array of 1000 jobs
bsub -J "jobarray[1-1000]" ./job.sh	

# Submit to priority queue, 32 cores, 4GB RAM per slot
bsub -q priority -n 32 -R "rusage[mem=4096]" ./job.sh	

# Kill all jobs of a user
bkill -u username 0 

# Kill all jobs 
bkill 0

# Suspend a job
bstop 12345	

# Resume a suspended job
bresume 12345	

# Job history for a specific user
bhist -u username

# List all queues and their status
bqueues

# how real-time CPU/memory load on all nodes
lsload


# Overall cluster health — daemons, nodes, jobs
badmin showstatus

# Reload LSF config without restart
badmin reconfig

# Restart the master batch daemon 
badmin mbdrestart

# Show user job limits and usage
busers

# sub -R "span[hosts=1] ? 
```
-n 16 requests 16 slots (CPU cores) but they can be spread across multiple hosts. -R "span[hosts=1]" forces all 16 slots to be on a single host. You use span[hosts=1] when your job needs shared memory and can't distribute across nodes. You use distributed slots for MPI jobs that scale across nodes.
```

# What is LSF Resource Connector ? 
```
Resource Connector is LSF's cloud auto-scaling plugin. When pending jobs accumulate in the queue beyond a threshold, Resource Connector calls the cloud provider API (IBM Cloud, AWS, Azure) to provision new compute VMs. Those VMs boot, install LSF agent, register with the management node, and start accepting jobs. When they've been idle beyond a configured timeout, Resource Connector terminates them. This gives elastic scaling — you only pay for compute when jobs are running."
```

# What is the difference between bhosts showing ok, closed_Adm, unavail, unreach?

```text
Status	         Meaning
==========================
ok	            Node is healthy and accepting jobs
closed_Adm	    Admin closed the node — no new jobs
closed_Full	    Node is full — all slots busy
unavail	        Node is down — LSF daemon not responding
unreach	        Network unreachable — can't connect to node
closed_LIM	    LIM daemon not running on the node
```

# How does LSF handle node failure during job execution?

```
"If a compute node fails mid-job, sbatchd on that node stops responding. The management node's mbatchd detects this via the lim heartbeat timeout. The job status changes to EXIT. If the queue has REQUEUE_EXIT_VALUES configured, the job is automatically requeued and runs on a different node. If the job supports checkpointing, it restarts from the last checkpoint rather than from scratch."
```

# What is lim and what happens if it goes down?

```
"lim — Load Information Manager — runs on every node and collects resource metrics (CPU load, memory, disk) and sends them to the master. If lim goes down on a compute node, the management node can no longer see that node's resources. The node shows as unavail in bhosts. No new jobs will be dispatched to it. You restart it with lsadmin limrestart hostname."
```

# How do you submit a job that needs 8 cores, 16GB RAM, runs only on GPU nodes, and must finish within 2 hours?

```shell
bsub -n 8 \
     -R "rusage[mem=16384] select[gpu_node==1]" \
     -q gpu \
     -W 2:00 \
     ./myjob.sh
```

# How do you drain all nodes gracefully before a cluster maintenance window?

```shell
# Close all nodes — no new jobs, existing jobs finish
badmin hclose all

# Monitor until no running jobs
watch bjobs -u all -r

# Once all jobs done, proceed with maintenance
# After maintenance — reopen all nodes
badmin hopen all
```