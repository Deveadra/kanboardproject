#!/bin/bash

echo PubkeyAcceptedKeyTypes=+ssh-rsa >> /etc/ssh/sshd_config 

systemctl restart sshd
