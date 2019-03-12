--*********************************************************
--Name:         Wenxuan Liu
--ID:           160678173/140777178/155695174/125838177
--Date:         2019/02/16
--Purpose:      Assignment 1 - DBS301
--*********************************************************

-- Question 1
--1.	Display the employee number, full employee name, job and hire date of all employees hired in May or November of any 
--      year, with the most recently hired employees displayed first. 
--�	Also, exclude people hired in 2014 and 2015.  
--�	Full name should be in the form Lastname,  Firstname  with an alias called Full Name.
--�	Hire date should point to the last day in May or November of that year (NOT to the exact day) and be in the form of [May 
--  31<st,nd,rd,th> of 2016] with the heading Start Date. Do NOT use LIKE operator. 
--�	<st,nd,rd,th> means days that end in a 1, should have �st�, days that end in a 2 should have �nd�, days that end in a 3
--  should have �rd� and all others should have �th�
--�	You should display ONE row per output line by limiting the width of the Full Name to 25 characters. 
--  The output lines should look like this line:

--QUESTION 1 SOLUTION
SELECT rpad(employee_id,11) AS "Employee Num",
       substr(last_name ||', '||first_name, 0, 25) AS "Full Name",
       job_id,
       to_char(hire_date,'"["fmMonth ddth" of "yyyy"]"') AS "Hire Date"
    FROM employees
    WHERE extract(Month FROM hire_date) IN (5,11)
            AND extract(Year FROM hire_date) NOT IN (2014,2015)
    ORDER BY hire_date DESC;

-- Question 2
--List the employee number, full name, job and the modified salary for all employees whose monthly earning (without this 
--increase) is outside the range $5,000 � $10,000 and who are employed as Vice Presidents or Managers 
--(President is not counted here).  
--�	You should use Wild Card characters for this. 
--�	VP�s will get 25% and managers 18% salary increase.  
--�	Sort the output by the top salaries (before this increase) firstly.
--�	Heading will be like Employees with increased Pay
--�	The output lines should look like this sample line:

--QUESTION 2 SOLUTION

SELECT 'Emp# '||employee_id||' named '||first_name||' '||last_name||' who is '||job_id ||' will have a new salary of '||
        (CASE  
            WHEN job_id LIKE '%VP%' THEN to_char(1.25*salary,'fm$999,999')
            ELSE to_char(1.18*salary,'fm$999,999')
         END
        ) 
        AS "Employees with increased Pay"
    FROM employees 
    WHERE (salary NOT BETWEEN 5000 AND 10000)
            AND (job_id LIKE '%VP%' OR  employee_id IN (
                SELECT DISTINCT m.employee_id 
                    FROM employees e INNER JOIN employees m
                ON e.manager_id=m.employee_id) 
            )
    ORDER BY salary DESC;
    
-- Question 3
--Display the employee last name, salary, job title and manager# of all employees not earning a commission OR if
--they work in the SALES department, but only  if their total monthly salary with $1000 included bonus and  
--commission (if  earned) is  greater  than  $15,000.  
--�	Let�s assume that all employees receive this bonus.
--�	If an employee does not have a manager, then display the word NONE 
--�	instead. This column should have an alias Manager#.
--�	Display the Total annual salary as well in the form of $135,600.00 with the 
--�	heading Total Income. Sort the result so that best paid employees are shown first.
--�	The output lines should look like this sample line:

--QUESTION 3 SOLUTION

SELECT last_name,to_char(salary),job_id, NVL(to_char(manager_id),'NONE') AS "Manager#",
        to_char((salary*(1+ NVL(commission_pct,0))+1000)*12, '$999,999.99') AS  "Total Income"
    FROM employees
    WHERE commission_pct IS NULL OR
        (employee_id IN (
            SELECT employee_id
                FROM employees 
                WHERE department_id IN (
                    SELECT department_id
                        FROM departments
                        WHERE upper(department_name) = 'SALES'
                )
                AND salary+1000+ NVL(commission_pct,0)*salary>15000)
        )
    ORDER BY "Total Income" DESC;
    
-- Question 4
--Display Department_id, Job_id and the Lowest salary for this combination under the alias Lowest Dept/Job Pay, 
--but only if that Lowest Pay falls in the range $6000 - $18000. Exclude people who work as some kind of 
--Representative job from this query and departments IT and SALES as well.
--�	Sort the output according to the Department_id and then by Job_id.
--�	You MUST NOT use the Subquery method.

--QUESTION 4 SOLUTION

SELECT department_id AS "Department ID", job_id AS "Job ID",  
        to_char(min(salary),'$999,999') AS "Lowest Dept/Job Pay" 
    FROM departments  RIGHT OUTER JOIN employees  USING(department_id)       
    WHERE upper(department_name) NOT IN ('IT','SALES') 
        AND upper(job_id) NOT LIKE '%REP%'
    GROUP BY department_id,job_id
    HAVING (min(salary) BETWEEN 6000 AND 18000)
    ORDER BY department_id,job_id;
    
