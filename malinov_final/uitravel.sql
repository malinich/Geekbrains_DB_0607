# Сайт о путшествии, где любой желающий может поделиться о своих подвигах.
# drop database uitravel;
# create database uitravel;
use uitravel;
drop table if exists user;
create table user(
    id serial primary key,
    username char(63) not null,
    password char (127) not null comment 'crypt password on app layer',
    created DATETIME default CURRENT_TIMESTAMP
);

drop table if exists profile;
create table profile (
    user_id bigint unsigned primary key,
    fio char(255),
    birth DATE,
    city char(255),
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists media;
create table media(
    id serial primary key,
    user_id bigint unsigned,
    type enum ('photo', 'video') not null,
    filename char(255) not null,
    metadata json,
    created DATETIME default current_timestamp,

    foreign key (user_id) REFERENCES user(id) on DELETE SET NULL
);

drop table if exists point;
create table point (
    id serial primary key,
    name CHAR(255) not null,
    user_id bigint unsigned not null,
    geo_meta json,

    FOREIGN KEY (user_id) REFERENCES user(id) on DELETE CASCADE
);

drop table if exists point_path;
create table point_path(
    id serial primary key,
    parent_point bigint unsigned not null
        COMMENT 'Проверка на цикличность на стоороне приложения (допущение только для текущего задания)',
    next_point bigint unsigned not null,
    created DATETIME default current_timestamp,

    foreign key (parent_point) REFERENCES point(id) on DELETE cascade,
    foreign key (next_point) REFERENCES point(id) on DELETE cascade,
    CHECK ( parent_point <> next_point )
);

drop table if exists point_mediateka;
create table point_mediateka(
    id serial primary key,
    content text,
    point_path_id bigint unsigned not null,
    media_point_id  bigint unsigned not null,

    foreign key (point_path_id) REFERENCES point_path(id) on DELETE CASCADE,
    foreign key (media_point_id) REFERENCES media(id) on DELETE cascade
);

drop table if exists blog;
create table blog(
    id serial primary key,
    author bigint unsigned not null,
    content text not null,
    created datetime default current_timestamp,

    foreign key (author) references user(id) on DELETE cascade
);

drop table if exists blog_points;
create table blog_points(
    id serial primary key ,
    blog_id bigint unsigned not null ,
    point_id bigint unsigned not null ,

    foreign key (blog_id) references blog(id) on DELETE cascade ,
    foreign key (point_id) references point(id) on DELETE cascade
);

drop table if exists comment;
create table comment(
    id serial primary key ,
    author_id bigint unsigned ,
    blog_id bigint unsigned not null,
    content text not null ,
    created datetime default current_timestamp,

    foreign key (author_id) references user(id) on DELETE set null ,
    foreign key (blog_id) references blog(id) on DELETE cascade

);

drop table if exists followers;
create table followers (
    id serial primary key ,
    follower_id bigint unsigned not null ,
    person_id bigint unsigned not null,

    foreign key (follower_id) references user(id) on DELETE cascade ,
    foreign key (person_id) references user(id) on DELETE cascade,
    constraint follower_unq UNIQUE  (follower_id, person_id),
    check ( person_id <> follower_id )
);

drop table if exists message;
create table message(
    id serial primary key,
    author_id bigint unsigned COMMENT 'author может быть null в случае,
                                        если это системное сообщение, в приложении
                                        должно это значение быть обязательно',
    target_id bigint unsigned not null,
    content text,
    created datetime default current_timestamp,

    foreign key (author_id) references user(id) on DELETE cascade ,
    foreign key (target_id) references user(id) on DELETE cascade

);

# triggers
# Автосоздание профеля при создании пользователя.
drop trigger if exists trigger_profile_auto_create;
create trigger trigger_profile_auto_create after insert on user
    for each row
    begin
        insert into profile values (NEW.id, NULL, NULL, null);
    end;

# Создание сообщения об уведомлении о том что путешественник (на которого вы подписанны)
# написал блог
drop trigger if exists new_blog;
create trigger new_blog after INSERT on blog
    for each row
    begin
        declare cursor_follower bigint;
        declare cursor_fio char(255);
        declare is_end int default 0;

        declare cur cursor for
            select follower_id, fio from followers
            left join profile on profile.user_id=followers.person_id
            where person_id = NEW.author;

        declare continue handler for NOT FOUND  set is_end = 1;

        OPEN cur;

        cycle: LOOP
            fetch cur INTO cursor_follower, cursor_fio;
            IF is_end THEN LEAVE cycle; END IF;
            insert into message values (DEFAULT, null, cursor_follower, CONCAT('Новая запись на стене ', cursor_fio), DEFAULT);

        end loop cycle;

        close cur;
    end;

# Самые активные авторы
select author, count(*) as count from blog group by author order by count desc LIMIT 5;
# +--------+-------+
# | author | count |
# +--------+-------+
# | 20     | 7     |
# | 12     | 6     |
# | 30     | 6     |
# | 15     | 6     |
# | 24     | 5     |
# +--------+-------+

# Самые популярные путешественники (на них больше всего подписанно людей)
select person_id, count(follower_id) c from followers group by person_id order by c desc LIMIT 5;
# +-----------+---+
# | person_id | c |
# +-----------+---+
# | 18        | 6 |
# | 19        | 6 |
# | 21        | 6 |
# | 24        | 5 |
# | 5         | 5 |
# +-----------+---+

# Hot Blog
select blog.id, count(c.blog_id) as comments_count from blog
left join comment c on blog.id = c.blog_id
group by blog.id, c.blog_id
order by comments_count desc limit 5;
# +----+----------------+
# | id | comments_count |
# +----+----------------+
# | 53 | 4              |
# | 45 | 3              |
# | 98 | 3              |
# | 35 | 3              |
# | 89 | 3              |
# +----+----------------+

# Самые активные пользователи
select  c.author_id, count(1) as comments_count from blog
    inner join comment c on blog.id = c.blog_id
group by c.author_id order by comments_count desc limit 5;

# +-----------+----------------+
# | author_id | comments_count |
# +-----------+----------------+
# | 6         | 7              |
# | 22        | 7              |
# | 29        | 5              |
# | 2         | 5              |
# | 20        | 5              |
# +-----------+----------------+

# длина маршрутов (логика не доработана.)
drop procedure if exists long_path;
CREATE procedure long_path() READS SQL DATA
BEGIN
    declare is_end int default 0;
    declare cur_point_id bigint unsigned;

    declare cur cursor for SELECT id from point_path;
    declare continue handler for NOT FOUND set is_end = 1;

    open cur;

    cycle: loop
        fetch cur into cur_point_id;
        select cur_point_id;
            IF is_end THEN LEAVE cycle; END IF;
            with RECURSIVE path_path AS (
                (select id, parent_point,  next_point from point_path where id = cur_point_id ORDER BY id)
                UNION ALL
                select p.id, p.parent_point, p.next_point from point_path p join path_path on path_path.next_point = p.parent_point
                )
            select * from path_path;
    end loop cycle;
    close cur;
end;


call long_path()
# +----+--------------+------------+
# | id | parent_point | next_point |
# +----+--------------+------------+
# | 56 | 91           | 87         |
# | 2  | 87           | 49         |
# | 84 | 87           | 97         |
# | 99 | 87           | 85         |
# | 10 | 49           | 22         |
# | 80 | 85           | 1          |
# +----+--------------+------------+