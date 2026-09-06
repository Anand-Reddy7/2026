# GutHub Actions
GitHub Actions is GitHub's native CI/CD automation platform. It allows us to define workflows as YAML files that are triggered by repository events such as push or pull request. The workflow contains jobs and steps, and those jobs execute on GitHub-hosted or self-hosted runners.

```text
Developer
   |
   | git push
   v
GitHub Repository
   |
   | triggers
   v
GitHub Actions
   |
   | runs workflow
   v
Runner
   |
   | executes commands
   v
Build / Test / Deploy
```

# Triggering the Workflow
- push
- pull_request
- issue
- schedule
- workflow_dispatch
- release

```yml
# Multiple branches
on:
  push:
    branches:
      - main
      - develop

# Branch pattern
on:
  push:
    branches:
      - 'release/**'
    
# pull_requeston:
on:
  pull_request:
    branches:
      - main

# pull_request types
on:
  pull_request:
    types:
      - opened
      - synchronize
      - reopened

# schedule
on:
  schedule:
    - cron: '0 2 * * *'

# release
on:
  release:
    types:
      - published

# issues
on:
  issues:
    types:
      - opened

# Multiple triggers
on:
  push:
    branches:
      - main

  pull_request:
    branches:
      - main

  workflow_dispatch:

# File/path filtering
on:
  push:
    branches:
      - main
    paths:
      - 'Dockerfile'
      - 'docker/**'
    paths-ignore:
      - 'docs/**'
      - 'README.md'
```


## workflow_run
```
Run a workflow after another workflow completes.

on:
  workflow_run:
    workflows:
      - "Docker Build"
    types:
      - completed
```

# GitHub Runners

A runner is the execution machine for a GitHub Actions job.

```
jobs:
  build:
    runs-on: ubuntu-latest
```

## GitHub Runner Types

### 1. GitHub-hosted

A GitHub-hosted runner is a virtual machine provided and managed by GitHub.

### 2. Larger GitHub-hosted
A larger GitHub-hosted runner is still managed by GitHub, but it provides more resources and additional capabilities than standard GitHub-hosted runners.

```
Normal runner
    |
    | CPU/RAM insufficient
    v
Build takes too long
```
A larger runner can provide substantially more compute resources, depending on the configuration available to your GitHub plan.

```
                 GitHub
                   |
          ┌────────┴─────────┐
          |                  |
      Standard            Larger
       Runner              Runner
          |                  |
       Normal             Heavy jobs
       workload           / large builds
```

### 3. Self-hosted

A self-hosted runner is a machine that you provide and manage yourself, with the GitHub Actions runner software installed on it.


```
GitHub-hosted = GitHub manages the machine.
Self-hosted = We manage the machine.
Ephemeral = fresh runner per job.
Persistent = same runner reused across jobs.
```
-------------------------------------

# Example configuration

```shell
mkdir actions-runner && cd actions-runner

curl -o actions-runner-osx-x64-2.337.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.337.0/actions-runner-osx-x64-2.337.0.tar.gz

tar xzf ./actions-runner-osx-x64-2.337.0.tar.gz

./config.sh --url https://github.com/Anand-Reddy7/testing-repo-delete --token xxxxxxxxxx

./run.sh
```


-------------------------------------

# Questions

## 1. Can I install custom software on the github hosted runner ?

Yes — but only temporarily during that workflow job.

With a normal GitHub-hosted runner, you can install additional software in your workflow, but you do not permanently modify the runner VM.

```yml
steps:
  - name: Install jq
    run: |
      sudo apt-get update
      sudo apt-get install -y jq

  - name: Check jq
    run: jq --version
```

We can install additional software during the workflow using shell commands or actions, but the changes are temporary because the GitHub-hosted runner environment is ephemeral. If we need persistent custom software, special networking, or a customized environment, we would typically use a self-hosted runner.


## 2. Where to create secret to use it ?

In your GitHub repository:
```
Repository → Settings → Secrets and variables → Actions → New repository secret
```

How to use it :
```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}
```


# Real time Terraform workflow

```yaml
name: 'Terraform'

on:
  push:
    branches: ["main"]
  pull_request:

permissions:
  contents: read

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    environment: production

    defaults:
      run:
        shell: bash

    steps:
      # Checkout the repository to the GitHub Actions runner
      - name: Checkout
        uses: actions/checkout@v4

      # Install Terraform CLI and configure Terraform Cloud authentication
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

      # Initialize Terraform
      - name: Terraform Init
        run: terraform init

      # Check Terraform formatting
      - name: Terraform Format
        run: terraform fmt -check

      # Generate Terraform execution plan
      - name: Terraform Plan
        run: terraform plan -input=false
```
