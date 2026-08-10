Navigation
---------
- pwd
- ls
- cd

Files
-----
- touch
- mkdir
- cp
- mv
- rm
- cat
- less
- head
- tail

Search
------
- grep
- find
- awk
- sed

Permissions
-----------
- chmod
- chown

Processes
---------
- ps
- top
- kill
- pgrep

Storage
-------
- df
- du
- lsblk
- mount

Networking
----------
- ip
- ping
- ss
- curl
- dig

Remote
------
- ssh
- scp
- rsync

Services
--------
- systemctl
- journalctl

Users
-----
- whoami
- id
- useradd
- passwd
- usermod
- groupadd

Archives
--------
- tar
- gzip

System
------
- uname
- hostname
- uptime
- env
- echo

Text Processing
---------------
- sort
- uniq
- wc
- cut
- awk
- sed

Shell
-----
|
>
>>
2>


----------------------------------------------------------------------------------------------

| Command   | Purpose                      | Common Example            |
| --------- | ---------------------------- | ------------------------- |
| `pwd`     | Show current directory       | `pwd`                     |
| `ls`      | List files                   | `ls -ltr`                 |
| `cd`      | Change directory             | `cd /var/log`             |
| `touch`   | Create/update file timestamp | `touch test.txt`          |
| `mkdir`   | Create directory             | `mkdir logs`              |
| `cp`      | Copy files/directories       | `cp file /backup/`        |
| `mv`      | Move/rename                  | `mv old new`              |
| `rm`      | Delete                       | `rm file.txt`             |
| `cat`     | Display file                 | `cat config.conf`         |
| `more`    | View file page by page       | `more logfile`            |
| `less`    | Advanced file viewer         | `less logfile`            |
| `head`    | Show beginning               | `head -20 logfile`        |
| `tail`    | Show end                     | `tail -50 logfile`        |
| `tail -f` | Follow log in real time      | `tail -f application.log` |


----------------------------------------------------------------------------------------------

grep → Find / Search
sed  → Find + Modify
awk  → Extract / Process columns and data

----------------------------------------------------------------------------------------------
## GREP (Find / Search)

- Basic Search
```
grep "error" application.log
```
Finds lines containing error.

- Case-insensitive search
```
grep -i "error" application.log
```
shows all the output with smaller or capital letters

- Show Line Numbers
```
grep -n "error" application.log
```

- Invert the Match

Use -v to show lines that do not match.
```
grep -v "INFO" application.log
```

- Search Multiple Files
```
grep "ERROR" app1.log app2.log app3.log
```

- Recursive Search
```
grep -R "ERROR" /var/log/
```

- Search Only Specific File Types
```
grep -r --include="*.log"  --include="*.txt" "ERROR" /opt/app/
```

- Exclude Files
```
grep -r --exclude="*.gz" "ERROR" /var/log/
```

- Exclude directories
```
grep -r --exclude-dir="archive" "ERROR" /var/log/
```

- Count Matches
```
grep -c "ERROR" application.log
```

- Show Only Matching Text
```
grep -o "ERROR" application.log
```

- Search Multiple Patterns
```
grep -e "ERROR" -e "WARNING" application.log
grep -E "ERROR|WARNING" application.log
```

- Show Files Containing a Match
```
grep -rl "ERROR" /opt/application/
```
Instead of printing matching lines, it prints the filenames.

- How do you search compressed .gz logs
```
zgrep "ERROR" application.log.gz
```

- Quiet Mode
```
grep -q "ERROR" application.log
```
It produces no output.

Example:
```
if grep -q "ERROR" application.log; then
    echo "Errors found"
fi
```

----------------------------------------------------------------------------------------------

## SED (Stream Editor) (Find + Modify)

| Syntax | Meaning                     |
| ------ | --------------------------- |
| `s`    | Substitute                  |
| `g`    | Global replacement          |
| `d`    | Delete                      |
| `p`    | Print                       |
| `i`    | Insert before               |
| `a`    | Append after                |
| `c`    | Change entire line          |
| `-i`   | Modify file in-place        |
| `-n`   | Suppress automatic printing |


## Replace first occurrence
```
sed 's/old/new/' file
```

## Replace all occurrences
```
sed 's/old/new/g' file
```

## Modify original file
```
sed -i 's/old/new/g' file
```

## Modify with backup
```
sed -i.bak 's/old/new/g' file
```

## Delete a line
```
sed '5d' file
```

## Delete a range
```
sed '10,20d' file
```

## Delete empty lines
```
sed '/^$/d' file
```

## Delete comments
```
sed '/^#/d' file
```

## Print specific line
```
sed -n '10p' file
```

## Print a range
```
sed -n '10,20p' file
```

## Print matching lines
```
sed -n '/ERROR/p' file
```

## Replace on matching lines
```
sed '/server/s/old/new/g' file
```

## Replace entire matching line
```
sed 's/^server=.*/server=10.10.10.20/' file
```

## Use | as delimiter for paths
```
sed 's|/old/path|/new/path|g' file
```

----------------------------------------------------------------------------------------------

## Print first column
```
awk '{print $1}' file
```

## Print multiple columns
```
awk '{print $1,$3}' file
```

## Print last column
```
awk '{print $NF}' file
```

## Print all lines 
```
awk '{print $0}' file
```

## Print line number
```
awk '{print NR,$0}' file
```

## Print number of columns
```
awk '{print NF}' file
```

## Use delimiter
```
awk -F: '{print $1,$7}' /etc/passwd
```

## Skip header
```
awk 'NR>1 {print $1,$5}' file
```

## Example for FS and OFS

### FS (Field Separator)
FS tells awk how to split each input line into fields/columns.

Example file 
```
john:25:Bangalore:Developer
alice:30:Chennai:DevOps
bob:28:Mumbai:Admin
```

Here, : is separating the columns.

You can tell awk to use : as the field separator:

```
awk -F: '{print $1, $2, $3}' users.txt
```

Output:

```
john 25 Bangalore
alice 30 Chennai
bob 28 Mumbai
```

### OFS — Output Field Separator

OFS tells awk what separator to use when printing multiple fields.

By default, awk uses a space.

```
awk -F: '{print $1, $2, $3}' users.txt
```
Output:

```
john 25 Bangalore
alice 30 Chennai
bob 28 Mumbai
```
If you want comma-separated output:

```
awk -F: 'BEGIN { OFS="," } { print $1, $2, $3 }' users.txt
```
Output:

```
john,25,Bangalore
alice,30,Chennai
bob,28,Mumbai
```