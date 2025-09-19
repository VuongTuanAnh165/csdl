-- 📌 Phần 1 — Các truy vấn cơ bản và WHERE đơn giản
-- Truy vấn cơ bản
-- Truy vấn nhanh: SELECT đơn giản với điều kiện WHERE có index
SELECT * FROM employees WHERE emp_no = 10001;

-- Truy vấn nhanh: chỉ lấy 1 dòng
SELECT first_name FROM employees LIMIT 1;

-- Truy vấn nhanh: COUNT(*) trên bảng nhỏ
SELECT COUNT(*) FROM departments;

-- Truy vấn nhanh: ORDER BY có LIMIT
SELECT emp_no FROM employees ORDER BY emp_no LIMIT 10;

-- Truy vấn nhanh: kiểm tra điều kiện boolean đơn giản
SELECT * FROM salaries WHERE salary > 50000 LIMIT 5;

-- Truy vấn nhanh: lấy 1 cột cụ thể
SELECT hire_date FROM employees WHERE emp_no = 10005;

-- Truy vấn nhanh: COUNT với điều kiện đơn giản
SELECT COUNT(*) FROM employees WHERE gender = 'M';

-- Truy vấn nhanh: DISTINCT trên cột nhỏ
SELECT DISTINCT dept_no FROM dept_emp;

-- Truy vấn nhanh: sử dụng điều kiện BETWEEN
SELECT * FROM salaries WHERE salary BETWEEN 60000 AND 61000 LIMIT 10;

-- Truy vấn nhanh: lấy max/min trên cột có index
SELECT MAX(salary) FROM salaries;
SELECT MIN(emp_no) FROM employees;

-- Truy vấn nhanh: kiểm tra tồn tại (EXISTS)
SELECT EXISTS(SELECT 1 FROM employees WHERE emp_no = 10001);

-- Truy vấn nhanh: lấy ngày/tháng từ date
SELECT YEAR(hire_date) FROM employees LIMIT 10;

-- Truy vấn nhanh: GROUP BY trên bảng nhỏ
SELECT dept_no, COUNT(*) FROM departments GROUP BY dept_no;

-- Truy vấn nhanh: ORDER BY + LIMIT nhỏ
SELECT last_name FROM employees ORDER BY last_name LIMIT 5;

-- Truy vấn nhanh: kiểm tra NOT IN với ít phần tử
SELECT * FROM employees WHERE emp_no NOT IN (10001, 10002, 10003) LIMIT 5;

-- Truy vấn nhanh: kết hợp 2 điều kiện đơn giản
SELECT first_name, last_name FROM employees 
WHERE gender = 'F' AND hire_date > '1995-01-01' LIMIT 10;

-- Truy vấn nhanh: subquery trả về 1 giá trị
SELECT * FROM employees 
WHERE emp_no = (SELECT MIN(emp_no) FROM employees);

-- Truy vấn nhanh: JOIN nhưng có điều kiện index (vẫn nhanh)
SELECT e.emp_no, d.dept_no 
FROM employees e 
JOIN dept_emp d ON e.emp_no = d.emp_no 
WHERE d.dept_no = 'd005' LIMIT 10;

-- Nhanh: lấy 1 dòng theo PK
SELECT * FROM employees WHERE emp_no = 10010;

-- Nhanh: lấy nhiều cột với LIMIT
SELECT first_name, last_name, gender FROM employees LIMIT 20;

-- Nhanh: aggregate đơn giản
SELECT AVG(salary) FROM salaries WHERE to_date > '1999-01-01';

-- Nhanh: DISTINCT trên bảng nhỏ
SELECT DISTINCT dept_name FROM departments;

-- Nhanh: GROUP BY trên bảng nhỏ
SELECT gender, COUNT(*) FROM employees GROUP BY gender;

-- Nhanh: JOIN với điều kiện index + LIMIT
SELECT e.first_name, d.dept_no
FROM employees e
JOIN dept_emp d ON e.emp_no = d.emp_no
WHERE d.dept_no = 'd001' LIMIT 10;

-- Nhanh: EXISTS với điều kiện dễ
SELECT EXISTS(SELECT 1 FROM employees WHERE emp_no = 10001);

-- Nhanh: Subquery scalar (1 giá trị)
SELECT first_name FROM employees WHERE emp_no = (SELECT MIN(emp_no) FROM employees);

-- Nhanh: ORDER BY + LIMIT
SELECT hire_date FROM employees ORDER BY hire_date ASC LIMIT 5;

-- Nhanh: dùng hàm đơn giản
SELECT LENGTH(first_name) FROM employees LIMIT 10;

-- Nhanh: BETWEEN + LIMIT
SELECT * FROM salaries WHERE salary BETWEEN 60000 AND 60500 LIMIT 10;

SELECT * FROM employees;
SELECT emp_no, first_name, last_name FROM employees;
SELECT first_name, last_name FROM employees WHERE gender = 'M';
SELECT * FROM employees WHERE birth_date < '1960-01-01';
SELECT emp_no, salary FROM salaries WHERE salary > 80000;
SELECT * FROM titles WHERE title = 'Engineer';

-- WHERE với nhiều điều kiện
SELECT * FROM employees WHERE gender = 'F' AND hire_date > '1995-01-01';
SELECT * FROM employees WHERE birth_date BETWEEN '1965-01-01' AND '1970-12-31';
SELECT * FROM employees WHERE last_name LIKE 'S%';
SELECT * FROM employees WHERE first_name LIKE '%a';
SELECT * FROM employees WHERE emp_no IN (10001, 10002, 10003);
SELECT * FROM salaries WHERE salary BETWEEN 40000 AND 60000;

-- ORDER BY và LIMIT
SELECT * FROM employees ORDER BY hire_date DESC LIMIT 50;
SELECT first_name, last_name, hire_date FROM employees ORDER BY last_name ASC, first_name ASC;
SELECT * FROM salaries ORDER BY salary DESC LIMIT 10;
SELECT emp_no, salary FROM salaries WHERE from_date > '2000-01-01' ORDER BY salary DESC;

-- 📌 Phần 2 — JOIN, GROUP BY, HAVING
-- JOIN cơ bản giữa employees và salaries
SELECT e.emp_no, e.first_name, e.last_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01';

-- LEFT JOIN để lấy nhân viên chưa có lương hiện tại
SELECT e.emp_no, e.first_name, e.last_name, s.salary
FROM employees e
LEFT JOIN salaries s ON e.emp_no = s.emp_no AND s.to_date = '9999-01-01'
WHERE s.salary IS NULL;

-- JOIN nhiều bảng
SELECT e.emp_no, e.first_name, e.last_name, t.title, s.salary
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01' AND t.to_date = '9999-01-01';

-- GROUP BY + COUNT
SELECT gender, COUNT(*) AS total_employees
FROM employees
GROUP BY gender;

-- GROUP BY + AVG
SELECT t.title, AVG(s.salary) AS avg_salary
FROM titles t
JOIN salaries s ON t.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
GROUP BY t.title
ORDER BY avg_salary DESC;

-- HAVING để lọc nhóm
SELECT dept_no, COUNT(emp_no) AS total_employees
FROM dept_emp
GROUP BY dept_no
HAVING COUNT(emp_no) > 100;

-- SUM và MIN/MAX
SELECT dept_no, SUM(salary) AS total_salary, MAX(salary) AS max_salary, MIN(salary) AS min_salary
FROM dept_emp de
JOIN salaries s ON de.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
GROUP BY dept_no;

-- DISTINCT kết hợp với ORDER BY
SELECT DISTINCT title
FROM titles
ORDER BY title ASC;

-- 📌 Phần 3 — Subquery, EXISTS, Window Functions
-- Subquery đơn giản trong WHERE
SELECT emp_no, first_name, last_name
FROM employees
WHERE emp_no IN (
    SELECT emp_no
    FROM salaries
    WHERE salary > 100000
);

-- Subquery trong SELECT
SELECT e.emp_no, e.first_name,
       (SELECT COUNT(*) FROM dept_emp de WHERE de.emp_no = e.emp_no) AS num_departments
FROM employees e
LIMIT 100;

-- Subquery trong FROM
SELECT d.dept_no, d.dept_name, avg_sal
FROM departments d
JOIN (
    SELECT dept_no, AVG(salary) AS avg_sal
    FROM dept_emp de
    JOIN salaries s ON de.emp_no = s.emp_no
    WHERE s.to_date = '9999-01-01'
    GROUP BY dept_no
) tmp ON d.dept_no = tmp.dept_no;

