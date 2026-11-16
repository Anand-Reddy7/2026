# DataBase ( PostGress 17)

## Relational databases vs non Relational databases ?
** Relational**
A relational database (RDBMS) stores data in structured tables containing rows and columns. Tables can be connected using primary keys and foreign keys.

Examples: PostgreSQL, MySQL, Oracle, SQL Server, MariaDB.

** Non-relational**
A non-relational database (NoSQL) stores data using models such as documents, key-value pairs, wide columns, or graphs rather than primarily relying on relational tables.

Examples: MongoDB, DynamoDB, Redis, Cassandra, Neo4j, Qdrant.

## Why you are using Postgress?
We use LangGraph for agent orchestration, where multiple agents collaborate to investigate Kubernetes incidents and perform remediation.

PostgreSQL is suitable for storing incident metadata, agent execution records, workflow checkpoints, remediation approvals, and audit logs.

## PostGress VS MYSQL ?
We evaluated PostgreSQL and MySQL for our Kubernetes Agentic AI troubleshooting platform.

Both provide ACID transactions, concurrency control, and reliable relational storage.

We selected PostgreSQL for three main reasons.

First, our agents generate heterogeneous metadata, and PostgreSQL JSONB provides flexible storage and indexing. ( Your agents generate different types of output. Example: 1.Monitoring Agent: CPU, memory, pod health. 2. Troubleshooting Agent: root cause, logs, diagnostics. 3.Automation Agent: remediation commands and results. PostgreSQL JSONB allows you to store these varying structures without creating a separate table for every output format.)

Second, we use LangGraph for multi-agent orchestration, and PostgreSQL has an official checkpoint integration that supports persistent workflow state and recovery.

Third, PostgreSQL provides strong capabilities for complex operational analytics and querying semi-structured execution data.

We use PostgreSQL for incidents, agent executions, approvals, and workflow state, while Qdrant handles RAG embeddings and vector search.

So the decision was based on application requirements and ecosystem integration, not because MySQL lacks transactional capabilities.

## How to take a Backup of DB?
1. Backup Single DB
pg_dump -U postgres -h localhost -d kubepilot_db -F c -f kubepilot_backup.dump

2. Restore Backup
createdb -U postgres -h localhost kubepilot_restore
pg_restore -U postgres -h localhost \
  -d kubepilot_restore \
  kubepilot_backup.dump

3. Backup All databases
pg_dumpall -U postgres -h localhost > all_databases.sql


## How do you optimize a slow database query?
This is one of the most practical senior-level interview questions.

Suppose your Kubernetes platform has 50 million incident records and dashboard queries are slow.

A systematic approach is:
1. Identify the slow query and measure its latency.
2. Examine the execution plan.
3. Check table scans, joins, estimated rows, and index usage.
4. Add or improve appropriate indexes.
5. Reduce unnecessary columns and returned rows.
6. Consider pagination, query rewrites, caching, or partitioning.
7. Benchmark again using realistic data.

## What is a database deadlock?
How to handle it:
- Acquire locks in a consistent order.
- Keep transactions short.
- Create suitable indexes to reduce unnecessary locking.
- Retry transactions when the database reports a deadlock.
InnoDB can detect deadlocks and roll back a victim transaction.










# MYSQL
## Create Database
CREATE database learning_db;
show databases;
use learning_db;

## Show all tables and list out all the data
show tables;
show tables from learning_db;

## Create Table Schema
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20),
    mail_id VARCHAR(30),
    department VARCHAR(20),
    salary DECIMAL(10,2)
);

## Insert Data 
INSERT INTO employees (name, mail_id, department, salary)
VALUES
('Anand Reddy', 'anand_reddy@ibm.com', 'Cloud', 240000),
('BALAJI', 'balaji@nike.com', 'Platinum', 440000),
('Mahesh', 'Mahesh', NULL, NULL),
('Jagadeesh Reddy', 'jagadeesh_reddy@nike.com', 'Platinum', 340000);

## Opetaions
select * from employees;
describe employees;

## Other Operations

1. SELECT name, mail_id FROM employees WHERE salary>30000 AND department IS NOT NULL;

2. SELECT
    COUNT(*) AS total_employees,
    SUM(salary) AS total_salary,
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary,
    AVG(salary) AS avg_salary,
    ROUND(AVG(salary), 2) AS round_salary
FROM 
    employees;

3. select cluster_name, COUNT(*) as total_incidents from kubernetes_incidents where severity="CRITICAl";

4. select cluster_name, COUNT(*) as total_incidents from kubernetes_incidents where severity="CRITICAl" GROUP BY cluster_name HAVING COUNT(*)>2;


## JOINS

## INNER JOIN
Returns only matching records from both tables.
```sql
SELECT i.incident_id, a.agent_name
FROM join_incidents i
INNER JOIN join_agents a
ON i.agent_id = a.agent_id;
```

## LEFT JOIN
Returns all records from the left table and matching records from the right table.
```sql
SELECT i.incident_id, a.agent_name
FROM join_incidents i
LEFT JOIN join_agents a
ON i.agent_id = a.agent_id;
```

## RIGHT JOIN
Returns all records from the right table and matching records from the left table.
```sql
SELECT i.incident_id, a.agent_name
FROM join_incidents i
RIGHT JOIN join_agents a
ON i.agent_id = a.agent_id;
```

## FULL OUTER JOIN
Returns all records from both tables, whether matched or unmatched.
MySQL does not directly support FULL OUTER JOIN. Use:
```sql
SELECT i.incident_id, a.agent_name
FROM join_incidents i
LEFT JOIN join_agents a
ON i.agent_id = a.agent_id

UNION ALL

SELECT i.incident_id, a.agent_name
FROM join_incidents i
RIGHT JOIN join_agents a
ON i.agent_id = a.agent_id
WHERE i.incident_id IS NULL;
```

## What is the difference between WHERE and HAVING?
Answer:
- WHERE filters rows before grouping.
- HAVING filters aggregated groups.

## What is the difference between GROUP BY and PARTITION BY?
Answer:
- GROUP BY combines rows into aggregated groups.
- PARTITION BY divides rows into logical groups for window functions without reducing the number of rows.

## What is INDEXING in database ?
An index is a data structure that helps MySQL find records faster without examining every row in a table.

Think of a book with 1,000 pages.

Without an index, you may need to read many pages to find a topic. With an index, you locate the topic and jump directly to the relevant page.

```sql
CREATE INDEX idx_cluster
ON kubernetes_incidents(cluster_name);
```


################################################################
SQL QUERY's
################################################################

## Filter 2 tables and perform below actions
- Cluster name
- Total number of incidents
- Number of CRITICAL incidents
- Number of unresolved incidents (OPEN or INVESTIGATING)
- Average resolution time in minutes for resolved incidents, rounded to two decimal places

```sql
select 
    c.cluster_name, 
    Count(i.incident_id) as total_incidents, 
    SUM(CASE WHEN i.severity = 'CRITICAL' THEN 1 ELSE 0 END) as critical_incidents,
    SUM(CASE WHEN i.status IN ('OPEN', 'INVESTIGATING') THEN 1 ELSE 0 END) as not_resolved,
    ROUND(AVG(CASE WHEN i.status = 'RESOLVED' AND i.resolved_at IS NOT NULL THEN TIMESTAMPDIFF(SECOND, i.created_at, i.resolved_at) / 60.0 END), 2) AS avg_resolution_minutes
from 
    clusters c
LEFT JOIN
     incidents i
ON 
    c.cluster_id = i.cluster_id
GROUP BY 
    c.cluster_id, c.cluster_name
ORDER BY
    c.cluster_id;
```