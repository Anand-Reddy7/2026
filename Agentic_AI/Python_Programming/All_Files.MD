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
```