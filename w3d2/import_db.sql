CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255),
  body VARCHAR(255) NOT NULL,
  author_id VARCHAR(255) NOT NULL,
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_followers (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body VARCHAR(255) NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Ronda', 'Rousey'),
  ('Julie', 'Andrews'),
  ('Barack', 'Obama');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Lorem Ipsim', 'Lorem Ipsim', (SELECT id FROM users WHERE fname = 'Julie')),
  ('Super Bowl', 'Matchup?', (SELECT id FROM users WHERE fname = 'Ronda'));

INSERT INTO
  question_followers (user_id, question_id)
VALUES
  ((SELECT id FROM users where fname = 'Barack'), (SELECT id FROM questions where title = 'Lorem Ipsim')),
  ((SELECT id FROM users where fname = 'Barack'), (SELECT id FROM questions where title = 'Super Bowl')),
  ((SELECT id FROM users where fname = 'Ronda'), (SELECT id FROM questions where title = 'Lorem Ipsim'));


INSERT INTO
    replies (question_id, parent_id, user_id, body)
VALUES
    ((SELECT id FROM questions where title = 'Super Bowl'), NULL,
    (SELECT id FROM users WHERE fname = 'Barack'), 'Seahawks vs. Ravens?');

    INSERT INTO
    replies (question_id, parent_id, user_id, body)
    VALUES
    ((SELECT id FROM questions where title = 'Super Bowl'),
    (SELECT id FROM replies WHERE body = 'Seahawks vs. Ravens?'),
    (SELECT id FROM users WHERE fname = 'Ronda'), 'No way!');

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users where fname = 'Barack'),
  (SELECT id FROM questions where title = 'Lorem Ipsim')),
  ((SELECT id FROM users where fname = 'Ronda'),
  (SELECT id FROM questions where title = 'Lorem Ipsim')),
  ((SELECT id FROM users where fname = 'Barack'),
  (SELECT id FROM questions where title = 'Super Bowl'));
