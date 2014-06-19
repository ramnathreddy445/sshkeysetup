#!/bin/bash

if [[ "$#" < 1 || "$#" > 2 ]]; then
    echo "Enter Username and IP in the form:"
    echo './sshkeysetup.sh "user@ip"'
    echo "or"
    echo './sshkeysetup.sh user ip'
    exit 1
fi

if [ "$#" == 1 ]; then
    USER=$(echo $1 | cut -d '@' -f 1)
    IP=$(echo $1 | cut -d '@' -f 2)
else
    USER=$1
    IP=$2
fi

echo "User: $USER"
echo "IP: $IP"

mkdir -p -m 700 ~/.ssh
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "No rsa keys found"
    ssh-keygen -t rsa -f ~/.ssh/ -N ''
fi

eval $(ssh-agent)
echo $SSH_AUTH_SOCK
echo $SSH_AGENT_PID
ssh-keyscan -t rsa -H $IP >> ~/.ssh/known_hosts

echo "cat ~/.ssh/id_rsa.pub | ssh $USER@$IP \"mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys\"" > keycopy.sh

chmod a+x keycopy.sh

read -s -p "Enter Password: " PASS
cat > tmp.exp << END
#!/usr/bin/expect
set pass [lindex $argv 0]
spawn ./keycopy.sh
expect "password:"
send "$pass\n"
interact
END
chmod a+x tmp.exp
echo "Transfering keys now"
./tmp.exp $PASS
rm -f keycopy.sh
rm -f tmp.exp
echo "Transfer complete."
ssh-add 
exit 0
