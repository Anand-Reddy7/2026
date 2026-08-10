# Linux Permission Modes

Linux provides **two methods** to change file and directory permissions:
1.  **Numeric (Octal) Mode**
2.  **Symbolic Mode**

------------------------------------------------------------------------
## 1. Numeric (Octal) Mode

### Definition
**Numeric (Octal) Mode** uses numbers to set permissions for the
**Owner**, **Group**, and **Others** in a single command.

### Permission Values
  Permission      Value
  ------------- -------
  Read (r)            4
  Write (w)           2
  Execute (x)         1
``` text
rwx = 7
rw- = 6
r-x = 5
r-- = 4
```
### Syntax
``` bash
chmod <permission> <file_name>
```
### Examples
``` bash
chmod 755 script.sh
chmod 644 file.txt
chmod 600 secret.txt
```
``` text
Owner  → rwx (7)
Group  → r-x (5)
Others → r-x (5)
```
------------------------------------------------------------------------

## 2. Symbolic Mode
### Definition
**Symbolic Mode** uses **letters and symbols** to **add, remove, or
assign** permissions without affecting existing permissions.
### Symbols
  Symbol   Meaning
  -------- --------------
  u        User (Owner)
  g        Group
  o        Others
  a        All
### Operators
  Operator   Meaning
  ---------- -------------------------
  \+         Add permission
  \-         Remove permission
  =          Assign exact permission
### Permissions
  Permission   Meaning
  ------------ ---------
  r            Read
  w            Write
  x            Execute
### Syntax
``` bash
chmod [ugoa][+-=][rwx] <file_name>
```
### Examples
``` bash
chmod +x script.sh
chmod u+x script.sh
chmod g-w file.txt
chmod o+r file.txt
chmod u=rwx,g=rx,o=r file.txt
```
------------------------------------------------------------------------
## Difference Between Numeric and Symbolic Mode
  -----------------------------------------------------------------------
  Numeric Mode                        Symbolic Mode
  ----------------------------------- -----------------------------------
  Uses numbers (755, 644, 600).       Uses letters and symbols (u+x,
                                      g-w).
  Sets all permissions at once.       Adds, removes, or modifies specific
                                      permissions.
  Best for setting complete           Best for changing specific
  permissions.                        permissions.
  -----------------------------------------------------------------------
------------------------------------------------------------------------
## Interview Summary
> Linux supports **Numeric (Octal) Mode** using numbers like **755** and
> **644**, and **Symbolic Mode** using expressions like **u+x**,
> **g-w**, and **o+r** to modify permissions.


## Notes
- By default, file will get 644 permissions and folder will get 755 permissions 
```
-rw-r--r--. 1 root root 0 Aug  3 07:47 anand.sh
drwxr-xr-x. 2 root root 6 Aug  3 07:47 test_folder