-- EXISTS
SELECT emp_no, first_name, last_name
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM dept_emp de WHERE de.emp_no = e.emp_no AND de.dept_no = 'd005'
);

-- NOT EXISTS
SELECT dept_no, dept_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM dept_emp de WHERE de.dept_no = d.dept_no
);

-- Window function: RANK
SELECT emp_no, salary,
       RANK() OVER (ORDER BY salary DESC) AS rank_salary
FROM salaries
WHERE to_date = '9999-01-01'
LIMIT 50;

-- Window function: ROW_NUMBER + PARTITION
SELECT emp_no, dept_no,
       ROW_NUMBER() OVER (PARTITION BY dept_no ORDER BY from_date) AS join_order
FROM dept_emp
LIMIT 100;

-- Window function: Moving average
SELECT emp_no, salary,
       AVG(salary) OVER (ORDER BY from_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_salary
FROM salaries
WHERE to_date = '9999-01-01'
LIMIT 50;

-- 📌 Phần 4 — Truy vấn phức tạp kết hợp nhiều đặc trưng
-- JOIN + Subquery + GROUP BY + HAVING
SELECT d.dept_no, d.dept_name, AVG(s.salary) AS avg_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
  AND de.emp_no IN (
      SELECT emp_no FROM titles WHERE title = 'Senior Engineer'
  )
GROUP BY d.dept_no, d.dept_name
HAVING AVG(s.salary) > 70000
ORDER BY avg_salary DESC;

-- Subquery + EXISTS + JOIN
SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
WHERE EXISTS (
    SELECT 1
    FROM salaries s
    WHERE s.emp_no = e.emp_no
      AND s.salary > 120000
      AND s.to_date = '9999-01-01'
);

-- Nested Subquery + GROUP BY
SELECT e.emp_no, e.first_name, e.last_name, t.title
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
WHERE e.emp_no IN (
    SELECT emp_no
    FROM (
        SELECT emp_no, AVG(salary) AS avg_sal
        FROM salaries
        GROUP BY emp_no
        HAVING AVG(salary) > 80000
    ) tmp
);

-- Multi-join + ORDER BY + LIMIT
SELECT e.emp_no, e.first_name, e.last_name, d.dept_name, s.salary
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
ORDER BY s.salary DESC
LIMIT 100;

-- JOIN + GROUP BY + COUNT + HAVING + ORDER BY
SELECT d.dept_no, d.dept_name, COUNT(e.emp_no) AS total_employees
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN employees e ON de.emp_no = e.emp_no
GROUP BY d.dept_no, d.dept_name
HAVING COUNT(e.emp_no) > 200
ORDER BY total_employees DESC;

-- Truy vấn nhiều điều kiện phức tạp
SELECT e.emp_no, e.first_name, e.last_name, s.salary, t.title
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
JOIN titles t ON e.emp_no = t.emp_no
WHERE s.to_date = '9999-01-01'
  AND t.to_date = '9999-01-01'
  AND s.salary > 90000
  AND (t.title LIKE '%Engineer%' OR t.title LIKE '%Manager%')
ORDER BY s.salary DESC;

-- 📌 Phần 5 — Truy vấn Stress Test & nâng cao
-- UNION giữa hai truy vấn SELECT
SELECT emp_no, first_name, last_name
FROM employees
WHERE hire_date < '1990-01-01'
UNION
SELECT emp_no, first_name, last_name
FROM employees
WHERE birth_date < '1960-01-01';

-- UNION ALL + ORDER BY
SELECT emp_no, salary
FROM salaries
WHERE salary > 100000
UNION ALL
SELECT emp_no, salary
FROM salaries
WHERE salary < 40000
ORDER BY salary DESC;

-- CASE WHEN trong SELECT
SELECT emp_no, salary,
       CASE
           WHEN salary > 120000 THEN 'High'
           WHEN salary BETWEEN 60000 AND 120000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_level
FROM salaries
WHERE to_date = '9999-01-01'
ORDER BY salary DESC;

-- CROSS JOIN (Cartesian product)
SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
CROSS JOIN departments d
LIMIT 200;

-- Nested Subquery nhiều lớp
SELECT emp_no, first_name, last_name
FROM employees
WHERE emp_no IN (
    SELECT emp_no
    FROM salaries
    WHERE salary = (
        SELECT MAX(salary)
        FROM salaries
        WHERE to_date = '9999-01-01'
    )
);

-- Subquery với GROUP BY và HAVING trong điều kiện
SELECT emp_no, first_name, last_name
FROM employees
WHERE emp_no IN (
    SELECT emp_no
    FROM salaries
    GROUP BY emp_no
    HAVING AVG(salary) > 95000
);

-- Truy vấn kết hợp UNION + JOIN
SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
JOIN (
    SELECT emp_no FROM dept_emp WHERE dept_no = 'd005'
    UNION
    SELECT emp_no FROM dept_emp WHERE dept_no = 'd007'
) tmp ON e.emp_no = tmp.emp_no;

-- Truy vấn có ORDER BY trên subquery
SELECT emp_no, salary
FROM (
    SELECT emp_no, salary
    FROM salaries
    WHERE to_date = '9999-01-01'
    ORDER BY salary DESC
    LIMIT 500
) top_salaries
ORDER BY salary ASC;

-- 📌 Phần 6 — Truy vấn Benchmark (OLAP / Window / CTE)
-- Window Function: ROW_NUMBER
SELECT emp_no, first_name, last_name, salary,
       ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary DESC) AS rn
FROM employees
JOIN salaries USING (emp_no)
WHERE to_date = '9999-01-01'
ORDER BY salary DESC
LIMIT 100;

-- Window Function: RANK
SELECT emp_no, salary,
       RANK() OVER (ORDER BY salary DESC) AS rank_salary
FROM salaries
WHERE to_date = '9999-01-01'
LIMIT 200;

-- Window Function: SUM OVER PARTITION
SELECT dept_no, emp_no, salary,
       SUM(salary) OVER (PARTITION BY dept_no) AS total_dept_salary
FROM dept_emp
JOIN salaries USING (emp_no)
WHERE to_date = '9999-01-01'
LIMIT 300;

-- CTE (Common Table Expression) với JOIN
WITH high_salary AS (
    SELECT emp_no, salary
    FROM salaries
    WHERE salary > 120000 AND to_date = '9999-01-01'
)
SELECT e.first_name, e.last_name, h.salary
FROM employees e
JOIN high_salary h ON e.emp_no = h.emp_no;

-- CTE lồng nhau + GROUP BY
WITH avg_salary_dept AS (
    SELECT dept_no, AVG(salary) AS avg_sal
    FROM dept_emp
    JOIN salaries USING (emp_no)
    WHERE to_date = '9999-01-01'
    GROUP BY dept_no
)
SELECT d.dept_name, a.avg_sal
FROM departments d
JOIN avg_salary_dept a ON d.dept_no = a.dept_no
ORDER BY a.avg_sal DESC;

-- OLAP: GROUP BY ROLLUP
SELECT dept_no, YEAR(from_date) AS year, SUM(salary) AS total_salary
FROM dept_emp
JOIN salaries USING (emp_no)
GROUP BY ROLLUP (dept_no, YEAR(from_date));

-- OLAP: GROUP BY CUBE (nếu DBMS hỗ trợ)
SELECT dept_no, gender, COUNT(*) AS emp_count
FROM employees
JOIN dept_emp USING (emp_no)
GROUP BY CUBE (dept_no, gender);

-- Truy vấn cực nặng: nhiều CTE và Window Function
WITH recent_hires AS (
    SELECT emp_no, hire_date
    FROM employees
    WHERE hire_date > '1995-01-01'
),
salary_rank AS (
    SELECT emp_no, salary,
           RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM salaries
    WHERE to_date = '9999-01-01'
)
SELECT e.first_name, e.last_name, r.hire_date, s.salary, s.salary_rank
FROM employees e
JOIN recent_hires r ON e.emp_no = r.emp_no
JOIN salary_rank s ON e.emp_no = s.emp_no
WHERE s.salary_rank <= 100
ORDER BY s.salary DESC;

-- 📌 Phần 7 — Truy vấn Stress Test (kích thước lớn, ORDER BY, LIMIT OFFSET)
-- Truy vấn phân trang OFFSET lớn
SELECT emp_no, first_name, last_name
FROM employees
ORDER BY hire_date
LIMIT 50 OFFSET 100000;

-- ORDER BY nhiều cột
SELECT emp_no, first_name, last_name, hire_date
FROM employees
ORDER BY last_name, first_name, hire_date DESC
LIMIT 200;

