# پروژه مدیریت پایگاه داده کتابخانه

1. نحوه اجرای پروژه با Docker
2. توضیح درباره ساختار جداول و روابط بین آن‌ها
3. دستورات تست برای عملیات CRUD با SQL

---

## 📦 اجرای پروژه با Docker

برای راه‌اندازی پایگاه داده PostgreSQL به همراه اجرای اسکریپت اولیه (`init.sql`) که شامل ساخت جدول‌ها و روابط است، ما از ابزار Docker استفاده می‌کنیم. این ابزار امکان اجرای برنامه‌ها در محیطی ایزوله را فراهم می‌سازد که وابستگی‌های سیستم میزبان را کاهش می‌دهد و راه‌اندازی پروژه را بسیار ساده‌تر می‌کند.

### 🔧 پیش‌نیازها

قبل از هر چیز، مطمئن شوید که ابزارهای زیر روی سیستم شما نصب شده‌اند:

* Docker
* Docker Compose

### 📁 ساختار پروژه

```
project-root/
├── docker-compose.yml
└── db/
    └── init.sql
```

### 🧾 محتویات فایل docker-compose.yml

```yaml
services:
  postgres:
    image: postgres:latest
    container_name: my_postgres
    environment:
      POSTGRES_USER: myuser
      POSTGRES_PASSWORD: mypassword
      POSTGRES_DB: mydb
    ports:
      - "5432:5432"
    volumes:
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

این فایل مشخص می‌کند که:

* از نسخه‌ای سبک از PostgreSQL (نسخه Alpine) استفاده می‌کنیم.
* اطلاعات مربوط به نام کاربری، رمز عبور و نام دیتابیس را تعیین می‌کنیم.
* فایل `init.sql` هنگام اجرای اولیه بارگذاری می‌شود و جداول را می‌سازد.
* داده‌ها در volume به‌نام `pgdata` ذخیره می‌شوند تا با هر بار راه‌اندازی، داده‌ها باقی بمانند.

### 🚀 اجرای سرویس

از طریق ترمینال، در مسیر ریشه‌ی پروژه، دستور زیر را اجرا کنید:

```bash
docker-compose up -d
```

برای مشاهده وضعیت اجرای سرویس:

```bash
docker-compose logs -f postgres
```

---

## 🧱 ساختار جداول و روابط بین آن‌ها

در فایل `init.sql`، ما چندین جدول اصلی برای مدیریت یک کتابخانه تعریف کرده‌ایم. این جدول‌ها به‌صورت زیر هستند:

### 1. جدول `author`

نماینده نویسندگان کتاب‌هاست:

```sql
CREATE TABLE author (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);
```

### 2. جدول `publisher`

اطلاعات ناشرین را ذخیره می‌کند:

```sql
CREATE TABLE publisher (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);
```

### 3. جدول `librarian`

مدیران کتابخانه را نگهداری می‌کند:

```sql
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
```

### 4. جدول `user`

نماینده کاربران یا اعضای کتابخانه است:

```sql
CREATE TABLE "user" (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  phone VARCHAR(20),
  email VARCHAR(100) UNIQUE,
  joined_at TIMESTAMP
);
```

### 5. جدول `user_address`

برای ثبت آدرس‌های کاربران استفاده می‌شود (با کلید مرکب):

```sql
CREATE TABLE user_address (
  user_id INTEGER NOT NULL,
  title VARCHAR(50),
  address TEXT,
  PRIMARY KEY (user_id, title),
  FOREIGN KEY (user_id) REFERENCES "user"(id) ON DELETE CASCADE
);
```

### 6. جدول `book`

اطلاعات کتاب‌ها را نگهداری می‌کند:

```sql
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
```

### 7. جدول `loan`

رابط بین کاربران، کتاب‌ها و کتابدار هنگام امانت گرفتن کتاب است:

```sql
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
```

---

## ✅ تست دستورات CRUD با SQL

در ادامه، نمونه‌هایی از دستورات SQL برای تست عملیات CRUD (ساخت، خواندن، ویرایش، حذف) را مشاهده می‌کنید.

### 📌 CREATE (درج داده)

```sql
-- افزودن نویسنده
INSERT INTO author (name) VALUES ('احمد محمود');

-- افزودن ناشر
INSERT INTO publisher (name) VALUES ('انتشارات نی');

-- افزودن کتابدار
INSERT INTO librarian (first_name, last_name, username, password)
VALUES ('رضا', 'کریمی', 'rezakr', 'secretpass');

-- افزودن کاربر
INSERT INTO "user" (first_name, last_name, email, joined_at)
VALUES ('سارا', 'قاسمی', 'sara@example.com', NOW());

-- افزودن آدرس برای کاربر
INSERT INTO user_address (user_id, title, address)
VALUES (1, 'خانه', 'تهران، خیابان آزادی');

-- افزودن کتاب
INSERT INTO book (author_id, publisher_id, title, publication_year, isbn, available_copies, added_by)
VALUES (1, 1, 'زوال کل', 2015, '9781234567890', 5, 1);

-- افزودن امانت
INSERT INTO loan (user_id, book_id, librarian_id, loan_date, due_date)
VALUES (1, 1, 1, NOW(), NOW() + INTERVAL '7 days');
```

---

### 📌 READ (خواندن داده)

```sql
-- مشاهده همه کتاب‌ها
SELECT * FROM book;

-- دریافت کتاب‌هایی که توسط کاربر خاصی امانت گرفته شده‌اند
SELECT b.title, l.loan_date, l.due_date
FROM loan l
JOIN book b ON l.book_id = b.book_id
WHERE l.user_id = 1;
```

---

### 📌 UPDATE (ویرایش داده)

```sql
-- افزایش تعداد نسخه‌های یک کتاب
UPDATE book SET available_copies = available_copies + 2 WHERE book_id = 1;

-- تغییر شماره تماس کاربر
UPDATE "user" SET phone = '09120001111' WHERE id = 1;
```

---

### 📌 DELETE (حذف داده)

```sql
-- حذف یک آدرس خاص کاربر
DELETE FROM user_address WHERE user_id = 1 AND title = 'خانه';

-- حذف کتابی خاص
DELETE FROM book WHERE book_id = 1;
```

---

## 📚 نتیجه‌گیری

با استفاده از Docker و PostgreSQL می‌توان به‌راحتی یک سیستم مدیریت کتابخانه را راه‌اندازی کرد. ساختار جداول به‌گونه‌ای طراحی شده که بتوان روابط بین نویسنده، ناشر، کتابدار، کاربر و کتاب را به خوبی نگهداری کرد. همچنین دستورات CRUD ارائه‌شده امکان تست این سیستم را به‌شکل کامل فراهم می‌کنند.

در صورت نیاز، می‌توان این پروژه را به یک رابط کاربری (مثلاً با Vue.js یا React) یا بک‌اند حرفه‌ای (مثلاً با Node.js یا Golang) متصل کرد.

---
