-- Truy vấn 1-10: WHERE với điều kiện đơn
SELECT * FROM employees WHERE emp_no = 10001;
SELECT * FROM employees WHERE gender = 'F';
SELECT * FROM employees WHERE hire_date > '1995-01-01';
SELECT * FROM employees WHERE birth_date BETWEEN '1960-01-01' AND '1970-01-01';
SELECT * FROM salaries WHERE salary > 70000;
SELECT * FROM titles WHERE title = 'Engineer';
SELECT * FROM departments WHERE dept_no = 'd005';
SELECT * FROM employees WHERE first_name = 'Mary';
SELECT * FROM employees WHERE last_name = 'Smith';
SELECT * FROM employees WHERE emp_no < 10010;

-- Truy vấn 11-20: WHERE + IN / NOT IN
SELECT * FROM employees WHERE emp_no IN (10001, 10002, 10003);
SELECT * FROM employees WHERE dept_no IN ('d001', 'd003', 'd005');
SELECT * FROM titles WHERE title IN ('Engineer', 'Manager');
SELECT * FROM employees WHERE emp_no NOT IN (10004, 10005);
SELECT * FROM employees WHERE gender IN ('M');
SELECT * FROM salaries WHERE salary IN (60117, 40000, 70000);
SELECT * FROM departments WHERE dept_no NOT IN ('d009');
SELECT * FROM employees WHERE hire_date IN ('1990-01-01', '2000-01-01');
SELECT * FROM employees WHERE birth_date IN ('1965-12-01');
SELECT * FROM dept_emp WHERE emp_no IN (10001, 10002, 10006);

-- Truy vấn 21-30: WHERE + LIKE / NOT LIKE
SELECT * FROM employees WHERE first_name LIKE 'A%';
SELECT * FROM employees WHERE last_name LIKE '%son';
SELECT * FROM employees WHERE first_name LIKE '%ar%';
SELECT * FROM employees WHERE first_name NOT LIKE 'B%';
SELECT * FROM employees WHERE last_name LIKE '__n%';
SELECT * FROM employees WHERE first_name LIKE '_e%';
SELECT * FROM employees WHERE first_name LIKE '%e%';
SELECT * FROM employees WHERE last_name NOT LIKE '%z%';
SELECT * FROM departments WHERE dept_name LIKE 'Sales%';
SELECT * FROM titles WHERE title LIKE '%Manager%';

-- Truy vấn 31-40: ORDER BY + LIMIT
SELECT * FROM employees ORDER BY emp_no LIMIT 10;
SELECT * FROM employees ORDER BY hire_date DESC LIMIT 5;
SELECT * FROM employees WHERE gender = 'F' ORDER BY birth_date ASC LIMIT 3;
SELECT * FROM salaries ORDER BY salary DESC LIMIT 10;
SELECT * FROM titles ORDER BY emp_no DESC LIMIT 5;
SELECT * FROM departments ORDER BY dept_no ASC;
SELECT * FROM employees ORDER BY last_name ASC, first_name ASC LIMIT 20;
SELECT * FROM employees WHERE first_name LIKE 'J%' ORDER BY birth_date DESC LIMIT 7;
SELECT * FROM employees WHERE emp_no BETWEEN 10001 AND 10050 ORDER BY hire_date;
SELECT * FROM employees ORDER BY RAND() LIMIT 10;

-- Truy vấn 41-50: IS NULL / IS NOT NULL
SELECT * FROM employees WHERE last_name IS NULL;
SELECT * FROM employees WHERE first_name IS NOT NULL;
SELECT * FROM salaries WHERE to_date IS NULL;
SELECT * FROM titles WHERE title IS NOT NULL;
SELECT * FROM dept_emp WHERE to_date IS NULL;
SELECT * FROM employees WHERE gender IS NULL;
SELECT * FROM employees WHERE hire_date IS NOT NULL;
SELECT * FROM departments WHERE dept_name IS NOT NULL;
SELECT * FROM employees WHERE birth_date IS NULL;
SELECT * FROM employees WHERE emp_no IS NOT NULL;