-- ORDER BY không có LIMIT (rất nặng trên bảng lớn)
SELECT emp_no, first_name, last_name
FROM employees
ORDER BY birth_date;

-- DISTINCT + ORDER BY
SELECT DISTINCT title
FROM titles
ORDER BY title;

-- 📌 Phần 8 — Truy vấn Phức tạp Đặc biệt (Subquery lồng nhiều tầng, HAVING, UNION)
-- Subquery lồng nhiều tầng
SELECT emp_no, first_name, last_name
FROM employees
WHERE emp_no IN (
    SELECT emp_no
    FROM dept_emp
    WHERE dept_no IN (
        SELECT dept_no
        FROM departments
        WHERE dept_name LIKE 'S%'
    )
);

-- HAVING phức tạp
SELECT dept_no, COUNT(*) AS num_emp
FROM dept_emp
GROUP BY dept_no
HAVING COUNT(*) > 20000;

-- UNION ALL vs UNION
SELECT emp_no, salary
FROM salaries
WHERE to_date = '9999-01-01'
UNION
SELECT emp_no, 0 AS salary
FROM employees
WHERE hire_date > '2000-01-01';

-- Truy vấn EXISTS
SELECT e.emp_no, e.first_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM salaries s
    WHERE s.emp_no = e.emp_no AND s.salary > 120000
);

-- 📌 Phần 9 — Truy vấn JOIN nhiều bảng (3–4 bảng)
-- JOIN 3 bảng: employees + dept_emp + departments
SELECT e.emp_no, e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
WHERE d.dept_no = 'd005';

-- JOIN 4 bảng: employees + titles + salaries + dept_emp
SELECT e.emp_no, e.first_name, t.title, s.salary, de.dept_no
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de ON e.emp_no = de.emp_no
WHERE s.to_date = '9999-01-01' AND t.to_date = '9999-01-01';

-- JOIN LEFT + WHERE
SELECT e.emp_no, e.first_name, d.dept_name
FROM employees e
LEFT JOIN dept_emp de ON e.emp_no = de.emp_no
LEFT JOIN departments d ON de.dept_no = d.dept_no
WHERE d.dept_name IS NULL;

-- JOIN nhiều bảng + GROUP BY
SELECT d.dept_name, COUNT(DISTINCT e.emp_no) AS num_emp
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name
HAVING COUNT(DISTINCT e.emp_no) > 10000;

-- 📌 Phần 10 — Truy vấn phân tích thời gian (DATE, INTERVAL, YEAR, MONTH)
-- Lọc theo khoảng thời gian
SELECT emp_no, salary
FROM salaries
WHERE from_date >= '2000-01-01' AND to_date <= '2005-01-01';

-- Tính số năm làm việc
SELECT emp_no, TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS years_worked
FROM employees
ORDER BY years_worked DESC
LIMIT 50;

-- GROUP BY theo năm
SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS num_hired
FROM employees
GROUP BY hire_year
ORDER BY hire_year;

-- Lọc theo tháng
SELECT MONTH(hire_date) AS hire_month, COUNT(*) AS num_emp
FROM employees
GROUP BY hire_month
ORDER BY num_emp DESC;

-- Truy vấn với INTERVAL
SELECT emp_no, salary
FROM salaries
WHERE from_date > (CURDATE() - INTERVAL 10 YEAR);

-- 📌 Phần 11 — Truy vấn nâng cao với CTE (Common Table Expression) và Subquery
-- CTE: Tìm 10 nhân viên có lương cao nhất hiện tại
WITH top_salaries AS (
    SELECT emp_no, salary
    FROM salaries
    WHERE to_date = '9999-01-01'
    ORDER BY salary DESC
    LIMIT 10
)
SELECT e.emp_no, e.first_name, e.last_name, t.salary
FROM employees e
JOIN top_salaries t ON e.emp_no = t.emp_no;

-- CTE: Đếm số nhân viên theo chức danh
WITH title_counts AS (
    SELECT title, COUNT(*) AS cnt
    FROM titles
    GROUP BY title
)
SELECT * FROM title_counts ORDER BY cnt DESC;

-- Subquery trong WHERE
SELECT emp_no, first_name, last_name
FROM employees
WHERE emp_no IN (
    SELECT emp_no FROM dept_emp WHERE dept_no = 'd001'
);

-- Subquery trong SELECT
SELECT e.emp_no,
       (SELECT COUNT(*) FROM dept_emp de WHERE de.emp_no = e.emp_no) AS dept_count
FROM employees e
LIMIT 20;

-- Subquery với EXISTS
SELECT e.emp_no, e.first_name
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM salaries s WHERE s.emp_no = e.emp_no AND s.salary > 100000
);

-- 📌 Phần 12 — Truy vấn đặc biệt: FULLTEXT search, UNION, Window Function
-- FULLTEXT search (nếu có index FULLTEXT trên last_name)
SELECT emp_no, first_name, last_name
FROM employees
WHERE MATCH(last_name) AGAINST('Smith' IN NATURAL LANGUAGE MODE)
LIMIT 10;

-- UNION
SELECT emp_no, dept_no
FROM dept_emp
WHERE dept_no = 'd001'
UNION
SELECT emp_no, dept_no
FROM dept_emp
WHERE dept_no = 'd002';

-- UNION ALL
SELECT emp_no, dept_no FROM dept_emp WHERE dept_no = 'd003'
UNION ALL
SELECT emp_no, dept_no FROM dept_emp WHERE dept_no = 'd004';

-- Window Function: Ranking theo lương
SELECT emp_no, salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM salaries
WHERE to_date = '9999-01-01'
LIMIT 20;

-- Window Function: Trung bình lương theo phòng ban
SELECT d.dept_no, d.dept_name,
       AVG(s.salary) OVER (PARTITION BY d.dept_no) AS avg_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
LIMIT 20;

-- Window Function: Rolling Count theo năm
SELECT YEAR(hire_date) AS hire_year,
       COUNT(*) OVER (ORDER BY YEAR(hire_date)) AS cumulative_hires
FROM employees
LIMIT 30;

-- 📌 Phần 13 — Truy vấn cực nặng: CROSS JOIN, SELF JOIN, Nested Subquery
-- CROSS JOIN (cartesian product - rất nặng)
SELECT e.first_name, d.dept_name
FROM employees e
CROSS JOIN departments d
LIMIT 1000;

-- SELF JOIN: So sánh nhân viên theo ngày tuyển
SELECT e1.emp_no, e1.first_name, e2.emp_no, e2.first_name
FROM employees e1
JOIN employees e2 ON e1.hire_date = e2.hire_date
WHERE e1.emp_no < e2.emp_no
LIMIT 50;

-- Nested Subquery 2 tầng
SELECT emp_no, first_name, last_name
FROM employees
WHERE emp_no IN (
    SELECT emp_no FROM salaries WHERE salary > (
        SELECT AVG(salary) FROM salaries
    )
);

-- Nested Subquery 3 tầng (cực nặng khi dữ liệu lớn)
SELECT emp_no
FROM employees
WHERE emp_no IN (
    SELECT emp_no FROM dept_emp
    WHERE dept_no IN (
        SELECT dept_no FROM departments WHERE dept_name LIKE 'S%'
    )
);

-- Correlated Subquery
SELECT e.emp_no, e.first_name
FROM employees e
WHERE e.hire_date = (
    SELECT MIN(hire_date) FROM employees e2 WHERE e2.dept_no = e.dept_no
);

-- 📌 Phần 14 — Truy vấn đặc biệt: CASE WHEN, HAVING phức tạp, Truy vấn tổng hợp
-- CASE WHEN trong SELECT
SELECT emp_no, 
       CASE 
         WHEN gender = 'M' THEN 'Male'
         WHEN gender = 'F' THEN 'Female'
         ELSE 'Other'
       END AS gender_label
FROM employees
LIMIT 20;

-- HAVING phức tạp với nhiều điều kiện
SELECT dept_no, COUNT(*) AS num_emp, AVG(salary) AS avg_salary
FROM dept_emp de
JOIN salaries s ON de.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
GROUP BY dept_no
HAVING COUNT(*) > 1000 AND AVG(salary) > 60000;

-- Tổng hợp với ROLLUP
SELECT dept_no, COUNT(*) AS num_emp
FROM dept_emp
GROUP BY dept_no WITH ROLLUP;

-- Tổng hợp với CUBE (nếu DB hỗ trợ)
SELECT dept_no, title, COUNT(*) AS cnt
FROM dept_emp de
JOIN titles t ON de.emp_no = t.emp_no
GROUP BY dept_no, title WITH ROLLUP;

