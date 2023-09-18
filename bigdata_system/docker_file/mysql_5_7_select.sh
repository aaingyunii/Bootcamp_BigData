#!/usr/bin/expect -f
expect << EOL
spawn dpkg -i /root/mysql-apt-config_0.8.12-1_all.deb
expect -re "Add repository to unsupported system?"
sleep 0.5
send "7\n"
sleep 0.5
expect -re "Which MySQL product do you wish to configure?"
sleep 0.5
send "1\n"
sleep 0.5
expect -re "Which server version do you wish to receive?"
sleep 0.5
send "1\n"
sleep 0.5
expect -re "Which MySQL product do you wish to configure?"
send "OK\n"
sleep 1
expect eof