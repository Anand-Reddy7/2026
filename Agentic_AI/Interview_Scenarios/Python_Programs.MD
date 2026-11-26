# Python Coding Interview Questions and Answers

A practical revision guide covering strings, lists, dictionaries, grouping and aggregation. Each example is independently executable.

## 1. Reverse a string

### Option 1 — Slicing
```python
st = "Anand Reddy"
print(st[::-1])
```
### Option 2 — Using `reversed()` and `join()`
`reversed()` returns an iterator, not a string.
```python
st = "Anand Reddy"
print("".join(reversed(st)))
```
### Option 3 — Using a list
```python
st = "Anand Reddy"
print(list(reversed(st)))
```
This returns a list of characters rather than a string.

### Option 4 — Using concatenation and `reversed()`
```python
st = "Anand Reddy"
rev_st = ""
for i in reversed(st):
    rev_st = rev_st + i
print(rev_st)
```
### Option 5 — Without built-in functions
```python
st = "Anand Reddy"
rev_str = ""
for i in st:
    rev_str = i + rev_str
print(rev_str)
```
**Output:** `yddeR dnanA` (except Option 3, which returns a character list).

**Complexity:** Options 1–3: O(n) time and O(n) space. Concatenation approaches: O(n²) worst-case time and O(n) peak space.

## 2. Find the second-largest distinct number in a list

### Option 1 — Using built-in functions
```python
li = [100, 50, 40, 70, 20, 10, 50, 30, 80, 90]
un_li = sorted(list(set(li)))
print(un_li[-2] if len(un_li) > 1 else None)
```
### Option 2 — Bubble sort (without built-in sorting)
```python
li = [100, 50, 40, 70, 20, 10, 50, 30, 80, 90]
unique_list = list(set(li))
n = len(unique_list)
for i in range(n):
    for j in range(n-i-1):
        if unique_list[j] > unique_list[j+1]:
            unique_list[j], unique_list[j+1] = unique_list[j+1], unique_list[j]
print(unique_list[-2] if n > 1 else None)
```
### Option 3 — Single pass without built-in functions (recommended)
```python
li = [100, 50, 40, 70, 20, 10, 50, 30, 80, 90]
largest = None
second_largest = None
for num in li:
    if largest is None or num > largest:
        second_largest = largest
        largest = num
    elif num != largest and (second_largest is None or num > second_largest):
        second_largest = num
print(f"Largest: {largest}")
print(f"Second largest: {second_largest}")
```
**Output:** Second largest: `90`.

**Complexity:** Option 1: O(n log n) time, O(n) space. Option 2: O(n²) time, O(n) space. Option 3: O(n) time, O(1) space.

## 3. Remove duplicates from a list while preserving order

### Option 1 — Using `dict.fromkeys()`
```python
li = [100, 50, 40, 70, 20, 10, 50, 30, 80, 90]
uni = list(dict.fromkeys(li))
print(uni)
```
### Option 2 — Using a set and a list
```python
li = [100, 50, 40, 70, 20, 10, 50, 30, 80, 90]
seen = set()
uni_li = []
for i in li:
    if i not in seen:
        seen.add(i)
        uni_li.append(i)
print(uni_li)
```
**Output:** `[100, 50, 40, 70, 20, 10, 30, 80, 90]`

**Complexity:** O(n) average time, O(k) space, where k is the number of distinct elements.

## 4. Find the first non-repeating character
```python
st = "programming"
dt = {}
for i in st:
    dt[i] = dt.get(i, 0) + 1
for k, v in dt.items():
    if v == 1:
        print(f"First non-repeating character: {k}")
        break
else:
    print("No non-repeating character")
```
**Output:** `p`

**Complexity:** O(n) average time, O(k) space for k distinct characters. Dictionaries preserve insertion order in Python 3.7+.

