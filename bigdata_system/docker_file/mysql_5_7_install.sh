#!/usr/bin/expect  -f
expect << EOL
spawn apt install  mysql-client=5.7* mysql-community-server=5.7* mysql-server=5.7* -y
expect -re "Enter root password:"
sleep 1
send "1111\n"
sleep 1
expect -re "Re-enter root password:"
sleep 1
send "1111\n"
sleep 1

expect eof