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
find → Search for files/directories
xargs → Takes input and passes it to another command
sort 

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
----------------------------------------------------------------------------------------------

# FIND

find is one of the most important Linux commands for locating files and directories based on name, type, size, permissions, ownership, time, and many other attributes.

```
mtime → Content modification time
atime → Access time
ctime → Metadata/status change time
```

## Find by name
```
find /opt -name "application.log"
```

## Find all log files
```
find /var/log -type f -name "*.log"
```

## Case-insensitive
```
find /opt -iname "*.LOG"
```

## Find directories
```
find /opt -type d -name "logs"
```

## Find large files
```
find /var -type f -size +1G
```

## Find recently modified files
```
find /opt -type f -mmin -30
```

## Find files older than 30 days
```
find /opt -type f -mtime +30
```

## Find files owned by root
```
find /opt -type f -user root
```

## Find specific permissions
```
find /opt -type f -perm 644
```

## Find SUID files
```
find / -type f -perm -4000 2>/dev/null
```

## Find and execute
```
find /opt -type f -name "*.log" -exec ls -lh {} \;
```

```
find files
   ↓
*.log
   ↓
run ls -lh
   ↓
{} = current file
```

## Find and grep
```
find /opt/logs -type f -name "*.log" -exec grep -H "ERROR" {} \;
```

## Find and delete
```
find /tmp -type f -name "*.tmp" -delete
```

## Limit search depth
```
find /opt -maxdepth 2 -type f
```

## Multiple conditions
```
find /var/log -type f -name "*.log" -size +100M
```

## Examples

- delete .log files older than 30 days:
```
find /opt/myapp/logs -type f -name "*.log" -mtime +30 -delete
```

- Find and Delete Empty Files
```
find /tmp -type f -empty -delete
```

----------------------------------------------------------------------------------------------
# XARGS

xargs is used to take input from standard input and convert it into arguments for another command.

xargs reads input from standard input and converts that input into arguments for another command. It is commonly used with find, grep, and other commands to process large numbers of files or values. -0 with find -print0 is important when filenames may contain spaces or special characters, and -P can be used for controlled parallel execution.

```
command1 | xargs command2
find /tmp -name "*.log" | xargs rm
```

## Basic
```
echo "a b c" | xargs echo
```

## One argument per command
```
echo "a b c" | xargs -n 1 echo
```

## Placeholder
```
echo "server1 server2" | xargs -n 1 -I {} echo "Checking {}"
```

## Find + grep
```
find /var/log -type f -name "*.log" | xargs grep "ERROR"
```

## Safe find + grep
```
find /var/log -type f -name "*.log" -print0 | xargs -0 grep "ERROR"
```

## Find + delete
```
find /tmp -type f -name "*.tmp" -print0 | xargs -0 rm
```

## Parallel execution
```
cat servers.txt | xargs -n 1 -P 4 -I {} ssh {} hostname
```

## Don't execute if there is no input
```
find /tmp -name "*.tmp" -print0 | xargs -0 -r rm
```

## Show commands before executing
```
cat files.txt | xargs -t rm
```


## find -print0 and xargs -0
```
find /tmp -type f | xargs rm
```

xargs uses whitespace to separate input. So a file like:
```
my application.log
```

can be incorrectly treated as two files:

```
my
application.log
```

### -print0
```
find /tmp -type f -print0
```

-print0 tells find to separate filenames using a NULL character (\0) instead of a newline.

```
file1.log\0
my application.log\0
server backup.log\0
```
NULL is safe because Linux filenames cannot contain NULL.

### xargs -0
Read input using NULL (\0) as the separator.

Therefore:

```
find /tmp -type f -print0 | xargs -0 rm
```

correctly treats:

```
my application.log
server backup.log
```

### Easy Way to Remember
```
find -print0
      ↓
NULL-separated filenames
      ↓
xargs -0
      ↓
Correct command arguments
```

