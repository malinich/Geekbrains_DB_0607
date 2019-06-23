use shop;
# ЗАДАНИЕ 1: ПОДГОТОВКА

select *
from orders_products;
# +----+----------+------------+-------+------------+------------+
# | id | order_id | product_id | total | created_at | updated_at |
# +----+----------+------------+-------+------------+------------+
select *
from orders;
# +----+---------+------------+------------+
# | id | user_id | created_at | updated_at |
# +----+---------+------------+------------+

insert into orders
values (NULL, 2, DEFAULT, DEFAULT),
       (NULL, 2, DEFAULT, DEFAULT),
       (NULL, 2, DEFAULT, DEFAULT),
       (NULL, 3, DEFAULT, DEFAULT);
# +----+---------+---------------------+---------------------+
# | id | user_id | created_at          | updated_at          |
# +----+---------+---------------------+---------------------+
# | 2  | 1       | 2019-06-23 12:06:33 | 2019-06-23 12:06:33 |
# | 3  | 2       | 2019-06-23 12:09:37 | 2019-06-23 12:09:37 |
# | 4  | 2       | 2019-06-23 12:09:37 | 2019-06-23 12:09:37 |
# | 5  | 2       | 2019-06-23 12:09:37 | 2019-06-23 12:09:37 |
# | 6  | 3       | 2019-06-23 12:09:37 | 2019-06-23 12:09:37 |
# +----+---------+---------------------+---------------------+


insert into orders_products
values (NULL, 2, 1, 10, default, default),
       (null, 3, 2, 3, default, default),
       (null, 4, 2, 3, default, default),
       (null, 5, 6, 3, default, default),
       (null, 6, 4, 8, default, default);
# +----+----------+------------+-------+---------------------+---------------------+
# | id | order_id | product_id | total | created_at          | updated_at          |
# +----+----------+------------+-------+---------------------+---------------------+
# | 1  | 2        | 1          | 10    | 2019-06-23 12:12:48 | 2019-06-23 12:12:48 |
# | 2  | 3        | 2          | 3     | 2019-06-23 12:12:48 | 2019-06-23 12:12:48 |
# | 3  | 4        | 2          | 3     | 2019-06-23 12:12:48 | 2019-06-23 12:12:48 |
# | 4  | 5        | 6          | 3     | 2019-06-23 12:12:48 | 2019-06-23 12:12:48 |
# | 5  | 6        | 4          | 8     | 2019-06-23 12:12:48 | 2019-06-23 12:12:48 |
# +----+----------+------------+-------+---------------------+---------------------+

# ЗАДАНИЕ 1:
# Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
select COUNT(1) as count, users.name
from orders
         left join users on orders.user_id = users.id
group by user_id
order by users.name;
# +-------+-----------+
# | count | name      |
# +-------+-----------+
# | 1     | Александр |
# | 1     | Геннадий  |
# | 3     | Наталья   |
# +-------+-----------+

# ЗАДАНИЕ 1:
# Выведите список товаров products и разделов catalogs, который соответствует товару
select products.id, products.name, catalog_id, catalogs.name
from products
         left join catalogs on products.catalog_id = catalogs.id;
# +----+-------------------------+------------+-------------------+
# | id | name                    | catalog_id | name              |
# +----+-------------------------+------------+-------------------+
# | 1  | Intel Core i3-8100      | 1          | Процессоры        |
# | 2  | Intel Core i5-7400      | 1          | Процессоры        |
# | 3  | AMD FX-8320E            | 1          | Процессоры        |
# | 4  | AMD FX-8320             | 1          | Процессоры        |
# | 5  | ASUS ROG MAXIMUS X HERO | 2          | Материнские платы |
# | 6  | Gigabyte H310M S2H      | 2          | Материнские платы |
# | 7  | MSI B250M GAMING PRO    | 2          | Материнские платы |
# +----+-------------------------+------------+-------------------+

# ЗАДАНИЕ 2 под *: ПОДГОТОВКА
drop table if exists cities;
create table cities
(
    label varchar(255) primary key,
    name  varchar(255)
);

drop table if exists flight;
create table flights
(
    id     serial,
    `from` VARCHAR(255) not null,
    `to`   VARCHAR(255) not null,
    FOREIGN KEY (`from`) REFERENCES cities (label),
    FOREIGN KEY (`to`) REFERENCES cities (label),
    CONSTRAINT flight_unq UNIQUE (`from`, `to`),
    CHECK ( `from` <> `to`)
);

insert into cities
values ('MSK', 'Москва'),
       ('KZN', 'Казань'),
       ('SPB', 'Питер'),
       ('VLG', 'Волгоград');
# +-------+-----------+
# | label | name      |
# +-------+-----------+
# | KZN   | Казань    |
# | MSK   | Москва    |
# | SPB   | Питер     |
# | VLG   | Волгоград |
# +-------+-----------+
insert flights
values (DEFAULT, 'MSK', 'KZN'),
       (DEFAULT, 'MSK', 'VLG'),
       (DEFAULT, 'MSK', 'SPB'),
       (DEFAULT, 'KZN', 'MSK'),
       (DEFAULT, 'SPB', 'MSK');
# +----+------+-----+
# | id | from | to  |
# +----+------+-----+
# | 4  | KZN  | MSK |
# | 1  | MSK  | KZN |
# | 3  | MSK  | SPB |
# | 2  | MSK  | VLG |
# | 5  | SPB  | MSK |
# +----+------+-----+

# ЗАДАНИЕ 2 под *:
# Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name).
# Поля from, to и label содержат английские названия городов, поле name — русское.
# Выведите список рейсов flights с русскими названиями городов.
select flights.id, c1.name, c2.name
from flights
         left join cities c1 on flights.`from` = c1.label
         left join cities c2 on flights.`to` = c2.label
order by flights.id;
# +----+--------+-----------+
# | id | name   | name      |
# +----+--------+-----------+
# | 1  | Москва | Казань    |
# | 2  | Москва | Волгоград |
# | 3  | Москва | Питер     |
# | 4  | Казань | Москва    |
# | 5  | Питер  | Москва    |
# +----+--------+-----------+
