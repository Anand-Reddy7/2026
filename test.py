## Question 1: Reverse a string without built-in functions
# st = "Anand Reddy"

## Option 1
# print(st[::-1])

## Option 2 // Here reversed will return iterator. So, use join or list
# With Join 
# an_re = "".join(reversed(st))
# print(an_re)

## With List
# print(list(reversed(st)))

## With String Concatination
# rev_st = ""
# for i in reversed(st):
#     rev_st = rev_st + i
# print(rev_st)

## Without inbuild function
# rev_str = ""
# for i in st:
#     rev_str = i + rev_str
# print(rev_str)



## Question - 2 : Find the second-largest distinct number in a list
li = [100, 50, 40, 70, 20, 10, 50, 30, 80, 90]

## Option -1 : With BuiltIn

# un_li = sorted(list(set(li)))
# print(un_li[-2])

## Option - 2: WithOut BuiltIn

# unique_list = list(set(li))
# n = len(unique_list)

# for i in range(n):
#     for j in range(n-i-1):
#         if unique_list[j] > unique_list[j+1]:
#             unique_list[j], unique_list[j+1] = unique_list[j+1], unique_list[j]

# print(unique_list[-2])

## Option-3 without any inbuilt functions
# largest = None
# second_larget = None

# for num in li:
#     if largest is None or num > largest:
#         second_larget = largest
#         largest = num
#     elif num != largest and (second_larget is None or num > second_larget):
#         second_larget = num
# print(f"Largets: {largest}")
# print(f"Second_largest: {second_larget}")


## Question - 3 : Remove duplicates from a list while preserving order
## Option - 1
# uni = list(dict.fromkeys(li))
# print(uni)

## Option - 2 
# seen = set()
# uni_li = []

# for i in li:
#     if i not in seen:
#         seen.add(i)
#         uni_li.append(i)
# print(uni_li)


## Question : Print first Non repeting charecter

# st = "programming"

# dt = {}

# for i in st:
#     dt[i] = dt.get(i, 0) + 1

# for k, v in dt.items():
#     if v == 1:
#         print(f"First Non repeting Char is : {k}")
#         break

## Question: Count the frequency of words in a sentence
# fre = "python is easy and python is powerful"

# fre_di = {}
# for word in fre.split():
#     fre_di[word] = fre_di.get(word, 0) + 1
# print(fre_di)

## Question: Calculate total sales for each product
# sales = [
#     {"product": "Laptop", "amount": 50000},
#     {"product": "Mobile", "amount": 20000},
#     {"product": "Laptop", "amount": 60000},
#     {"product": "Tablet", "amount": 15000},
#     {"product": "Mobile", "amount": 25000},
#     {"product": "Tablet", "amount": 18000}
# ]

# group = {}

# for sale in sales:
#     product = sale["product"]
#     amount = sale["amount"]

#     if product not in group:
#         group[product] = 0
#     group[product] = group[product] + amount
# print(group)


## Question : Count incident statuses for each server

# incidents = [
#     {"server": "server-1", "status": "SUCCESS"},
#     {"server": "server-2", "status": "FAILED"},
#     {"server": "server-1", "status": "FAILED"},
#     {"server": "server-2", "status": "SUCCESS"},
#     {"server": "server-1", "status": "SUCCESS"},
#     {"server": "server-3", "status": "FAILED"},
#     {"server": "server-2", "status": "FAILED"}
# ]

# groups = {}
# for incident in incidents:
#     server = incident["server"]
#     status = incident["status"]

#     if server not in groups:
#         groups[server] = {"SUCCESS": 0, "FAILED": 0}

#     groups[server][status] += 1

# print(groups)


# events = [
#     {"pod": "pod-1", "status": "RUNNING"},
#     {"pod": "pod-1", "status": "CRASHED"},
#     {"pod": "pod-2", "status": "RUNNING"},
#     {"pod": "pod-1", "status": "RUNNING"},
#     {"pod": "pod-2", "status": "PENDING"},
#     {"pod": "pod-2", "status": "RUNNING"}
# ]

