insert into users (email, password) values
('foo', 'foo'), ('bar', 'bar'), ('baz', 'baz'), ('quux', 'quux');

insert into submissions (userid, time, problem, result) values
(1, 1, 0, 0),
   (1, 2, 0, 0),
   (2, 2, 0, 0),
   (3, 3, 0, 0),
   (4, 3, 0, 0),

   (2, 10, 0, 1),
   (2, 12, 0, 1),
   (4, 13, 0, 1),
   (1, 15, 0, 1),

   (1, 17, 1, 0),
   (3, 18, 1, 0),
   (2, 20, 1, 0),

   (4, 25, 1, 1),
   (1, 26, 1, 1),
   (1, 27, 1, 1),
   (3, 30, 1, 1),
   (2, 35, 1, 1),

   (4, 40, 2, 0),
   (4, 45, 2, 1),
   (3, 46, 2, 0),
   (3, 50, 2, 0),
   (2, 52, 2, 1),
   (2, 55, 2, 0),
   (1, 57, 2, 1),
   (3, 60, 2, 1);