-- Pivot bằng CASE WHEN
SELECT dept_no,
       SUM(CASE WHEN gender='M' THEN 1 ELSE 0 END) AS num_male,
       SUM(CASE WHEN gender='F' THEN 1 ELSE 0 END) AS num_female
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
GROUP BY dept_no;

-- Query kết hợp ORDER BY, LIMIT, OFFSET
SELECT emp_no, salary
FROM salaries
WHERE to_date = '9999-01-01'
ORDER BY salary DESC
LIMIT 50 OFFSET 100;

-- 📌 Phần 15 — Cặp Truy Vấn Tối Ưu vs Không Tối Ưu
-- ❌ Không tối ưu: quét toàn bảng (sử dụng hàm trên cột)
SELECT * 
FROM employees
WHERE YEAR(hire_date) = 1995;

-- ✅ Tối ưu: dùng điều kiện range (có thể tận dụng chỉ mục)
SELECT *
FROM employees
WHERE hire_date BETWEEN '1995-01-01' AND '1995-12-31';

-- ❌ Không tối ưu: LIKE với ký tự đầu là '%'
SELECT *
FROM employees
WHERE last_name LIKE '%son';

-- ✅ Tối ưu: LIKE với prefix (có thể dùng index)
SELECT *
FROM employees
WHERE last_name LIKE 'Son%';

-- ❌ Không tối ưu: JOIN mà không có điều kiện
SELECT e.first_name, s.salary
FROM employees e
JOIN salaries s;

-- ✅ Tối ưu: JOIN có điều kiện khóa chính/ngoại
SELECT e.first_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no;

-- ❌ Không tối ưu: Đếm thủ công bằng subquery
SELECT COUNT(*)
FROM (SELECT emp_no FROM employees) t;

-- ✅ Tối ưu: Dùng COUNT(*) trực tiếp
SELECT COUNT(*)
FROM employees;

-- ❌ Không tối ưu: IN với tập con lớn
SELECT first_name, last_name
FROM employees
WHERE emp_no IN (
    SELECT emp_no FROM salaries WHERE salary > 80000
);

-- ✅ Tối ưu: EXISTS
SELECT e.first_name, e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM salaries s 
    WHERE s.emp_no = e.emp_no AND s.salary > 80000
);

-- ❌ Không tối ưu: SELECT *
SELECT *
FROM employees
WHERE emp_no < 1000;

-- ✅ Tối ưu: Chỉ lấy cột cần thiết
SELECT emp_no, first_name, last_name
FROM employees
WHERE emp_no < 1000;

-- 📌 Phần 16 — Truy vấn phức hợp nhiều mệnh đề
SELECT d.dept_name, AVG(s.salary) AS avg_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
GROUP BY d.dept_name
HAVING AVG(s.salary) > 60000
ORDER BY avg_salary DESC
LIMIT 5;

SELECT e.emp_no, e.first_name, e.last_name, e.hire_date, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
ORDER BY e.hire_date ASC, s.salary DESC
LIMIT 10;

SELECT d.dept_no, d.dept_name, COUNT(*) AS num_emps, AVG(s.salary) AS avg_sal
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
GROUP BY d.dept_no
HAVING COUNT(*) > 50 AND AVG(s.salary) < 55000
ORDER BY num_emps DESC;

SELECT e.emp_no, e.first_name, e.last_name, COUNT(*) AS num_salary_changes
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
GROUP BY e.emp_no
HAVING COUNT(*) > 5
ORDER BY num_salary_changes DESC
LIMIT 10;

SELECT e.emp_no, e.first_name, e.last_name, COUNT(DISTINCT t.title) AS num_titles
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
GROUP BY e.emp_no
HAVING COUNT(DISTINCT t.title) > 2
ORDER BY num_titles DESC, e.emp_no ASC
LIMIT 15;

SELECT dm.emp_no, e.first_name, e.last_name, s.salary, AVG(s2.salary) AS dept_avg
FROM dept_manager dm
JOIN employees e ON dm.emp_no = e.emp_no
JOIN salaries s ON dm.emp_no = s.emp_no AND s.to_date = '9999-01-01'
JOIN dept_emp de ON dm.dept_no = de.dept_no
JOIN salaries s2 ON de.emp_no = s2.emp_no AND s2.to_date = '9999-01-01'
GROUP BY dm.emp_no, e.first_name, e.last_name, s.salary
HAVING s.salary < AVG(s2.salary);

SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS hires
FROM employees
GROUP BY hire_year
HAVING COUNT(*) > 100
ORDER BY hires DESC
LIMIT 10;

SELECT s.salary, e.first_name, e.last_name, d.dept_name
FROM salaries s
JOIN employees e ON s.emp_no = e.emp_no
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
WHERE s.to_date = '9999-01-01'
AND s.salary IN (
    SELECT salary
    FROM salaries
    WHERE to_date = '9999-01-01'
    GROUP BY salary
    HAVING COUNT(DISTINCT emp_no) > 1
)
ORDER BY s.salary DESC
LIMIT 20;

-- 📌 Phần 17 — Window Functions nâng cao
SELECT d.dept_name, e.emp_no, e.first_name, e.last_name, s.salary,
       ROW_NUMBER() OVER (PARTITION BY d.dept_no ORDER BY s.salary DESC) AS rank_in_dept
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
LIMIT 50;

SELECT emp_no, salary, from_date,
       LAG(salary) OVER (PARTITION BY emp_no ORDER BY from_date) AS prev_salary
FROM salaries
ORDER BY emp_no, from_date
LIMIT 50;

SELECT emp_no, salary, from_date,
       LEAD(salary) OVER (PARTITION BY emp_no ORDER BY from_date) AS next_salary
FROM salaries
ORDER BY emp_no, from_date
LIMIT 50;

SELECT emp_no, salary,
       NTILE(4) OVER (ORDER BY salary DESC) AS salary_quartile
FROM salaries
WHERE to_date = '9999-01-01'
LIMIT 100;