-- Truy vấn 51-60: WHERE + nhiều điều kiện
SELECT * FROM employees WHERE gender = 'M' AND hire_date > '1990-01-01';
SELECT * FROM employees WHERE gender = 'F' AND birth_date < '1970-01-01';
SELECT * FROM employees WHERE first_name LIKE 'J%' AND gender = 'M';
SELECT * FROM employees WHERE last_name LIKE '%son' OR last_name LIKE '%berg';
SELECT * FROM salaries WHERE salary > 50000 AND salary < 60000;
SELECT * FROM dept_emp WHERE from_date < '1990-01-01' AND to_date > '2000-01-01';
SELECT * FROM employees WHERE emp_no BETWEEN 10001 AND 10020 AND gender = 'F';
SELECT * FROM employees WHERE birth_date < '1965-01-01' OR hire_date > '2000-01-01';
SELECT * FROM employees WHERE first_name = 'John' OR last_name = 'Smith';
SELECT * FROM employees WHERE (gender = 'M' AND hire_date < '1980-01-01') OR birth_date > '1975-01-01';

-- Truy vấn 61-70: LIMIT và OFFSET
SELECT * FROM employees LIMIT 10 OFFSET 10;
SELECT * FROM employees LIMIT 5 OFFSET 20;
SELECT * FROM employees ORDER BY emp_no LIMIT 15 OFFSET 30;
SELECT * FROM salaries ORDER BY salary DESC LIMIT 20 OFFSET 10;
SELECT * FROM employees WHERE gender = 'F' ORDER BY birth_date ASC LIMIT 5 OFFSET 10;
SELECT * FROM employees WHERE first_name LIKE 'A%' LIMIT 25 OFFSET 5;
SELECT * FROM titles LIMIT 5 OFFSET 5;
SELECT * FROM employees WHERE emp_no > 10100 LIMIT 10 OFFSET 5;
SELECT * FROM employees ORDER BY RAND() LIMIT 10 OFFSET 10;
SELECT * FROM employees ORDER BY emp_no DESC LIMIT 50 OFFSET 50;

-- Truy vấn 71-80: JOIN 2 bảng
SELECT e.first_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.salary > 60000;

SELECT e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no;

SELECT e.emp_no, t.title
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no;

SELECT s.emp_no, s.salary, s.to_date
FROM salaries s
JOIN dept_emp de ON s.emp_no = de.emp_no;

SELECT e.first_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01';

-- Truy vấn 81-90: JOIN với điều kiện AND / OR
SELECT e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
WHERE e.gender = 'F' AND de.to_date > '2000-01-01';

SELECT e.emp_no, t.title
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
WHERE t.title LIKE '%Manager%' OR t.title LIKE '%Engineer%';

SELECT s.emp_no, s.salary
FROM salaries s
JOIN titles t ON s.emp_no = t.emp_no
WHERE s.salary > 70000 AND t.title = 'Engineer';

-- Truy vấn 91-100: JOIN 3+ bảng nâng cao
SELECT e.first_name, e.last_name, s.salary, d.dept_name
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
WHERE s.salary > 80000;

SELECT e.first_name, t.title, s.salary
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
JOIN salaries s ON e.emp_no = s.emp_no
WHERE t.title LIKE '%Engineer%' AND s.salary > 60000;

SELECT e.emp_no, d.dept_name, s.salary
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.salary BETWEEN 50000 AND 80000;

-- Truy vấn 101-110: GROUP BY cơ bản
SELECT gender, COUNT(*) FROM employees GROUP BY gender;
SELECT title, COUNT(*) FROM titles GROUP BY title;
SELECT dept_no, COUNT(*) FROM dept_emp GROUP BY dept_no;
SELECT dept_no, AVG(salary) FROM salaries s JOIN dept_emp de ON s.emp_no = de.emp_no GROUP BY dept_no;
SELECT hire_date, COUNT(*) FROM employees GROUP BY hire_date;

-- Truy vấn 111-120: GROUP BY nâng cao + HAVING
SELECT gender, COUNT(*) AS total FROM employees GROUP BY gender HAVING total > 1000;
SELECT title, COUNT(*) AS total FROM titles GROUP BY title HAVING total > 500;
SELECT dept_no, AVG(salary) AS avg_sal FROM salaries s JOIN dept_emp de ON s.emp_no = de.emp_no GROUP BY dept_no HAVING avg_sal > 60000;
SELECT hire_date, COUNT(*) FROM employees GROUP BY hire_date HAVING COUNT(*) > 10;
SELECT birth_date, COUNT(*) FROM employees GROUP BY birth_date HAVING COUNT(*) > 5;

