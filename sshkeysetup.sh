#!/bin/bash

if [ -n "$1" ]; then
    IP=$1
else
    echo "Enter remote IP to setup"
    exit 1
fi

if [ -n "$2" ]; then
    USER=$2
else
    echo "Enter username as 2nd parameter"
    exit 1
fi

mkdir -p -m 700 ~/.ssh
rm -f ~/.ssh/$(whoami)_$IP
ssh-keygen -t rsa -f ~/.ssh/$(whoami)_$IP -N ''

eval $(ssh-agent)
echo $SSH_AUTH_SOCK
echo $SSH_AGENT_PID
ssh-add ~/.ssh/$(whoami)_$IP
ssh-keyscan -t rsa -H $IP >> ~/.ssh/known_hosts

echo "cat ~/.ssh/$(whoami)_$IP.pub | ssh $USER@$IP \"mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys\"" > keycopy.sh

chmod a+x keycopy.sh

read -s -p "Enter Password: " PASS

/usr/bin/expect -c '
spawn ./keycopy.sh
expect "password:"
send [lindex $argv 1]+"\n"
interact' $PASS

rm -f keycopy.sh

exit 0
