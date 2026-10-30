# Python Interview Coding Preparation

# Topics

1. String
2. Number
3. List
4. Tuple
5. Set
6. Dict


# String

A string in Python is a sequence of Unicode characters enclosed in single quotes (' '), double quotes (" "), or triple quotes (''' ''' or """ """

Strings are Immutable and iterables.

```py
name = "Hello Anand, How are you ?"

## Lenth of the string
print(len(name))

## remove the spaces. Remove leading/trailing whitespace
print(name.strip())
print(s.lstrip())    # Removes left whitespace
print(s.rstrip())    # Removes right whitespace

## Print in Uppercase 
print(name.upper())

## Print in Lower case
print(name.lower())

## Starts with
print(name.startswith("He"))

## Ends with
print(name.endswith("An"))

## Count of specific Charecter
print(name.count("H"))

## Replace
print(name.replace("Anand", "Baby"))

## Is Digit
print("123".isdigit())
print(name.isdigit())

## Is Title
print(name.istitle())

## Indexing and Slicing
print(name[0]) # First Charecter
print(name[-1]) # Last Charecter
print(name[7:]) # start from 7th Charecter
print(name[:7]) # Print upto 7th Charecter
print(name[::-1]) # Reverse 
print(name[::2]) # Print every 2nd Charecter

## Split and Join
## Split into list
print(name.split())

## Split into list with separater
print(name.split(","))

## Join List -> String ["Hello", "Anand", "reddy"] to "HelloAnandreddy"
n_list = ["Hello", "Anand", "reddy"]
print("".join(n_list))

## Reverse words in a sentence.
s = "I love Python"
print(s.split()[::-1])

## Find and Index
### find()	-> Returns -1
### index()	-> Raises ValueError

## Find the Index of Specific Charecter
print(name.index("?"))

## Find the specific Charecter
print(name.find(">"))

## Find After Specific Index
print(name.find("?", 5))

## Sorted
print(sorted(name))

## get Unique Charecters
print(set(name))

## Get Unique Charecters with preserverd order
print("".join(dict.fromkeys(name)))


----------------------------------------------------
# Programs
----------------------------------------------------

# Character frequency and first non-repeating character
name = "programming"

# Output:
##Frequency: {'p': 1, 'r': 2, 'o': 1, 'g': 2, 'a': 1, 'm': 2, 'i': 1, 'n': 1}
## First non-repeating: p

# Option - 1
non_repet = ""
for char in name:
    if char not in non_repet:
        non_repet = non_repet + char

print(f"First Non Repeting Char: {non_repet[0]}")

# Option - 2
non_repet = {}
for char in name:
    non_repet[char] = non_repet.get(char, 0) + 1

for k, v in non_repet.items():
    if v == 1:
        print(f"First Non repeting charecter is: {k}")
        break
```

# List
A list is an ordered, mutable collection that can store multiple values, including different data types.

Property	Description
=======================
Ordered	        Maintains element order
Mutable	        Elements can be modified
Duplicates	    Allowed
Indexed	        Supports positive and negative indexes
Mixed types	    Can contain integers, strings, dictionaries, etc.
Dynamic size	Can grow or shrink


```py
numbers = [10, 20, 30, 20, 50, 60, 10]

# Indexing
print(numbers[0])
print(numbers[-1])
print(numbers[3:])
print(numbers[:4])
print(numbers[3:6])
print(numbers[::-1])

# Append
numbers.append(90)
print(numbers)

# Extend
n = [70, 120]
numbers.extend(n)
print(numbers)

# Insert
numbers.insert(1, 9)
print(numbers)

# Reverse
numbers.reverse()
print(numbers)

# Count
print(numbers.count(10))
numbers.sort(reverse=True)
print(numbers)


# Find Min, Max, Sum
print(max(numbers))
print(min(numbers))
print(sum(numbers))
print(len(numbers))





#1	Find largest and second-largest distinct number	[10,40,20,40,30] → 30
n = [10,40,20,40,30]
n.sort(reverse=True)
print(n[0])

#2	Remove duplicates preserving order	[1,2,2,3,1] → [1,2,3]
n = [1,2,2,3,1]
print(list(dict.fromkeys(n)))


#3. Find the missing value
n = [1,2,4,5,7,11,7,8]
n.sort()

for i in range(1, n[-1]):
    if i not in n:
        print(f"Missing value is : {i}")

    


#4	Find duplicate numbers	[1,2,3,2,4,1] → [1,2]
n = [1,2,3,2,4,1]

du = {}
for i in n:
    du[i] = du.get(i, 0) + 1
uni = []
for k, v in du.items():
    if v == 1:
        uni.append(k)
```

# Tuple
A tuple is an ordered, immutable collection of elements. It can store different data types and allows duplicate values.

```py
# count() and index()
t = (10, 20, 30, 40, 50)

print(t.count(20))   # 2
print(t.index(20))   # 1

# Built-in Functions
t = (10, 20, 30, 40, 50)

print(len(t))        # 5
print(max(t))        # 50
print(min(t))        # 10
print(sum(t))        # 150
print(sorted(t))     # [10, 20, 30, 40, 50]

# Tuple immutability

t = (10, 20, 30)
# t[0] = 100  # TypeError
```

# Set
A set in Python is a mutable collection of unique, hashable elements. Sets are mainly used for removing duplicates, fast membership checking, and mathematical set operations.

Property	    Set
=====================
Ordered	        No guaranteed order
Mutable	        Yes
Duplicates	    Not allowed
Indexing	    Not supported
Slicing	        Not supported
Mixed data types	Yes, if elements are hashable
Membership checking	O(1) average

```py
s = {3, 6, 9, 3, 6, 1, 2, 6}

# Add & Update
s.add(19) # Add one element
s.update([5, 67, 8]) # adds elements from an iterable.

# remove() vs discard()
s.remove(12) # Key error if no value found
s.discard(12) # No error if missing
```

# Dict
A dictionary in Python stores data in key-value pairs. It is one of the most important data structures for coding interviews, especially for frequency counting, grouping, caching, and fast lookups.

Property	    Dictionary
==========================

Ordered	        Yes, insertion order (Python 3.7+)
Mutable	        Yes
Duplicate keys	Not allowed
Duplicate values	Allowed
Keys	        Must be hashable
Values	        Any data type
Lookup complexity	O(1) average


```py

```