-- Truy vấn 121-130: SUM, MIN, MAX
SELECT dept_no, SUM(salary) AS total_sal FROM salaries s JOIN dept_emp de ON s.emp_no = de.emp_no GROUP BY dept_no;
SELECT dept_no, MAX(salary) FROM salaries s JOIN dept_emp de ON s.emp_no = de.emp_no GROUP BY dept_no;
SELECT title, MIN(salary) FROM salaries s JOIN titles t ON s.emp_no = t.emp_no GROUP BY title;
SELECT hire_date, MAX(emp_no) FROM employees GROUP BY hire_date;
SELECT gender, MIN(birth_date) FROM employees GROUP BY gender;

-- Truy vấn 131-140: COUNT(*) nâng cao
SELECT COUNT(*) FROM employees WHERE gender = 'F';
SELECT COUNT(*) FROM employees WHERE birth_date < '1970-01-01';
SELECT COUNT(*) FROM salaries WHERE salary > 60000;
SELECT COUNT(DISTINCT title) FROM titles;
SELECT COUNT(*) FROM departments;

-- Truy vấn 141-150: GROUP BY nhiều cột
SELECT gender, hire_date, COUNT(*) FROM employees GROUP BY gender, hire_date;
SELECT dept_no, from_date, COUNT(*) FROM dept_emp GROUP BY dept_no, from_date;
SELECT title, to_date, COUNT(*) FROM titles GROUP BY title, to_date;
SELECT gender, birth_date, COUNT(*) FROM employees GROUP BY gender, birth_date;
SELECT dept_no, emp_no, COUNT(*) FROM dept_emp GROUP BY dept_no, emp_no;

-- Truy vấn 151-160: GROUP BY + ORDER BY
SELECT title, COUNT(*) AS total FROM titles GROUP BY title ORDER BY total DESC;
SELECT gender, COUNT(*) AS total FROM employees GROUP BY gender ORDER BY total ASC;
SELECT dept_no, AVG(salary) AS avg_sal FROM salaries s JOIN dept_emp de ON s.emp_no = de.emp_no GROUP BY dept_no ORDER BY avg_sal DESC;
SELECT birth_date, COUNT(*) FROM employees GROUP BY birth_date ORDER BY COUNT(*) DESC LIMIT 10;
SELECT hire_date, COUNT(*) FROM employees GROUP BY hire_date ORDER BY hire_date ASC;

-- Truy vấn 161-170: GROUP BY với các điều kiện
SELECT dept_no, COUNT(*) FROM dept_emp WHERE from_date < '1990-01-01' GROUP BY dept_no;
SELECT title, AVG(salary) FROM salaries s JOIN titles t ON s.emp_no = t.emp_no WHERE s.salary > 60000 GROUP BY title;
SELECT gender, COUNT(*) FROM employees WHERE hire_date > '2000-01-01' GROUP BY gender;
SELECT dept_no, COUNT(*) FROM dept_emp WHERE to_date = '9999-01-01' GROUP BY dept_no;
SELECT dept_no, MAX(salary) FROM salaries s JOIN dept_emp de ON s.emp_no = de.emp_no WHERE s.salary < 80000 GROUP BY dept_no;

-- Truy vấn 171-180: Subquery trong WHERE
SELECT emp_no, first_name FROM employees
WHERE emp_no IN (
    SELECT emp_no FROM salaries WHERE salary > 80000
);

SELECT first_name FROM employees
WHERE emp_no NOT IN (
    SELECT emp_no FROM dept_emp WHERE to_date = '9999-01-01'
);

SELECT dept_name FROM departments
WHERE dept_no IN (
    SELECT dept_no FROM dept_emp WHERE emp_no IN (
        SELECT emp_no FROM salaries WHERE salary > 90000
    )
);

-- Truy vấn 181-190: Subquery trong FROM
SELECT avg_salary FROM (
    SELECT dept_no, AVG(salary) AS avg_salary
    FROM salaries s JOIN dept_emp de ON s.emp_no = de.emp_no
    GROUP BY dept_no
) AS salary_stats;

SELECT gender, max_birth FROM (
    SELECT gender, MAX(birth_date) AS max_birth
    FROM employees GROUP BY gender
) AS birth;

