-- Library Management System Project 2

-- Creating Branch table

DROP TABLE IF EXISTS branch;
CREATE TABLE branch(
	branch_id varchar(10) PRIMARY KEY,
	manager_id varchar(10),
	branch_address varchar(50),
	contact_no varchar(11)
);

ALTER TABLE branch ALTER COLUMN contact_no TYPE varchar(20);
-- Creating Employee table

DROP TABLE IF EXISTS employee;
CREATE TABLE employee(
	emp_id varchar(10) PRIMARY KEY,
	emp_name varchar(30),
	position varchar(30),
	salary int,
	branch_id varchar(10) --FK
);

-- Creating Books table

DROP TABLE IF EXISTS books;
CREATE TABLE books(
	isbn VARCHAR(30) PRIMARY KEY,
	book_title VARCHAR(75),
	catrgory VARCHAR(20),
	rental_price float,
	status VARCHAR(10),
	author VARCHAR(30),
	publisher VARCHAR(60)
	
);

ALTER TABLE books RENAME COLUMN catrgory TO category;

-- Creating members table
DROP TABLE IF EXISTS members;
CREATE TABLE members(
	member_id VARCHAR(10) PRIMARY KEY,
	member_name VARCHAR(30),
	member_address VARCHAR(50),
	reg_date DATE
);

-- Creating issued_status table
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status(
	issued_id VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(10), --FK
	issued_book_name VARCHAR(75),
	issued_date DATE,
	issued_book_isbn VARCHAR(30), --FK
	issued_emp_id VARCHAR(10) --FK
);

-- Creating return_status table
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status(
	return_id VARCHAR(10) PRIMARY KEY,
	issued_id VARCHAR(10),
	return_book_name VARCHAR(75),
	return_date DATE,
	return_book_isbn VARCHAR(30) --FK
);

-- Adding the FOREIGN KEYS

ALTER TABLE issued_status ADD CONSTRAINT fk_members FOREIGN KEY(issued_member_id) REFERENCES members(member_id);

ALTER TABLE issued_status ADD CONSTRAINT fk_books FOREIGN KEY(issued_book_isbn) REFERENCES books(isbn);

ALTER TABLE issued_status ADD CONSTRAINT fk_employee FOREIGN KEY(issued_emp_id) REFERENCES employee(emp_id);

ALTER TABLE employee ADD CONSTRAINT fk_branch FOREIGN KEY(branch_id) REFERENCES branch(branch_id);

ALTER TABLE return_status ADD CONSTRAINT fk_issued_status FOREIGN KEY(issued_id) REFERENCES issued_status(issued_id);