SELECT emp_no, salary, from_date,
       AVG(salary) OVER (PARTITION BY emp_no ORDER BY from_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_salary
FROM salaries
ORDER BY emp_no, from_date
LIMIT 100;

SELECT YEAR(hire_date) AS hire_year, emp_no, first_name, last_name,
       RANK() OVER (PARTITION BY YEAR(hire_date) ORDER BY emp_no ASC) AS rank_in_year
FROM employees
LIMIT 50;

SELECT e.emp_no, e.first_name, e.last_name, d.dept_name, s.salary,
       s.salary - AVG(s.salary) OVER (PARTITION BY d.dept_no) AS diff_from_avg
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
LIMIT 50;

SELECT YEAR(hire_date) AS hire_year,
       COUNT(*) OVER (ORDER BY YEAR(hire_date) ROWS UNBOUNDED PRECEDING) AS cumulative_hires
FROM employees
LIMIT 50;

-- 📌 Phần 18 — Truy vấn cực nặng (Nested Subquery, Cross Join, Self Join)
SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
WHERE e.emp_no IN (
    SELECT emp_no FROM salaries
    WHERE salary > (
        SELECT AVG(salary) 
        FROM salaries 
        WHERE emp_no IN (
            SELECT emp_no FROM dept_emp WHERE dept_no = 'd005'
        )
    )
)
LIMIT 50;

SELECT e.emp_no, e.first_name, d.dept_no, d.dept_name
FROM employees e
CROSS JOIN departments d
LIMIT 200;

SELECT e1.emp_no, e1.first_name, e1.last_name, e2.emp_no AS emp_no2
FROM employees e1
JOIN employees e2 ON e1.last_name = e2.last_name
AND e1.emp_no <> e2.emp_no
LIMIT 100;

SELECT dept_no, COUNT(*) AS num_emps
FROM dept_emp
GROUP BY dept_no
HAVING COUNT(*) > (
    SELECT AVG(cnt)
    FROM (
        SELECT dept_no, COUNT(*) AS cnt
        FROM dept_emp
        GROUP BY dept_no
    ) t
);

SELECT e.emp_no, e.first_name, e.last_name, d.dept_name, s.salary, t.title
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
JOIN salaries s ON e.emp_no = s.emp_no
JOIN titles t ON e.emp_no = t.emp_no
WHERE s.to_date = '9999-01-01'
ORDER BY s.salary DESC
LIMIT 100;

SELECT sub.dept_no, AVG(sub.salary) AS avg_sal
FROM (
    SELECT d.dept_no, s.salary
    FROM departments d
    JOIN dept_emp de ON d.dept_no = de.dept_no
    JOIN salaries s ON de.emp_no = s.emp_no
    WHERE s.to_date = '9999-01-01'
) sub
GROUP BY sub.dept_no
ORDER BY avg_sal DESC;

SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
CROSS JOIN departments d
WHERE e.emp_no < 1000
AND d.dept_no IN ('d001', 'd002', 'd003');

SELECT e1.emp_no, e1.first_name, e1.last_name, e2.first_name AS colleague_name
FROM employees e1
JOIN employees e2 ON e1.hire_date = e2.hire_date
WHERE e1.emp_no <> e2.emp_no
AND e1.emp_no IN (
    SELECT emp_no FROM salaries WHERE salary > 90000
)
LIMIT 50;

-- 📌 Phần 19 — So sánh Truy vấn Tối ưu vs Không Tối ưu (Index & Tuning)
-- ❌ Không tối ưu: Không tận dụng index vì áp dụng hàm lên cột
SELECT * 
FROM employees
WHERE LOWER(last_name) = 'smith';

-- ✅ Tối ưu: Sử dụng điều kiện trực tiếp
SELECT *
FROM employees
WHERE last_name = 'Smith';

-- ❌ Không tối ưu: Subquery lặp lại nhiều lần
SELECT e.first_name, e.last_name
FROM employees e
WHERE e.emp_no IN (
    SELECT s.emp_no FROM salaries s WHERE s.salary > 100000
);

-- ✅ Tối ưu: JOIN trực tiếp
SELECT e.first_name, e.last_name
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.salary > 100000;

-- ❌ Không tối ưu: DISTINCT trên nhiều cột
SELECT DISTINCT e.emp_no, e.first_name, e.last_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no;

-- ✅ Tối ưu: GROUP BY (khi chỉ cần unique)
SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
GROUP BY e.emp_no, e.first_name, e.last_name;

-- ❌ Không tối ưu: ORDER BY toàn bộ bảng
SELECT *
FROM employees
ORDER BY last_name;

-- ✅ Tối ưu: ORDER BY với LIMIT (giảm chi phí)
SELECT *
FROM employees
ORDER BY last_name
LIMIT 50;

-- ❌ Không tối ưu: Đếm qua subquery
SELECT COUNT(*) 
FROM (SELECT emp_no FROM employees) t;

-- ✅ Tối ưu: Đếm trực tiếp
SELECT COUNT(*) 
FROM employees;

-- ❌ Không tối ưu: LEFT JOIN dư thừa
SELECT e.emp_no, e.first_name, s.salary
FROM employees e
LEFT JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01';

-- ✅ Tối ưu: INNER JOIN khi biết chắc chắn có dữ liệu
SELECT e.emp_no, e.first_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01';

-- ❌ Không tối ưu: IN với tập lớn
SELECT emp_no, first_name, last_name
FROM employees
WHERE emp_no IN (SELECT emp_no FROM dept_emp WHERE dept_no = 'd001');

-- ✅ Tối ưu: EXISTS
SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM dept_emp de 
    WHERE de.emp_no = e.emp_no AND de.dept_no = 'd001'
);

-- ❌ Không tối ưu: UNION (mặc định loại bỏ trùng, tốn thêm sort)
SELECT emp_no FROM dept_emp WHERE dept_no = 'd001'
UNION
SELECT emp_no FROM dept_emp WHERE dept_no = 'd002';

-- ✅ Tối ưu: UNION ALL (giữ trùng, nhanh hơn)
SELECT emp_no FROM dept_emp WHERE dept_no = 'd001'
UNION ALL
SELECT emp_no FROM dept_emp WHERE dept_no = 'd002';

-- 📌 Phần 20 — Truy vấn đặc biệt trong AI/Analytics
-- Lấy tên từ JSON field (giả sử bảng employees có cột json_info)
SELECT emp_no,
       JSON_EXTRACT(json_info, '$.skills') AS skills
FROM employees
LIMIT 20;

-- Tìm nhân viên có kỹ năng "AI"
SELECT emp_no
FROM employees
WHERE JSON_CONTAINS(json_info, '"AI"', '$.skills');

WITH active_salaries AS (
    SELECT emp_no, salary
    FROM salaries
    WHERE to_date = '9999-01-01'
),
high_salary AS (
    SELECT emp_no, salary
    FROM active_salaries
    WHERE salary > 100000
),
joined AS (
    SELECT e.emp_no, e.first_name, e.last_name, h.salary
    FROM employees e
    JOIN high_salary h ON e.emp_no = h.emp_no
)
SELECT * FROM joined
ORDER BY salary DESC
LIMIT 10;

WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n+1 FROM seq WHERE n < 10
)
SELECT * FROM seq;

SELECT emp_no, salary, from_date,
       LAG(salary, 1) OVER (PARTITION BY emp_no ORDER BY from_date) AS prev_sal,
       LEAD(salary, 1) OVER (PARTITION BY emp_no ORDER BY from_date) AS next_sal
FROM salaries
LIMIT 50;

SELECT dept_no,
       COUNT(*) AS total_emp,
       SUM(CASE WHEN gender='M' THEN 1 ELSE 0 END) AS male_count,
       SUM(CASE WHEN gender='F' THEN 1 ELSE 0 END) AS female_count
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
GROUP BY dept_no;

SELECT YEAR(from_date) AS year, AVG(salary) AS avg_salary
FROM salaries
GROUP BY YEAR(from_date)
ORDER BY year;

SELECT dept_no, gender, COUNT(*) AS cnt
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
GROUP BY dept_no, gender WITH ROLLUP;

SELECT dept_no, gender, COUNT(*) AS cnt
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
GROUP BY CUBE (dept_no, gender);

-- 📌 Phần 21 — Truy vấn thực tế trong doanh nghiệp (HR, KPI, báo cáo)
SELECT d.dept_no, d.dept_name, COUNT(e.emp_no) AS total_employees
FROM departments d
LEFT JOIN dept_emp de ON d.dept_no = de.dept_no
LEFT JOIN employees e ON de.emp_no = e.emp_no
GROUP BY d.dept_no, d.dept_name
ORDER BY total_employees DESC;

SELECT d.dept_name, AVG(s.salary) AS avg_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
GROUP BY d.dept_name
ORDER BY avg_salary DESC;

SELECT e.emp_no, e.first_name, e.last_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
ORDER BY s.salary DESC
LIMIT 10;

SELECT gender, COUNT(*) AS cnt, 
       ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM employees), 2) AS percent
FROM employees
GROUP BY gender;

SELECT e.emp_no, e.first_name, e.last_name, 
       TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) AS years_worked
FROM employees e
WHERE TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) > 20
ORDER BY years_worked DESC;

SELECT de.emp_no, d.dept_name, MAX(de.to_date) AS last_day
FROM dept_emp de
JOIN departments d ON de.dept_no = d.dept_no
WHERE de.to_date <> '9999-01-01'
GROUP BY de.emp_no, d.dept_name
ORDER BY last_day DESC
LIMIT 20;

SELECT d.dept_name,
       SUM(CASE WHEN e.gender='M' THEN 1 ELSE 0 END) AS male_count,
       SUM(CASE WHEN e.gender='F' THEN 1 ELSE 0 END) AS female_count
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_name
ORDER BY d.dept_name;

SELECT e.emp_no, e.first_name, e.last_name, COUNT(s.salary) AS salary_changes
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
GROUP BY e.emp_no
HAVING salary_changes > 5
ORDER BY salary_changes DESC;

-- 📌 Phần 22 — Truy vấn báo cáo tài chính & quản trị
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, 
       SUM(amount) AS total_revenue
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

SELECT YEAR(expense_date) AS year, 
       SUM(amount) AS total_expense
FROM expenses
GROUP BY YEAR(expense_date)
ORDER BY year;

SELECT CONCAT(YEAR(o.order_date), '-Q', QUARTER(o.order_date)) AS quarter,
       SUM(o.amount) - IFNULL(SUM(e.amount),0) AS profit
FROM orders o
LEFT JOIN expenses e ON QUARTER(o.order_date) = QUARTER(e.expense_date)
   AND YEAR(o.order_date) = YEAR(e.expense_date)
GROUP BY YEAR(o.order_date), QUARTER(o.order_date)
ORDER BY quarter;