-- Truy vấn 191-200: EXISTS / NOT EXISTS
SELECT emp_no FROM employees e
WHERE EXISTS (
    SELECT * FROM salaries s WHERE s.emp_no = e.emp_no AND s.salary > 90000
);

SELECT emp_no FROM employees e
WHERE NOT EXISTS (
    SELECT * FROM dept_emp d WHERE d.emp_no = e.emp_no
);

-- Truy vấn 201-210: UNION / UNION ALL
SELECT first_name FROM employees WHERE gender = 'M'
UNION
SELECT first_name FROM employees WHERE gender = 'F';

SELECT dept_no FROM dept_emp WHERE from_date < '1995-01-01'
UNION ALL
SELECT dept_no FROM dept_emp WHERE to_date > '2005-01-01';

-- Truy vấn 211-220: CASE WHEN
SELECT emp_no,
       CASE WHEN gender = 'M' THEN 'Male'
            WHEN gender = 'F' THEN 'Female'
            ELSE 'Other' END AS gender_label
FROM employees;

SELECT emp_no,
       CASE WHEN salary > 90000 THEN 'High'
            WHEN salary > 60000 THEN 'Medium'
            ELSE 'Low' END AS salary_level
FROM salaries;

-- Truy vấn 221-230: IS NULL / NOT NULL
SELECT * FROM employees WHERE last_name IS NULL;
SELECT * FROM employees WHERE last_name IS NOT NULL;

-- Truy vấn 231-240: DISTINCT, LIMIT, OFFSET
SELECT DISTINCT title FROM titles;
SELECT * FROM employees LIMIT 10;
SELECT * FROM employees ORDER BY hire_date DESC LIMIT 10 OFFSET 20;

-- Truy vấn 241-250: EXPLAIN sử dụng trong script
EXPLAIN SELECT * FROM employees WHERE emp_no = 10001;
EXPLAIN SELECT * FROM employees WHERE first_name LIKE '%John%';
EXPLAIN SELECT e.first_name, s.salary FROM employees e JOIN salaries s ON e.emp_no = s.emp_no;

-- Truy vấn 251-260: HAVING nâng cao
SELECT title, AVG(salary) AS avg_sal
FROM salaries s JOIN titles t ON s.emp_no = t.emp_no
GROUP BY title
HAVING COUNT(*) > 100 AND AVG(salary) > 60000;

-- Truy vấn 261-270: Truy vấn lỗi hiệu năng phổ biến
SELECT * FROM employees WHERE first_name LIKE '%ohn%';  -- leading LIKE
SELECT * FROM employees WHERE YEAR(hire_date) = 1995;    -- disable index
SELECT * FROM employees WHERE first_name = 'John' OR last_name = 'Smith'; -- OR condition

-- Truy vấn 271-280: Truy vấn thiếu tối ưu
SELECT * FROM employees ORDER BY RAND();      -- tránh dùng RAND trong ORDER
SELECT * FROM salaries ORDER BY salary;       -- nếu không cần sắp xếp thì bỏ ORDER BY
SELECT * FROM employees LIMIT 100000;         -- tránh giới hạn quá lớn

-- Truy vấn 281-290: Truy vấn nặng tổng hợp
SELECT d.dept_name, t.title, AVG(s.salary) AS avg_salary
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name, t.title
ORDER BY avg_salary DESC;

-- Truy vấn 291-300: Redundant JOIN
SELECT e.first_name, e.last_name
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no;

-- Truy vấn 301-310: Truy vấn kiểm tra MAX MIN đặc biệt
SELECT * FROM salaries WHERE salary = (SELECT MAX(salary) FROM salaries);
SELECT * FROM employees WHERE birth_date = (SELECT MIN(birth_date) FROM employees);
SELECT * FROM employees WHERE hire_date = (SELECT MAX(hire_date) FROM employees);

SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM employees;

SELECT emp_no, UPPER(last_name) AS last_upper FROM employees;

SELECT emp_no, LOWER(first_name) AS first_lower FROM employees;

SELECT emp_no, SUBSTRING(first_name, 1, 2) AS prefix FROM employees;

SELECT emp_no, LENGTH(first_name) AS len FROM employees;

SELECT emp_no, TRIM(first_name) FROM employees;

SELECT emp_no, REPLACE(first_name, 'a', '@') AS modified FROM employees;

SELECT emp_no, LOCATE('e', first_name) AS pos_e FROM employees;

