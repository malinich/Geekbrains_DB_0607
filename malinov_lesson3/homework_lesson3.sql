use vk;
alter table users add column updates_at datetime;
alter table users add column created_at  datetime;
# +----+-----------+----------+-------------------------------+------------+------------+------------+
# | id | firstname | lastname | email                         | phone      | updates_at | created_at |
# +----+-----------+----------+-------------------------------+------------+------------+------------+
# | 1  | May       | White    | kuvalis.estevan@example.com   | 1358760101 | <null>     | <null>     |
# | 2  | Ozella    | Gaylord  | rosenbaum.adeline@example.com | 0          | <null>     | <null>     |
# | 3  | Lacy      | Herman   | freida04@example.com          | 0          | <null>     | <null>     |
# | 4  | Omari     | Grant    | hamill.april@example.org      | 129876     | <null>     | <null>     |
# | 5  | Rosemarie | Luettgen | gaylord.drew@example.net      | 783        | <null>     | <null>     |
# +----+-----------+----------+-------------------------------+------------+------------+------------+

# ЗАДАНИЕ:
# Заполнить updated, created текущей датой и временем
update users set users.updates_at = now(), users.created_at = now();
# +----+-----------+----------+-------------------------------+------------+---------------------+---------------------+
# | id | firstname | lastname | email                         | phone      | updates_at          | created_at          |
# +----+-----------+----------+-------------------------------+------------+---------------------+---------------------+
# | 1  | May       | White    | kuvalis.estevan@example.com   | 1358760101 | 2019-06-14 20:46:53 | 2019-06-14 20:46:53 |
# | 2  | Ozella    | Gaylord  | rosenbaum.adeline@example.com | 0          | 2019-06-14 20:46:53 | 2019-06-14 20:46:53 |
# | 3  | Lacy      | Herman   | freida04@example.com          | 0          | 2019-06-14 20:46:53 | 2019-06-14 20:46:53 |
# | 4  | Omari     | Grant    | hamill.april@example.org      | 129876     | 2019-06-14 20:46:53 | 2019-06-14 20:46:53 |
# | 5  | Rosemarie | Luettgen | gaylord.drew@example.net      | 783        | 2019-06-14 20:46:53 | 2019-06-14 20:46:53 |
# +----+-----------+----------+-------------------------------+------------+---------------------+---------------------+

alter table users drop column updates_at;
alter table users drop column created_at ;

# ЗАДАНИЕ:
# updated, created были заполнены типом VARCHAR формат строки 20.10.2017 8:10
#  заполняем такие данные
alter table users add column updates_at varchar(255);
alter table users add column created_at  varchar(255);

update users set users.updates_at = '20.10.2017 8:10', users.created_at = '20.10.2017 18:10';
# +----+-----------+----------+-------------------------------+------------+-----------------+------------------+
# | id | firstname | lastname | email                         | phone      | updates_at      | created_at       |
# +----+-----------+----------+-------------------------------+------------+-----------------+------------------+
# | 1  | May       | White    | kuvalis.estevan@example.com   | 1358760101 | 20.10.2017 8:10 | 20.10.2017 18:10 |
# | 2  | Ozella    | Gaylord  | rosenbaum.adeline@example.com | 0          | 20.10.2017 8:10 | 20.10.2017 18:10 |
# | 3  | Lacy      | Herman   | freida04@example.com          | 0          | 20.10.2017 8:10 | 20.10.2017 18:10 |
# +----+-----------+----------+-------------------------------+------------+-----------------+------------------+

# updated, created конвертировать в DATETIME
update users set users.updates_at = STR_TO_DATE(users.updates_at, '%d.%m.%Y %H:%i'), users.created_at = STR_TO_DATE(users.created_at, '%d.%m.%Y %H:%i');
ALTER TABLE users MODIFY updates_at datetime;
ALTER TABLE users MODIFY created_at datetime;
# +----+-----------+----------+-------------------------------+------------+---------------------+---------------------+
# | id | firstname | lastname | email                         | phone      | updates_at          | created_at          |
# +----+-----------+----------+-------------------------------+------------+---------------------+---------------------+
# | 1  | May       | White    | kuvalis.estevan@example.com   | 1358760101 | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 |
# | 2  | Ozella    | Gaylord  | rosenbaum.adeline@example.com | 0          | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 |
# | 3  | Lacy      | Herman   | freida04@example.com          | 0          | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 |
# +----+-----------+----------+-------------------------------+------------+---------------------+---------------------+

