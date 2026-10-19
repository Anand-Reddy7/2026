# First understand the AWS GenAI ecosystem

There are three important AWS services you need to distinguish.
## Amazon Bedrock
Foundation models, inference, Knowledge Bases, Agents, Guardrails

## Amazon Bedrock AgentCore
Agent runtime, tool gateway, identity, memory, policies, observability

## Amazon SageMaker AI
Model development, training, fine-tuning, deployment, and ML operations


## Think of them this way:
- Bedrock: Gives your application access to AI models and managed GenAI capabilities.
- AgentCore: Helps you deploy and operate AI agents in production.
- SageMaker AI: Gives ML engineers greater control over building, customizing, and hosting models.
---------------------------------------------------------------------------------

# AWS BedRock
Amazon Bedrock is a fully managed AWS service for building generative AI applications using foundation models.


## Bedrock Runtime Endpoint

**Bedrock Runtime Endpoint:** The API address your application uses to send requests to AI models and receive responses. Think of it as the entry point to Bedrock's AI models.

## 1. Discover

| Feature | Explanation |
|---|---|
| **Model Catalog** | A library of AI models such as Claude, Nova, and GPT-OSS. You can explore available models and their capabilities. |
| **API Keys** | Credentials that let your application authenticate to supported Bedrock APIs. Like a password for API access, but with configurable permissions and expiration. |

## 2. Test

| Feature | Explanation |
|---|---|
| **Playground** | A testing area where you can chat with AI models without writing code. Useful for comparing model responses. |
| **Tokenizer** | Shows how your text is broken into tokens (small pieces of text). Helps estimate token usage and cost. |

## 3. Infer

| Feature | Explanation |
|---|---|
| **Inference Profiles** | Configure how model requests are routed, including across supported AWS Regions. Helps manage capacity, usage tracking, and costs. |
| **Batch Inference** | Process many AI requests together instead of individually in real time. Useful for processing thousands of documents overnight. |
| **Provisioned Throughput** | Reserve dedicated model processing capacity. Useful when your application needs predictable performance. |
| **Custom Model On-Demand** | Deploy eligible customized models and pay for inference usage without continuously reserving capacity. |

## 4. Tune

| Feature | Explanation |
|---|---|
| **Custom Models** | Customize supported foundation models using your own data. Useful when a general-purpose model needs specialized knowledge or behavior. |
| **Prompt Router Models** | Automatically select an appropriate model for a request. Helps balance response quality and cost across supported models. |

## 5. Build

| Feature | Explanation |
|---|---|
| **AgentCore** | Managed services to run, secure, monitor, and connect AI agents to tools. Useful for taking LangGraph or other agents into production. |
| **Knowledge Bases (KB)** | Connect company documents to AI models using RAG. Allows AI to answer questions using your organization's information. |
| **Flows** | Visually connect prompts, models, Knowledge Bases, and other steps into a workflow. Like building an AI process using a flowchart. |
| **Automated Reasoning** | Uses formal logic to check whether supported AI-generated claims follow defined rules. Useful for validating answers against business policies. |
| **Guardrails** | Set safety rules for AI inputs and outputs. Helps block harmful content, sensitive information, and certain unwanted topics. |
| **Prompt Management** | Store, organize, version, and reuse prompts. Similar to maintaining different versions of application configurations. |
| **Advanced Prompt Optimization** | Automatically improve prompts for supported models and tasks. Helps produce better responses without manually rewriting every prompt. |
| **Data Automation** | Extract useful information from unstructured documents, images, audio, and video. For example, turn invoices and PDFs into structured data. |

## 6. Assess

| Feature | Explanation |
|---|---|
| **Evaluations** | Test and compare the quality of AI models, prompts, or RAG applications. Helps determine which option produces more accurate and useful responses. |

---

## Quick Interview Memory Trick

| Category | Remember it as |
|---|---|
| **Discover** | Find AI models and access methods |
| **Test** | Experiment with AI models |
| **Infer** | Run models and manage inference capacity |
| **Tune** | Customize models and optimize model selection |
| **Build** | Create AI applications, agents, RAG, and workflows |
| **Assess** | Measure AI application quality |

**Most important for Agentic AI interviews:** Converse API, Inference Profiles, Knowledge Bases, AgentCore, Guardrails, Prompt Management, and Evaluations. These are particularly relevant to production GenAI and agent architecture discussions.


=========================================================================


# Amazon Bedrock AgentCore — Quick Reference Guide

**Amazon Bedrock AgentCore** is an AWS-managed platform that helps you build, deploy, secure, and monitor AI agents without managing all the underlying infrastructure.

## 1. Discover

