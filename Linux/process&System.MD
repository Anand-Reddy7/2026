# 1. Check load
uptime

# 2. Check CPU
top

# 3. Check memory
free -h

# 4. Check system pressure
vmstat 1 5

# 5. Find processes
ps aux --sort=-%cpu | head

# 6. Find high-memory processes
ps aux --sort=-%mem | head

# 7. Find a specific process
pgrep -a nginx

# 8. Inspect a specific PID
ps -p <PID> -o pid,ppid,user,%cpu,%mem,etime,cmd

# 9. Gracefully terminate
kill <PID>

# 10. Force terminate only if necessary
kill -9 <PID>