# ЗАДАНИЕ:
# сортировка колонки value, 0 оставить в конце вывода данных
# подготовка
alter table users drop column value;
alter table  users add column  value int default 0;
update users set value = id % 6 ;

# Сортировка
select * from users order by  value=0, value;

# ЗАДАНИЕ:
# Извлечь пользователей родившихся в августе и мае
select  u.firstname, lower(date_format(birthday, '%M')) as month_day from profiles
left join users u on profiles.user_id = u.id
having month_day in ('may', 'august');
# +------------------------+-----------+
# | ANY_VALUE(u.firstname) | month_day |
# +------------------------+-----------+
# | Ellie                  | may       |
# | Ericka                 | august    |
# | Allene                 | august    |
# | Gwendolyn              | may       |
# +------------------------+-----------+

# ЗАДАНИЕ:
# из таблицы  извлечь записи при помощи запроса SELECT * from xxxx WHERE value  in (5,2,1)  Отсортировать  записи в заданном порядке в спике IN
select * from users where value in (5,2,1) order by value=5 desc, value=2 desc , value = 1 desc ;
# +----+-----------+-------------+--------------------------------+------------+---------------------+---------------------+-------+
# | id | firstname | lastname    | email                          | phone      | updates_at          | created_at          | value |
# +----+-----------+-------------+--------------------------------+------------+---------------------+---------------------+-------+
# | 77 | Arielle   | Schultz     | effie16@example.com            | 0          | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 | 5     |
# | 53 | Herbert   | Barton      | mcdermott.pete@example.net     | 1          | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 | 5     |
# | 5  | Rosemarie | Luettgen    | gaylord.drew@example.net       | 783        | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 | 5     |
# | 80 | Patricia  | Hilll       | jazlyn20@example.com           | 0          | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 | 2     |
# | 50 | Lamar     | Lueilwitz   | kemmer.kali@example.net        | 0          | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 | 2     |
# | 74 | Katelynn  | Weissnat    | webster47@example.net          | 630545     | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 | 2     |
# | 44 | Jannie    | Lueilwitz   | lhuels@example.org             | 2036263004 | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 | 2     |
# | 38 | Horacio   | Kling       | runolfsson.reagan@example.org  | 863450     | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 | 2     |
# | 43 | Gussie    | Gerlach     | mkozey@example.com             | 1          | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 | 1     |
# | 49 | Chadrick  | Hahn        | jabari.franecki@example.net    | 1          | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 | 1     |
# | 97 | Uriel     | Kunze       | randall.carroll@example.org    | 1          | 2017-10-20 08:10:00 | 2017-10-20 18:10:00 | 1     |
# +----+-----------+-------------+--------------------------------+------------+---------------------+---------------------+-------+

#  ЗАДАНИЕ
# Средний возраст пользователей
select  AVG( TIMESTAMPDIFF( YEAR , profiles.birthday, NOW())) as YEAR  from profiles
left join users u on profiles.user_id = u.id;
# +---------+
# | YEAR    |
# +---------+
# | 22.6900 |
# +---------+

#  ЗАДАНИЕ
# Посдчитать количество дней рождения , которые приходятся на каждую из дней недели.
select  date_format(profiles.birthday   , '%W') as week, COUNT(1) as  total from profiles
left join users u on profiles.user_id = u.id
group by week;
# +-----------+-------+
# | week      | total |
# +-----------+-------+
# | Thursday  | 11    |
# | Wednesday | 9     |
# | Saturday  | 17    |
# | Friday    | 15    |
# | Monday    | 21    |
# | Tuesday   | 14    |
# | Sunday    | 13    |
# +-----------+-------+

# ЗАДАНИЕ
#  Умножение значений в колонке
#  НЕТ (((