SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;


-- Project Task

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;


-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;


-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status
WHERE issued_id = 'IS121';

DELETE FROM issued_status
WHERE issued_id = 'IS121'



-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';


-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.



SELECT 
    ist.issued_emp_id,
     e.emp_name
    -- COUNT(*)
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
GROUP BY 1, 2
HAVING COUNT(ist.issued_id) > 1


-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE book_cnts
AS    
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;


SELECT * FROM
book_cnts;

-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books WHERE category='Mystery';

-- Task 8: Find Total Rental Income by Category:

SELECT b.category,SUM(b.rental_price),COUNT(*) FROM books b INNER JOIN issued_status ist ON b.isbn=ist.issued_book_isbn GROUP BY 1;

-- Task 9: List Members Who Registered in the Last 180 Days:

SELECT * FROM MEMBERS WHERE CURRENT_DATE-reg_date<=180;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT e1.emp_id,e1.emp_name,e1.position,e1.salary,b.*,e2.emp_name AS manager FROM employee e1 INNER JOIN branch b ON e1.branch_id=b.branch_id INNER JOIN employee e2 ON b.manager_id=e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE books_threshold AS
SELECT * FROM books WHERE rental_price>=6;
SELECT * FROM books_threshold;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT ist.* FROM issued_status AS ist LEFT OUTER JOIN return_status rst ON ist.issued_id=rst.issued_id WHERE return_id IS NULL;