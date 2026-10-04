# Top 5 models

| Provider                                                       | Model family | Examples                            | Important for you because                       |
| -------------------------------------------------------------- | ------------ | ----------------------------------- | ----------------------------------------------- |
| [OpenAI](https://openai.com/?utm_source=chatgpt.com)           | **GPT**      | GPT-5.x family                      | General reasoning, coding, tool calling, agents |
| [Anthropic](https://www.anthropic.com/?utm_source=chatgpt.com) | **Claude**   | Claude family                       | Reasoning, coding, tool use, enterprise agents  |
| [Google Gemini](https://ai.google.dev/?utm_source=chatgpt.com) | **Gemini**   | Gemini 3.x family                   | Multimodal, reasoning, tools/agents             |
| [Meta AI](https://ai.meta.com/llama/?utm_source=chatgpt.com)   | **Llama**    | Llama 4 Scout, Maverick             | Open-weight/self-hosted deployments             |
| [Mistral AI](https://mistral.ai/?utm_source=chatgpt.com)       | **Mistral**  | Mistral Large/Medium/Small families | Open-weight and commercial deployment choices   |


# More important: types of models
```
Models
│
├── Chat / Generative models
│      GPT, Claude, Gemini, Llama
│
├── Reasoning models
│      complex planning/problem solving
│
├── Embedding models
│      text → vector
│      used heavily in RAG
│
├── Reranking models
│      reorder retrieved documents
│
└── Multimodal models
       text + image + audio/video depending on model
```

# Why do we need LangChain?

Suppose you want to build a DevOps AI assistant.

A user asks:
```
"Why did my Kubernetes deployment fail?"
```

Your application might need to:
```
Understand the question.
Search your Kubernetes documentation.
Retrieve relevant logs.
Call Kubernetes APIs.
Give the information to an LLM.
Ask the LLM to analyze it.
Return a response.
```

Without a framework, you'd write and maintain much of this orchestration yourself.


With LangChain, you can build components such as:

```
User question
      ↓
LangChain
      ↓
Retrieve relevant documents
      ↓
Call tools/APIs
      ↓
Send context to OpenAI
      ↓
Generate answer
```

```

                    ┌── OpenAI
                    │
User → LangChain ───┼── Database
                    │
                    ├── Documents
                    │
                    ├── APIs
                    │
                    └── Tools
```

# OpenAI
```sh
OpenAI provides the LLM that understands and generates natural language, while LangChain is a framework used to build applications around LLMs. LangChain helps integrate the LLM with external data, documents, APIs, tools, retrieval systems and application workflows. We don't necessarily need LangChain for a simple OpenAI API call, but it becomes useful when building more complex LLM applications.
```
# LLM = Large Language Model.
```
It is an AI model trained on a very large amount of text/data so it can understand and generate human-like language.

Why "Large Language Model"?

Large → trained using huge amounts of data and many parameters.
Language → designed to understand and generate language.
Model → a trained machine-learning model.
```

# OpenAI + LangChain
```sh
OpenAI provides the LLM, and LangChain helps your application use that LLM together with data, APIs, tools, and workflows.
```