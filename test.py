# l = [1, 2, [2, 3], 3, 4]

# final_list = []
# for i in l:
#     if isinstance(i, list):
#         final_list.extend(i)
#         # for j in i:
#         #     final_list.append(j)
#     else:
#         final_list.append(i)

# # print(final_list)
# print(list(final_list))
# # print(list(dict.fromkeys(final_list)))


events = [
    {"tool": "get_pod", "args": {"pod": "payments-1"}, "request_id": "r1"},
    {"tool": "get_pod", "args": {"pod": "payments-1"}, "request_id": "r2"},
    {"tool": "restart_pod", "args": {"pod": "payments-1"}, "request_id": "r3"},
    {"tool": "restart_pod", "args": {"pod": "payments-1"}, "request_id": "r4"},
    {"tool": "get_pod", "args": {"pod": "orders-1"}, "request_id": "r5"},
]


seen = set()
unique_list = []
for event in events:
    key = (event["tool"], event["args"]["pod"])

    if key not in seen:
        seen.add(key)
        unique_list.append(event)


print(unique_list)
    




