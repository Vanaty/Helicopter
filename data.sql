create database helicopter;
use helicopter;
create table obstacle(
    id SERIAL PRIMARY KEY,
    x1 INT,
    y1 INT,
    x2 INT,
    y2 INT,
    x3 INT,
    y3 INT,
    x4 INT,
    y4 INT
);
insert into obstacle values(default, 100, 100, 150, 100, 150, 800, 100, 800);
insert into obstacle values(default, 300, 70, 350, 70, 350, 800, 300, 800);
insert into obstacle values(default, 500, 70, 550, 70, 550, 800, 500, 800);
create table heliport(
    id SERIAL PRIMARY KEY,
    x INT,
    y INT
);
insert into heliport values(default, 50, 400);
insert into heliport values(default, 650, 200);

create table helicopter(
    id SERIAL PRIMARY KEY,
    x INT,
    y INT    
);
insert into helicopter values(default,30,400);
update helicopter set x=30,y=400;

create table tank(
    id SERIAL PRIMARY KEY,
    point INT default 0,
    x INT,
    y INT
);
insert into tank values(default,1, 600, 585);
insert into tank values(default,20, 400, 585);
insert into tank values(default,50, 200, 585);
insert into tank values(default,90, 35, 585);
update tank set y=585;