SELECT c.customer_id, c.customer_name, SUM(o.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

SELECT p.product_id, p.product_name, 
       SUM(o.amount - p.cost_price*oi.quantity) AS total_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
GROUP BY p.product_id, p.product_name
ORDER BY total_profit DESC
LIMIT 10;

SELECT r.region_name, SUM(o.amount) AS revenue
FROM regions r
JOIN customers c ON r.region_id = c.region_id
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY r.region_name
ORDER BY revenue DESC;

SELECT YEAR(order_date) AS year, 
       SUM(amount) AS total_revenue
FROM orders
GROUP BY YEAR(order_date)
ORDER BY year;

SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, 
       SUM(amount) AS revenue,
       ROUND((SUM(amount) - LAG(SUM(amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')))
             / LAG(SUM(amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) * 100, 2) AS growth_rate
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- 📌 Phần 23 — Truy vấn OLAP nâng cao
SELECT YEAR(order_date) AS year,
       QUARTER(order_date) AS quarter,
       MONTH(order_date) AS month,
       SUM(amount) AS revenue
FROM orders
GROUP BY GROUPING SETS (
    (YEAR(order_date)),
    (YEAR(order_date), QUARTER(order_date)),
    (YEAR(order_date), QUARTER(order_date), MONTH(order_date))
)
ORDER BY year, quarter, month;

SELECT YEAR(order_date) AS year,
       MONTH(order_date) AS month,
       SUM(amount) AS revenue
FROM orders
GROUP BY ROLLUP (YEAR(order_date), MONTH(order_date));

SELECT r.region_name,
       p.category,
       SUM(o.amount) AS total_sales
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN regions r ON c.region_id = r.region_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY CUBE (r.region_name, p.category);

SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       SUM(amount) AS monthly_revenue,
       AVG(SUM(amount)) OVER (
            ORDER BY DATE_FORMAT(order_date, '%Y-%m')
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS moving_avg
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

SELECT c.customer_id, c.customer_name,
       SUM(o.amount) AS total_spent,
       RANK() OVER (ORDER BY SUM(o.amount) DESC) AS rank_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY rank_revenue;

SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       SUM(amount) AS revenue,
       LAG(SUM(amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS prev_month,
       SUM(amount) - LAG(SUM(amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS diff
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       SUM(amount) AS monthly_revenue,
       SUM(SUM(amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS cumulative_revenue
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

SELECT c.customer_id, c.customer_name,
       SUM(o.amount) AS total_spent,
       ROUND(PERCENT_RANK() OVER (ORDER BY SUM(o.amount)) * 100, 2) AS percentile_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

-- 📌 Phần 24 — Truy vấn phục vụ AI/ML & log analysis
SELECT q.query_id,
       q.query_text,
       l.exec_time,
       l.rows_examined,
       l.uses_index
FROM query_log l
JOIN queries q ON l.query_id = q.query_id
WHERE l.exec_time IS NOT NULL;

SELECT query_id, exec_time
FROM query_log
WHERE exec_time > (
    SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY exec_time)
    FROM query_log
);

SELECT COUNT(*) AS num_joins
FROM queries
WHERE query_text LIKE '%JOIN%';

SELECT
    SUM(CASE WHEN query_text LIKE '%GROUP BY%' THEN 1 ELSE 0 END) AS num_group_by,
    SUM(CASE WHEN query_text LIKE '%ORDER BY%' THEN 1 ELSE 0 END) AS num_order_by,
    SUM(CASE WHEN query_text LIKE '%LIKE%' THEN 1 ELSE 0 END) AS num_like
FROM queries;

SELECT query_id,
       CASE WHEN query_text LIKE '%JOIN%' THEN 1 ELSE 0 END AS has_join,
       CASE WHEN query_text LIKE '%GROUP BY%' THEN 1 ELSE 0 END AS has_group,
       CASE WHEN query_text LIKE '%LIKE%' THEN 1 ELSE 0 END AS has_like,
       exec_time
FROM query_log l
JOIN queries q ON l.query_id = q.query_id;

SELECT DATE(log_time) AS day,
       query_id,
       MAX(exec_time) AS max_exec_time
FROM query_log
GROUP BY DATE(log_time), query_id
ORDER BY day DESC;

SELECT query_id, query_text
FROM queries
WHERE query_text LIKE 'ERROR%' OR query_text LIKE 'EXPLAIN%';

SELECT query_id, AVG(rows_examined) AS avg_rows
FROM query_log
GROUP BY query_id
ORDER BY avg_rows DESC
LIMIT 5;

SELECT CORR(rows_examined, exec_time) AS correlation_value
FROM query_log;

SELECT WIDTH_BUCKET(exec_time, 0, 5, 10) AS bucket,
       COUNT(*) AS num_queries
FROM query_log
GROUP BY WIDTH_BUCKET(exec_time, 0, 5, 10)
ORDER BY bucket;

-- 📌 Phần 25 — Truy vấn Benchmark (TPC-H / TPC-DS Style)
SELECT c.nationkey, 
       SUM(l.extendedprice * (1 - l.discount)) AS revenue
FROM customer c
JOIN orders o ON c.custkey = o.custkey
JOIN lineitem l ON o.orderkey = l.orderkey
WHERE o.orderdate >= DATE '1995-01-01'
  AND o.orderdate < DATE '1996-01-01'
  AND l.returnflag = 'R'
GROUP BY c.nationkey
ORDER BY revenue DESC;

SELECT s.suppkey,
       SUM(l.extendedprice * (1 - l.discount) - ps.supplycost * l.quantity) AS profit
FROM part p
JOIN partsupp ps ON p.partkey = ps.partkey
JOIN supplier s ON ps.suppkey = s.suppkey
JOIN lineitem l ON l.partkey = p.partkey AND l.suppkey = s.suppkey
WHERE p.name LIKE '%green%'
GROUP BY s.suppkey
ORDER BY profit DESC
LIMIT 10;

SELECT i.item_id,
       d.year,
       SUM(ss.sales_price) AS total_sales
FROM store_sales ss
JOIN item i ON ss.item_id = i.item_id
JOIN date_dim d ON ss.sold_date_sk = d.date_sk
GROUP BY i.item_id, d.year
ORDER BY total_sales DESC;

SELECT i.category,
       COUNT(CASE WHEN sr.return_quantity > 0 THEN 1 END) * 100.0 / COUNT(*) AS return_rate
FROM store_sales ss
JOIN store_returns sr ON ss.item_id = sr.item_id
JOIN item i ON ss.item_id = i.item_id
GROUP BY i.category
ORDER BY return_rate DESC;

SELECT c.region,
       d.year,
       d.quarter,
       SUM(ws.sales_price) AS revenue
FROM web_sales ws
JOIN customer c ON ws.customer_id = c.customer_id
JOIN date_dim d ON ws.sold_date_sk = d.date_sk
GROUP BY c.region, d.year, d.quarter
ORDER BY revenue DESC;

SELECT c.customer_id,
       SUM(ws.sales_price) AS total_spent
FROM web_sales ws
JOIN customer c ON ws.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING SUM(ws.sales_price) > 100000
ORDER BY total_spent DESC;

SELECT i.item_id, 
       SUM(inv.quantity_on_hand) AS stock,
       SUM(ss.sales_price) AS sold
FROM inventory inv
JOIN item i ON inv.item_id = i.item_id
LEFT JOIN store_sales ss ON ss.item_id = i.item_id
GROUP BY i.item_id
HAVING SUM(inv.quantity_on_hand) > SUM(ss.sales_price) * 2
ORDER BY stock DESC;

SELECT i.item_id,
       SUM(ss.sales_price - ss.cost) AS profit_margin
FROM store_sales ss
JOIN item i ON ss.item_id = i.item_id
GROUP BY i.item_id
ORDER BY profit_margin DESC
LIMIT 5;

SELECT c.income_band,
       c.age_band,
       COUNT(*) AS num_customers
FROM customer c
GROUP BY c.income_band, c.age_band
ORDER BY num_customers DESC;

SELECT d.month,
       SUM(ss.sales_price) AS total_sales
FROM store_sales ss
JOIN date_dim d ON ss.sold_date_sk = d.date_sk
GROUP BY d.month
ORDER BY total_sales DESC;

-- 📌 Phần 26 — Truy vấn Phức hợp Nâng cao
SELECT e.employee_id, e.name, e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary) 
    FROM employees 
    WHERE department_id = e.department_id
);

SELECT dept_id, AVG(avg_salary) AS dept_avg
FROM (
    SELECT department_id AS dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) sub
GROUP BY dept_id;

SELECT c.customer_id, c.name,
       (SELECT COUNT(*) 
        FROM orders o 
        WHERE o.customer_id = c.customer_id) AS total_orders
FROM customers c;

WITH sales_per_month AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(total_amount) AS revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month, revenue
FROM sales_per_month
ORDER BY revenue DESC;

WITH RECURSIVE emp_hierarchy AS (
    SELECT employee_id, name, manager_id, 0 AS level
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.name, e.manager_id, h.level + 1
    FROM employees e
    JOIN emp_hierarchy h ON e.manager_id = h.employee_id
)
SELECT * FROM emp_hierarchy
ORDER BY level, employee_id;

SELECT customer_id, order_id, total_amount,
       RANK() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS rank_in_customer
FROM orders;

SELECT product_id, sales_month, sales_amount,
       ROW_NUMBER() OVER (PARTITION BY sales_month ORDER BY sales_amount DESC) AS row_num
FROM monthly_sales;

SELECT order_id, order_date, total_amount,
       SUM(total_amount) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders;

SELECT product_id, sales_month, sales_amount,
       LAG(sales_amount, 1, 0) OVER (PARTITION BY product_id ORDER BY sales_month) AS prev_sales
FROM monthly_sales;

SELECT product_id, sales_month, sales_amount,
       LEAD(sales_amount, 1, 0) OVER (PARTITION BY product_id ORDER BY sales_month) AS next_sales
FROM monthly_sales;

-- 📌 Phần 27 — Truy vấn Tối ưu hóa & Kịch bản Đặc biệt
SELECT SQL_NO_CACHE *
FROM orders FORCE INDEX (idx_customer_date)
WHERE customer_id = 123
ORDER BY order_date DESC
LIMIT 10;

SELECT *
FROM products USE INDEX (idx_category_price)
WHERE category_id = 5
AND price > 500;

SELECT *
FROM employees IGNORE INDEX (idx_department)
WHERE department_id = 10;

SELECT customer_id, order_date, total_amount
FROM orders
WHERE total_amount > 500
UNION
SELECT customer_id, order_date, total_amount
FROM archive_orders
WHERE total_amount > 500;

SELECT product_id, quantity
FROM order_items
WHERE quantity > 10
UNION ALL
SELECT product_id, quantity
FROM backup_order_items
WHERE quantity > 10;

SELECT c.customer_id, c.name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.total_amount > 1000
);

SELECT e.employee_id, e.name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.salesperson_id = e.employee_id
);

SELECT order_id,
       total_amount,
       CASE 
            WHEN total_amount >= 1000 THEN 'VIP Order'
            WHEN total_amount BETWEEN 500 AND 999 THEN 'Medium Order'
            ELSE 'Normal Order'
       END AS order_type
FROM orders;

SELECT product_id, name, stock
FROM products
ORDER BY 
    CASE 
        WHEN stock = 0 THEN 1
        ELSE 0
    END, name;

SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 100000, 50;

-- 📌 Phần 28 — Truy vấn Phân vùng Dữ liệu & Giả lập Dữ liệu Lớn
SELECT *
FROM orders_partitioned
WHERE order_date >= '2023-01-01'
  AND order_date < '2023-02-01';

SELECT *
FROM customers_partitioned
WHERE customer_id = 1054321;

SELECT YEAR(order_date) AS year, SUM(total_amount) AS revenue
FROM orders_partitioned
GROUP BY YEAR(order_date);

SELECT o.order_id, o.total_amount, c.name
FROM orders_partitioned o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2023-06-01';

SELECT COUNT(DISTINCT customer_id) AS active_customers
FROM orders_partitioned
WHERE order_date >= '2023-01-01';

SELECT *
FROM orders_partitioned
WHERE customer_id IN (
    SELECT customer_id
    FROM customers
    WHERE country = 'Japan'
);

SELECT * FROM orders_partitioned_2023
UNION ALL
SELECT * FROM orders_partitioned_2024;

SELECT order_id, customer_id, total_amount,
       RANK() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS rank_in_customer
FROM orders_partitioned;

WITH high_value_orders AS (
    SELECT order_id, customer_id, total_amount
    FROM orders_partitioned
    WHERE total_amount > 5000
)
SELECT c.name, COUNT(h.order_id) AS num_high_orders
FROM high_value_orders h
JOIN customers c ON h.customer_id = c.customer_id
GROUP BY c.name;

SELECT *
FROM orders_partitioned
ORDER BY order_date DESC
LIMIT 1000000, 100;

-- 📌 Phần 29 — Truy vấn Nâng cao với Stored Procedures, Views, Materialized Views
CREATE VIEW high_value_customers AS
SELECT customer_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > 10000;

SELECT * FROM high_value_customers;

CREATE VIEW customer_order_summary AS
SELECT c.customer_id, c.name, COUNT(o.order_id) AS num_orders, SUM(o.total_amount) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

SELECT * FROM customer_order_summary WHERE revenue > 5000;

CREATE TABLE mv_monthly_sales AS
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, SUM(total_amount) AS revenue
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date);

SELECT * FROM mv_monthly_sales WHERE revenue > 20000;

DELIMITER //
CREATE PROCEDURE GetCustomerOrders(IN cid INT)
BEGIN
    SELECT * FROM orders WHERE customer_id = cid;
END //
DELIMITER ;

CALL GetCustomerOrders(123);

DELIMITER //
CREATE PROCEDURE GetCustomerCategory(IN cid INT)
BEGIN
    DECLARE total_spent DECIMAL(10,2);
    SELECT SUM(total_amount) INTO total_spent FROM orders WHERE customer_id = cid;

    IF total_spent >= 10000 THEN
        SELECT 'VIP';
    ELSE
        SELECT 'NORMAL';
    END IF;
END //
DELIMITER ;

CALL GetCustomerCategory(456);

DELIMITER //
CREATE PROCEDURE ListLargeOrders()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE oid INT;
    DECLARE cur CURSOR FOR SELECT order_id FROM orders WHERE total_amount > 5000;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO oid;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT oid;
    END LOOP;
    CLOSE cur;
END //
DELIMITER ;

CALL ListLargeOrders();

SELECT hvc.customer_id, hvc.total_spent, cos.num_orders
FROM high_value_customers hvc
JOIN customer_order_summary cos ON hvc.customer_id = cos.customer_id
WHERE cos.num_orders > 20;

CREATE VIEW top_orders_per_customer AS
SELECT order_id, customer_id, total_amount,
       RANK() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS rank_in_customer
FROM orders;

SELECT * FROM top_orders_per_customer WHERE rank_in_customer <= 3;

CREATE VIEW recent_large_orders AS
SELECT order_id, customer_id, total_amount
FROM orders
WHERE total_amount > (
    SELECT AVG(total_amount) FROM orders
)
AND order_date >= '2024-01-01';

SELECT * FROM recent_large_orders;

DELIMITER //
CREATE PROCEDURE GetOrdersAfterDate(IN input_date DATE)
BEGIN
    SELECT * FROM orders WHERE order_date >= input_date;
END //
DELIMITER ;

CALL GetOrdersAfterDate('2024-06-01');

-- 📌 Phần 30 — Truy vấn bảo mật & Kiểm soát truy cập
CREATE USER 'report_user'@'%' IDENTIFIED BY 'StrongPass123!';
GRANT SELECT ON sales.* TO 'report_user'@'%';

GRANT UPDATE (price, stock) ON sales.products TO 'inventory_mgr'@'localhost';

REVOKE UPDATE ON sales.products FROM 'inventory_mgr'@'localhost';

SHOW GRANTS FOR 'report_user'@'%';

SELECT user, host, db, command, time, state
FROM information_schema.processlist
WHERE time > 10;

SELECT * FROM users WHERE username = 'admin' OR '1'='1';

SELECT id, username, password FROM users WHERE id = 1
UNION SELECT 1, 'hacker', 'guess';

SELECT * FROM users WHERE username = 'test'
AND password = '' OR 1=1; --';

CREATE ROLE data_analyst;
GRANT SELECT, SHOW VIEW ON sales.* TO data_analyst;
GRANT data_analyst TO 'alice'@'localhost';

SELECT user, host FROM mysql.user WHERE Super_priv = 'Y';

SELECT user, COUNT(*) AS failed_attempts
FROM login_logs
WHERE status = 'FAILED'
GROUP BY user
HAVING COUNT(*) > 3;

SHOW GRANTS FOR 'alice'@'localhost';

DELIMITER //
CREATE PROCEDURE SecureSelect(IN tbl_name VARCHAR(64))
BEGIN
    IF EXISTS (SELECT * FROM information_schema.table_privileges
               WHERE grantee = CURRENT_USER() AND table_name = tbl_name) THEN
        SET @s = CONCAT('SELECT * FROM ', tbl_name, ' LIMIT 10');
        PREPARE stmt FROM @s;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ELSE
        SELECT 'Permission Denied' AS msg;
    END IF;
END //
DELIMITER ;

CALL SecureSelect('orders');

-- ================================
-- FAST QUERIES PACK (~100 queries)
-- ================================

-- 🔹 Truy vấn PK / chỉ số đơn giản
SELECT * FROM employees WHERE emp_no = 10001;
SELECT * FROM employees WHERE emp_no = 10005;
SELECT first_name, last_name FROM employees WHERE emp_no = 10010;
SELECT hire_date FROM employees WHERE emp_no = 10020;

-- 🔹 LIMIT nhỏ
SELECT * FROM employees LIMIT 1;
SELECT * FROM employees LIMIT 5;
SELECT emp_no, first_name FROM employees LIMIT 10;
SELECT first_name, last_name, gender FROM employees LIMIT 20;

-- 🔹 COUNT / aggregate nhanh
SELECT COUNT(*) FROM departments;
SELECT COUNT(*) FROM employees WHERE gender = 'M';
SELECT AVG(salary) FROM salaries WHERE to_date > '1999-01-01';
SELECT MIN(hire_date) FROM employees;
SELECT MAX(salary) FROM salaries;

-- 🔹 DISTINCT
SELECT DISTINCT dept_no FROM dept_emp;
SELECT DISTINCT dept_name FROM departments;
SELECT DISTINCT gender FROM employees;

-- 🔹 BETWEEN (trên index)
SELECT * FROM salaries WHERE salary BETWEEN 60000 AND 60500 LIMIT 10;
SELECT * FROM employees WHERE emp_no BETWEEN 10001 AND 10020;

-- 🔹 ORDER BY + LIMIT
SELECT emp_no FROM employees ORDER BY emp_no ASC LIMIT 10;
SELECT hire_date FROM employees ORDER BY hire_date DESC LIMIT 5;
SELECT salary FROM salaries ORDER BY salary ASC LIMIT 10;

-- 🔹 GROUP BY nhỏ
SELECT dept_no, COUNT(*) FROM departments GROUP BY dept_no;
SELECT gender, COUNT(*) FROM employees GROUP BY gender;

-- 🔹 EXISTS / IN nhỏ
SELECT EXISTS(SELECT 1 FROM employees WHERE emp_no = 10001);
SELECT * FROM employees WHERE emp_no IN (10001,10002,10003);
SELECT * FROM employees WHERE emp_no NOT IN (10001,10002,10003) LIMIT 5;

-- 🔹 Subquery scalar
SELECT * FROM employees WHERE emp_no = (SELECT MIN(emp_no) FROM employees);
SELECT first_name FROM employees WHERE emp_no = (SELECT MAX(emp_no) FROM employees);

-- 🔹 JOIN có index
SELECT e.first_name, d.dept_no
FROM employees e
JOIN dept_emp d ON e.emp_no = d.emp_no
WHERE d.dept_no = 'd001' LIMIT 10;

SELECT e.emp_no, t.title
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
WHERE t.title = 'Engineer' LIMIT 10;

-- 🔹 Hàm đơn giản
SELECT YEAR(hire_date) FROM employees LIMIT 10;
SELECT LENGTH(first_name) FROM employees LIMIT 10;
SELECT UPPER(last_name) FROM employees LIMIT 5;

-- 🔹 Các query nhỏ khác để đa dạng
SELECT * FROM departments;
SELECT dept_no, dept_name FROM departments WHERE dept_no = 'd001';
SELECT emp_no FROM dept_emp WHERE dept_no = 'd002' LIMIT 10;
SELECT * FROM titles WHERE title = 'Manager' LIMIT 5;
SELECT COUNT(*) FROM salaries WHERE salary > 100000;

-- 🔹 Repeat patterns with variations (to reach ~100 queries)
SELECT * FROM employees WHERE emp_no = 10030;
SELECT * FROM employees WHERE emp_no = 10040;
SELECT * FROM employees WHERE emp_no = 10050;
SELECT * FROM employees WHERE emp_no = 10060;
SELECT * FROM employees WHERE emp_no = 10070;
SELECT * FROM employees WHERE emp_no = 10080;
SELECT * FROM employees WHERE emp_no = 10090;
SELECT * FROM employees WHERE emp_no = 10100;
SELECT * FROM employees WHERE emp_no = 10110;
SELECT * FROM employees WHERE emp_no = 10120;

SELECT first_name FROM employees WHERE emp_no = 10130;
SELECT first_name FROM employees WHERE emp_no = 10140;
SELECT first_name FROM employees WHERE emp_no = 10150;
SELECT first_name FROM employees WHERE emp_no = 10160;
SELECT first_name FROM employees WHERE emp_no = 10170;
SELECT first_name FROM employees WHERE emp_no = 10180;
SELECT first_name FROM employees WHERE emp_no = 10190;
SELECT first_name FROM employees WHERE emp_no = 10200;

SELECT * FROM salaries WHERE emp_no = 10001 LIMIT 1;
SELECT * FROM salaries WHERE emp_no = 10005 LIMIT 1;
SELECT * FROM salaries WHERE emp_no = 10010 LIMIT 1;
SELECT * FROM salaries WHERE emp_no = 10020 LIMIT 1;
SELECT * FROM salaries WHERE emp_no = 10030 LIMIT 1;

SELECT * FROM titles WHERE emp_no = 10001 LIMIT 1;
SELECT * FROM titles WHERE emp_no = 10005 LIMIT 1;
SELECT * FROM titles WHERE emp_no = 10010 LIMIT 1;

SELECT COUNT(*) FROM dept_emp WHERE dept_no = 'd003';
SELECT COUNT(*) FROM dept_emp WHERE dept_no = 'd004';
SELECT COUNT(*) FROM dept_emp WHERE dept_no = 'd005';

SELECT dept_no FROM dept_manager LIMIT 5;
SELECT emp_no FROM dept_manager WHERE dept_no = 'd001';
SELECT emp_no FROM dept_manager WHERE dept_no = 'd002';

-- 🔹 Query với điều kiện LIKE có prefix (sử dụng index nên nhanh)
SELECT * FROM employees WHERE last_name LIKE 'Smi%';
SELECT * FROM employees WHERE first_name LIKE 'An%';

-- 🔹 Query với IS NULL / IS NOT NULL (trên cột index)
SELECT * FROM employees WHERE hire_date IS NOT NULL LIMIT 10;
SELECT * FROM titles WHERE to_date IS NULL LIMIT 10;

-- 🔹 Query với ORDER BY trên cột có index + LIMIT
SELECT emp_no, hire_date FROM employees ORDER BY emp_no ASC LIMIT 5;
SELECT emp_no, hire_date FROM employees ORDER BY hire_date DESC LIMIT 5;

-- 🔹 Query với hàm ngày đơn giản
SELECT YEAR(hire_date) AS year_hired FROM employees LIMIT 5;
SELECT MONTH(hire_date) AS month_hired FROM employees LIMIT 5;

-- 🔹 Query với toán tử IN nhỏ (trên PK → nhanh)
SELECT * FROM employees WHERE emp_no IN (10001, 10002, 10003, 10004);
SELECT first_name FROM employees WHERE emp_no IN (10005, 10006);

-- 🔹 Query trên bảng nhỏ (departments)
SELECT * FROM departments;
SELECT dept_no FROM departments ORDER BY dept_no;
SELECT COUNT(*) FROM departments;

-- 🔹 Query JOIN có index + LIMIT nhỏ
SELECT e.emp_no, d.dept_no
FROM employees e
JOIN dept_emp d ON e.emp_no = d.emp_no
WHERE d.dept_no = 'd006'
LIMIT 5;

SELECT e.first_name, t.title
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
WHERE t.title = 'Staff'
LIMIT 5;

-- 🔹 Query aggregate có điều kiện đơn giản
SELECT AVG(salary) FROM salaries WHERE from_date > '1990-01-01';
SELECT MAX(hire_date) FROM employees WHERE gender = 'F';

-- 🔹 Query kiểm tra tồn tại (EXISTS)
SELECT EXISTS(SELECT 1 FROM dept_manager WHERE dept_no = 'd001');
SELECT EXISTS(SELECT 1 FROM employees WHERE emp_no = 10001);

-- 🔹 Query chỉ lấy 1 cột + LIMIT
SELECT emp_no FROM employees LIMIT 10;
SELECT salary FROM salaries LIMIT 10;

-- 🔹 Query với ORDER BY + LIMIT + điều kiện
SELECT emp_no, salary FROM salaries WHERE emp_no = 10001 ORDER BY from_date DESC LIMIT 1;

-- 🔹 Query NOT IN nhỏ
SELECT * FROM employees WHERE emp_no NOT IN (10001, 10002) LIMIT 5;
