# ImageOps AI - Project explanation 

One of the projects I worked on is ImageOps AI, an Agentic AI-based container image lifecycle management platform.

In our environment, we maintain standardized foundation container images for Python, Java, and Node.js. For each runtime, we maintain the latest three supported versions. For example, if the supported Python versions are 3.11, 3.12, and 3.13, we maintain foundation images for all three.

The challenge was that whenever a new runtime version became available, the platform team had to manually identify it, create or modify the Dockerfile, validate security standards, build and test the image, create a pull request, and monitor the CI/CD pipeline.

We automated this using an Agentic AI architecture built around Python, FastAPI, PostgreSQL, LangGraph, OpenAI, RAG, MCP, Docker, GitHub, CI/CD, and OpenTelemetry.
A scheduled Version/EOL service retrieves runtime lifecycle information and compares the latest three supported versions against the images maintained in our repository. If a version is missing, it creates a build request in PostgreSQL.

A LangGraph agent picks up that request. It uses RAG to retrieve our internal container standards, security policies, runtime-specific instructions, troubleshooting runbooks, and historical fixes. OpenAI uses that context along with existing Dockerfiles to generate the required changes.
The LLM doesn't get direct access to GitHub or Docker. We expose controlled operations through MCP tools. For example, Git MCP handles repository operations and Container MCP delegates test builds to an isolated build service.

Before creating a PR, we perform Dockerfile validation, build a temporary image, run the container, verify the runtime version, perform smoke tests, check non-root execution, and run security scanning.
If everything passes, the agent creates a PR. We keep human approval before merge. After approval, CI/CD independently rebuilds, tests, scans, signs, and publishes the production image to the container registry.

We also implemented a self-healing workflow. If a test or CI build fails, the agent reads the build logs, retrieves relevant troubleshooting knowledge and historical fixes through RAG, asks OpenAI to analyze the root cause, generates a corrective change, validates it, and retries. We limit autonomous retries to three before escalating to an engineer.
Finally, the complete workflow is instrumented using OpenTelemetry so that we can trace agent runs, LLM calls, MCP tool calls, build operations, latency, token usage, failures, and retries.




# Arch Diagram

![image](../images/AI_Container_Image_Lifecycle_Architecture.png)

# Arch Diagram

```text
                    Runtime APIs
                 Python / Java / Node
                         │
                         ▼
                Version/EOL Service
                         │
                  Latest-3 Policy
                         │
                         ▼
                     PostgreSQL
                         │
                  Build Request
                         │
                         ▼
                ┌─────────────────┐
                │ LangGraph Agent │
                └────────┬────────┘
                         │
             ┌───────────┼──────────────┐
             │           │              │
             ▼           ▼              ▼
           OpenAI       RAG             MCP
                         │              │
                         ▼              ├── Git MCP
                    Retriever           ├── Container MCP
                         │              ├── Version MCP
                         ▼              └── Notification MCP
                    Vector DB
                         │
            ┌────────────┼─────────────┐
            ▼            ▼             ▼
        Container     Security     Historical
        Standards     Policies     Build Fixes
            │            │             │
            └────────────┼─────────────┘
                         │
                         ▼
                 Retrieved Context
                         │
                         ▼
                      OpenAI
                         │
                         ▼
                 Generate / Fix
                    Dockerfile
                         │
                         ▼
              Static Validation
              ├── Dockerfile lint
              ├── Policy validation
              ├── Approved base image
              ├── Non-root check
              └── Secret/config checks
                         │
                         ▼
                ┌──────────────────┐
                │    TEST BUILD    │
                │                  │
                │ LangGraph Agent  │
                │        │         │
                │        ▼         │
                │  Container MCP   │
                │        │         │
                │        ▼         │
                │  Build Service   │
                └────────┬─────────┘
                         │
                         ▼
               Isolated Build Environment
                         │
             ┌───────────┼────────────┐
             │           │            │
             ▼           ▼            ▼
         docker       docker        Security
          build         run           Scan
             │           │            │
             │           ▼            │
             │     Runtime Tests      │
             │                         │
             └───────────┬─────────────┘
                         │
                         ▼
                  Test Build Result
                         │
                   ┌─────┴─────┐
                   │           │
                  PASS        FAIL
                   │           │
                   │           ▼
                   │      Build/Test Logs
                   │           │
                   │           ▼
                   │      RAG Retrieval
                   │      ├── Runbooks
                   │      ├── Past fixes
                   │      └── Known issues
                   │           │
                   │           ▼
                   │     OpenAI Analysis
                   │           │
                   │           ▼
                   │      Generate Fix
                   │           │
                   │           ▼
                   │       Validate Again
                   │           │
                   │           ▼
                   │      Test Build Again
                   │
                   │      Max 3 Attempts
                   │           │
                   │      Still Failed?
                   │           │
                   │           ▼
                   │     Human Escalation
                   │
                   ▼
                 Git PR
                   │
                   ▼
             Human Approval
                   │
                   ▼
                  Merge
                   │
                   ▼
                  CI/CD
           Production Image Build
                   │
          ┌────────┼─────────┐
          │        │         │
          ▼        ▼         ▼
       Build     Test     Security Scan
          │        │         │
          └────────┼─────────┘
                   │
              ┌────┴────┐
              │         │
           SUCCESS    FAILURE
              │         │
              ▼         ▼
          Sign Image  Build Logs
              │         │
              ▼         ▼
           Registry   PostgreSQL
                        │
                        ▼
                 Retry Build Request
                        │
                        ▼
                 LangGraph Agent
                        │
                        ▼
                   RAG + OpenAI
                        │
                        ▼
                Root Cause Analysis
                        │
                        ▼
                   Generate Fix
                        │
                        ▼
                  Validate + Test
                        │
                        ▼
                     Fix PR
                        │
                        ▼
                 Human Approval
```

