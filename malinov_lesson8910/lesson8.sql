# Задание 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие,
# в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна возвращать
# фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
# с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи"

drop function if exists hello;
create function hello()
    returns VARCHAR(255) DETERMINISTIC
begin
    declare cur_hour int default HOUR(
            CONVERT_TZ(UTC_TIMESTAMP(), 'UTC', 'Europe/Moscow'));

    If (6 <= cur_hour and cur_hour <= 12) THEN
        return 'Доброе Утро';
    ELSEIF (12 < cur_hour and cur_hour <= 18) THEN
        return 'Добрый День';
    ELSEIF (18 < cur_hour OR cur_hour = 0) THEN
        return 'Добрый вечер';
    ELSEIF (0 < cur_hour and cur_hour <= 6) THEN
        return 'Доброй ночи';
    ELSE
        return '';
    end if;
end;

set timestamp = 1561886964; -- 12 MSK
select hello();
# +-------------+
# | hello()     |
# +-------------+
# | Доброе Утро |
# +-------------+

set timestamp = 1561901364; -- 16 MSK
select hello();
# +-------------+
# | hello()     |
# +-------------+
# | Добрый День |
# +-------------+

set timestamp = 1561912164; -- 19:29 MSK
select hello();
# +--------------+
# | hello()      |
# +--------------+
# | Добрый вечер |
# +--------------+

set timestamp = 1561930164; -- 0:29 MSK
select hello();
# +--------------+
# | hello()      |
# +--------------+
# | Добрый вечер |
# +--------------+

set timestamp = 1561854564; -- 3:29 MSK
select hello();
# +-------------+
# | hello()     |
# +-------------+
# | Доброй ночи |
# +-------------+
set timestamp  = default;

# Задание 2. В таблице products есть два текстовых поля: name с названием товара и
# description с его описанием. Допустимо присутствие обоих полей или одно из них.
# Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.
# Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были
# заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию
drop trigger if exists product_require_desc_or_name;
create TRIGGER product_require_desc_or_name BEFORE INSERT on products
    for each row
    begin
        IF(NEW.name is NULL and NEW.description is NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NOT ALLOW both `name` and `desc` to be NULL';
        END IF;
END;

select id, products.name, products.description from products;
# +----+-------------------------+-----------------------------------------------------------------------------------+
# | id | name                    | description                                                                       |
# +----+-------------------------+-----------------------------------------------------------------------------------+
# | 1  | Intel Core i3-8100      | Процессор для настольных персональных компьютеров, основанных на платформе Intel. |
# | 2  | Intel Core i5-7400      | Процессор для настольных персональных компьютеров, основанных на платформе Intel. |
# | 3  | AMD FX-8320E            | Процессор для настольных персональных компьютеров, основанных на платформе AMD.   |
# | 4  | AMD FX-8320             | Процессор для настольных персональных компьютеров, основанных на платформе AMD.   |
# | 5  | ASUS ROG MAXIMUS X HERO | Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX        |
# | 6  | Gigabyte H310M S2H      | Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX            |
# | 7  | MSI B250M GAMING PRO    | Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX             |
# | 8  | my name 1               | my description                                                                    |
# | 9  | <null>                  | my description                                                                    |
# +----+-------------------------+-----------------------------------------------------------------------------------+
INSERT into products values (DEFAULT, NULL, NULL, 9000, 1, DEFAULT, DEFAULT);
# (1644, 'NOT ALLOW both `name` and `desc` to be NULL')


# Задача 3. Функция Фибоначчи
drop function if exists fibonacci;
-- Формула Бине
create function fibonacci(num int)
    returns int DETERMINISTIC

BEGIN
    if (num <= 0) THEN
        return 0;
    ELSEIF (num = 1) THEN
        return 1;
    ELSE
        return (
            POW(((1 + sqrt(5)) / 2), num) +
            POW(((1 - sqrt(5)) / 2), num)
        ) / SQRT(5);
    end if;
end;

select fibonacci(10);
# +---------------+
# | fibonacci(10) |
# +---------------+
# | 55            |
# +---------------+
