# RAG

# DATA INGESTION 

```
RAG
│
├── 1. DATA INGESTION / INDEXING
│      ├── Document Loading
│      ├── Cleaning / Preprocessing
│      ├── Chunking
│      │      ├── Recursive & Fixed
│      │      ├── Structure-based
│      │      ├── Semantic
│      │      └── Parent-Child
│      ├── Metadata Enrichment
│      ├── Embeddings
│      └── Vector DB / Indexing
│             ├── Qdrant
|             ├── Cosine Similarity
│             └── HNSW
│
├── 2. RETRIEVAL
│      │
│      ├── Query Optimization
│      │      ├── Query Rewrite
│      │      └── Multi-Query
│      │
│      ├── Search
│      │      ├── Dense / Semantic
│      │      ├── Sparse / BM25
│      │      ├── Hybrid
│      │      └── Metadata Filtering
│      │
│      └── Result Optimization
│             ├── Reranking
│             ├── Score Threshold
│             ├── Deduplication
│             └── Top-K
│
├── 3. CONTEXT CONSTRUCTION
│      ├── Select relevant chunks
│      ├── Parent document retrieval
│      ├── Context compression
│      └── Fit within token budget
│
├── 4. GENERATION
│      ├── System Prompt
│      ├── User Question
│      ├── Retrieved Context
│      ├── LLM
│      └── Grounded Answer + Citations/Sources
│
├── 5. EVALUATION
│      ├── Retrieval Quality
│      │      ├── Recall@K
│      │      ├── Precision@K
│      │      └── MRR / NDCG
│      │
│      └── Generation Quality
│             ├── Faithfulness / Groundedness
│             ├── Answer Relevance
│             └── Correctness
│
└── 6. PRODUCTION / OPERATIONS
       ├── Document Updates
       ├── Upsert / Delete
       ├── Idempotent Ingestion
       ├── Access Control / Metadata Filtering
       ├── Observability
       ├── Latency / Cost
       └── Versioning / Re-indexing
```

---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------


# Topic - 1

```
├── 1. DATA INGESTION / INDEXING
│      ├── Document Loading
│      ├── Cleaning / Preprocessing
│      ├── Chunking
│      │      ├── Recursive
│      │      ├── Structure-based
│      │      ├── Semantic
│      │      └── Parent-Child
│      ├── Metadata Enrichment
│      ├── Embeddings
│      └── Vector DB / Indexing
│             ├── Qdrant
│             ├── Cosine Similarity
│             └── HNSW
```



## Document Loading

Document loading is the first stage of RAG ingestion. It reads knowledge from sources such as Markdown, PDF, databases, object storage, or enterprise documentation systems and converts it into a standard document representation containing the text and metadata. In my Kubernetes RAG project, I load Markdown troubleshooting runbooks using LangChain's TextLoader before preprocessing, chunking and embedding them.

Loading = get the data into the pipeline.

```py
for file_path in Path("knowledge").glob("*.md"):
    loader = TextLoader(str(file_path))
    documents.extend(loader.load())
```

## Cleaning / Preprocessing

After document loading, I preprocess the documents before chunking. The purpose is to remove noise such as excessive whitespace, duplicate headers, footers and irrelevant boilerplate while preserving domain-specific information. In my Kubernetes RAG system, I make sure Kubernetes error names, resource names, commands and error codes are preserved because they are important for both semantic and keyword-based retrieval.

```py
import re

def clean_document(text: str) -> str:
    # Normalize excessive whitespace
    text = re.sub(r"\n{3,}", "\n\n", text)
    text = re.sub(r"[ \t]+", " ", text)

    return text.strip()
```

## Chunking

Chunking is the process of splitting large documents into smaller meaningful pieces before generating embeddings. This improves retrieval because the system can retrieve the specific relevant section instead of an entire document. Common strategies include recursive, structure-based, semantic and parent-child chunking. In my Kubernetes RAG project, I currently use recursive chunking with a chunk size of 500 and overlap of 100. In production, I would tune these values based on retrieval quality.

