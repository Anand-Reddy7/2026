```py
from fastapi import FastAPI

# help(fastapi)
# print(dir(fastapi))

## Swagger
# http://127.0.0.1:8000/docs

## OpenAPI
#http://127.0.0.1:8000/openapi.json

## ALternative Doc
# http://127.0.0.1:8000/redoc

servers = [
    {
        "id": 1,
        "name": "ai-worker-01",
        "status": "running"
    },
    {
        "id": 2,
        "name": "ai-worker-02",
        "status": "running"
    },
    {
        "id": 3,
        "name": "ml-worker-01",
        "status": "stopped"
    }
]

app = FastAPI(
    title="Fast API First App",
    description="FastAPI for the learning",
    version="1.0.0"
)

@app.get("/")
def home():
    return {
        "My first FastAPI application"
    }

# # Single Parameter
# @app.get("/server/{server_id}")
# def server_health(server_id: int):
#     return(f"Your server {server_id} is Healthy")

# Multiple path parameters
@app.get("/environment/{envi}/server/{server_id}")
def env_server_health(envi: str, server_id:int):
    return (f"Your {envi} server Id is: {server_id}")

# get Server Details
@app.get("/server/{server_id}")
def get_server_info(server_id: int):
    for server in servers:
        if server["id"] == server_id:
            return server
        
    return "Server Not found"
```

```py
## Actually filter servers
servers = [
    {
        "id": 1,
        "name": "ai-worker-01",
        "environment": "prod",
        "status": "running"
    },
    {
        "id": 2,
        "name": "ai-worker-02",
        "environment": "prod",
        "status": "stopped"
    },
    {
        "id": 3,
        "name": "ml-worker-01",
        "environment": "stage",
        "status": "running"
    }
]

## Calling

### All Servers
curl "http://127.0.0.1:8000/servers"

### Filter
curl "http://127.0.0.1:8000/servers?environment=prod"
```


# Path + Query Parameter

```
GET /environments/prod/servers?status=running
                  ↑                 ↑
                path              query
```

```py
@app.get("/environments/{environment}/servers")
def get_environment_servers(
    environment: str,
    status: str | None = None
):
    return {
        "environment": environment,
        "status": status
    }
```


# POST

```py
from fastapi import FastAPI
from pydantic import BaseModel, Field

servers = [
    {
        "id": 1,
        "name": "ai-worker-01",
        "environment": "prod",
        "status": "running"
    },
    {
        "id": 2,
        "name": "ai-worker-02",
        "environment": "prod",
        "status": "stopped"
    },
    {
        "id": 3,
        "name": "ml-worker-01",
        "environment": "stage",
        "status": "running"
    }
]

app = FastAPI(
    title="Fast API First App",
    description="FastAPI for the learning",
    version="1.0.0"
)

# Pydantic request Model
class Server(BaseModel):
    name: str
    environment: Literal["dev", "stage", "prod"]
    status: Literal["running", "stopped"] = "running"
    cpu: int = Field(ge=0, le=100)
    memory: int = Field(ge=0, le=100)
    description: str | None = None

@app.get("/")
def home():
    return {
        "My first FastAPI application"
    }

@app.get("/servers")
def get_servers(environment: str | None=None):

    if environment is None:
        return servers

    filtered_servers = []
    for server in servers:
        if server["environment"] == environment:
            filtered_servers.append(server)
    return filtered_servers


# POST Request Body + Pydantic
@app.post("/servers")
def create_entry(server: Server):
    new_server = server.model_dump()
    new_server["id"] = len(servers) + 1
    servers.append(new_server)
    return new_server
```

# Final Application

```py
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel


servers = [
    {
        "id": 1,
        "name": "ai-worker-01",
        "cloud": "aws",
        "environment": "prod",
        "status": "running",
        "cpu": 65,
        "memory": 72
    },
    {
        "id": 2,
        "name": "ai-worker-02",
        "cloud": "aws",
        "environment": "dev",
        "status": "running",
        "cpu": 75,
        "memory": 72
    },
    {
        "id": 3,
        "name": "ai-worker-03",
        "cloud": "aws",
        "environment": "prod",
        "status": "running",
        "cpu": 95,
        "memory": 92
    },
]


app = FastAPI(
    title="FastAPI App",
    version="1.0.0"
)


class ServerCreate(BaseModel):
    name: str
    cloud: str
    environment: str
    status: str
    cpu: int
    memory: int


# GET /
@app.get("/")
def home():
    return {"message": "Welcome to the FastAPI application !!"}


# GET /health
@app.get("/health")
def health():
    return {"status": "Server health is Good"}


# GET /servers
# Examples:
# /servers
# /servers?environment=prod
# /servers?environment=prod&environment=dev
@app.get("/servers")
def server_list(
    environment: list[str] | None = Query(default=None)
):
    if environment is None:
        return servers

    filtered_servers = []

    for server in servers:
        if server["environment"] in environment:
            filtered_servers.append(server)

    return filtered_servers


# GET /servers/{server_id}
@app.get("/servers/{server_id}")
def get_server(server_id: int):

    for server in servers:
        if server["id"] == server_id:
            return server

    raise HTTPException(
        status_code=404,
        detail="Server not found"
    )


# POST /servers
@app.post("/servers", status_code=201)
def create_server(server: ServerCreate):

    new_server = server.model_dump()

    new_server["id"] = max(
        (server["id"] for server in servers),
        default=0
    ) + 1

    servers.append(new_server)

    return new_server


# DELETE /servers/{server_id}
@app.delete("/servers/{server_id}")
def delete_server(server_id: int):

    for index, server in enumerate(servers):

        if server["id"] == server_id:

            deleted_server = servers.pop(index)

            return {
                "message": "Server deleted successfully",
                "server": deleted_server
            }

    raise HTTPException(
        status_code=404,
        detail="Server not found"
    )
```
