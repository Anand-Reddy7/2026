############################################
## Main Values
############################################

# input()
It returns always text. So, if you give the value as number then also it returns as string only.
input_value = input("Enter your Name:")
print(f"What is You input: {input_value}")

# f-strings
print(f"Application: {application}, Environment: {environment}")

# Arithmetic
print(10 // 3) // floor division => 3
print(10 % 3) // remainder/modulus => 1
print(2 ** 3) // exponent/power => 8

# Type conversion
replicas = int(input("Enter replicas: "))
print(type(replicas))

cpu = "75.5"
cpu = float(cpu)
print(type(cpu))


############################################
## Comparison operators and Conditions
############################################

```text
Operator     Meaning

==           equal
!=           not equal
>            greater than
<            less than
>=           greater than or equal
<=           less than or equal

## 
.lower()
.upper()

True
False

and
or
not
```

```py
## IF:ELSE
cpu = 87
if cpu > 80:
    print(f"{cpu} is the High CPU")
elif cpu < 80:
    print(f"{cpu} is Low CPU")
else:
    print(f"{cpu} value is equal")

## String Comparition
environemnt = input("Enter ENV:").lower()
if environemnt == "prod":
    print("Its Prod")
else:
    print("Its not Prod")

## AND / OR
if cpu > 80 or memory > 80:
if environment == "prod" and approved == "yes":

## Bool 
gender = True
if gender:
    print("Mahesh is Female")


if gender == True:

## Bool if not
if not gender:
    print("Mahesh is Female")
```

############################################
## List, Tuple, Set and Dictionary
############################################

## List 

A list in Python is an ordered, mutable collection that can store multiple elements, including duplicate values and different data types.

```py
li = ["worker-1", "worker-2", "worker-3", "worker-4", "worker-5"]
li2 = ["server-1", "server-2"]

print(li)

print(len(li))
print(li[0])
print(li[0:2])
print(li[-1]) //Print the last item
li.append("worker-6") // append at the end
li.pop(1) // Remove Item
li.append(li) // [1, 2,[3,4]]
li.extend(li2) // it will iterate the second list and add a single list [1,2,3,4]]

# IN
if "worker-4" in li:
    print("Server Found")

# NOT IN
if "worker-7" not in li:
    print("Server7 not found")

# String Reverse
li.reverse()
// li[start : stop : step]
print(li[::-1]) --> List reverse
print(li[::1]) --> List forword
```

## Tuple

```text
LIST
→ mutable
→ can change


TUPLE
→ immutable
→ can't modify elements in place
```

## Sets

A Python set is a mutable collection of unique, unordered elements. We can modify it by adding or removing elements.

```
Set → mutable ✅
Frozen set (frozenset) → immutable ❌
```

```py
servers = {
    "worker-1",
    "worker-2",
    "worker-1",
    "worker-3",
    "worker-2"
}

unique_servers = set(servers)

print(unique_servers)

# frozenset
fs = frozenset({1, 2, 3})
fs.add(4)      # ❌ error
```

## Dict

Ii is a collection that stores data as key-value pairs.

```py
person = {
    "name": "Anand",
    "age": 30,
    "role": "DevOps Engineer"
}

print(person)
print(person["age"])

print(person.keys())
print(person.values())
print(person.get("anand", 0))
person["company"] = "IBM"
print(person)

# Iterate
for key, value in person.items():
    print(key, value)

# Iterate keys
for key in person.keys():
    print(key, person[key])

```

## Example

```py
pods = [
    {"name": "api-1", "status": "Running", "restarts": 0},
    {"name": "api-2", "status": "Running", "restarts": 5},
    {"name": "api-3", "status": "Failed", "restarts": 2},
    {"name": "api-4", "status": "Running", "restarts": 0}
]

for pod in pods:
    if pod["restarts"] == 0:
        print(f"{pod['name']} is Healthy")
    elif pod['restarts'] >= 1 and pod['status'] == "Running":
        print(f"{pod['name']} has too many restarts")
    else:
        print(f"{pod['name']} is not running")
```

## Functions

```py
def get_pods():
    return [
        {"name": "api-1", "status": "Running", "restarts": 0},
        {"name": "api-2", "status": "Running", "restarts": 5},
        {"name": "api-3", "status": "Failed", "restarts": 2}
    ]


def check_pod(pod):

    if pod["status"] != "Running":
        return "NOT_RUNNING"

    elif pod["restarts"] >= 1:
        return "TOO_MANY_RESTARTS"

    else:
        return "HEALTHY"


pods = get_pods()

for pod in pods:

    result = check_pod(pod)

    print(f"{pod['name']} → {result}")
```

## Modules & Imports

A Python .py file is a module that can contain reusable Python code.

```py
# monitoring.py
def check_cpu(cpu):
    if cpu >= 90:
        return "CRITICAL"
    elif cpu >= 75:
        return "WARNING"
    else:
        return "HEALTHY"

#app.py
import monitoring

status = monitoring.check_cpu(85)

print(status)

# you can import the function directly:
from monitoring import check_cpu

status = check_cpu(85)

# Import Multiple Functions
from monitoring import check_cpu, check_memory

# Import everything
rom monitoring import *

# Import aliases
import monitoring as mon
```

## Package
A package organizes related modules in a directory.

```
ai-platform/
│
├── app.py
│
└── platform/
    ├── __init__.py
    └── monitoring.py
```

```py
from platform.monitoring import check_cpu

status = check_cpu(85)

print(status)

# Explanation for above
from platform.monitoring import check_cpu
       │        │                │
       │        │                └── function
       │        │
       │        └── module
       │
       └── package
```

## Overall Program with the above things

```py
# servers.py
def server_info():
     return [
        {
            "name": "ai-worker-01",
            "cloud": "AWS",
            "environment": "prod",
            "status": "running",
            "cpu": 45,
            "memory": 55,
            "restarts": 0
        }
     ]
# monitoring.py
def server_health_status(server):
    if server["status"] == "running":
        if server["cpu"] >= 90 or server["memory"] >=90:
            return "CRITICAL"
        elif server["cpu"] >= 75 or server["memory"] >= 75:
            return "WARNING"
        else:
            return "HEALTHY"
    else:
        return "STOPPED"


# app.py
from servers import server_info
import monitoring

healthy=0
critical=0
warning=0
stopped=0
prod_servers = []

server_info = server_info()
for server in server_info:
    server_health = monitoring.server_health_status(server)
    if server_health == "HEALTHY":
        healthy=healthy+1
    elif server_health == "CRITICAL":
        critical=critical+1
    elif server_health == "WARNING":
        warning=warning+1
    elif server_health == "STOPPED":
        stopped=stopped+1

    if server["environment"] == "prod":
        prod_servers.append(server["name"])

    print(f"{server['name']} is in {server['status']} and it is {server_health} \n")


server_total = healthy + critical + warning + stopped
print()
print(
    f"============= Summary ===============\n"   
    f"Total Servers : {server_total}\n"
    f"Healthy       : {healthy}\n"
    f"Warning       : {warning}\n"
    f"Critical      : {critical}\n"
    f"Stopped       : {stopped}\n"
)

print("============= Prod Servers ==========\n")
for serve2 in prod_servers:
    print(serve2)
```

# OS
```py
import os

print(os.getcwd())
print(os.getenv("ENVIRONMENT"))

if os.path.exists("servers.yaml"):
    print("File exists")
else:
    print("File does not exist")
```

## Pathlib
```py
from pathlib import Path

file_path = Path("config/servers.yaml")

if file_path.exists():
    print("File exists")
else:
    print("File doesn't exist")

## 
print(file_path.is_file())
print(file_path.is_dir())
reports_dir.mkdir()
```

# venv + pip

Suppose your machine has two projects:

```
Project A
└── PyYAML 6.x

Project B
└── PyYAML 5.x
```
Installing everything globally can cause dependency/version conflicts.

```
Python             Linux

PyPI        ≈      package repository
pip         ≈      package manager/client
```

## requirements.txt

```sh
cd cloud-health-monitor

python3 -m venv .venv

source .venv/bin/activate

which python
which pip

pip install pyyaml

pip list

pip freeze > requirements.txt

cat requirements.txt

python app.py

# Deactivet 
deactivate
```

# None

There is currently no value.

```
None     → no value

""       → string containing zero characters

0        → integer zero

False    → boolean false

[]       → empty list
```

```py
value = None

print(type(value))

# You'll get:
<class 'NoneType'>
```

# is / is not

```py
if server is None:
    print("Server not found")

if server is not None:
    print(server["name"])
```

# Mutable vs Immutable

```
| Type    | Mutable? |
| ------- | -------- |
| `list`  | ✅ Yes    |
| `dict`  | ✅ Yes    |
| `set`   | ✅ Yes    |
| `int`   | ❌ No     |
| `float` | ❌ No     |
| `str`   | ❌ No     |
| `bool`  | ❌ No     |
| `tuple` | ❌ No     |
```

# enumerate

enumerate() lets us iterate over an iterable while getting both the index and the value. By default the index starts at 0, but we can change it using the start parameter.


```py
# Start from 0 by default
for index, server in enumerate(servers):
    print(index, server)

# start from 1
for index, server in enumerate(servers, start=1):
    print(index, server)
```

# Zip

```py
servers = [
    "ai-worker-01",
    "ai-worker-02",
    "ml-worker-01"
]

statuses = [
    "running",
    "running",
    "stopped"
]

for server, status in zip(servers, statuses):
    print(server, status)

# output 
ai-worker-01 running
ai-worker-02 running
ml-worker-01 stopped

# If you have diffrent lengths
## Output
server-1 running
server-2 stopped

## Ignored
server-3

By default, zip() stops when the shortest iterable is exhausted.
```

# UnPacking

```py
server = ("ai-worker-01", "running", 75)

name, status, cpu = server

print(name)
print(status)
print(cpu)

## We will get "ValueError: not enough values to unpack" when we don't have exact match
```

# List Comprehensions

A list comprehension is a shorter Python syntax for creating a new list from an existing iterable.

```py
numbers = [1, 2, 3, 4, 5]

squares = []

for number in numbers:
    squares.append(number * number)

# Comprahensation
squares = [server * server for server in servers]
```

# Dictionary Comprehensions

```py
server_cpu = {
    server["name"]: server["cpu"]
    for server in servers
}
```

# *args 

*args collects all additional positional arguments into a tuple.

```
*args   → variable number of positional arguments
**kwargs → variable number of keyword arguments

*args     → tuple
**kwargs  → dictionary


deploy("server-1", "server-2", "server-3")
          │           │           │
          └───────────┼───────────┘
                      ↓
                    *args
                      ↓
("server-1", "server-2", "server-3")

def deploy(*args):
    print(args)


def example(*args, **kwargs):
    print(args)
    print(kwargs)
    
```

```py
import requests

url = "https://httpbin.org/status/404"

try:
    response = requests.get(
        url,
        timeout=10
    )

    response.raise_for_status()

    print("Request successful")

except requests.exceptions.Timeout:
    print("Request timed out")

except requests.exceptions.ConnectionError:
    print("Unable to connect to server")

except requests.exceptions.HTTPError as error:
    print(f"HTTP error: {error}")

except requests.exceptions.RequestException as error:
    print(f"Request failed: {error}")
```

```
import time
import requests

url = "https://httpbin.org/status/503"

max_attempts = 3

for attempt in range(1, max_attempts + 1):

    print(f"Attempt: {attempt}")

    try:
        response = requests.get(
            url,
            timeout=5
        )

        if response.status_code == 200:
            print("Success")
            break

        print("Status:", response.status_code)

    except requests.exceptions.RequestException as error:
        print("Request failed:", error)

    time.sleep(2)
```