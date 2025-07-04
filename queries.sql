-- 1. Simple queries (can run very fast)
-- 1.1 Query by primary key
SELECT * FROM employees WHERE emp_no = 10001;

-- 1.2 Query by indexed foreign key
SELECT * FROM salaries WHERE emp_no = 10001;

-- 1.3 Query using LIKE (still fast if few records)
SELECT * FROM employees WHERE first_name LIKE 'Ge%';


-- 2. JOIN queries (medium to heavy)
-- 2.1 JOIN 2 tables (salaries and employees)
SELECT e.first_name, e.last_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.salary > 60000;

-- 2.2 JOIN 3 tables with WHERE condition
SELECT e.first_name, d.dept_name, de.from_date
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
WHERE de.to_date > '2000-01-01';

-- 2.3 JOIN with complex filter condition
SELECT e.first_name, d.dept_name, t.title
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
JOIN titles t ON e.emp_no = t.emp_no
WHERE t.title LIKE '%Engineer%' AND de.to_date > '2001-01-01';


-- 3. Queries with GROUP BY, ORDER BY (heavier)
-- 3.1 Calculate average salary by department
SELECT d.dept_name, AVG(s.salary) AS avg_salary
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
JOIN salaries s ON e.emp_no = s.emp_no
GROUP BY d.dept_name;

-- 3.2 Sort employee list by birth date
SELECT first_name, last_name, birth_date
FROM employees
ORDER BY birth_date;

-- 3.3 Count number of employees by title
SELECT title, COUNT(*) AS total
FROM titles
GROUP BY title
ORDER BY total DESC;

-- 4. Queries without index (resource intensive)
-- 4.1 Query with leading LIKE (no index used)
SELECT * FROM employees WHERE first_name LIKE '%ohn%';

-- 4.2 Query with calculation (disables index usage)
SELECT * FROM employees WHERE YEAR(hire_date) = 1995;


-- 5. Subquery (CPU, RAM intensive)
-- 5.1 Subquery in WHERE
SELECT emp_no, first_name, last_name
FROM employees
WHERE emp_no IN (
    SELECT emp_no
    FROM salaries
    WHERE salary > 80000
);

-- 5.2 Subquery in FROM
SELECT dept_name, avg_salary
FROM (
    SELECT d.dept_name, AVG(s.salary) AS avg_salary
    FROM employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    JOIN departments d ON de.dept_no = d.dept_no
    JOIN salaries s ON e.emp_no = s.emp_no
    GROUP BY d.dept_name
) AS dept_avg;


-- 6. Very heavy queries (causing bottlenecks)
-- 6.1 JOIN all data, no WHERE
SELECT *
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no;

-- 6.2 Nested JOINs + GROUP BY + ORDER BY
SELECT d.dept_name, t.title, AVG(s.salary) AS avg_salary
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name, t.title
ORDER BY avg_salary DESC;
