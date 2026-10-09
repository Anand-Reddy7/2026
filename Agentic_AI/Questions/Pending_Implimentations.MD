## 13. How would you integrate user-specific AWS s3 access and permissions?
In our enterprise KubePilot AI platform, we implement user-specific document access using AWS IAM, application-level RBAC, and document-level ACL filtering.
We authenticate users through an identity provider such as Keycloak or AWS Cognito. Based on their identity and group memberships, we determine which S3 documents they are authorized to access.
During ingestion, we store document ownership and access-control metadata in PostgreSQL and Qdrant.
When an agent performs RAG retrieval, we apply authorization filters before returning documents to the LLM. This prevents users from accessing another team's confidential runbooks or incident reports.


## golden dataset of Kubernetes troubleshooting

## What is cosine similarity and how it will calculate ?
Cosine similarity is a mathematical technique used to measure how similar two vectors are based on the angle between them.
It is calculated by taking the dot product of two vectors and dividing it by the product of their magnitudes. The dot product means multiplying corresponding vector values and adding them together.
In our KubePilot AI RAG application, we convert Kubernetes runbook chunks into embeddings and store them in Qdrant. When a user asks a question, we generate its embedding using the same model.
Qdrant uses cosine similarity to identify the document vectors closest in direction to the query vector. A higher similarity score generally indicates greater semantic similarity.
Qdrant also uses HNSW indexing to efficiently search millions of vectors without comparing every vector individually.
Finally, Qdrant returns the Top-K relevant chunks, which our Insight Agent passes to the LLM to generate a grounded troubleshooting response.