-- Question 5
--Display last_name, salary and job for all employees who earn more than all lowest paid 
--employees per department outside the US locations.
--�	Exclude President and Vice Presidents from this query.
--�	Sort the output by job title ascending.
--�	You need to use a Subquery and Joining.

--QUESTION 5 SOLUTION

SELECT last_name,to_char(salary,'$999,999.99') AS "Salary",job_id 
    FROM employees LEFT OUTER JOIN departments USING(department_id)
        LEFT OUTER JOIN locations USING (location_id)
    WHERE salary > ANY (
        SELECT min(salary)
            FROM employees
            GROUP BY department_id)
        AND upper(job_id) NOT LIKE '%VP%' 
        AND upper(job_id) NOT LIKE '%PRES%'
        AND upper(country_id)!= 'US'
    ORDER BY job_id;
    
-- Question 6
--Who are the employees (show last_name, salary and job) who work either in IT or MARKETING department and 
--earn more than the worst paid person in the ACCOUNTING department. 
--�	Sort the output by the last name alphabetically.
--�	You need to use ONLY the Subquery method (NO joins allowed).

--QUESTION 6 SOLUTION

SELECT last_name,to_char(salary,'$999,999.99') AS "Salary",job_id
    FROM employees
    WHERE department_id IN (
        SELECT department_id
            FROM departments
            WHERE upper(department_name) IN ( 'IT','MARKETING')
    )
        AND salary > (
            SELECT min(salary)
                FROM employees
                WHERE department_id =  (
                    SELECT department_id
                        FROM departments
                        WHERE upper(department_name) = 'ACCOUNTING')
        )
    ORDER BY last_name;
 
-- Question 7
--Display alphabetically the full name, job, salary (formatted as a currency amount incl. thousand separator, 
--but no decimals) and department number for each employee who earns less than the best paid unionized employee 
--(i.e. not the president nor any manager nor any VP), and who work in either SALES or MARKETING department.  
--�	Full name should be displayed as Firstname  Lastname and should have the heading Employee. 
--�	Salary should be left-padded with the = symbol till the width of 15 characters. It should have an alias Salary.
--�	You should display ONE row per output line by limiting the width of the 	Employee to 25 characters.
--�	The output lines should look like this sample line:

--QUESTION 7 SOLUTION

SELECT substr(first_name|| ' '||last_name,0,25) AS "Employee", job_id,
        LPAD(to_char(salary,'$999,999'),15,'=') AS "Salary",department_id
    FROM employees 
    WHERE salary < (
        SELECT max(salary)
            FROM employees
            WHERE job_id NOT LIKE '%VP%' 
                AND job_id NOT LIKE '%PRES%'
                AND employee_id NOT IN (
                    SELECT NVL(manager_id,0)
                        FROM departments)
        )
        AND job_id NOT LIKE '%VP%' 
                AND job_id NOT LIKE '%PRES%'
                AND employee_id NOT IN (
                    SELECT NVL(manager_id,0)
                        FROM departments)
        AND department_id IN (
            SELECT department_id
                FROM departments
                WHERE upper(department_name) IN ( 'SALES','MARKETING')
        );
        --Employee with ID 178 not belong into the departments of sales and marketing, so he is not in The records
        
-- Question 8
--Display department name, city and number of different jobs in each department. If city is null, you should print Not Assigned Yet.
--�	This column should have alias City.
--�	Column that shows # of different jobs in a department should have the heading # of Jobs
--�	You should display ONE row per output line by limiting the width of the City to 25 characters.
--�	You need to show complete situation from the EMPLOYEE point of view, meaning include also employees 
--  who work for NO department (but do NOT display empty departments) and from the CITY point of view 
--  meaning you need to display all cities without departments as well.

--QUESTION 8 SOLUTION

SELECT
    (CASE 
        WHEN department_name IS NULL THEN 'Not Assigned Yet'
        ELSE department_name
    END)  AS "Dept Name",
    substr((CASE 
        WHEN city IS NULL THEN 'Not Assigned Yet'
        ELSE city
     END ),0,25) AS "City",
    count(DISTINCT job_id)AS "# of Jobs"
    FROM employees LEFT OUTER JOIN departments 
        USING(department_id)
            RIGHT OUTER JOIN  locations  USING(location_id)
    GROUP BY   (CASE WHEN department_name IS NULL THEN 'Not Assigned Yet' ELSE department_name END), 
                substr((CASE WHEN city IS NULL THEN 'Not Assigned Yet' ELSE city END ),0,25);
        