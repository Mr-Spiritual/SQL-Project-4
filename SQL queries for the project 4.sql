CREATE DATABASE project4_library_management_analysis;
USE project4_library_management_analysis;

SELECT * FROM issued_status;

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

-- 1. Retrieve All Books in a Specific Category
SELECT * FROM books
WHERE category = 'Horror'; -- Enter any category you are looking for

-- 2. Find Total Rental Income by Category
SELECT b.category, SUM(b.rental_price) AS rental_income, COUNT(*) AS issued_times
FROM books AS b
JOIN issued_status AS i
ON b.isbn = i.issued_book_isbn
GROUP BY 1;

-- 3. List Members Who Registered in the Last 180 Days
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE() - INTERVAL '180' DAY;

-- 4. List Employees with Their Branch Manager's Name and their branch details
SELECT e1.emp_id, e1.emp_name, e2.emp_name as manager, e1.position,  e1.salary, b.*
FROM employees as e1
JOIN  branch as b
ON e1.branch_id = b.branch_id    
JOIN employees as e2 
ON e2.emp_id = b.manager_id;

-- 5. Create a Table of Books with Rental Price Above a Certain Threshold (6 USD)
CREATE TABLE higher_range_books AS
SELECT * FROM books
WHERE rental_price > 6;

-- 6. Retrieve the List of Books Not Yet Returned
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

-- 7. Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.
SELECT m.member_id, m.member_name, b.book_title, ist.issued_date, DATEDIFF(CURDATE(), ist.issued_date) AS days_overdue  
FROM issued_status AS ist
JOIN members AS m
ON ist.issued_member_id = m.member_id
JOIN books AS b
ON ist.issued_book_isbn = b.isbn
LEFT JOIN return_status AS r
ON r.issued_id = ist.issued_id
WHERE 
	r.return_id IS NULL
	AND DATEDIFF(CURDATE(), ist.issued_date) > 30;

-- 8. Create a query that generates a performance report for each branch, 
-- showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
CREATE TABLE branch_reports
AS
SELECT b.branch_id, b.manager_id, COUNT(ist.issued_id) as number_book_issued, 
COUNT(rs.return_id) as number_of_book_return, SUM(bk.rental_price) as total_revenue
FROM issued_status as ist JOIN employees as e
ON e.emp_id = ist.issued_emp_id
JOIN branch as b
ON e.branch_id = b.branch_id
LEFT JOIN return_status as rs
ON rs.issued_id = ist.issued_id
JOIN  books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

-- 9. Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.
SELECT b.branch_id, e.emp_name, COUNT(ist.issued_id) AS no_of_issued_books
FROM employees AS e
JOIN branch AS b
ON e.branch_id = b.branch_id
JOIN issued_status AS ist
ON e.emp_id = ist.issued_emp_id
GROUP BY 1,2
ORDER BY COUNT(ist.issued_id) DESC;
