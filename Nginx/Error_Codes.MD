## HTTP Status Codes — Beginner Understanding

The first digit tells you the category:

```
1xx → Information
2xx → Success
3xx → Redirection
4xx → Client/request problem
5xx → Server problem
```

You mainly need to understand 2xx, 3xx, 4xx and 5xx.


## 2xx — Success ✅

### 200 : Most common success response.
```
Browser
   |
   | GET /
   v
Nginx
   |
   | 200 OK
   v
index.html
```


### 201 Created : Usually means something was successfully created.

Common with APIs:

```
POST /users
       |
       v
    201 Created
```

## 3xx — Redirection : The resource is somewhere else / use another URL.

### 301 : Moved Permanently

Example:

```
http://example.com
        |
        | 301
        v
https://example.com
```
Very commonly used to redirect HTTP → HTTPS.

### 302 Found : Temporary redirect.
For example:

```
/login
   |
   v
302
   |
   v
/login-page
```

## 4xx — Client Error ( Problem with the request/client side ) ❌ : The request from the client is invalid, unauthorized, or cannot be fulfilled.

```
400 → Bad request
401 → Authentication required
403 → Permission denied
404 → Resource not found
408 → Request timeout
429 → Too many requests
```

### 400 — Bad Request ( The request itself is invalid. I don't understand your request.)

Real-time example:

Suppose an API expects:
```
POST /users
Content-Type: application/json

{
  "name": "Anand",
  "email": "anand@example.com"
}
```

But the client sends invalid JSON:
```
{
  "name": "Anand",
  "email":
}
```

The server cannot understand the request.

```
Your request is not properly formed.
```

### 401 Unauthorized : Authentication is required or failed.

You have an API:

```
GET /api/users
```
The API requires authentication.

You call:

```
curl https://myapp.com/api/users
```
But you don't provide a valid authentication token.

Response:

```
401 Unauthorized
Client
   |
   | No/invalid authentication
   v
Application
   |
   v
401
```

Simple meaning:

```
"You need to authenticate yourself."
```
### 403 Forbidden 🚫 : I know what you want, but you're not allowed.

Now suppose you successfully logged in.
```
User = Anand
Authenticated = YES
```
But you try to access an admin page:
```
GET /admin
```
Your account isn't allowed to access it.

Response:
```
403 Forbidden
Client
   |
   | Authenticated
   v
Application
   |
   | Access not allowed
   v
403
```
Simple meaning:
```
"I know who you are, but you're not allowed to access this."
```
Think:
```
403 → I know who you are, but NO.
```

### 404 Not Found : I can't find what you're asking for.

### 408 Request Timeout : The client took too long to send the request.
Imagine you're uploading a request but your connection is extremely slow.

The server waits:
```
Client
   |
   | ............... very slow
   |
   v
Server
   |
   | Timeout
   v
408
```

Simple meaning:
```
"I waited too long for you to send the request."
```
### 429 Too Many Requests : The client is sending too many requests.
This is very common with APIs.

Suppose an API allows:
```
100 requests/minute
```
But your client sends:
```
500 requests/minute
```
The server/rate limiter says:
```
429 Too Many Requests
```

| Code    | Real-life situation                      | Meaning                  |
| ------- | ---------------------------------------- | ------------------------ |
| **400** | You gave an invalid form                 | "Your request is wrong." |
| **401** | You have no ID card                      | "Who are you?"           |
| **403** | You have an ID but no permission         | "You're not allowed."    |
| **404** | Room doesn't exist                       | "I can't find it."       |
| **408** | You took too long to provide information | "You took too long."     |
| **429** | You keep pressing the doorbell 100 times | "Slow down!"             |


## 5xx — Server Error 🔥 : The server had a problem processing a valid request.

```
Client
  |
  | Valid request
  v
Nginx
  |
  | Problem on server/backend
  v
5xx
```

| Code    | Simple Meaning         | Real-Time Example                     |
| ------- | ---------------------- | ------------------------------------- |
| **500** | Application error      | Application code crashed/exception    |
| **502** | Bad backend connection | Nginx → Backend is down/not reachable |
| **503** | Service unavailable    | No healthy backend servers available  |
| **504** | Backend timeout        | Backend took too long to respond      |

### 🔴 500 — Internal Server Error

Real situation: Your application has a bug and throws an exception.
```
User → Nginx → Application 💥
                    ↓
                 Exception
                    ↓
                  500
```

Example: Java/Python application crashes while processing /login.

### 🔴 502 — Bad Gateway

Real situation: Nginx is running, but the application is down.
```
User → Nginx → Application ❌
                 (port 8080)
```
Nginx tries localhost:8080, but nothing is listening.

Result: 502 Bad Gateway

### 🔴 503 — Service Unavailable

Real situation: You have 3 application servers, but all are unavailable.
```
             Nginx
           /   |   \
         ❌   ❌   ❌
        App1 App2 App3
```
Result: 503 Service Unavailable

### 🔴 504 — Gateway Timeout

Real situation: Application is running but takes too long to respond.
```
User → Nginx → Application
                 ⏳
                 ⏳
                 ⏳
              Timeout
```
Result: 504 Gateway Timeout