Chunking means splitting a large document into smaller meaningful pieces before generating embeddings.

Main chunking methods:

### 0. Fixed-size

It tries to split using fixed size of charecters

```py
splitter = RecursiveCharacterTextSplitter(
    chunk_size=500
)
```


### 1. Recursive chunking — what we currently use

It tries to split using natural boundaries such as paragraphs/newlines while respecting the configured maximum chunk size.

```py
splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=100
)
```

### 2. Structure-based chunking

Split according to document structure:

```
# ImagePullBackOff
    → Chunk

## Causes
    → Chunk

## Troubleshooting
    → Chunk

## Resolution
    → Chunk
```

We can use LangChain's MarkdownHeaderTextSplitter to split the file into small chuncks based on structred format.

```py
from langchain_text_splitters import MarkdownHeaderTextSplitter

headers_to_split_on = [
    ("#", "title"),
    ("##", "section"),
    ("###", "subsection"),
]

splitter = MarkdownHeaderTextSplitter(
    headers_to_split_on=headers_to_split_on
)

chunks = splitter.split_text(markdown_text)

for chunk in chunks:
    print(chunk.page_content)
    print(chunk.metadata)
```

You can also combine structure-based + recursive chunking. For example, first split by headings, then split very large sections

### 3. Semantic chunking
Split based on meaning/topic changes, rather than primarily character count.

```
Image pull problem...
Registry authentication...
Image tag validation...
-------------------------- topic changes
Pod memory problem...
OOMKilled...
Memory limits...
```

With LangChain's experimental semantic splitter, the pattern is:

```py
splitter = SemanticChunker(
    embeddings
)

chunks = splitter.create_documents([text])

for chunk in chunks:
    print(chunk.page_content)
```
### 4. Parent-child chunking
Create larger parent chunks and smaller child chunks.

```
Parent:
ImagePullBackOff Troubleshooting
       │
       ├── Child: Check image tag
       ├── Child: Check registry
       └── Child: Check events
```

Search the small child chunks for precision, then return the larger parent for richer context.


## Metadata Enrichment

Metadata enrichment means attaching descriptive information to each chunk before storing it in the vector database. For my Kubernetes runbooks, metadata can include source file, section, issue category, environment and team. The embedding is used for semantic similarity, while metadata allows me to filter the retrieval—for example, searching only production runbooks—and also helps with source attribution and access control.

```
Chunk
  ├── Text
  │     "Check image name, tag and registry credentials..."
  │
  └── Metadata
        ├── source = image_pull_runbook.md
        ├── category = ImagePullBackOff
        ├── section = Troubleshooting
        ├── environment = production
        └── team = platform
```

```py
for doc in documents:
    doc.metadata["environment"] = "production"
    doc.metadata["team"] = "platform"
    doc.metadata["document_type"] = "kubernetes_runbook"
```

**Wht Metadata ? :**

Instead of searching every vector,Then Qdrant searches only appropriate documents. Metadata is also useful for access control and document lifecycle.

## Embeddings

An embedding is a numerical vector representation of text that captures semantic meaning. In my Kubernetes RAG project, after chunking the runbooks I use text-embedding-3-small to convert each chunk into a 1536-dimensional vector and store it in Qdrant along with the original text and metadata. At query time, I use the same embedding model to convert the user's question into a query vector, and Qdrant searches for semantically similar document vectors.


### Don't think that Qdrant stores only the vector.

```
Qdrant Point
│
├── ID
│
├── Vector
│      └── [1536 numbers]
│
└── Payload
       ├── original chunk text
       ├── source
       ├── section
       ├── category
       └── other metadata

## Example
ID:
chunk-001

Vector:
[0.021, -0.183, 0.442, ...]

Payload:
text = "Check image name and registry credentials"
source = "image_pull_runbook.md"
category = "ImagePullBackOff"
```

