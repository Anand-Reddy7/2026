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

## Question: Find two numbers that sum to a target

nums = [2, 7, 11, 15]
target = 9