# RAG information Stored

| Category | What to store | Example use |
|---|---|---|
| **1. Container Standards** | Organization Docker/container standards | Generate compliant Dockerfiles |
| **2. Security Policies** | Hardening rules, prohibited patterns, vulnerability policies | Validate generated images |
| **3. Runtime Standards** | Python, Java, Node-specific build instructions | Generate correct runtime image |
| **4. Dockerfile Patterns** | Approved Dockerfile templates/patterns | Use known-good implementation |
| **5. Troubleshooting Runbooks** | Common build/runtime failures and resolutions | Self-healing |
| **6. Historical Build Fixes** | Previous failure → root cause → successful fix | Solve recurring problems |
| **7. Dependency/Package Guidance** | OS/package compatibility knowledge | Resolve apt/package failures |
| **8. CI/CD Runbooks** | Pipeline stages, errors, remediation | Diagnose CI failures |
| **9. Vulnerability Remediation** | CVE remediation guidelines | Fix security scan failures |
| **10. Operational Runbooks** | Build-service/registry/Git/MCP operational procedures | Diagnose platform failures |
| **11. Architecture/Design Docs** | System architecture and service responsibilities | Agent understands boundaries |
| **12. Agent Instructions** | Tool-selection and remediation guidance | Control agent behavior |



## general-container-standards.md might contain:

```
All production foundation images must:

- Run as non-root
- Use approved base images
- Define WORKDIR
- Remove package-manager cache
- Contain required OCI labels
- Use COPY instead of ADD unless justified
- Avoid unnecessary packages
- Not contain embedded credentials
- Define approved filesystem permissions
```

## Security Policies

```
CRITICAL vulnerabilities → build must fail

HIGH vulnerabilities → fail unless exception exists

Secrets inside image → always fail

Root container → fail

Unapproved base image → fail

Privileged container → prohibited
```

## Dangerous patterns:

```
DO NOT:

curl ... | bash
chmod 777
USER root as final user
COPY . .
hardcode passwords
disable TLS verification
download binaries without checksum verification
```

## Runtime-specific standards

```
knowledge/runtimes/

├── python/
│   ├── installation.md
│   ├── configuration.md
│   ├── dependencies.md
│   ├── ssl.md
│   └── troubleshooting.md
│
├── java/
│   ├── installation.md
│   ├── jdk-configuration.md
│   ├── certificates.md
│   ├── jvm-settings.md
│   └── troubleshooting.md
│
└── node/
    ├── installation.md
    ├── npm-configuration.md
    ├── certificates.md
    ├── dependencies.md
    └── troubleshooting.md
```

```
Installation procedure
Required system libraries
pip configuration
Certificate configuration
SSL requirements
Expected python --version output
Smoke tests
Filesystem locations
Environment variables
```

## Approved Dockerfile patterns

```
knowledge/templates/

├── python-foundation-pattern.md
├── java-foundation-pattern.md
├── node-foundation-pattern.md
├── non-root-pattern.md
├── certificate-installation-pattern.md
├── package-installation-pattern.md
└── multi-stage-build-pattern.md
```

## Troubleshooting runbooks

