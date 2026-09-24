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