# groups = {}
# for event in events:
#     pod = event["pod"]
#     status = event["status"]

#     if pod not in groups:
#         groups[pod] = {"RUNNING": 0, "CRASHED": 0, "PENDING": 0}

#     groups[pod][status] += 1

# print(groups)


## Question: Find the second-highest salary in each department

# employees = [
#     {"name": "Anand", "department": "IT", "salary": 85000},
#     {"name": "Priya", "department": "IT", "salary": 95000},
#     {"name": "Arjun", "department": "IT", "salary": 90000},
#     {"name": "Vijay", "department": "IT", "salary": 95000},
#     {"name": "Rahul", "department": "HR", "salary": 55000},
#     {"name": "Kiran", "department": "HR", "salary": 60000},
#     {"name": "Sneha", "department": "Finance", "salary": 75000},
#     {"name": "Divya", "department": "Finance", "salary": 80000}
# ]

# groups = {}
# for employee in employees:
#     department = employee["department"]
#     salary = employee["salary"]

#     if department not in groups:
#         groups[department] = []

#     groups[department].append(salary)
# print(groups)

# for key, value in groups.items():
#     uni_sal = list(set(value))
#     sort_list = sorted(uni_sal)

#     if len(sort_list) > 1:
#         print(key, sort_list[-2])

## Question : Calculate average response time for each API

# requests = [
#     {"api": "/users", "time": 120, "status": 200},
#     {"api": "/orders", "time": 300, "status": 200},
#     {"api": "/users", "time": 180, "status": 200},
#     {"api": "/orders", "time": 500, "status": 500},
#     {"api": "/payments", "time": 400, "status": 200},
#     {"api": "/orders", "time": 200, "status": 200},
#     {"api": "/payments", "time": 600, "status": 200},
#     {"api": "/users", "time": 900, "status": 500}
# ]

# groups = {}

# for request in requests:
#     api = request["api"]
#     time = request["time"]

#     if api not in groups:
#         groups[api] = []

#     if request["status"] == 200:
#         groups[api].append(time)

# print(groups)

# result = {}
# for key, value in groups.items():
#     result[key] = sum(value)/len(value)

# print(result)


## Question: Find the most frequently used tool by each AI agent

# tool_logs = [
#     {"agent": "monitoring", "tool": "get_metrics"},
#     {"agent": "troubleshooting", "tool": "get_logs"},
#     {"agent": "monitoring", "tool": "get_pods"},
#     {"agent": "troubleshooting", "tool": "get_events"},
#     {"agent": "monitoring", "tool": "get_metrics"},
#     {"agent": "automation", "tool": "restart_pod"},
#     {"agent": "troubleshooting", "tool": "get_logs"},
#     {"agent": "monitoring", "tool": "get_metrics"},
#     {"agent": "automation", "tool": "scale_deployment"},
#     {"agent": "automation", "tool": "restart_pod"},
#     {"agent": "troubleshooting", "tool": "get_logs"}
# ]


# {
#     'monitoring': {'get_metrics': 3, 'get_pods': 1},
#     'troubleshooting': {'get_logs': 3, 'get_events': 1},
#     'automation': {'restart_pod': 2, 'scale_deployment': 1}
# }

# groups = {}

# for tools in tool_logs:
#     agent = tools["agent"]
#     tool = tools["tool"]

#     if agent not in groups:
#         groups[agent] = {}

#     if tool not in groups[agent]:
#         groups[agent][tool] = 0

#     groups[agent][tool] += 1


# result = {}

# for agent, tools in groups.items():
#     max_count = 0
#     max_tool = None
#     for tool, count in tools.items():
#         if count > max_count:
#             max_count = count
#             max_tool = tool

#     result[agent] = {"tool" : max_tool, "count": max_count}
# print(result)


words = ["eat", "tea", "tan", "ate", "nat", "bat"]

groups = {}
for word in words:
    key = "".join(sorted(word))

    if key not in groups:
        groups[key] = []

print(groups)