| Feature | Explanation |
|---|---|
| **Overview** | The main dashboard introducing AgentCore and its capabilities. Helps you understand what services are available and how to get started. |
| **Registry** | A central directory for discovering and organizing agents and tools. Think of it as a catalog where teams can find reusable AI capabilities. |

## 2. Build

| Feature | Explanation |
|---|---|
| **Harness** | Provides a ready-made framework for running an AI agent, including its reasoning and tool-calling loop. Reduces the need to build the basic agent execution logic yourself. |
| **Runtime** | A managed environment where your AI agent application runs. Similar to hosting your LangGraph application without managing servers directly. |
| **Gateways** | Connects AI agents to external APIs, Lambda functions, and tools through a managed interface such as MCP. Think of it as a central entry point for agent tools. |
| **Memory** | Helps AI agents remember information across conversations and sessions. Useful for maintaining context and recalling previous interactions. |
| **Policy** | Defines rules controlling which tools and actions an agent is allowed to use. For example, allow reading Kubernetes logs but restrict restarting deployments. |
| **Identity** | Manages authentication and access to external services on behalf of agents and users. Helps agents securely access protected tools without hardcoding credentials. |
| **Payments** | Provides payment-related capabilities for supported agent transactions. Helps agents participate in authorized purchasing or payment workflows. |

## 3. Built-in Tools

| Feature | Explanation |
|---|---|
| **Browser** | Gives agents a managed browser to interact with websites. For example, an agent can navigate a web application and collect information. |
| **Code Interpreter** | Allows agents to execute code in an isolated environment. Useful for calculations, data analysis, and processing files. |
| **Knowledge Bases (KB)** | Gives agents access to information stored in connected knowledge bases. For example, an agent can retrieve troubleshooting instructions from company documents. |

## 4. Test

| Feature | Explanation |
|---|---|
| **Harness Playground** | A testing environment where you can experiment with supported agent harnesses. Helps you observe agent responses and behavior before production use. |

## 5. Assess

| Feature | Explanation |
|---|---|
| **Observability** | Monitors what your agents are doing, including model calls, tool execution, errors, and latency. Helps troubleshoot agent failures using traces and metrics. |
| **Evaluations** | Measures how well your agents perform tasks. For example, whether a Kubernetes troubleshooting agent identifies the correct root cause. |
| **Optimizations** | Helps improve supported agent workloads based on performance and efficiency insights. Useful for reducing unnecessary execution overhead and improving agent behavior. |

---

## Quick interview memory trick

| Category | Remember it as |
|---|---|
| **Discover** | Find and organize agents and tools |
| **Build** | Run agents and connect them to services securely |
| **Built-in Tools** | Give agents browsing, coding, and knowledge capabilities |
| **Test** | Experiment with agent behavior |
| **Assess** | Monitor, evaluate, and improve agents |

## Most important components for Agentic AI interviews

For your Kubernetes Agentic AI project, focus on these six:

1. **Runtime:** Where your LangGraph agent runs.
2. **Gateway:** How your agent accesses Kubernetes MCP tools.
3. **Identity:** How agents authenticate and access services securely.
4. **Memory:** How agents remember relevant information.
5. **Policy:** How you restrict dangerous operations.
6. **Observability:** How you monitor agent execution and debug failures.

**One important interview distinction:**

- **LangGraph** = Defines the agent workflow and orchestration.
- **Bedrock** = Provides foundation models and managed GenAI capabilities.
- **AgentCore** = Provides infrastructure and services to operate AI agents in production.

These are complementary technologies, not necessarily replacements for each other.


# AWS Sage Maker
Amazon SageMaker AI is an AWS-managed service that helps developers and ML engineers build, train, fine-tune, deploy, and monitor machine learning models.



# Coding

