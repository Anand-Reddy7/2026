======================================================================================================
## Tell me about Kube Pilet AI Project.

I am working on a Kubernetes Agentic AI platform called **KubePilot AI**.

At IBM, multiple application teams deploy their production workloads on a shared Kubernetes platform. Platform Engineering and Site Reliability teams monitor these workloads continuously. When an application fails, engineers inspect Kubernetes resources, logs, and events, then refer to runbooks and application documents to identify the root cause. This process is slow, requires Kubernetes expertise, and depends heavily on experienced engineers.

To improve this process, I designed an Agentic AI platform that accepts requests from chat or Slack and combines LLM reasoning, Kubernetes tools, RAG, LangChain, LangGraph, and MCP.

## Request Flow

### 1. Request intake

The user submits a request such as:

```text
Why is the fast-api-demo Deployment failing in the dev namespace?
```

The request enters the FastAPI application. A correlation ID traces the request across the Supervisor, agents, RAG service, MCP server, and Kubernetes cluster.

### 2. Security guardrails

Application-level guardrails run before the LLM. They check for empty or oversized requests, secret access, destructive commands, shell injection, unsupported operations, and unsafe cluster-wide changes. Unsafe requests are blocked before any agent, RAG service, or Kubernetes tool is called.

### 3. Conversation context

For follow-up questions, the application loads chat history from PostgreSQL. It redacts sensitive values, limits messages, trims large content, and summarizes older messages when necessary. The original history remains stored in PostgreSQL.

### 4. Supervisor intent classification

The Supervisor Agent classifies the intent, namespace, resource, action, RAG requirement, HITL requirement, clarification requirement, and confidence.

Example:

```text
Intent: diagnosis
Namespace: dev
Resource: Deployment/fast-api-demo
Needs RAG: true
Needs HITL: false
```

The Supervisor coordinates the workflow but does not directly modify Kubernetes resources.

### 5. Agent selection

```text
Normal read request → Insight Agent
Diagnosis or remediation → Troubleshooting Agent
```

## Insight Agent

The Insight Agent handles read-only questions such as listing pods, showing Deployments, or retrieving logs. It dynamically discovers tools from `/mcp/kubernetes/read` and uses Developer Kubernetes permissions. It cannot modify the cluster.

## Troubleshooting Agent

The Troubleshooting Agent investigates failures by inspecting Deployments, related pods, status, events, and logs. It compares live evidence with RAG guidance, identifies the likely root cause, and proposes remediation. Write tools are available only when the user requests a change and human approval is granted.

## RAG Retrieval

When documented knowledge is needed, the selected agent sends the question to the independent RAG service. The service creates an embedding, searches Qdrant, applies filters, retrieves and reranks relevant chunks, fits them within the token budget, and returns them to the agent.

For ImagePullBackOff, RAG may return:

```text
The image tag does not exist.
Check the Deployment image.
Update the Deployment to an available image.
Verify the rollout.
```

RAG provides documented knowledge; it does not inspect or modify the live cluster.

## MCP Tool Discovery and Execution

Agents discover typed tool names, descriptions, and schemas from:

```text
/mcp/kubernetes/read
/mcp/kubernetes/write
```

MCP exposes controlled Kubernetes SDK operations instead of unrestricted shell commands. It validates inputs, normalizes Kubernetes errors, and records audit information.

Typical tools include:

```text
diagnose_deployment
get_pod_logs
get_pod_events
list_pods
```

## Context Construction and Reasoning

The selected agent constructs the model context from:

```text
System instructions
+ User question
+ Sanitized conversation history
+ Live Kubernetes evidence
+ Relevant RAG chunks
+ Tool results
```

The LLM then produces the observed evidence, likely cause, remediation, and verification steps.

## Human-in-the-Loop Approval

For a cluster change, the system prepares an approval request containing the namespace, resource, container, current value, and proposed value. LangGraph pauses the workflow and the UI shows Approve and Deny actions.

Example:

```text
Namespace: dev
Deployment: fast-api-demo
Container: fast-api
Current image: anandreddy571/fast-api-app:does-not-exist
New image: anandreddy571/fast-api-app:v1.0.0
```

## Controlled Remediation and Verification

After approval, the Troubleshooting Agent calls a validated write MCP tool using the admin kubeconfig. The LLM never executes `kubectl` directly. Read-only tools then verify rollout status, available replicas, pod readiness, events, restart count, and container state.

The final response explains what was observed, the root cause, the approved change, the rollout result, and any remaining issue.

## Persistence and Auditability

The system stores chat history, LangGraph checkpoints, tool calls, RAG retrieval information, approval decisions, correlation IDs, and errors. This supports troubleshooting, auditing, evaluation, and recovery after service restarts.

## Important Routing Rule

The request below should go to the Troubleshooting Agent because it includes diagnosis and remediation:

```text
Check the application status and provide remediation if there is an issue.
```

Read-only status requests go to the Insight Agent. Diagnosis and remediation requests go to the Troubleshooting Agent.

## Interview Summary

The main design principle is separation of responsibilities. The Supervisor coordinates the workflow, the Insight Agent handles safe read-only operations, the Troubleshooting Agent diagnoses and proposes remediation, RAG provides documented knowledge, MCP provides controlled Kubernetes tools, and LangGraph manages state and HITL approval. The LLM reasons over evidence, but it never receives unrestricted cluster access or directly executes shell commands.


===============================================================================================