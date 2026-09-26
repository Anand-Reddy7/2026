# Suppose our production application suddenly becomes very slow and some requests start returning 5xx errors.

```txt
First, I check the monitoring dashboard and see that the request latency has increased significantly, but CPU and memory are normal. So instead of immediately scaling the application, I check the application metrics and logs.

I notice that the database connection pool has reached its maximum limit. For example, the application allows a maximum of 50 concurrent database connections, and all 50 connections are currently in use.

Normally, a database query may complete in around 100 milliseconds, so a connection is quickly returned to the pool. But in this incident, one of the queries has become slow and is taking around 10 seconds.

Because each request holds a database connection for much longer, all 50 connections eventually become occupied. New application requests cannot immediately get a connection, so they start waiting.

The flow looks like this:

Slow database query
→ connections are held longer
→ 50/50 connection pool becomes occupied
→ new requests wait for a connection
→ application latency increases
→ requests eventually timeout
→ users start receiving 5xx errors.

At this point, simply increasing the connection pool from 50 to 100 may not be the correct solution because it can put even more load on the database.

First, I would identify why the query became slow. I would check slow-query logs, database CPU and I/O, locks, execution plans, and whether a recent deployment or data-volume change caused the problem.

For immediate recovery, depending on the cause, I might roll back a recent problematic deployment, stop or optimize the expensive query, reduce incoming load, or temporarily scale resources if necessary.

Once the service is stable, I would fix the actual root cause. For example, if the query is doing a full table scan because an index is missing, I would optimize the query or add the appropriate index.

Finally, I would add monitoring and alerts for database query latency and connection-pool utilization. For example, if the pool stays above 80% utilization for a meaningful period, we should receive an alert before it reaches 100%.

So my approach is not just to restart the application or increase the connection limit. I first understand why the connections are getting exhausted, restore the service, fix the root cause, and then add monitoring and preventive controls so the same incident does not happen again.
```
