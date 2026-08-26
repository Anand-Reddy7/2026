## What is --start-at-task

Suppose your playbook contains:

```
1. Install packages
2. Create users
3. Configure Nginx
4. Deploy application
5. Restart service
6. Health check
```

The playbook fails at:
```
4. Deploy application
```

You fix the problem.

Instead of running everything again:

```
ansible-playbook deploy.yml
```

you can start from:
```
ansible-playbook deploy.yml --start-at-task "Deploy application"
```

Ansible starts execution from that named task.

Important limitation:

```
- This won't work with the blocks. inside the block tasks it works
- It isn't a universal checkpoint/resume mechanism. Dependencies or state from earlier tasks may still be required.
```

## Differences ?
```
serial
    → controls rollout size

max_fail_percentage
    → controls failure threshold

health check
    → validates application

rescue/rollback
    → recovers from failure
```

## Fork Vs Serial

forks controls how many hosts Ansible can process concurrently for performance, while serial controls how many hosts participate in each deployment batch for controlled rolling deployments. For example, with 1,000 servers, I might configure forks=50 and serial=20; Ansible deploys 20 servers at a time, while the available forks determine how many of those hosts can be processed concurrently."

```
- name: Production Application Deployment
  hosts: web_servers
  become: true
  serial: 20

  tasks:
    - name: Deploy application
      ansible.builtin.copy:
        src: app.tar.gz
        dest: /opt/app/app.tar.gz
```