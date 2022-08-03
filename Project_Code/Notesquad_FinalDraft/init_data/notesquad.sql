SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = '';

SET default_with_oids = false;
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE;

CREATE EXTENSION pgcrypto;

DROP TABLE IF EXISTS notes CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS messages CASCADE;

CREATE TABLE IF NOT EXISTS users (
  user_id SERIAL PRIMARY KEY,
  username varchar(50) UNIQUE NOT NULL,
  full_name varchar(50),
  email varchar UNIQUE NOT NULL,
  pass_word varchar NOT NULL,
  account_type char(1) NOT NULL CHECK (account_type = 's' OR account_type = 'n'),
  is_admin boolean NOT NULL,
  university varchar(200) NOT NULL,
  -- Suppposedly have an array of notes via note_id here
  saved_notes integer[],
  about_me varchar(1000),
  courses varchar[]
);

CREATE TABLE IF NOT EXISTS notes (
  note_id SERIAL PRIMARY KEY,
  -- This is a file path (absolute or relative), that holds the path for the pdf
  filepath varchar(200) NOT NULL, 
  major varchar(30) NOT NULL,
  course_id char(8) NOT NULL,
  note_title varchar NOT NULL,
  semester date,
  reported boolean NOT NULL,
  note_user_id integer NOT NULL
);

CREATE TABLE IF NOT EXISTS messages (
  message_id SERIAL PRIMARY KEY,
  sender_id integer NOT NULL,
  reciever_id integer NOT NULL,
  body varchar(300) NOT NULL,
  creationDate DATE NOT NULL
);


CREATE TABLE "session" (
  "sid" varchar NOT NULL COLLATE "default",
	"sess" json NOT NULL,
	"expire" timestamp(6) NOT NULL
)
WITH (OIDS=FALSE);

ALTER TABLE "session" ADD CONSTRAINT "session_pkey" PRIMARY KEY ("sid") NOT DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX "IDX_session_expire" ON "session" ("expire");


ALTER TABLE "users" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "notes" ADD FOREIGN KEY ("note_user_id") REFERENCES "users" ("user_id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "messages" ADD FOREIGN KEY ("sender_id") REFERENCES "users" ("user_id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "messages" ADD FOREIGN KEY ("reciever_id") REFERENCES "users" ("user_id") ON UPDATE CASCADE ON DELETE CASCADE;

INSERT INTO users(username, full_name, email, pass_word, account_type, is_admin, university, saved_notes, about_me, courses)
VALUES ('user1','Sean', 'user1@email.com', crypt('user1password', gen_salt('bf')), 's', 'false', 'CU Boulder', ARRAY [1,6,4], 'Hello this is user1 I am very tired!', ARRAY ['CSCI']),
('user2', 'Cory' ,'user2@email.com', crypt('user2password', gen_salt('bf')), 'n', 'false', 'CU Boulder', ARRAY [2,6], 'Hello this is user2 I am very tired!', ARRAY ['CSCI']),
('user3', 'Ethan', 'user3@email.com', crypt('user3password', gen_salt('bf')), 's', 'false', 'CU Boulder', ARRAY [2,5], 'Hello this is user3 I am very tired!', ARRAY ['CSCI', 'ASTR']),
('user4', 'Grace','user4@email.com', crypt('user4password', gen_salt('bf')), 'n', 'false', 'CU Boulder', ARRAY [3], 'Hello this is user4 I am very tired!', ARRAY ['CSCI', 'ASTR']),
('admin', 'Mark' , 'admin@email.com', crypt('admin1password', gen_salt('bf')), 'n', 'true', 'CU Boulder', ARRAY [3], 'Hello this is the admin I am very tired!', NULL);;

INSERT INTO notes(filepath, major, course_id, note_title, semester, reported, note_user_id)
VALUES('/', 'Computer Science', 'CSCI3308', 'Software Dev Notes', '20210121', 'FALSE','3'),
('/', 'Computer Science', 'CSCI3308', 'Software Dev Notes2', '20210222', 'TRUE','1'),
('/', 'Computer Science', 'CSCI3302', 'Data Science', '20210323', 'FALSE','2'),
('/', 'Computer Science', 'CSCI1300', 'Intro to Computer Science', '20210120', 'TRUE','2'),
('/', 'Computer Science', 'CSCI3104', 'Algorithms', '20210424', 'FALSE','1'),
('/', 'Computer Science', 'CSCI2824', 'Linear Algebra', '20210525', 'TRUE','3');

INSERT INTO messages(sender_id, reciever_id, body, creationDate)
VALUES (1, 2, 'a message from 1 to 2', '20210421'), 
(2, 1, 'a message from 2 to 1', '20210422'),
(4, 5, 'a message from 4 to 5', '20210423'),
(5, 1, 'a message from 5 to 1', '20210424'),
(3, 4, 'a message from 3 to 4', '20210424'),
(2, 1, 'a message from 2 to 1', '20210425'),
(1, 2, 'a message from 1 to 2', '20210426'),
(4, 3, 'a message from 4 to 3', '20210427'),
(3, 4, 'a message from 3 to 4', '20210427'),
(5, 1, 'a message from 5 to 1', '20210428'),
(3, 1, 'a message from 3 to 1', '20210429'),
(4, 2, 'a message from 4 to 2', '20210430');


-- OLD STUFF

-- crypt('user1password', gen_salt('bf'))

-- ALTER TABLE "notes" ADD FOREIGN KEY ("note_id") REFERENCES "users" ("saved_notes");

-- ALTER TABLE "notes" ADD FOREIGN KEY ("note_id") REFERENCES "users" ("written_notes");

-- ALTER TABLE "users" ADD FOREIGN KEY ("user_id") REFERENCES "messages" ("sender_id");

-- ALTER TABLE "users" ADD FOREIGN KEY ("user_id") REFERENCES "messages" ("reciever_id");

-- ALTER TABLE "users" ADD FOREIGN KEY ("courses") REFERENCES "notes" ("course_id");

-- some queries using the crypto, it does work.
-- select user_id from users where email = 'user2@email.com' and pass_word = crypt('user2password',pass_word);
-- select * from users where email = 'user2@email.com' and pass_word = crypt('user2password',pass_word);
