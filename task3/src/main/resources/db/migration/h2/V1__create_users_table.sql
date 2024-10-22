CREATE TABLE users
(
    id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL

);

insert into users (name, email) values ('devops', 'test@test.test');