### Example
```
find /var/log -type f -name "*.log" -print0 | xargs -0 grep "ERROR"
```


----------------------------------------------------------------------------------------------
# SORT
sort is used to sort lines of text alphabetically, numerically, by columns, or in reverse order.

## Basic alphabetical sort
```
sort file.txt
```

## Reverse alphabetical sort
```
sort -r file.txt
```

## Numeric sort
```
sort -n numbers.txt
```

## Numeric reverse sort
```
sort -nr numbers.txt
```

## Sort by second column
```
sort -k2 file.txt
```

## Sort second column numerically
```
sort -k2 -n file.txt
```

## Sort second column numerically in descending order
```
sort -k2 -nr file.txt
```

## Sort using a specific delimiter
```
sort -t, -k2 -n users.csv
```

## Sort and remove duplicate lines
```
sort -u file.txt (or) sort file.txt | uninq
```

## Sort by human-readable sizes
```
sort -h sizes.txt
```


----------------------------------------------------------------------------------------------

# CUT

cut is used to extract specific columns, fields, or characters from text.


### ⭐ Most important options

```text
-d → Specify delimiter
-f → Select fields
-c → Select characters
```
## Extract first field using delimiter
```
cut -d: -f1 /etc/passwd
```

## Extract multiple fields
```
cut -d: -f1,3 /etc/passwd
```

## Extract a range of fields
```
cut -d: -f1-4 /etc/passwd
```

## Extract a specific field
```
cut -d: -f7 /etc/passwd
```

## Use comma as delimiter
```
cut -d, -f2 users.csv
```

## Extract multiple CSV columns
```
cut -d, -f1,3,5 users.csv
```

## Extract characters 1 to 5
```
cut -c1-5 file.txt
```

## Extract first character
```
cut -c1 file.txt
```

## Extract characters from position 5 onwards
```
cut -c5- file.txt
```

## Extract characters 1, 3 and 5
```
cut -c1,3,5 file.txt
```

## Extract username from /etc/passwd
```
cut -d: -f1 /etc/passwd
```

## Extract home directory from /etc/passwd
```
cut -d: -f6 /etc/passwd
```

## Extract shell from /etc/passwd
```
cut -d: -f7 /etc/passwd
```

## Extract username from email
```
echo "anand@example.com" | cut -d@ -f1
```

## Extract domain from email
```
echo "anand@example.com" | cut -d@ -f2
```

## Extract IP address from simple output
```
echo "IP: 192.168.1.10" | cut -d' ' -f2
```

## Combine with grep
```
grep "ERROR" app.log | cut -d' ' -f1
```

## Combine with sort and uniq
```
cut -d: -f7 /etc/passwd | sort | uniq -c
```

---------------------------------------------------------------------
# TEE
tee is used to display output on the terminal and save it to a file at the same time.

## Basic — Display and save
```
echo "Hello" | tee output.txt
```
## Append to file
```
echo "Hello" | tee -a output.txt
```

## Save command output
```
ls -l | tee files.txt
```

## Save output and continue the pipeline
```
df -h | tee disk.txt | grep "/dev"
```

## Save logs while displaying them
```
./script.sh 2>&1 | tee -a app.log
```

## Write to multiple files
```
echo "Hello" | tee file1.txt file2.txt
```

## Write to a protected file
```
echo "vm.swappiness=10" | sudo tee /etc/sysctl.conf
```

---------------------------------------------------------------------
# COUNT
wc (word count) is used to count lines, words, characters, and bytes.

## Count lines, words, and bytes
```
wc file.txt
```

## Count lines
```
wc -l file.txt
```

## Count words
```
wc -w file.txt
```

## Count characters
```
wc -m file.txt
```

## Count bytes
```
wc -c file.txt
```

## Count lines from command output
```
ps -ef | wc -l
```

## Example
```
grep "ERROR" application.log | wc -l
```