SELECT emp_no, REVERSE(first_name) AS reversed FROM employees;

SELECT DISTINCT SUBSTRING(last_name, 1, 1) AS initial FROM employees;

SELECT salary, ROUND(salary / 1000, 2) AS k_salary FROM salaries;

SELECT emp_no, MOD(emp_no, 2) AS parity FROM employees;

SELECT emp_no, FLOOR(emp_no / 10000) AS emp_group FROM employees;

SELECT salary, CEIL(salary / 10000) AS salary_bucket FROM salaries;

SELECT salary, POWER(salary, 1.05) AS adjusted FROM salaries LIMIT 100;

SELECT salary, salary * 1.1 AS raised FROM salaries;

SELECT salary, LOG(salary) AS log_salary FROM salaries WHERE salary > 0;

SELECT salary, EXP(1) * salary FROM salaries;

SELECT salary, ABS(salary - 50000) AS diff_50k FROM salaries;

SELECT salary, ROUND(RAND() * salary, 2) AS salary_variation FROM salaries;

SELECT hire_date, YEAR(hire_date) AS year_hired FROM employees;

SELECT birth_date, MONTH(birth_date) AS birth_month FROM employees;

SELECT emp_no, DATEDIFF(NOW(), hire_date) AS days_worked FROM employees;

SELECT emp_no, TIMESTAMPDIFF(YEAR, hire_date, NOW()) AS years FROM employees;

SELECT emp_no, WEEK(hire_date) AS hire_week FROM employees;

SELECT emp_no, QUARTER(birth_date) AS birth_quarter FROM employees;

SELECT emp_no, hire_date, DATE_ADD(hire_date, INTERVAL 5 YEAR) AS end_contract FROM employees;

SELECT emp_no, DATE_FORMAT(hire_date, '%Y-%m') AS hire_month FROM employees;

SELECT emp_no, STR_TO_DATE('1999-05-10', '%Y-%m-%d') AS fixed_date FROM employees LIMIT 1;

SELECT emp_no, DAYNAME(hire_date) AS hire_day FROM employees;

SELECT * FROM employees ORDER BY emp_no LIMIT 10 OFFSET 10;

SELECT * FROM employees ORDER BY emp_no LIMIT 20 OFFSET 100;

SELECT * FROM employees ORDER BY emp_no DESC LIMIT 5;

SELECT * FROM salaries ORDER BY salary DESC LIMIT 3;

SELECT * FROM titles LIMIT 15;

SELECT * FROM employees WHERE emp_no > 10010 LIMIT 10;

SELECT emp_no FROM employees LIMIT 100 OFFSET 9000;

SELECT emp_no FROM employees WHERE emp_no BETWEEN 10000 AND 10100 LIMIT 5;

SELECT emp_no FROM employees ORDER BY emp_no LIMIT 1;

SELECT emp_no FROM employees ORDER BY RAND() LIMIT 1;

SELECT * FROM employees WHERE gender = 'M' AND hire_date < '1990-01-01';

SELECT * FROM employees WHERE first_name LIKE 'A%' OR last_name LIKE 'Z%';

SELECT * FROM employees WHERE NOT (gender = 'F');

SELECT * FROM employees WHERE hire_date BETWEEN '1985-01-01' AND '1995-01-01' AND gender = 'M';

SELECT * FROM employees WHERE (gender = 'M' AND hire_date < '1990-01-01') OR (gender = 'F' AND hire_date > '2000-01-01');

SELECT * FROM employees WHERE emp_no IN (10001, 10002, 10003) AND gender = 'F';

SELECT * FROM employees WHERE emp_no NOT BETWEEN 10010 AND 10020;

SELECT * FROM salaries WHERE salary BETWEEN 60000 AND 70000;

SELECT * FROM titles WHERE title IN ('Engineer', 'Senior Engineer');

SELECT * FROM dept_emp WHERE from_date < '1995-01-01' AND to_date > '2000-01-01';

SELECT gender, COUNT(*) AS count_emp FROM employees GROUP BY gender;

SELECT title, COUNT(*) FROM titles GROUP BY title;

SELECT dept_no, AVG(salary) AS avg_sal FROM dept_emp de JOIN salaries s ON de.emp_no = s.emp_no GROUP BY dept_no;

SELECT YEAR(hire_date) AS year, COUNT(*) FROM employees GROUP BY YEAR(hire_date);

