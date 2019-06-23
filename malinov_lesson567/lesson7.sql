# ЗАДАНИЕ 1
# Создайте двух пользователей которые имеют доступ к базе данных shop.
# Первому пользователю shop_read должны быть
# доступны только запросы на чтение данных, второму пользователю shop
# — любые операции в пределах базы данных shop.
create USER shop_read IDENTIFIED with sha256_password by 'pass';
create USER shop IDENTIFIED with sha256_password by 'pass';

GRANT SELECT on shop.* to shop_read;
GRANT ALL on shop.* to shop_read;

show grants for 'shop';
# +----------------------------------+
# | Grants for shop@%                |
# +----------------------------------+
# | GRANT USAGE ON *.* TO `shop`@`%` |
# +----------------------------------+
show grants for 'shop_read';
# +-----------------------------------------------------+
# | Grants for shop_read@%                              |
# +-----------------------------------------------------+
# | GRANT USAGE ON *.* TO `shop_read`@`%`               |
# | GRANT ALL PRIVILEGES ON `shop`.* TO `shop_read`@`%` |
# +-----------------------------------------------------+

# ЗАДАНИЕ 2*
# Пусть имеется таблица accounts содержащая три столбца id, name, password,
# содержащие первичный ключ, имя пользователя и его пароль.
# Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name.
# Создайте пользователя user_read, который бы не имел доступа к таблице accounts,
# однако, мог бы извлекать записи из представления username.

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts
(
    id       SERIAL PRIMARY KEY,
    name     varchar(255),
    password varchar(255)
);

create view username as (
    select id, name
    from accounts
);
create user user_read IDENTIFIED with sha256_password by 'pass';
grant usage ON *.*  to user_read;
grant select on shop.username to user_read;

# mycli -u user_read
# \u shop;
select * from accounts;
# (1142, "SELECT command denied to user 'user_read'@'172.17.0.1' for table 'accounts'")
select * from username;
# +----+------+
# | id | name |
# +----+------+

