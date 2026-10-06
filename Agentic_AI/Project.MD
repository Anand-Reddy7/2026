```text
                         DEVELOPER
                             │
                             ▼
                       Git Repository
                             │
                        PR Merged
                             │
                             ▼
                      CI PIPELINE
                             │
              ┌──────────────┼──────────────┐
              │              │              │
          Unit Tests      Security       Docker Build
                         Scanning             │
                                             ▼
                                     Container Registry
                                             │
                                      Release Artifact
                                             │
                                             ▼
                                      Release Event
                                             │
                                             ▼
                                  ┌─────────────────────┐
                                  │  SUPERVISOR AGENT   │
                                  └──────────┬──────────┘
                                             │
                                             ▼
                                  ┌─────────────────────┐
                                  │  AUTOMATION AGENT   │
                                  │                     │
                                  │ Validate Release    │
                                  │ Pre-deploy Checks   │
                                  │ Deployment Plan     │
                                  └──────────┬──────────┘
                                             │
                                      PROD → HITL
                                             │
                                             ▼
                                         MCP Server
                                             │
                                             ▼
                                      Kubernetes API
                                             │
                                             ▼
                                        DEPLOYMENT
                                             │
                                             ▼
                                     Verify Rollout
                                             │
                              ┌──────────────┴──────────────┐
                              │                             │
                           SUCCESS                        FAILED
                              │                             │
                              ▼                             ▼
                       Digital Worker               Supervisor Agent
                         Monitoring                        │
                                                           ▼
                                                    INSIGHT AGENT
                                                           │
                                              ┌────────────┴───────────┐
                                              │                        │
                                             MCP                      RAG
                                              │                        │
                                      Pods / Events / Logs          Runbooks
                                      Deployment / Config            SOPs
                                              │                        │
                                              └────────────┬───────────┘
                                                           ▼
                                                    ROOT CAUSE
                                                           │
                                                           ▼
                                                 Is issue fixable?
                                                   /             \
                                                 YES              NO
                                                  │                │
                                                  ▼                │
                                          Remediation Plan         │
                                                  │                │
                                                  ▼                │
                                          AUTOMATION AGENT         │
                                                  │                │
                                           Apply Safe Fix          │
                                                  │                │
                                                  ▼                │
                                             RETRY DEPLOYMENT      │
                                                  │                │
                                                  ▼                │
                                            Verify Again           │
                                                  │                │
                                      ┌───────────┴───────────┐    │
                                      │                       │    │
                                   SUCCESS                  FAILED │
                                      │                       │    │
                                      ▼                       ▼    │
                               Digital Worker          Retry Counter
                                                          │
                                             ┌────────────┴───────────┐
                                             │                        │
                                      Retry Remaining?          Retries Exhausted
                                             │                        │
                                            YES                      │
                                             │                        │
                                             ▼                        │
                                      Insight Agent                  │
                                             │                        │
                                      Investigate Again              │
                                             │                        │
                                      Fix → Retry                     │
                                                                      │
                                   ┌──────────────────────────────────┘
                                   ▼
                             ROLLBACK REQUIRED
                                   │
                                   ▼
                           Automation Agent
                                   │
                         Prepare Rollback Plan
                                   │
                              PROD → HITL
                                   │
                                   ▼
                              MCP Server
                                   │
                                   ▼
                           Kubernetes Rollback
                                   │
                                   ▼
                            Verify Rollback
                                   │
                          ┌────────┴────────┐
                          │                 │
                       HEALTHY          STILL FAILED
                          │                 │
                          ▼                 ▼
                   Digital Worker       Escalation
```