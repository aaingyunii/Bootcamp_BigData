use mysql;

select user, host from user;

create user 'root'@'%' identified by '1234';
grant all privileges on *.* to 'root'@'%' with grant option;
flush privileges;