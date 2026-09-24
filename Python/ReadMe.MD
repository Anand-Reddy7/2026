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