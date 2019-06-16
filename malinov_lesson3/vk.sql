drop database if exists vk;
create database vk;
use vk;


drop table if exists users;
create table users
(
    id        serial primary key,
    firstname varchar(50),
    lastname  varchar(50),
    email     varchar(120) unique,
    phone     int,
    index users_phone_idx (phone),
    index users_firstname_lastname_idx (firstname, lastname)
);

drop table if exists `profiles`;
create table `profiles`
(
    user_id    serial primary key,
    gender     CHAR(1),
    birthday   DATE,
    created_at datetime default now(),
    hometown   varchar(100),
    foreign key (user_id) references users (id) on update CASCADE on DELETE restrict
);

drop table if exists messages;
create table messages
(
    id           serial primary key,
    from_user_id bigint unsigned not null,
    to_user_id   bigint unsigned not null,
    body         text,
    created_at   datetime default now(),
    index messages_from_user_id_idx (from_user_id),
    index messages_to_user_id_idx (to_user_id),
    foreign key (from_user_id) references users (id),
    foreign key (to_user_id) references users (id)
);

drop table if exists friend_requests;
create table friend_requests
(
--     id serial primary key,
    initiator_user_id bigint unsigned not null,
    target_user_id    bigint unsigned not null,
    `status`          enum ('requested', 'approved', 'unfriended', 'declined'),
    requested_at      datetime default now(),
    confirmed_at      datetime,

    index (initiator_user_id),
    index (target_user_id),
    primary key (initiator_user_id, target_user_id),
    foreign key (initiator_user_id) references users (id),
    foreign key (target_user_id) references users (id)
);

drop table if exists communities;
create table communities
(
    id   serial primary key,
    name varchar(150),
    index communities_name_idx (name)
);


drop table if exists user_communities;
create table user_communities
(
    user_id      bigint unsigned not null,
    community_id bigint unsigned not null,

    primary key (user_id, community_id),
    foreign key (user_id) references users (id),
    foreign key (community_id) references communities (id)

);


drop table if exists media_types;
create table media_types
(
    id         serial primary key,
    name       varchar(255),
    created_at datetime default now()
);

drop table if exists media;
create table media
(
    id            serial primary key,
    media_type_id bigint unsigned not null,
    user_id       bigint unsigned not null,
    filename      varchar(255),
    size          int,
    metadata      json,
    created_at    datetime default now(),
    updated_at    datetime default current_timestamp on update current_timestamp,

    index (user_id),
#     index (media_type_id),
    foreign key (user_id) references users (id),
    foreign key (media_type_id) references media_types (id)
);


drop table if exists likes;
create table likes
(
    id            serial primary key,
    user_id       bigint unsigned not null,
    to_subject_id int unsigned    not null,
    subject_type  enum ('user', 'post', 'video', 'message'),
    created_at    datetime default now()
);

alter table likes
    add constraint likes_users_fk
        foreign key (user_id) references vk.users (id);

alter table likes
    add constraint likes_media_fk
        foreign key (media_id) references vk.media (id);


--
select firstname, lastname, 'photo', 'city'
from users
where id = 1;
