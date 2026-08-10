# Linux Sticky Bit

## Definition

**Sticky Bit** is a special permission applied to **directories**. It allows all users to create files in a shared directory, but **only the file owner, the directory owner, or the root user can delete or rename** those files.

---

## Why is Sticky Bit Needed?

Consider a shared directory:

```text
/shared
├── john.txt   (Owner: John)
└── alice.txt  (Owner: Alice)
```

With Sticky Bit enabled:

- John can delete `john.txt`
- Alice can delete `alice.txt`
- John cannot delete `alice.txt`
- Alice cannot delete `john.txt`
- Root can delete either file

---

## Real-World Example

The `/tmp` directory is shared by all users.

Check the permissions using:

```bash
ls -ld /tmp
```

Example:

```text
drwxrwxrwt /tmp
```

The **`t`** at the end indicates that the **Sticky Bit** is enabled.

---

## Set Sticky Bit

### Using Symbolic Notation

```bash
chmod +t /shared
```

### Using Numeric Notation

```bash
chmod 1777 /shared
```

Here:

```text
1    → Sticky Bit
777  → Read, Write, Execute for Owner, Group, and Others
```

---

## Verify Sticky Bit

Run:

```bash
ls -ld /shared
```

If the permissions end with **`t`**, Sticky Bit is enabled.

Example:

```text
drwxrwxrwt /shared
         ↑
     Sticky Bit
```

---

## Difference Between `t` and `T`

| Symbol | Meaning |
|---|---|
| **`t`** | Sticky Bit is enabled and the directory has **execute permission** for others. |
| **`T`** | Sticky Bit is enabled but the directory does **not have execute permission** for others. |

Example:

```text
drwxrwxrwt
        ↑
        t
```

```text
drwxrwxrwT
        ↑
        T
```

---

## Interview Summary

> **Sticky Bit is a special permission mainly used on shared directories such as `/tmp`. It allows all users to create files but ensures that only the file owner, the directory owner, or root can delete or rename those files.**
