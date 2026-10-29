events = [
    {"tool": "get_pod", "args": {"pod": "payments-1"}, "request_id": "r1"},
    {"tool": "get_pod", "args": {"pod": "payments-1"}, "request_id": "r2"},
    {"tool": "restart_pod", "args": {"pod": "payments-1"}, "request_id": "r3"},
    {"tool": "restart_pod", "args": {"pod": "payments-1"}, "request_id": "r4"},
    {"tool": "get_pod", "args": {"pod": "orders-1"}, "request_id": "r5"},
]

unique_events = set()
answer = []
for event in events:
    key = (event["tool"], event["args"]["pod"])
    if key not in unique_events:
        unique_events.add(key)
        answer.append(event)
        
print(answer)