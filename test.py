la = [10, -10, -8, -105, 1000, 0, 20, 155, 71]

n = len(la)

for i in range(n):
    for j in range(n-i-1):
        if la[j] > la[j+1]:
            la[j], la[j+1] = la[j+1], la[j]
        print(la)

Cosine similarity



Dot product



Euclidean distance



KNN vs ANN



HNSW



BM25 vs dense retrieval



Hybrid search with RRF and reranking