```py

import argparse
import json
import os
import uuid

import boto3
from botocore.exceptions import BotoCoreError, ClientError


def create_client(region: str, profile: str | None):
    session = boto3.Session(
        profile_name=profile,
        region_name=region
    )
    return session.client("bedrock-agentcore")


def invoke_agent(
    client,
    agent_arn: str,
    prompt: str,
    session_id: str
):
    payload = {
        "prompt": prompt
    }

    response = client.invoke_agent_runtime(
        agentRuntimeArn=agent_arn,
        qualifier="DEFAULT",
        runtimeSessionId=session_id,
        contentType="application/json",
        accept="application/json",
        payload=json.dumps(payload).encode("utf-8")
    )

    print("\n--- Agent Response ---\n")

    body = response["response"]
    content_type = response.get("contentType", "")

    if "text/event-stream" in content_type:
        for line in body.iter_lines():
            if not line:
                continue

            decoded = line.decode("utf-8")

            if decoded.startswith("data:"):
                print(decoded[5:].strip())
    else:
        raw = body.read().decode("utf-8")

        try:
            result = json.loads(raw)
            print(json.dumps(result, indent=2))
        except json.JSONDecodeError:
            print(raw)


def main():
    parser = argparse.ArgumentParser(
        description="Invoke deployed KubePilot AgentCore agent"
    )

    parser.add_argument(
        "--region",
        default=os.getenv("AWS_REGION", "ap-south-1")
    )

    parser.add_argument(
        "--profile",
        default=os.getenv("AWS_PROFILE")
    )

    parser.add_argument(
        "--agent-arn",
        default=os.getenv("AGENTCORE_RUNTIME_ARN")
    )

    parser.add_argument(
        "--prompt",
        default=(
            "Troubleshoot the payment-service pods "
            "in the production namespace. "
            "Check pod status, events and logs. "
            "Explain the likely root cause. "
            "Do not restart, delete or modify resources."
        )
    )

    args = parser.parse_args()

    if not args.agent_arn:
        parser.error(
            "Provide --agent-arn or set AGENTCORE_RUNTIME_ARN"
        )

    client = create_client(args.region, args.profile)

    session_id = str(uuid.uuid4())

    print("Region:", args.region)
    print("Session:", session_id)
    print("Question:", args.prompt)

    try:
        invoke_agent(
            client=client,
            agent_arn=args.agent_arn,
            prompt=args.prompt,
            session_id=session_id
        )

    except (ClientError, BotoCoreError) as error:
        print("\nAWS invocation failed:")
        print(error)
        raise SystemExit(1)


if __name__ == "__main__":
    main()

```


## Create S3 Bucket

```py

import boto3
from botocore.exceptions import ClientError

BUCKET_NAME = "my-kubepilot-ai-bucket-123456"
REGION = "ap-south-1"  # Mumbai


def create_s3_bucket(bucket_name, region):
    s3_client = boto3.client("s3", region_name=region)

    try:
        response = s3_client.create_bucket(
            Bucket=bucket_name,
            CreateBucketConfiguration={
                "LocationConstraint": region
            }
        )

        print(f"S3 bucket '{bucket_name}' created successfully!")
        print(f"Region: {region}")
        print(f"Location: {response.get('Location')}")

    except ClientError as e:
        print("Error creating S3 bucket:")
        print(e.response["Error"]["Message"])


if __name__ == "__main__":
    create_s3_bucket(BUCKET_NAME, REGION)
```

```py
import boto3

session = boto3.Session(
    profile_name="bedrock-dev",
    region_name="ap-south-1"
)

s3 = session.client("s3")
bedrock = session.client("bedrock-runtime")
ec2 = session.client("ec2")

print(s3.list_buckets())
```

=====================================================

## Converse API
You send messages in a standardized Bedrock format. Bedrock translates them into the appropriate model interaction.
Example: Use Claude today and another Converse-compatible model tomorrow with fewer application-level changes.

Converse API — standardized messages:
```py
import boto3

client = boto3.client(
    "bedrock-runtime",
    region_name="us-east-1"
)

response = client.converse(
    modelId="YOUR_CONVERSE_SUPPORTED_MODEL_ID",
    messages=[
        {
            "role": "user",
            "content": [
                {"text": "Why is my Kubernetes pod crashing?"}
            ]
        }
    ],
    inferenceConfig={"maxTokens": 300}
)

print(response["output"]["message"]["content"])
```

## InvokeModel API
You construct the request using the specific JSON schema expected by that model.
Example: A Claude request may use a different payload structure from a Nova request.

InvokeModel API — model-specific JSON:
```py
import boto3
import json

client = boto3.client(
    "bedrock-runtime",
    region_name="us-east-1"
)

response = client.invoke_model(
    modelId="YOUR_CLAUDE_MODEL_ID",
    contentType="application/json",
    accept="application/json",
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 300,
        "messages": [
            {
                "role": "user",
                "content": "Why is my Kubernetes pod crashing?"
            }
        ]
    })
)

result = json.loads(response["body"].read())
print(result)
```


## Responses API
You use the OpenAI Responses request format to interact with supported Bedrock-hosted models.
Example: Your existing OpenAI().responses.create() call using openai.gpt-oss-120b on the Bedrock Mantle endpoint.

Responses API — OpenAI-compatible:
```py
from openai import OpenAI

client = OpenAI()

response = client.responses.create(
    model="openai.gpt-oss-120b",
    input=[
        {
            "role": "user",
            "content": "Why is my Kubernetes pod crashing?"
        }
    ]
)

print(response.output_text)
```