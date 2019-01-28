create database duan default character set utf8 collate utf8_general_ci;
create user 'duan'@'%' identified by '1234';
grant select,insert,update,delete,create on duan.* to duan;
flush  privileges;