## 5. Count the frequency of words in a sentence
```python
fre = "python is easy and python is powerful"
fre_di = {}
for word in fre.split():
    fre_di[word] = fre_di.get(word, 0) + 1
print(fre_di)
```
**Output:**
```python
{'python': 2, 'is': 2, 'easy': 1, 'and': 1, 'powerful': 1}
```
**Complexity:** O(n) average time and O(n) auxiliary space, where n is the sentence length; `split()` creates a list of words.

## 6. Calculate total sales for each product
```python
sales = [
    {"product": "Laptop", "amount": 50000},
    {"product": "Mobile", "amount": 20000},
    {"product": "Laptop", "amount": 60000},
    {"product": "Tablet", "amount": 15000},
    {"product": "Mobile", "amount": 25000},
    {"product": "Tablet", "amount": 18000}
]
group = {}
for sale in sales:
    product = sale["product"]
    amount = sale["amount"]
    if product not in group:
        group[product] = 0
    group[product] = group[product] + amount
print(group)
```
**Output:** `{'Laptop': 110000, 'Mobile': 45000, 'Tablet': 33000}`

**Complexity:** O(n) average time, O(k) space for k products.

## 7. Count incident statuses for each server
```python
incidents = [
    {"server": "server-1", "status": "SUCCESS"},
    {"server": "server-2", "status": "FAILED"},
    {"server": "server-1", "status": "FAILED"},
    {"server": "server-2", "status": "SUCCESS"},
    {"server": "server-1", "status": "SUCCESS"},
    {"server": "server-3", "status": "FAILED"},
    {"server": "server-2", "status": "FAILED"}
]
groups = {}
for incident in incidents:
    server = incident["server"]
    status = incident["status"]
    if server not in groups:
        groups[server] = {"SUCCESS": 0, "FAILED": 0}
    groups[server][status] += 1
print(groups)
```
**Output:**
```python
{
    'server-1': {'SUCCESS': 2, 'FAILED': 1},
    'server-2': {'SUCCESS': 1, 'FAILED': 2},
    'server-3': {'SUCCESS': 0, 'FAILED': 1}
}
```
**Complexity:** O(n) average time, O(k) space for k servers and a fixed set of statuses.

## 8. Count Kubernetes pod statuses
```python
events = [
    {"pod": "pod-1", "status": "RUNNING"},
    {"pod": "pod-1", "status": "CRASHED"},
    {"pod": "pod-2", "status": "RUNNING"},
    {"pod": "pod-1", "status": "RUNNING"},
    {"pod": "pod-2", "status": "PENDING"},
    {"pod": "pod-2", "status": "RUNNING"}
]
groups = {}
for event in events:
    pod = event["pod"]
    status = event["status"]
    if pod not in groups:
        groups[pod] = {"RUNNING": 0, "CRASHED": 0, "PENDING": 0}
    groups[pod][status] += 1
print(groups)
```
**Output:**
```python
{
    'pod-1': {'RUNNING': 2, 'CRASHED': 1, 'PENDING': 0},
    'pod-2': {'RUNNING': 2, 'CRASHED': 0, 'PENDING': 1}
}
```
**Complexity:** O(n) average time, O(k) space for k pods and fixed statuses.

## 9. Find the second-highest distinct salary in each department
```python
employees = [
    {"name": "Anand", "department": "IT", "salary": 85000},
    {"name": "Priya", "department": "IT", "salary": 95000},
    {"name": "Arjun", "department": "IT", "salary": 90000},
    {"name": "Vijay", "department": "IT", "salary": 95000},
    {"name": "Rahul", "department": "HR", "salary": 55000},
    {"name": "Kiran", "department": "HR", "salary": 60000},
    {"name": "Sneha", "department": "Finance", "salary": 75000},
    {"name": "Divya", "department": "Finance", "salary": 80000}
]
groups = {}
for employee in employees:
    department = employee["department"]
    salary = employee["salary"]
    if department not in groups:
        groups[department] = []
    groups[department].append(salary)
for key, value in groups.items():
    uni_sal = list(set(value))
    sort_list = sorted(uni_sal)
    if len(sort_list) > 1:
        print(key, sort_list[-2])
```
**Output:**
```text
IT 90000
HR 55000
Finance 75000
```
**Complexity:** O(n log n) worst-case time, O(n) space. A department with fewer than two distinct salaries is skipped.

