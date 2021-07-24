---
- hosts: localhost
  become: yes

  vars:
    configfile: /root/.ssh/config
    marker: "Auto Terraform"
    sshkey: /etc/keys/ssh-key01.key
    sshname: aws
    user: ubuntu
    pub_ip: ${ip}

  tasks:
  - name: Create SSH config file if not exists
    file:
      path: "{{ configfile }}"
      mode: 0644
      state: touch

  - name: Add VM connection to the SSH config
    blockinfile:
      dest: "{{configfile}}"
      marker: "# {mark} {{ marker }}"
      block: |
        Host {{ sshname }}
          User {{user}}
          StrictHostKeyChecking no
          IdentityFile {{ sshkey }}
          Hostname {{ pub_ip }}
          Port 22

