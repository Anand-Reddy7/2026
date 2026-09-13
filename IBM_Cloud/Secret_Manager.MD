# IBM Secrets Manager

---

## What is IBM Secrets Manager?

IBM Secrets Manager is a **managed secrets management service** on IBM Cloud that helps you **securely store, manage, and access secrets** used by your applications and infrastructure.

---

## What is a "Secret"?

A secret is any **sensitive piece of information** your app needs to function:

| Type | Examples |
|---|---|
| **Credentials** | Usernames, passwords |
| **API Keys** | IBM Cloud API keys, third-party API keys |
| **Certificates** | TLS/SSL certificates |
| **SSH Keys** | Private keys for server access |
| **Tokens** | OAuth tokens, service tokens |
| **Arbitrary Secrets** | Connection strings, config values |

---

## What Problem Does It Solve?

### Without Secrets Manager
```
❌ Hardcoded in source code         → git leaks
❌ Stored in environment variables  → exposed in logs
❌ Passed via config files          → copied everywhere
❌ Shared over Slack/email          → no audit trail
```

### With Secrets Manager
```
✅ Centrally stored and encrypted
✅ Access controlled via IAM
✅ Auto-rotated before expiry
✅ Full audit trail of who accessed what
✅ Injected at runtime — never hardcoded
```

---

## Core Concepts

### 1. Secret
The actual sensitive value stored and managed (password, API key, certificate, etc.)

---

### 2. Secret Group
A **logical folder** to organize secrets by team, environment, or application.

```
Secret Groups:
├── lsf-prod
│   ├── db-password
│   ├── api-key
│   └── tls-cert
└── lsf-dev
    ├── db-password
    └── api-key
```

> IAM policies can be scoped to a secret group — e.g., dev team can only access the `lsf-dev` group.

---

### 3. Secret Rotation
Automatically **renews or regenerates** a secret before it expires.

| | Without Rotation | With Rotation |
|---|---|---|
| **Process** | Manually update before expiry | Auto-rotated on schedule |
| **Risk** | Expired credentials cause failures | Always fresh credentials |
| **Downtime** | Risk of downtime if forgotten | Zero downtime rotation |

---

### 4. Secret Engines
Different engines handle different types of secrets:

| Engine | Manages |
|---|---|
| **IAM Credentials** | IBM Cloud API keys (dynamic, auto-created) |
| **Key-Value** | Arbitrary secrets (JSON, strings) |
| **Public Cert** | TLS certs from Let's Encrypt / external CAs |
| **Private Cert** | Internal TLS certs (IBM Cloud private CA) |
| **Username/Password** | Credential pairs |
| **Service Credentials** | IBM Cloud service credentials |

---

## How It Works — Flow

```
App / VSI / Pipeline
      │
      │  "Give me the DB password for prod"
      ▼
IBM Secrets Manager  ←── Protected by IAM + Key Protect (CRK)
      │
      │  Checks: Does this identity have access?
      │  Decrypts the secret using Key Protect root key
      ▼
Returns secret value at runtime
      │
      ▼
App uses it — secret never stored locally
```

---

## Secrets Manager + Key Protect Integration

Secrets Manager uses **IBM Key Protect** (or HPCS) as its encryption backend:

```
Secret value
    └── Encrypted by → Key Protect Root Key (CRK)
                           └── Owned by you → full control
```

> If you delete the Root Key → all secrets become inaccessible → **crypto-shredding**

---

## IAM Access Control

Access is controlled at multiple levels:

| Level | Example |
|---|---|
| **Instance level** | Admin can manage the entire Secrets Manager instance |
| **Secret Group level** | Dev team can only read secrets in `lsf-dev` group |
| **Secret level** | A specific app can only read one specific secret |

---

## Secret Lifecycle

```
Create → Active → [Rotate] → Expired → Destroyed
                     ↑
              Auto or Manual rotation
```

| State | Description |
|---|---|
| **Active** | Secret is valid and accessible |
| **Pre-activation** | Created but not yet valid |
| **Expired** | Past expiry date — no longer usable |
| **Destroyed** | Permanently deleted — unrecoverable |

---

## In LSF Context

| Secret | How Secrets Manager Helps |
|---|---|
| **SSH private keys** | Stored securely, injected at VSI boot |
| **IBM Cloud API keys** | Dynamic IAM credentials for LSF nodes |
| **LDAP bind password** | Centrally managed, rotated automatically |
| **TLS certificates** | Auto-renewed for LSF web interfaces |
| **Database passwords** | Rotated without changing app config |

---

## Secrets Manager vs Storing in Code / Config

| Feature | Hardcoded / Config File | IBM Secrets Manager |
|---|---|---|
| **Encrypted at rest** | ❌ No | ✅ Yes |
| **Access audit trail** | ❌ No | ✅ Yes |
| **Auto rotation** | ❌ No | ✅ Yes |
| **IAM controlled access** | ❌ No | ✅ Yes |
| **Centrally managed** | ❌ No | ✅ Yes |
| **Risk of git leak** | ❌ High | ✅ None |

---

## One-line Summary

> IBM Secrets Manager = **A secure vault for all your sensitive credentials** — centrally stored, IAM-protected, auto-rotated, and never hardcoded.