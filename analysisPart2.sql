-- SQL - Library Management System N2

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employee;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT ist.issued_id,m.member_name,bk.book_title,ist.issued_date, CURRENT_DATE - ist.issued_date AS overdue_days FROM issued_status AS ist
	INNER JOIN members AS m ON ist.issued_member_id=m.member_id
	INNER JOIN books AS bk ON ist.issued_book_isbn=bk.isbn
	LEFT OUTER JOIN return_status AS rst ON ist.issued_id=rst.issued_id
	WHERE rst.return_date IS NULL 
	AND (CURRENT_DATE-ist.issued_date)>30 ORDER BY 1;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
-- As soon as somebody adds a record in return_status, the status of the book in books table should be updated to yes
-- Can be done manually or by using stored procedures

-- Let's fist do for 1 record manually

SELECT * FROM issued_status WHERE issued_book_isbn='978-0-307-58837-1';

SELECT * FROM books WHERE isbn='978-0-307-58837-1';

UPDATE books SET status='no' WHERE isbn='978-0-451-52994-2';

SELECT * FROM return_status WHERE issued_id='IS130';

-- The books is not returned 
-- Let's say C106 has returned the book:
INSERT INTO return_status(return_id,issued_id,return_date,book_quality) VALUES ('RS125','IS130',CURRENT_DATE,'Good');
SELECT * FROM return_status WHERE issued_id='IS130';
-- But even after this, the status of this book in books table is still no. We need to manually override it
UPDATE books SET status='yes' WHERE isbn='978-0-451-52994-2';

-- Now all these tasks can be automated using stored procedures and triggers in PL/SQL

-- STORED PROCEDURES

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10),p_issued_id VARCHAR(10),p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$
	
DECLARE 
	v_isbn VARCHAR(30);
	v_book_name VARCHAR(75);
BEGIN 
	-- all your logic and code
	-- inserting into returns based on user input-params
	INSERT INTO return_status(return_id,issued_id,return_date,book_quality) VALUES(p_return_id,p_issued_id,CURRENT_DATE,p_book_quality);
	-- getting book's isbn from issued_status table
	SELECT issued_book_isbn,issued_book_name  INTO v_isbn, v_book_name FROM issued_status WHERE issued_id=p_issued_id;
	-- updating the status in books table
	UPDATE books SET status='yes' WHERE isbn=v_isbn;

	RAISE NOTICE 'Thank you for returning the book %' , v_book_name;
	
END;
$$

CALL add_return_records()


SELECT * FROM books;
SELECT * FROM return_status;
-- Finding non returned books
SELECT * FROM issued_status AS ist LEFT OUTER JOIN return_status AS rst ON rst.issued_id=ist.issued_id WHERE rst.return_id IS NULL;
-- We find IS135 is not yet retuned and status is no in books table
SELECT * FROM issued_status WHERE issued_id='IS135';

-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';     

-- calling function
CALL add_return_records('R138','IS135','Good');
--Let's check the status now:
SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';
-- It has 'yes'

SELECT * FROM books WHERE isbn='978-0-330-25864-8';
UPDATE books SET status= 'no' WHERE isbn='978-0-330-25864-8';

CALL add_return_records('RS148','IS140','Good');


-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

SELECT * FROM branch;
SELECT * FROM issued_status;
SELECT * FROM employee;
SELECT * FROM return_status;

CREATE TABLE branch_reports AS
SELECT b.branch_id,b.manager_id,SUM(bk.rental_price) AS total_revenue,COUNT(ist.issued_id) AS number_of_books_issued,COUNT(rst.return_id) AS number_of_books_returned FROM issued_status ist INNER JOIN employee e ON ist.issued_emp_id=e.emp_id
	INNER JOIN branch b ON e.branch_id=b.branch_id
	LEFT OUTER JOIN return_status rst ON rst.issued_id=ist.issued_id
	INNER JOIN books bk ON bk.isbn=ist.issued_book_isbn
	GROUP BY 1,2;

SELECT * FROM branch_reports;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

CREATE TABLE active_members AS 
SELECT * FROM issued_status;
SELECT * FROM members WHERE member_id IN
	(SELECT DISTINCT issued_member_id FROM issued_status WHERE (CURRENT_DATE-issued_date)<=60);

SELECT * FROM active_members;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT e.emp_name, b.*, COUNT(ist.issued_id) AS number_of_books_processed FROM issued_status ist INNER JOIN employee e ON ist.issued_emp_id=e.emp_id 
	INNER JOIN branch b ON e.branch_id=b.branch_id
	GROUP BY 1,2 ORDER BY number_of_books_processed DESC LIMIT 3;

-- Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
-- The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
-- If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

SELECT * FROM issued_status;
CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10),p_issued_member_id VARCHAR(10),p_issued_book_isbn VARCHAR(30),p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE
	v_status VARCHAR(10);
BEGIN
	-- Checking the current status of the book
	SELECT status INTO v_status FROM books WHERE isbn=p_issued_book_isbn;

	-- Writing conditional statements:

	IF v_status='yes' THEN
		INSERT INTO issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id) 
		VALUES(p_issued_id,p_issued_member_id,CURRENT_DATE,p_issued_book_isbn,p_issued_emp_id);

		UPDATE books SET status='no' WHERE isbn=p_issued_book_isbn;

		RAISE NOTICE 'Book records are sucessfully updated for isbn: %',p_issued_book_isbn;

	ELSE 
		RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;

	END IF;
END
$$

-- Testing the procedure
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';
SELECT * FROM books
WHERE isbn = '978-0-553-29698-2';

