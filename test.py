# st = "programminG"

# # convert string to Set if the order is not importent 
# # join to the set back to string
# # print("".join(set(st)))

# # If Order is importent then use dict.
# # print("".join(dict.fromkeys(st.lower())))


# # new_l = ""
# # for i in st:
# #     if i not in new_l:
# #         new_l += i
# # print(new_l)

# # count_n = {}
# # for i in st:
# #     count_n[i.lower()] = count_n.get(i.lower(), 0) + 1

# # print(count_n)


# n = [1, 2, 2, 3, 4, 3, 5]

# # print(list(set(n)))

# print(list(dict.fromkeys(n)))


text = "programming"

# print(text[::-1])

# rev_l = "".join(list(reversed(text)))
# print(rev_l)

# rev_s = ""
# for i in text:
#     rev_s = i + rev_s
# print(rev_s)

n = [1, 2, 3, 2, 4, 5, 6, 5, 3]

# du = []
# un = []

# for i in n:
#     if i not in un:
#         un.append(i)
#     else:
#         du.append(i)

# print(du)
# print(un)

# di = {}

# for i in n:
#     di[i] = di.get(i, 0) + 1

# uni = []
# du = []
# for k, v in di.items():
#     if v == 1:
#         uni.append(k)
#     else:
#         du.append(k)

# print(uni)
# print(du)

# numbers = [10, 20, 5]

# sorted = sorted(list(set(numbers)))
# print(sorted[-1])

# n = sorted(list(dict.fromkeys(numbers)))
# print(n)

numbers = [10, 20, 5, 34]
for i in range(len(numbers)):
    for j in range(len(numbers)-1):
        if numbers[j] > numbers[j + 1]:
            numbers[j], numbers[j + 1] = numbers[j + 1], numbers[j]
    print(numbers)

print(numbers)