## 10. Calculate average response time for each API (successful requests only)
```python
requests = [
    {"api": "/users", "time": 120, "status": 200},
    {"api": "/orders", "time": 300, "status": 200},
    {"api": "/users", "time": 180, "status": 200},
    {"api": "/orders", "time": 500, "status": 500},
    {"api": "/payments", "time": 400, "status": 200},
    {"api": "/orders", "time": 200, "status": 200},
    {"api": "/payments", "time": 600, "status": 200},
    {"api": "/users", "time": 900, "status": 500}
]
groups = {}
for request in requests:
    api = request["api"]
    time = request["time"]
    if api not in groups:
        groups[api] = []
    if request["status"] == 200:
        groups[api].append(time)
result = {}
for key, value in groups.items():
    if value:
        result[key] = sum(value) / len(value)
print(result)
```
**Output:** `{'/users': 150.0, '/orders': 250.0, '/payments': 500.0}`

**Complexity:** O(n) average time, O(n) space. The empty-list check prevents division by zero for APIs without successful requests.

## 11. Find the most frequently used tool by each AI agent
```python
tool_logs = [
    {"agent": "monitoring", "tool": "get_metrics"},
    {"agent": "troubleshooting", "tool": "get_logs"},
    {"agent": "monitoring", "tool": "get_pods"},
    {"agent": "troubleshooting", "tool": "get_events"},
    {"agent": "monitoring", "tool": "get_metrics"},
    {"agent": "automation", "tool": "restart_pod"},
    {"agent": "troubleshooting", "tool": "get_logs"},
    {"agent": "monitoring", "tool": "get_metrics"},
    {"agent": "automation", "tool": "scale_deployment"},
    {"agent": "automation", "tool": "restart_pod"},
    {"agent": "troubleshooting", "tool": "get_logs"}
]
groups = {}
for tools in tool_logs:
    agent = tools["agent"]
    tool = tools["tool"]
    if agent not in groups:
        groups[agent] = {}
    if tool not in groups[agent]:
        groups[agent][tool] = 0
    groups[agent][tool] += 1
result = {}
for agent, tools in groups.items():
    max_count = 0
    max_tool = None
    for tool, count in tools.items():
        if count > max_count:
            max_count = count
            max_tool = tool
    result[agent] = {"tool": max_tool, "count": max_count}
print(result)
```
**Intermediate grouping:**
```python
{
    'monitoring': {'get_metrics': 3, 'get_pods': 1},
    'troubleshooting': {'get_logs': 3, 'get_events': 1},
    'automation': {'restart_pod': 2, 'scale_deployment': 1}
}
```
**Output:**
```python
{
    'monitoring': {'tool': 'get_metrics', 'count': 3},
    'troubleshooting': {'tool': 'get_logs', 'count': 3},
    'automation': {'tool': 'restart_pod', 'count': 2}
}
```
**Complexity:** O(n) average time, O(k) space for k distinct agent-tool pairs. Ties are resolved in favor of the first encountered tool.

---

## Quick complexity revision

| Question | Time | Auxiliary space |
|---|---|---|
| Reverse string (slicing) | O(n) | O(n) |
| Second-largest (single pass) | O(n) | O(1) |
| Remove duplicates | O(n) | O(k) |
| First non-repeating character | O(n) | O(k) |
| Word frequency | O(n) | O(n) |
| Total sales | O(n) | O(k) |
| Server status counts | O(n) | O(k) |
| Pod status counts | O(n) | O(k) |
| Second-highest salary | O(n log n) | O(n) |
| Average API response time | O(n) | O(n) |
| Most-used agent tool | O(n) | O(k) |

Hash-based operations assume average-case dictionary/set performance. Space includes constructed results, but excludes the original input. Here k represents the relevant number of distinct keys or groups.