SELECT dept_no, gender, COUNT(*) FROM dept_emp de JOIN employees e ON de.emp_no = e.emp_no GROUP BY dept_no, gender;

SELECT title, COUNT(*) FROM titles GROUP BY title WITH ROLLUP;

SELECT dept_no, title, COUNT(*) FROM titles t JOIN dept_emp de ON t.emp_no = de.emp_no GROUP BY dept_no, title;

SELECT dept_no, SUM(salary) FROM salaries s JOIN dept_emp d ON s.emp_no = d.emp_no GROUP BY dept_no;

SELECT title, MAX(salary), MIN(salary) FROM titles t JOIN salaries s ON t.emp_no = s.emp_no GROUP BY title;

SELECT dept_no, COUNT(DISTINCT emp_no) FROM dept_emp GROUP BY dept_no;

SELECT * FROM employees WHERE emp_no = 10020;
SELECT * FROM employees WHERE emp_no = 10030;
SELECT * FROM employees WHERE emp_no = 10040;
SELECT * FROM employees WHERE emp_no = 10050;
SELECT * FROM employees WHERE emp_no = 10060;

SELECT * FROM employees WHERE first_name LIKE 'B%';
SELECT * FROM employees WHERE first_name LIKE 'C%';
SELECT * FROM employees WHERE first_name LIKE '%son%';
SELECT * FROM employees WHERE first_name LIKE '%ard%';
SELECT * FROM employees WHERE first_name LIKE '%ina%';

SELECT * FROM employees ORDER BY emp_no LIMIT 10 OFFSET 20;
SELECT * FROM employees ORDER BY emp_no LIMIT 10 OFFSET 30;
SELECT * FROM employees ORDER BY emp_no LIMIT 10 OFFSET 40;
SELECT * FROM employees ORDER BY emp_no LIMIT 10 OFFSET 50;
SELECT * FROM employees ORDER BY emp_no LIMIT 10 OFFSET 60;

SELECT * FROM employees ORDER BY RAND() LIMIT 1;
SELECT * FROM employees ORDER BY RAND() LIMIT 3;
SELECT * FROM salaries ORDER BY salary LIMIT 5 OFFSET 100;
SELECT * FROM salaries ORDER BY salary DESC LIMIT 5 OFFSET 200;
SELECT * FROM titles ORDER BY emp_no LIMIT 5 OFFSET 10;

SELECT * FORM employees;
SELEC * FROM employees;
SELECT * FROM employeess;
SELECT * FROM emp WHERE id = 1;
SELECT first_name last_name FROM employees;
SELECT FROM employees;
SELECT emp_no WHERE emp_no = 10001;
SELECT * FROM employees WHERE;
INSERT INTO employees VALUES ();
SELECT COUNT(*) FROM;

SELECT * FROM employees WHERE UPPER(first_name) = 'MARK';
SELECT * FROM employees WHERE LENGTH(last_name) > 7;
SELECT * FROM employees WHERE YEAR(hire_date) BETWEEN 1990 AND 2000;
SELECT * FROM employees WHERE first_name LIKE '%a%' AND gender = 'F';
SELECT * FROM employees WHERE hire_date > birth_date;
SELECT emp_no FROM employees WHERE emp_no IN (SELECT emp_no FROM salaries WHERE salary > 70000);
SELECT * FROM salaries WHERE salary > (SELECT AVG(salary) FROM salaries);
SELECT * FROM employees WHERE emp_no NOT IN (SELECT emp_no FROM titles WHERE title = 'Engineer');
SELECT * FROM dept_emp WHERE dept_no = 'd005' AND from_date < '1990-01-01';
SELECT * FROM employees WHERE emp_no BETWEEN 10001 AND 10010;

SELECT * FROM employees e WHERE EXISTS (SELECT 1 FROM salaries s WHERE s.emp_no = e.emp_no AND s.salary > 80000);

SELECT emp_no, AVG(salary) FROM salaries GROUP BY emp_no HAVING AVG(salary) > 70000;

SELECT emp_no FROM salaries WHERE salary > ALL (SELECT salary FROM salaries WHERE emp_no = 10001);

SELECT emp_no FROM salaries WHERE salary < ANY (SELECT salary FROM salaries WHERE emp_no = 10010);

SELECT dept_no, COUNT(*) FROM dept_emp GROUP BY dept_no HAVING COUNT(*) > 100;

