# File Operations

```py
with open('servers.txt', 'r') as read_file:
    # data = read_file.readline() # Reading a sigle line
    # data = read_file.read() # Reading the entire file
    data = read_file.readlines() # Reading Multiple lines as a List
```
```py
error_lines = 0
warning_lines = 0
info_lines = 0
total_lines = 0

with open('servers.txt', 'r') as read_file:
    for line in read_file:
        print(line)
        if "ERROR" in line:
            error_lines += 1
        elif "WARNING" in line:
            warning_lines += 1
        elif "INFO" in line:
            info_lines += 1
        
total_lines = error_lines + warning_lines + info_lines

print(
    f"======= Server Log Info =======\n"
    f"TOTAL_LINES  :{total_lines}\n"
    f"INFO         :{info_lines}\n"
    f"WARNING      :{warning_lines}\n"
    f"ERROR        :{error_lines}\n"
)
```


# JSON

```txt
json.load()
     ↑
JSON FILE


json.loads()
      ↑
JSON STRING

json.dump() --> Write Python data to a JSON file:
json.dumps() --> Convert Python data into a JSON string
```

## The JSON module handles the conversion.

```
Python        JSON

dict      →   object {}
list      →   array []
str       →   string
int       →   number
float     →   number
True      →   true
False     →   false
None      →   null
```

## YAML
```py
import yaml

with open("cluster.yaml", "r") as file:
    data = yaml.safe_load(file)

# dump
server = {
    "name": "ai-worker-01",
    "cloud": "AWS",
    "cpu": 45
}

with open("output.yaml", "w") as file:
    yaml.safe_dump(server, file)
```


# raise — very important

Sometimes a function detects a problem but shouldn't hide it.

```
def check_cpu(cpu):
    if cpu < 0:
        ...
# CPU -20 doesn't make sense.


def check_cpu(cpu):
    if cpu < 0:
        raise ValueError("CPU cannot be negative")

    return cpu
```

# try-catch block

```py
import yaml

def load_servers():
    try:
        with open("servers.yaml", "r") as file:
            servers = yaml.safe_load(file)

        return servers

    except FileNotFoundError:
        print("servers.yaml was not found")

    except yaml.YAMLError:
        print("servers.yaml contains invalid YAML")
```

```py
try:
    number = int(input("Enter a number: "))
    result = 100 / number

except ValueError:
    print("Please enter a valid number")

except ZeroDivisionError:
    print("Number cannot be zero")

else:
    print(f"Result is: {result}")

finally:
    print("Program execution completed")
```