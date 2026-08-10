# Linux Sticky Bit

## Definition
**Sticky Bit** is a special permission applied to **directories**. It
allows all users to create files in a shared directory, but **only the
file owner, the directory owner, or the root user can delete or rename
those files**.

------------------------------------------------------------------------
## Why is Sticky Bit Needed?
``` text
/shared
├── john.txt   (Owner: John)
└── alice.txt  (Owner: Alice)
```
**Without Sticky Bit** - John can delete `alice.txt` - Alice can delete
`john.txt`
**With Sticky Bit** - John can delete only `john.txt` - Alice can delete
only `alice.txt` - Root can delete any file
------------------------------------------------------------------------
## Real-World Example
The `/tmp` directory is shared by all users.
``` bash
ls -ld /tmp
```
Example:
``` text
drwxrwxrwt /tmp
```
The **t** at the end indicates the Sticky Bit.
------------------------------------------------------------------------
## Set Sticky Bit
``` bash
chmod +t /shared
```
or
``` bash
chmod 1777 /shared
```
------------------------------------------------------------------------
## Verify Sticky Bit
``` bash
ls -ld /shared
```
If permissions end with **t**, Sticky Bit is enabled.
------------------------------------------------------------------------
## Difference Between t and T
  -----------------------------------------------------------------------
  Symbol                              Meaning
  ----------------------------------- -----------------------------------
  `t`                                 Sticky Bit enabled and execute
                                      permission exists for others.
  `T`                                 Sticky Bit enabled but execute
                                      permission is not set for others.
  -----------------------------------------------------------------------
------------------------------------------------------------------------
## Interview Summary
> Sticky Bit is a special permission mainly used on shared directories
> such as `/tmp`. It allows all users to create files but ensures that
> only the file owner, the directory owner, or root can delete or rename
> those files.
