## Nginx

It is a high-performance web server and reverse proxy server.

### Main uses:
```
Web Server → Serves static files like HTML, CSS, images.
Reverse Proxy → Receives client requests and forwards them to applications.
Load Balancer → Distributes traffic across multiple application servers.
SSL/TLS Termination → Handles HTTPS and forwards requests to backend applications.
HTTP Gateway → Handles routing, headers, caching, rate limiting, etc.
```

### Simple example

- Your application runs on:
```
localhost:8080
```

- Instead of exposing it directly:
```
Client → :8080 → Application
```

- Nginx sits in front:
```
Client → :80/:443 → Nginx → :8080 → Application
```

## Nginx Reload Vs Restart 

```
Reload  → Applies configuration changes without stopping Nginx.
Restart → Stops and starts Nginx again, which may cause downtime.
```

## Nginx importent .conf file 
```
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        location / {
        }

        error_page 404 /error.html;
            location = /error.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
```

## Reverse Proxy 

```
        location /api/hello {
            proxy_pass http://127.0.0.1:8080/api/hello;
        }

        location /api/users {
            proxy_pass http://127.0.0.1:8080/api/users;
        }
```

## Forward Proxy vs Reverse Proxy

```
Forward Proxy → represents the CLIENT
Reverse Proxy → represents the SERVER
```

### 1. Forward Proxy
```
Client → Forward Proxy → Internet → Website
```
The client knows about the proxy and sends requests through it.

Real-time example:
```
Your company's laptops access the internet through a corporate proxy.

Your Laptop
     ↓
Corporate Proxy
     ↓
Internet
     ↓
google.com
```

The proxy hides/protects the client.

### 2. Reverse Proxy
```
Client → Reverse Proxy → Backend Application
```

The client doesn't know the backend server details.

Your current Nginx setup is exactly this:
```
Browser
   ↓
Nginx :80
   ↓
Python :8080
```

Browser calls:
```
http://162.133.135.229/api/hello
```

Nginx internally forwards it to:

```
127.0.0.1:8080/api/hello
```
The proxy hides/protects the backend servers.


## Load Balancing
```
upstream myapp_loadbalancer { 
    server 127.0.0.1:8080;
    server 127.0.0.1:8081;
}

server {
    listen 80;

    location /api/ {
        proxy_pass http://myapp_loadbalancer;
    }
}
```

Note: Hete "/api/ is enough for all the api's start with /api. if some other api start with /web then we need to add another reverse proxy entry.

```
server {
    listen 80;

    location /api/ {
        proxy_pass http://myapp_loadbalancer;
    }

    location /web/ {
        proxy_pass http://myapp_loadbalancer;
    }
}
```

## HTTPS / SSL / TLS   

- Create a folder
```
mkdir -p /etc/nginx/ssl
```

- create a Slef signed certificate 
```
openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout /etc/nginx/ssl/server.key \
-out /etc/nginx/ssl/server.crt
```

Note : Use your IP/Load Banalcer name for Common Name

- Update the nginx.conf file

```
upstream myapp_loadbalancer {
    server 127.0.0.1:8080;
    server 127.0.0.1:8081;
}

server {
    listen 443 ssl;

    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    location /api/ {
        proxy_pass http://myapp_loadbalancer;
    }
}
```

- Check the Syntax and Reload
```
nginx -t
service nginx reload
```

## Deploy Multiple Static Applications through Nginx

```
mkdir -p /var/www/app1
mkdir -p /var/www/app2
mkdir -p /var/www/app3
echo "<h1>Application 1</h1>" > /var/www/app1/index.html
echo "<h1>Application 2</h1>" > /var/www/app2/index.html
echo "<h1>Application 3</h1>" > /var/www/app3/index.html
```

```
server {
    listen 80;

    location /app1/ {
        alias /var/www/app1/;
        index index.html;
    }

    location /app2/ {
        alias /var/www/app2/;
        index index.html;
    }

    location /app3/ {
        alias /var/www/app3/;
        index index.html;
    }
}
```

## Caching

Caching means storing a copy of frequently requested data so Nginx doesn't need to fetch/generate it every time.
```
 location /app1/ {
        alias /var/www/app1/;
        index index.html;

        expires 1h;
        add_header Cache-Control "public";
    }
```

### What does expires 1h mean?
```
expires 1h;
```

means:

```
Tell the client to cache this resource for 1 hour.
```

For example:
```
10:00 → Browser downloads app.js
       ↓
       Cache for 1 hour

10:10 → Browser requests app.js
       ↓
       Uses cached copy

10:30 → Uses cached copy

11:01 → Cache expired
       ↓
       Requests from Nginx again
```

Note:

```
We have both Brower cache and Nginx Cache. Nginx Cache used to store the backend data.
```

## Nginx Timeouts & Connections
```
proxy_read_timeout 30s;
```
```
0 sec     Request starts
          ↓
10 sec    Backend processing
          ↓
20 sec    Backend processing
          ↓
30 sec    Nginx timeout
          ↓
504 Gateway Timeout
```

Even though the backend may eventually finish at 60 seconds, Nginx has already stopped waiting.

| Setting                 | Simple meaning                             |
| ----------------------- | ------------------------------------------ |
| `proxy_connect_timeout` | Time to connect to backend                 |
| `proxy_send_timeout`    | Time to send request to backend            |
| `proxy_read_timeout`    | Time waiting for backend response          |
| `keepalive_timeout`     | How long idle client connection stays open |