## Vector DB / Indexing


### Qdrant

Qdrant is the vector database I use in my Kubernetes RAG system. During ingestion, each runbook chunk is converted into an embedding and stored in Qdrant as a point containing an ID, vector and payload. The payload contains the original chunk text and metadata. At query time, the user's question is converted into a vector and Qdrant performs similarity search against the stored vectors to retrieve the most relevant Kubernetes runbook chunks.

### Cosine similarity

** At Ingestion: **
Cosine similarity is not used to compare documents during normal ingestion. But it appears in the indexing configuration because the vector database needs to know which distance metric will be used later during retrieval.

Think of it as configured during indexing, used during retrieval.

```py
VectorParams(
    size=1536,
    distance=Distance.COSINE
)
```

Cosine is configured when I create the Qdrant collection because the vector database needs to know which distance metric the vector index will use. However, its main role is during retrieval, where it measures the closeness between the query embedding and document embeddings. So I describe it as configured during indexing but used for similarity search during retrieval.

** At Retrival **


### HNSW — Hierarchical Navigable Small World

#### Data Ingestion time

HNSW is part of the indexing side during ingestion, and it is then used during retrieval.
Qdrant organizes the stored vectors into the HNSW graph so they can be searched efficiently later.

HNSW is a graph-based Approximate Nearest Neighbor (ANN) indexing algorithm used to find similar vectors efficiently without scanning every vector in the database.


#### Data Retrival Time

HNSW stands for Hierarchical Navigable Small World. It's a graph-based approximate nearest-neighbor indexing algorithm commonly used by vector databases such as Qdrant. During indexing, vectors are organized into a multi-layer graph. During retrieval, the search starts at sparse upper layers to quickly navigate toward the relevant region and then moves to denser lower layers for a more precise search. This avoids a full scan of all vectors and provides low-latency retrieval at scale. Important parameters include m for graph connectivity, ef_construct for index-build quality, and query-time ef for the latency-versus-recall trade-off.

**Why do we need HNSW?**

Imagine Qdrant contains 1 million vectors.
Without an ANN index, exact search could conceptually compare the query against all vectors:
```
Query vector
    ↓
Compare with vector 1
Compare with vector 2
Compare with vector 3
...
Compare with vector 1,000,000
```

That's exact/brute-force search.
HNSW instead creates a graph where vectors are connected to nearby vectors:
```
A ───── B
|\      |\
| \     | \
C ───── D ───── E
        |
        F
```

At query time, it navigates through promising neighbors rather than exhaustively checking everything.


**Why is it called "Hierarchical"?**

This is the important part.
HNSW doesn't maintain only one graph. It creates multiple graph layers.
Think of it like roads:
```
Layer 2        A ---------------- H
               ↑
               │     Highway

Layer 1        A ---- C ---- F ---- H
                     ↑
                     │

Layer 0        A-B-C-D-E-F-G-H-I-J
                         ↑
                      detailed
```

The upper layers are sparse and let the search move long distances quickly.
The lower layer contains many more vectors and allows a more detailed search.
So the query roughly does:
```
Start at upper layer
       ↓
Move toward promising region quickly
       ↓
Move down one layer
       ↓
Search more precisely
       ↓
Move to bottom layer
       ↓
Find nearest vectors
```

That's why a useful analogy is:

```
Upper HNSW layers are highways; lower layers are local roads.
```
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------

# DATA RETRIEVAL
```
├── 2. RETRIEVAL
│      │
│      ├── Query Optimization
│      │      ├── Query Rewrite
│      │      └── Multi-Query
│      │
│      ├── Search
│      │      ├── Dense / Semantic
│      │      ├── Sparse / BM25
│      │      ├── Hybrid
│      │      └── Metadata Filtering
│      │
│      └── Result Optimization
│             ├── Reranking
│             ├── Score Threshold
│             ├── Deduplication
│             └── Top-K
```








---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------