```
knowledge/troubleshooting/

├── docker/
│   ├── build-failure.md
│   ├── network-errors.md
│   ├── permission-errors.md
│   └── filesystem-errors.md
│
├── python/
│   ├── pip-errors.md
│   ├── openssl-errors.md
│   ├── compilation-errors.md
│   └── dependency-errors.md
│
├── java/
│   ├── jdk-install-errors.md
│   ├── certificate-errors.md
│   └── dependency-errors.md
│
├── node/
│   ├── npm-errors.md
│   ├── node-gyp-errors.md
│   └── package-errors.md
│
├── registry/
│   ├── authentication-errors.md
│   └── push-errors.md
│
└── cicd/
    ├── pipeline-failures.md
    └── security-scan-failures.md
```

```
Problem:
Python image build fails installing OpenSSL.

Symptoms:
...

Possible Causes:
1. Package renamed
2. Repository unavailable
3. OS version incompatible
4. Runtime requires newer OpenSSL

Diagnosis:
...

Approved Resolution:
...

Validation:
...

Do NOT:
...
```



# Final RAG structure I'd use

```
imageops-ai/
│
├── knowledge-base/
│
│   ├── container-standards/
│   │   ├── general-standards.md
│   │   ├── approved-base-images.md
│   │   ├── dockerfile-guidelines.md
│   │   └── image-labels.md
│   │
│   ├── security/
│   │   ├── container-security.md
│   │   ├── secrets-policy.md
│   │   ├── vulnerability-policy.md
│   │   ├── sbom-policy.md
│   │   └── prohibited-patterns.md
│   │
│   ├── runtimes/
│   │   ├── python/
│   │   ├── java/
│   │   └── node/
│   │
│   ├── templates/
│   │   ├── python-pattern.md
│   │   ├── java-pattern.md
│   │   └── node-pattern.md
│   │
│   ├── troubleshooting/
│   │   ├── docker/
│   │   ├── python/
│   │   ├── java/
│   │   ├── node/
│   │   ├── registry/
│   │   └── cicd/
│   │
│   ├── historical-fixes/
│   │   ├── python/
│   │   ├── java/
│   │   └── node/
│   │
│   ├── vulnerability-remediation/
│   │
│   ├── cicd/
│   │
│   ├── runbooks/
│   │
│   ├── architecture/
│   │
│   └── agent-guides/
│
└── ...
```


## Scheduler Example

```py
from contextlib import asynccontextmanager

from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import FastAPI


scheduler = BackgroundScheduler()


def check_runtime_versions():
    print("Checking Python, Java and Node.js versions...")

    check_python_versions()
    check_java_versions()
    check_node_versions()


def check_python_versions():
    print("Checking Python versions")


def check_java_versions():
    print("Checking Java versions")


def check_node_versions():
    print("Checking Node.js versions")


@asynccontextmanager
async def lifespan(app: FastAPI):

    scheduler.add_job(
        check_runtime_versions,
        trigger="interval",
        hours=24,
        id="runtime_version_check",
        replace_existing=True
    )

    scheduler.start()

    yield

    scheduler.shutdown()


app = FastAPI(
    title="ImageOps AI - Version Service",
    lifespan=lifespan
)


@app.get("/health")
def health():
    return {
        "status": "UP"
    }
```


--------------------------------------

# Project Explanation in Different way

```
One of the projects I worked on is **ImageOps AI**, an Agentic AI-based platform for managing the lifecycle of secure container base images.

Let me first explain the problem we were trying to solve.

Earlier, different application teams across the organization were deploying their applications as containers. Most teams were directly using publicly available Docker images as their base images.

For example, a Python application might use:

```text
python:3.11
```

A Java application might use:

```text
eclipse-temurin:21
```

and similarly teams were using public images for Node.js, Go, and other runtimes.

As container adoption increased, we had growing concerns around **security, vulnerabilities, consistency, and governance**.

We didn't want every application team independently selecting a public image and configuring security in its own way.

So the organization decided to provide **internally managed and security-hardened foundation images**.

Instead of application teams directly consuming arbitrary public images, the platform team would maintain approved base images.

For example:

```text
Public Image
     ↓
Platform Team
     ↓
Security Hardening
     ↓
Vulnerability Validation
     ↓
Required Certificates
     ↓
Standard OS Packages
     ↓
Non-root Configuration
     ↓
Standard Docker Policies
     ↓
Approved Internal Base Image
     ↓
