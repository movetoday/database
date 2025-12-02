

show databases;
use mytest;
show tables;
select count(*) from users;


select * from users limit 3;

select * from users
where email= 'bgim@example.org';


create index idx_email on users(email);