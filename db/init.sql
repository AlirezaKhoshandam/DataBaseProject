CREATE TABLE author (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE publisher (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE librarian (
  librarian_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  phone VARCHAR(20),
  username VARCHAR(50) UNIQUE,
  password VARCHAR(100),
  role VARCHAR(20) DEFAULT 'admin',
  hire_date TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE "user" (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  phone VARCHAR(20),
  email VARCHAR(100) UNIQUE,
  joined_at TIMESTAMP
);

CREATE TABLE user_address (
  user_id INTEGER NOT NULL,
  title VARCHAR(50),
  address TEXT,
  PRIMARY KEY (user_id, title),
  FOREIGN KEY (user_id) REFERENCES "user"(id) ON DELETE CASCADE
);

CREATE TABLE book (
  book_id SERIAL PRIMARY KEY,
  author_id INTEGER NOT NULL,
  publisher_id INTEGER NOT NULL,
  title VARCHAR(200),
  publication_year INTEGER,
  isbn VARCHAR(20) UNIQUE NOT NULL,
  available_copies INTEGER DEFAULT 0,
  added_by INTEGER,
  FOREIGN KEY (author_id) REFERENCES author(id) ON DELETE CASCADE,
  FOREIGN KEY (publisher_id) REFERENCES publisher(id) ON DELETE CASCADE,
  FOREIGN KEY (added_by) REFERENCES librarian(librarian_id) ON DELETE SET NULL
);

CREATE TABLE loan (
  loan_id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  book_id INTEGER NOT NULL,
  librarian_id INTEGER,
  loan_date TIMESTAMP NOT NULL,
  due_date TIMESTAMP NOT NULL,
  return_date TIMESTAMP,
  status VARCHAR(20) DEFAULT 'loan',
  FOREIGN KEY (user_id) REFERENCES "user"(id) ON DELETE CASCADE,
  FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
  FOREIGN KEY (librarian_id) REFERENCES librarian(librarian_id) ON DELETE SET NULL
);