Application Teams
```

These internal images follow our organizational standards.

We perform things such as vulnerability scanning, installing required CA/SSL certificates, configuring non-root users, applying approved filesystem permissions, adding required image labels, controlling OS packages, removing unnecessary packages and package-manager caches, and applying other container security standards.

The application teams then use these approved internal images as the foundation for their application containers.

For example, instead of directly using:

```text
FROM python:3.13
```

they could use an internally maintained image such as:

```text
FROM company-registry/python:3.13
```

This gave us much better control over security and standardization.

But that introduced another challenge.

We don't maintain just one image for each technology. Different applications run on different supported runtime versions.

For example, for Python we may need to support:

```text
Python 3.11
Python 3.12
Python 3.13
```

Similarly, we maintain multiple approved versions for Java, Node.js, Go, and other commonly used runtimes.

We therefore defined a lifecycle policy where, for the runtimes managed by the platform, we maintain a defined supported version window—for example, the latest three approved versions.

So if our current Python images are:

```text
Python 3.11
Python 3.12
Python 3.13
```

and Python 3.14 becomes an approved version, our desired state changes to:

```text
Python 3.12
Python 3.13
Python 3.14
```

We need to create and validate the new Python 3.14 foundation image, while the older 3.11 image goes through our deprecation lifecycle rather than being immediately deleted.

Initially, much of this lifecycle involved manual platform-engineering work.

An engineer had to monitor runtime versions and EOL information, determine whether we were missing an image, inspect the existing Dockerfiles, create the Dockerfile for the new version, apply our security standards, build the image, run validation tests, perform vulnerability scans, create a Git pull request, and then monitor the CI/CD pipeline.

That is where we introduced **ImageOps AI**.

The objective was not to allow AI to control the infrastructure directly. The objective was to automate the repetitive parts of the container-image lifecycle while keeping our existing security, Git, human-review, and CI/CD controls in place.

We built the solution around **Python, FastAPI, PostgreSQL, LangGraph, OpenAI, RAG, MCP, Docker, Git, CI/CD, and OpenTelemetry**.

The workflow starts with a scheduled **Version/EOL service**.

Every 24 hours, the service checks the supported versions of the runtimes we manage. It applies our version-support policy and compares the desired versions against the foundation images already maintained by the platform.

For example:

```text
Version/EOL API

Python supported versions
        ↓
Latest-three policy
        ↓
3.12
3.13
3.14
        ↓
Compare with our repository/database
        ↓
Existing:
3.11
3.12
3.13
        ↓
Missing:
3.14
```

If a required version is missing, the service creates a **build request in PostgreSQL**.

PostgreSQL acts as our operational system of record. It stores runtime information, container variants, build requests, build results, retry counts, and agent-run status.

The new build request then becomes input to our **LangGraph agent workflow**.

We use LangGraph because this isn't just a single LLM call. The process contains multiple steps, state transitions, conditional decisions, tool calls, retries, failure handling, and human approval.

For a Python 3.14 request, for example, the agent first examines the existing repository and identifies the closest approved implementation, such as the Python 3.13 Dockerfile.

But the LLM also needs to understand our organization's standards.

OpenAI already understands Docker in general, but it doesn't automatically know our internal container policies, certificate requirements, approved installation patterns, security standards, troubleshooting procedures, or previous build failures.

That's where we use **RAG**.

Our RAG knowledge base contains information such as:

```text
Container standards
Security policies
Runtime-specific instructions
Approved Dockerfile patterns
Certificate installation procedures
Troubleshooting runbooks
Vulnerability-remediation guidance
CI/CD runbooks
Historical successful build fixes
```

For example, when generating the Python 3.14 image, the agent can retrieve the relevant Python standards, container security requirements, certificate configuration, and approved Dockerfile patterns.

We combine that retrieved knowledge with the existing Python Dockerfile and provide the relevant context to OpenAI.

OpenAI can then reason about what needs to change for Python 3.14 and generate the proposed Dockerfile or supporting-file changes.

A very important part of our architecture is that **the LLM does not directly access Git, Docker, or production infrastructure**.

We separate reasoning from execution using **MCP tools**.

For example:

```text
LangGraph Agent
      │
      ├── Git MCP
      │     ├── read files
      │     ├── create branch
      │     ├── push changes
      │     └── create PR
      │
      ├── Container MCP
      │     ├── validate Dockerfile
      │     ├── request test build
      │     ├── run smoke tests
      │     └── request security scan
      │
      └── Notification MCP
            └── send notifications
```

So the LLM reasons about what should happen, while controlled tools perform the actual operations.

Before creating a pull request, we don't simply trust the generated Dockerfile.

First, we perform deterministic validation.

We check things such as the approved base image, Dockerfile syntax and policy compliance, non-root configuration, prohibited patterns, certificate requirements, and other mandatory security rules.

Critical policies are enforced by code. We don't depend only on the LLM or RAG for security enforcement.

After static validation succeeds, we perform a **test build**.

The LangGraph agent does not directly run Docker. It calls our Container MCP, which delegates the operation to an isolated build service.

The flow looks like:

```text
LangGraph Agent
      ↓