# What is Chunking?
Chunking means splitting a large document into smaller meaningful pieces before creating embeddings and storing them in a vector database.

For example, our Kubernetes runbook may contain:
```
ImagePullBackOff
CrashLoopBackOff
OOMKilled
Pending Pod
```

Instead of embedding the whole runbook as one large document, we split it:
```
Runbook
  ↓
Chunk 1 → ImagePullBackOff
Chunk 2 → CrashLoopBackOff
Chunk 3 → OOMKilled
Chunk 4 → Pending Pod
  ↓
Embeddings
  ↓
Qdrant
```

This helps retrieve only the relevant part of the runbook for a user's question.
Main chunking methods
You only need to remember these 4 important ones for an interview:
```
Method	                        Meaning
Fixed-size	                    Split based on a fixed number of characters/tokens
Recursive	                    Split using natural boundaries like paragraphs/newlines while respecting a maximum size
Structure-based	                Split based on headings/sections
Semantic	                    Split when the meaning/topic changes
Parent-Child                    Use small child chunks for accurate retrieval, but provide the larger parent chunk to the LLM for sufficient context.


Fixed-size — split by fixed characters/tokens.
Recursive — split using natural boundaries while respecting size.
Structure/heading-based — split by document sections.
Semantic — split when the topic/meaning changes.
Parent-child — search smaller child chunks but return larger parent context.
```


In our Kubernetes project, we use recursive chunking:

```py
RecursiveCharacterTextSplitter(    
    chunk_size=500,    
    chunk_overlap=100)
```

### Parent-Child 

In parent-child chunking, I split the document into larger parent chunks and then split each parent into smaller child chunks. I embed and search the smaller child chunks because they provide more precise retrieval. Each child maintains a reference to its parent. When a child matches the user's query, I retrieve the larger parent chunk and send that to the LLM, giving me both retrieval precision and sufficient context.


A practical implementation for our project could use, for example, parent size 1500 and child size 400


```
Runbook
   ↓
Parent chunks (large)
   ↓
Child chunks (small)
   ↓
Embed CHILD chunks
   ↓
Qdrant

Query → match child → get its parent → send parent to LLM
```

```py
from pathlib import Path
import uuid

from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_qdrant import QdrantVectorStore


# 1. Load Kubernetes runbooks
documents = []

for file_path in Path("knowledge").glob("*.md"):
    loader = TextLoader(str(file_path))
    documents.extend(loader.load())


# 2. Create parent chunks
parent_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1500,
    chunk_overlap=200
)

parents = parent_splitter.split_documents(documents)


# 3. Create child chunks
child_splitter = RecursiveCharacterTextSplitter(
    chunk_size=400,
    chunk_overlap=50
)

children = []

for parent in parents:

    parent_id = str(uuid.uuid4())

    child_docs = child_splitter.split_documents([parent])

    for child in child_docs:
        child.metadata["parent_id"] = parent_id
        child.metadata["parent_text"] = parent.page_content
        children.append(child)


# 4. Embed child chunks and store them in Qdrant
embeddings = OpenAIEmbeddings(
    model="text-embedding-3-small"
)

QdrantVectorStore.from_documents(
    documents=children,
    embedding=embeddings,
    url="http://localhost:6333",
    collection_name="kubernetes_runbooks_parent_child"
)

## ------------------------
## The important part is:

child.metadata["parent_id"] = parent_id
child.metadata["parent_text"] = parent.page_content

## ------------------------
## Retrival

docs = retriever.invoke(query)

parents = []

for doc in docs:
    parent_text = doc.metadata["parent_text"]

    if parent_text not in parents:
        parents.append(parent_text)

return "\n\n".join(parents)
```

```
ID
+
Vector
+
Payload
    ├── original chunk text
    ├── source
    ├── topic
    └── parent_id (if parent-child)
```

---------------------------------------------------------

# Embedding

