## Netcat
```
nc -zv <IP> <PORT>
-z → Just scan/check the port; don't send data
-v → Verbose; show what is happening
```
```
nc -zv 10.10.10.20 8080
O/p:
Connection to 10.10.10.20 8080 port [tcp/*] succeeded!
```

```
Your Server ─────TCP 8080─────> Remote Server
             ✅ reachable
```

## Telnet
```
telnet 10.10.10.20 8080
```

## CURL
```
curl -v http://<IP>:<PORT>\
```


| Tool     | Use                                |
| -------- | ---------------------------------- |
| `nc`     | ⭐ Modern/general network debugging |
| `telnet` | Simple TCP connectivity testing    |
| `curl`   | HTTP/HTTPS application testing     |


## SS

ss means Socket Statistics. It is used to inspect network sockets, listening ports, active connections, TCP/UDP connections, and the processes using them. It is the modern replacement commonly used instead of netstat.

```
ss -lntp

-l → listening
-n → numeric IP/port
-t → TCP
-p -> Process
```

### TCP connection summary
```
ss -s
-s displays summary statistics.
```

```
[root@anand-vsi-dnd ~]# ss -s
Total: 132
TCP:   7 (estab 1, closed 0, orphaned 0, timewait 0)

Transport Total     IP        IPv6
RAW       1         0         1        
UDP       4         3         1        
TCP       7         5         2        
INET      12        8         4        
FRAG      0         0         0  
```