Container MCP
      ↓
Isolated Build Service
      ↓
docker build
      ↓
docker run
      ↓
Runtime Version Test
      ↓
Smoke Tests
      ↓
Non-root Validation
      ↓
Security Scan
      ↓
Structured Build Result
```

For a Python 3.14 image, for example, we verify that the container starts successfully, `python --version` returns the expected version, required certificates and libraries are available, the process runs as the expected non-root user, smoke tests pass, and the image meets our vulnerability policy.

If all validations pass, the agent uses the Git MCP to create a branch, commit the proposed changes, and create a pull request.

At this point we intentionally introduce **human-in-the-loop approval**.

The agent can generate, test, and propose the change, but it cannot independently merge a production change.

An engineer reviews and approves the PR.

After the PR is merged, the normal CI/CD pipeline takes over.

CI/CD independently checks out the approved source and performs a clean production build. It runs the required tests and security scans, generates the required software-bill-of-materials information where applicable, signs the image, and finally publishes the approved image to our internal container registry.

One important design decision is that we **do not promote the temporary image created by the AI test-build process directly to production**.

The pre-PR build is only validation.

The authoritative production image is independently rebuilt by CI/CD from the reviewed and approved source.

We also added a **self-healing workflow** for build failures.

Suppose the Python 3.14 build fails with an error such as an OpenSSL or OS-package compatibility problem.

The CI/CD system sends the build status and build-log reference back to ImageOps AI.

The detailed CI logs are kept in log or object storage, while PostgreSQL stores the structured build result and log reference.

The agent retrieves the relevant failure information through a controlled tool.

We don't normally send thousands of raw CI-log lines directly to OpenAI. A deterministic log-processing layer extracts useful information such as:

```text
Failed stage
Failed command
Error message
Exit code
Relevant surrounding log lines
```

The agent then uses that failure context to retrieve related information from RAG—for example, Python troubleshooting instructions, OpenSSL remediation guidance, security policies, and similar historical successful fixes.

The combination looks like:

```text
Current Build Error
        +
Current Dockerfile
        +
Relevant RAG Knowledge
        ↓
      OpenAI
        ↓
Root Cause Analysis
        ↓
Recommended Remediation
```

The agent first classifies the failure.

This is important because not every CI failure requires a Dockerfile modification.

For example, if the failure is caused by an invalid dependency, the agent may generate a corrective Dockerfile change.

But if the registry returns an HTTP 503 or there is a temporary network failure, the agent should classify it as an infrastructure or transient issue and retry according to policy rather than unnecessarily changing the Dockerfile.

If a code or configuration change is required, the agent generates the smallest appropriate correction, validates it, performs another isolated test build, and, if successful, creates a fix PR.

We also don't allow unlimited autonomous self-healing.

We use a bounded retry policy. For example, after a maximum of three unsuccessful automated remediation attempts, the workflow stops and escalates the issue to an engineer with the build information, attempted fixes, and failure history.

Finally, we instrument the complete workflow using **OpenTelemetry**.

This allows us to trace an entire execution from the initial build request through RAG retrieval, OpenAI calls, MCP tool executions, test builds, Git operations, and final CI/CD result.

We capture information such as LLM latency and token usage, tool execution time, build duration, retry count, failures, and final workflow status.

So at a high level, I describe the architecture as:

```text
Runtime APIs
     ↓
Version/EOL Service
     ↓
PostgreSQL
     ↓
LangGraph
     ↓
RAG + OpenAI
     ↓
MCP Tools
     ↓
Generate + Validate
     ↓
Isolated Test Build
     ↓
Git PR
     ↓
Human Approval
     ↓
CI/CD
     ↓
Secure Internal Registry
```

The main design principle behind the project is:

**We use APIs for current facts, PostgreSQL for operational state, RAG for organizational knowledge, OpenAI for reasoning, MCP for controlled actions, and LangGraph for stateful orchestration.**

We don't try to replace normal DevOps automation with AI. Deterministic activities such as version comparison, policy enforcement, database operations, security gates, and CI/CD remain deterministic. We use AI primarily where reasoning adds value—for understanding existing implementations, generating changes, analyzing complex failures, and proposing remediation.

That combination gives us the benefit of Agentic AI while still maintaining the security, predictability, auditability, and human control required for a production DevOps platform.
```