SELECT * FROM employees WHERE hire_date > ALL (SELECT hire_date FROM employees WHERE gender = 'M');

SELECT * FROM employees WHERE emp_no = ANY (SELECT emp_no FROM titles WHERE title LIKE '%Manager%');

SELECT emp_no FROM employees WHERE EXISTS (SELECT 1 FROM titles WHERE titles.emp_no = employees.emp_no AND title = 'Staff');

SELECT emp_no FROM employees WHERE NOT EXISTS (SELECT 1 FROM salaries WHERE salaries.emp_no = employees.emp_no);

SELECT emp_no FROM salaries GROUP BY emp_no HAVING MAX(salary) > 90000;

SELECT DISTINCT d.dept_name FROM departments d JOIN dept_emp de ON d.dept_no = de.dept_no;

SELECT t.title, COUNT(*) FROM titles t GROUP BY t.title;

SELECT s.salary, COUNT(*) FROM salaries s GROUP BY s.salary HAVING COUNT(*) > 1;

SELECT e.gender, AVG(s.salary) FROM employees e JOIN salaries s ON e.emp_no = s.emp_no GROUP BY e.gender;

SELECT e.first_name, e.last_name, s.salary FROM employees e JOIN salaries s ON e.emp_no = s.emp_no WHERE s.salary > 90000;

SELECT e.first_name, COUNT(*) FROM employees e GROUP BY e.first_name ORDER BY COUNT(*) DESC LIMIT 5;

SELECT emp_no FROM employees WHERE emp_no IN (SELECT emp_no FROM dept_emp WHERE dept_no = 'd007');

SELECT * FROM employees WHERE last_name LIKE 'A%' AND hire_date < '1995-01-01';

SELECT emp_no FROM employees WHERE first_name LIKE '__e%';

SELECT emp_no, birth_date FROM employees WHERE birth_date < '1960-01-01';

SELECT * FROM employees WHERE hire_date BETWEEN '1990-01-01' AND '1990-12-31';

-- Truy vấn theo năm (dữ liệu thời gian)
SELECT COUNT(*) FROM employees WHERE YEAR(hire_date) = 1985;
SELECT COUNT(*) FROM employees WHERE YEAR(hire_date) = 1986;
...
SELECT AVG(salary) FROM salaries WHERE from_date >= '2000-01-01' AND from_date < '2001-01-01';

-- Phân hạng sử dụng WINDOW FUNCTION (MySQL 8+)
SELECT emp_no, salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM salaries
WHERE to_date > '2000-01-01'
LIMIT 100;

-- Truy tìm lần tăng lương đầu tiên
SELECT emp_no, salary,
       ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY from_date) AS salary_seq
FROM salaries
LIMIT 100;

UPDATE employees SET last_name = 'Test' WHERE emp_no = 10001;
DELETE FROM employees WHERE emp_no = 10001;

SELECT emp_no,
       CASE WHEN gender = 'M' THEN 'Male' ELSE 'Female' END AS gender_label
FROM employees
LIMIT 100;

SELECT emp_no, salary,
       CASE WHEN salary > 80000 THEN 'High' ELSE 'Normal' END AS salary_class
FROM salaries
LIMIT 100;

SELECT emp_no, 'emp' AS source FROM employees WHERE emp_no < 10010
UNION
SELECT emp_no, 'sal' AS source FROM salaries WHERE emp_no < 10010;

SELECT emp_no FROM employees WHERE gender = 'M'
UNION ALL
SELECT emp_no FROM employees WHERE gender = 'F';

SELECT * FROM employees, salaries LIMIT 10000;
SELECT * FROM employees ORDER BY RAND() LIMIT 1000;

SELECT e.emp_no, d.dept_name
FROM employees e
LEFT JOIN dept_emp de ON e.emp_no = de.emp_no
LEFT JOIN departments d ON de.dept_no = d.dept_no
LIMIT 100;

SELECT d.dept_name, e.emp_no
FROM departments d
RIGHT JOIN dept_emp de ON d.dept_no = de.dept_no
RIGHT JOIN employees e ON de.emp_no = e.emp_no
LIMIT 100;

SELECT e.emp_no, d.dept_name
FROM employees e
JOIN departments d
WHERE e.emp_no % 10 = d.dept_no % 10
LIMIT 100;