After chunking the documents, I use an embedding model to convert each chunk into a numerical vector that represents its semantic meaning. In my Kubernetes RAG project, I use OpenAI text-embedding-3-small, which gives us 1536-dimensional vectors by default. I then store those vectors in Qdrant along with the original chunk and metadata. For initial ingestion, LangChain can handle embedding and insertion through QdrantVectorStore.from_documents(). For more controlled production ingestion, we can explicitly generate embeddings and upsert points with stable IDs and metadata into Qdrant.

```
Kubernetes Runbook
        ↓
     Chunking
        ↓
     Embedding
        ↓
1536-dimensional vectors
        ↓
      Qdrant
        ↓
   HNSW Index
```

## HNSW
HNSW stands for Hierarchical Navigable Small World. It is an approximate nearest-neighbor indexing algorithm used by vector databases such as Qdrant. After we create and store embeddings, HNSW organizes the vectors as a graph so Qdrant can find similar vectors efficiently instead of scanning every vector. In our Kubernetes RAG system, we use embeddings for representation, cosine for similarity, HNSW for efficient search, and Top-K to control how many runbook chunks are returned.

HNSW = Hierarchical Navigable Small World. It is an index that helps Qdrant find similar vectors quickly.
For example, suppose Qdrant eventually has 1 million runbook vectors.
Without an index, conceptually Qdrant could compare the query against every vector:
```
Query vector
    ↓
Vector 1
Vector 2
Vector 3
...
Vector 1,000,000
```

That's expensive.
HNSW builds connections between nearby vectors:
```
       A ─── B
      /     / \
     C ─── D   E
          / \
         F   G
```

## Flow : HNSW → Cosine → Top-K
In my Kubernetes RAG system, after the user query is converted into an embedding, Qdrant uses the HNSW index to efficiently navigate the vector space and find nearby candidate vectors. We use cosine as the distance metric to determine how close the query vector is to the stored runbook vectors. Finally, Top-K controls how many of the highest-ranked results are returned; for example, in my current implementation K is 3.

### 1. HNSW — finds the candidate nearest vectors efficiently

Instead of comparing against every vector in the database, HNSW navigates its graph index to find promising nearby vectors.
```
Query Vector
     ↓
   HNSW
     ↓
Find promising nearby vectors
```

Think:
```
HNSW = Where should I search?
```

For example, it may narrow millions of vectors down to a useful candidate set.

### 2. Cosine — measures how close those vectors are
Qdrant uses the configured Cosine metric to evaluate vector closeness.

```
Conceptually:
Candidate A → ImagePullBackOff     → very similar
Candidate B → Registry problem     → similar
Candidate C → Invalid image tag    → similar
Candidate D → OOMKilled            → less similar
Candidate E → DNS                  → less similar
```
Think:
```
Cosine = How similar is this vector to my query vector?
```

So HNSW and cosine are related but not the same:
```
HNSW   → Search/index algorithm
Cosine → Distance/similarity metric
```

### 3. Top-K — returns only the best K results
After finding/ranking the nearby vectors, we don't necessarily want all of them.
Our configuration says:
```
search_kwargs={"k": 3}
```

Therefore:
```
Ranked results

1. ImagePullBackOff
2. Registry problem
3. Invalid image tag
4. OOMKilled
5. DNS
       ↓
     K = 3
       ↓
Return only:

1. ImagePullBackOff
2. Registry problem
3. Invalid image tag
```

### Alternative Methods

| Method | Basic idea | Good for |
|---|---|---|
| **HNSW** | Graph-based ANN search | Fast search, high recall; very common |
| **Flat / Exact Search** | Compare query with every vector | Small datasets, maximum accuracy |
| **IVF** | Divide vectors into clusters and search relevant clusters | Very large datasets |
| **IVF + PQ** | Clustering + vector compression | Huge datasets where memory/storage matters |
| **DiskANN** | ANN optimized to keep much of the index on disk/SSD | Very large-scale datasets |

---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------




