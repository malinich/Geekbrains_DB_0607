-- Задание 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи
-- в таблицах users, catalogs и products в таблицу logs помещается время и дата
-- создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.
create table logs (
    id serial primary key,
    table_name NCHAR(255),
    table_pk BIGINT unsigned,
    description text,
    created datetime default NOW()
) engine = 'MyISAM';


create trigger mini_logger_users
    AFTER INSERT
    on shop.users
    FOR EACH ROW
BEGIN
    INSERT INTO logs values (DEFAULT, 'users', NEW.id, NEW.name, DEFAULT);
end;


create trigger mini_logger_catalogs
    AFTER INSERT
    on shop.catalogs
    FOR EACH ROW
BEGIN
    INSERT INTO logs values (DEFAULT, 'catalogs', NEW.id, NEW.name, DEFAULT);
end;


create trigger mini_logger_products
    AFTER INSERT
    on shop.products
    FOR EACH ROW
BEGIN
    INSERT INTO logs values (DEFAULT, 'products', NEW.id, NEW.name, DEFAULT);
end;


insert into shop.users values (default, 'test_trigger_username', '2019-010-01', DEFAULT, DEFAULT);
select  id, name from shop.users where name = 'test_trigger_username';
select * from logs;
# +----+------------+----------+-----------------------+---------------------+
# | id | table_name | table_pk | description           | created             |
# +----+------------+----------+-----------------------+---------------------+
# | 1  | users      | 7        | test_trigger_username | 2019-06-30 17:54:14 |
# +----+------------+----------+-----------------------+---------------------+

# Задание 2
#  Создайте SQL-запрос, который помещает в таблицу users миллион записей.
create function gen_name()
    returns char(8) deterministic
begin
    declare name char(8) default '';
    declare ch char(1) default '';
    cycling_name:
        loop
            select CHAR(97 + (rand() * 100) % 22) into ch;
            set name = concat(name, ch);
            if (LENGTH(name) >= 8) THEN
                leave cycling_name;
            end if;
        end loop cycling_name;
    return name;
end;


drop procedure if exists billion_users;
create procedure billion_users()
begin
    declare num int default 0;
while num <= 1000000
DO
    insert into shop.users values (DEFAULT, gen_name(), '2019-01-01', default, default);
    set num = num + 1;
    end WHILE;
end;

call billion_users();
select count(*) from shop.users;
# +----------+
# | count(*) |
# +----------+
# | 427746   |
# +----------+