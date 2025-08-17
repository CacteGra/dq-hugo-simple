---
title: "Setup A VPS, Secure SSH and Firewall (optional DNS redirecting)"
date: 2025-06-30
draft: false
tags: ["dev", "ssh"]
categories: ["tutorials"]
description: "How to configure your brand new Virtual Private Server with a secure access and a peace of mind."
---
### User setup
Username and password (received by email or via the hosting services console interface).
`adduser username`
Add it to *sudo group*:
`usermod -aG sudo username`

Remove old user:
`sudo deluser username`
Log in the new user
`su - username`
  
### Securing SSH
Now's the time to secure our SSH install to disallow anything but public key authentication.
Generate SSH key for the current user.
`ssh-keygen`
Ensure your user has the right permissions:
`chmod -R go= ~/.ssh`
`chown -R username:username ~/.ssh`
Then you'll want to edit SSH config file in order to secure your install:
`sudo nano /etc/ssh/sshd_config`
```
...
PermitRootLogin no
...
PubkeyAuthentication yes
...
PasswordAuthentication no
...
```
  
For extra security you can also change the port used to connect via SSH:
From `#Port 22`
To `Port 99`
  
Add your local machine *SSH key* to your VPS authorised keys:
`nano ~/.ssh/authorized_keys`
```bash
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDK5qMYLD27fPFEWPZRBHSGCJ+AQU1mezF9qFfnHEL7wq76mPY7ZAkzkF2RRUKdo0d8iCFKwlJbXHTiR01SmuL2SjuNcjeZt8w6ACcsa9ogBAsIuLuT/zChnBjLyk2GCRHNbIJBtP7TNSDOUQy+0RbARec+TGblW/ZGaSOLwd/YZQ== local_machine_name
```
  
### Firewalling
`sudo apt install ufw`
Then enter the following commands to set up your firewall:
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 22
sudo ufw enable
sudo ufw status verbose
sudo ufw allow http
sudo ufw allow https
sudo ufw reload
```
`sudo nano /etc/default/ufw`
```
Include IPV6 in the firewall rules
# Set to yes to apply rules
# to support IPv6 (no means only IPv6 on loopback accepted).
# You will need to 'disable' and then 'enable' the firewall for the changes to take affect.
IPV6=yes
```
Verify that hosts contains this configuration, editing */etc/hosts*:
```
127.0.0.1 localhost.localdomain localhost machine_name
127.0.1.1 machine_name
```
Then `/etc/hostname`:
`machine_name`
  
### Banning IPs trying to get inside your VPS
We can now install Fail2Ban in order to ban IP addresses trying to force their way onto our machines through SSH protocols.
```
sudo apt install fail2ban
sudo apt install sendmail
sudo sendmailconfig
```
Type "Y" to answer all questions
```
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo systemctl status fail2ban
```
Edit `/etc/fail2ban/jail.conf`

Under [sshd] add:
```
[sshd]
logpath = %(sshd_log)s
filter = sshd
backend = systemd
enabled = true
port = 22
destemail = root@<fq-hostname>
sender = root@<fq-hostname>
ignoreip = 127.0.0.1/8 # add any static IP address you will connect from
action = %(action_mwl)s
mta = sendmail
maxretry = 3
findtime = 300
bantime = 3600
```
`sudo systemctl restart fail2ban`
  
### Domain name
Now onto making your domain name stick to your IP address. This should work with any DNS service, however interface might differ. For this example we are setting it up on Porkbun.
Delete Porkbun records.
In your domain DNS manager:
Type A - Address record
Leave *Host* blank
Add the IP address of your server to *Answer* (that's what it's called on Porkbun):
xx.xx.xx.xx
Do the same again:
Type A - Address record
But for *Host* add:
*www*
And your server's IP address to *Answer*.
  
### Use a third-party to send emails with your domain for free
Zoho third party mail setup:
Select *MX* (Mail Exchange record), add to *Answer*:
mail (or whatever subdomain or even domain you want people to see in your email address)
And to *Priority*:
10
Do the same for mx2.zoho.eu with *Priority* 20 and mx3.zoho.eu with *Priority* 30
  
MX your_domain.extension mx2.zoho.eu 600 20
MX your_domain.extension mx3.zoho.eu 600 50
MX your_domain.extension mx.zoho.eu 600 10
Zoho will ask you to input new DNS records, *TXT - Text Record* in order to link various features of your Zoho email account to your domain.
If it does not work, retry again.
  
### Git configuration
```
git config --global user.name username
git config --global user.email username@email.com
```
 
