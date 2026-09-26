# HTTP

```
| Operation      | HTTP     |
| -------------- | -------- |
| Create         | `POST`   |
| Read           | `GET`    |
| Update/replace | `PUT`    |
| Partial update | `PATCH`  |
| Delete         | `DELETE` |
```

```
200 → OK
201 → Created
204 → Success, no body

400 → Bad request
401 → Authentication problem
403 → Permission problem
404 → Not found
429 → Too many requests

500 → Internal server error
502 → Bad gateway
503 → Service unavailable
504 → Gateway timeout
```

# REST API Fundamentals

HTTP is the protocol; REST is an architectural style for designing resource-oriented APIs, commonly over HTTP.

```
HTTP = how client and server communicate

REST = how we organize/design the API resources and operations
```

```
| Method   | Usually idempotent? | Why                                           |
| -------- | ------------------: | --------------------------------------------- |
| `GET`    |                 Yes | Reading doesn't change intended state         |
| `PUT`    |                 Yes | Same replacement produces same intended state |
| `DELETE` |                 Yes | Resource remains deleted                      |
| `POST`   |                  No | Repeated calls may create repeated effects    |
| `PATCH`  |             Depends | Depends on the patch semantics                |
```

# Requests
requests is a popular Python library for making HTTP requests.

```py
import requests

url = "https://jsonplaceholder.typicode.com/users"

data = requests.get(url, timeout=10)

form_data = data.json()

# print(f"Status Code: {data.status_code}")
# print(type(form_data))
# print(f"Total Users: {len(form_data)}")

for users in form_data:
    print(f"Name: {users['name']}\n"
        f"Email: {users['email']}\n"
        f"City: {users['address']['city']}\n"
        f"Company: {users['company']['name']}\n"
    )
```

```py
import requests

url = "https://jsonplaceholder.typicode.com/posts"

params = {
    "userId": 1,
    "id": 5
}

response = requests.get(
    url,
    params=params,
    timeout=10
)

print("Status:", response.status_code)
print("URL:", response.url)

posts = response.json()

print(posts)
```

## Token 
```py
import os
import requests

url = "https://httpbin.org/headers"

token = os.getenv("API_TOKEN")

headers = {
    "Authorization": f"Bearer {token}",
    "Accept": "application/json"
}

response = requests.get(
    url,
    headers=headers,
    timeout=10
)

print("Status:", response.status_code)

data = response.json()

print(data)
```