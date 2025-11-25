-- --------------Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
-- a)
use classicmodels;

select * from employees;
select employeeNumber,firstName,lastName 
from employees
where jobTitle = "Sales Rep" 
and reportsto =1102;

-- b)
select distinct productline
from products 
where productLine like "%cars";

-- ================================================================

-- --------------Q2. CASE STATEMENTS for Segmentation
select * from customers;

select customerNumber,customerName,
case
when country In( "USA","Canada")
then 
"North America"
when country In("Uk","France","Germany")
then 
"Europe"
Else
"Other"
End CustomerSegment
from customers;

-- =========================================================================================

-- --------------Q3. Group By with Aggregation functions and Having clause, Date and Time functions
/* 
a.	Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.
*/
select * from orderdetails;
select productCode,sum(quantityOrdered) TotalQuantity
from orderdetails
group by productCode
order by TotalQuantity desc
limit 10;

/* b.	Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total 
number of payments for each month and include only those
 months with a payment count exceeding 20. Sort the results by total number of payments in descending order.  (Refer Payments table).  */

select * from payments;
select monthname(paymentDate) Payment_Month,
count(*) num_payment
from payments
group by Payment_Month
having count(*) > 20
order by num_payment desc;

-- ===========================================================================================================

-- ------------ Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default

create database Customers_order;
use Customers_order;

create table Customers
(customer_id int primary key auto_increment,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(50) unique ,
phone_number varchar(20)
);

insert Customers value
(101,"Kiran","Bawane","bawaneki89@gmail.com","+91-3456789"),
(102,"Pooja","Bawane","bawanepooja78@gmail.com","+91-45663"),
(103,"SOnu","Thakre","thakresonu67@gmail,com","+91-234569"),
(104,"Tanusha","Sahu","sahutanu67@gmail.com","+91-456789");
select * from Customers;

 create table Orders 
 (order_id int primary key auto_increment,
 customer_id int,
 order_date date ,
 total_amount decimal(10,2) ,
 check(total_amount>0),
  constraint customer_id foreign key(customer_id) references Customers(customer_id)
 );

 insert into Orders (customer_id,order_date,total_amount) values
(101,"2021-4-21","345.88"),
(102,"2022-7-21","395.89"),
(103,"2023-6-21","345.88"),
(104,"2022-5-21","345.88");
 
 select * from orders;
 
 -- ================================================================================================
 
 -- -------------- Q5. JOINS
 -- a. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)
 select * from customers;
 select * from Orders;
 
 select c.country,
 count(orderNumber) order_count
 from customers c
 inner join
 orders o 
 on c.customerNumber = o.customerNumber
group by
c.country
order by
order_count desc
limit 5; 

-- ======================================================================================================

/*------------ Q6. SELF JOIN 
a. Create a table project with below fields.*/
drop table project;
create table Project
(
EmployeeID int primary key auto_increment,
FullName varchar(50),
Gender enum("Male","Female"),
managerID int
);

insert into project(FullName,Gender,managerID)  values 
("Pranaya","Male",3),
("Priyanka","Female",1),
("Preety","Female",Null),
("Anurag","male",1),
("Sambit","Male",1),
("Rajesh","Male",3),
("Hina","Female",3);

select * from project;

select m1.fullname as 'Manager_Name',
m2.fullname as 'Emp_Name'
 from
 project m2
 join 
 project m1 on  m2.ManagerID= m1.EmployeeID
 order by m1.fullname;
 
 -- ============================================================================================================
 
 -- -------------- Q7. DDL Commands: Create, Alter, Rename
 
 create database DDL_Commands;
 use DDL_Commands;
 create table facility
 (
Facility_ID int,
Name varchar(30),
State varchar(40),
Country varchar(30) 
);
 
 -- i) 
 alter table facility
 modify column Facility_ID int primary key auto_increment;
 
 -- ii)
 alter table facility
 add column city varchar(30) not null after name;
  
 desc facility;
 
 -- ==================================================================================================================
 
 /*-------------- Q8. Views in SQL */
 
  CREATE  OR REPLACE VIEW product_category_sales AS
SELECT 
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM
    ProductLines pl
JOIN
    Products p ON pl.productLine = p.productLine
JOIN
    orderdetails od ON p.productCode = od.productCode
JOIN
    orders o ON od.orderNumber = o.orderNumber
GROUP BY
    pl.productLine;
    
    -- ======================================================================================================
    
    -- --------------- Q9. Stored Procedures in SQL with parameters

DELIMITER $$
USE `classicmodels`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_country_payments`(
    IN in_year INT,
    IN in_country VARCHAR(50)
)
BEGIN
    SELECT
        in_year AS Year,
        in_country AS country,
        CONCAT(ROUND(SUM(p.amount) / 1000), 'K') AS total_amount
    FROM Payments p
    INNER JOIN Customers c ON p.customerNumber = c.customerNumber
    WHERE YEAR(p.paymentDate) = in_year
      AND c.country = in_country
    GROUP BY in_year, in_country;
END$$

DELIMITER ;

CALL Get_country_payments(2003, 'France');

select * from payments;

-- ==================================================================================

-- --------------Q10.
-- ---------------a) Window functions - Rank, dense_rank, lead and lag
select * from customers;
select * from orders;

SELECT
    c.customerName,
    COUNT(o.orderNumber) AS Order_count,
    DENSE_RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_frequency_rnk
FROM
    customers c
    JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY
    c.customerName
ORDER BY
    Order_count DESC;
    
    
-- -------------------------- Q10. 
-- -----b) Calculate year wise, month name wise count of orders and year over year (YoY) 
-- percentage change. Format the YoY values in no decimals and show in % sign.

SELECT
    YEAR(orderDate) AS Year,
    MONTHNAME(orderDate) AS Month,
    COUNT(*) AS Total_Orders,
    CONCAT(
        CASE
            WHEN LAG(COUNT(*)) OVER (
                PARTITION BY MONTH(orderDate)
                ORDER BY YEAR(orderDate)
            ) IS NULL THEN NULL
            ELSE
                ROUND(
                    (COUNT(*) - LAG(COUNT(*)) OVER (
                        PARTITION BY MONTH(orderDate)
                        ORDER BY YEAR(orderDate)
                    )) * 100.0
                    / NULLIF(LAG(COUNT(*)) OVER (
                        PARTITION BY MONTH(orderDate)
                        ORDER BY YEAR(orderDate)
                    ), 0), 0
                )
        END,
        CASE
            WHEN LAG(COUNT(*)) OVER (
                PARTITION BY MONTH(orderDate)
                ORDER BY YEAR(orderDate)
            ) IS NOT NULL THEN '%'
            ELSE ''
        END
    ) AS `YoY % Change`
FROM orders
GROUP BY YEAR(orderDate), MONTH(orderDate), MONTHNAME(orderDate)
ORDER BY YEAR(orderDate), MONTH(orderDate);

-- ===================================================================================

-- ---------Q11.Subqueries and their applications
select * from products;

SELECT
    productLine,
    COUNT(*) AS Total
FROM
    products
WHERE
    buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY
    productLine
ORDER BY
    Total DESC;
    
    
    /* ==================================================================================================== */
    
    -- --------------- Q12. ERROR HANDLING in SQL
           
CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100)
);
DELIMITER $$
USE `classicmodels`$$
CREATE PROCEDURE InsertEmp_EH(
  IN p_EmpID INT,
  IN p_EmpName VARCHAR(255),
  IN p_EmailAddress VARCHAR(255)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error occurred';
  END;

  START TRANSACTION;
  
  -- Insert into the Emp_EH table
  INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
  VALUES (p_EmpID, p_EmpName, p_EmailAddress);

  COMMIT;
END;$$

DELIMITER ;
;

call InsertEmp_EH(1,'Kiran','bawane@gmail.com');
call InsertEmp_EH(2,Null,'bawane@gmail.com');
CALL InsertEmp_EH(101, 'Alice', 'alice@example.com');

select * from emp_eh;

    /* ==================================================================================================== */
-- Q13. TRIGGERS

CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT VALUES
('Kiran', 'Scientist', '2025-10-04', 12),  
('Raju', 'Engineer', '2025-10-04', 10),  
('Pooja', 'Actor', '2025-10-04', 13),  
('Sonal', 'Doctor', '2025-10-04', 14),  
('Tanusha', 'Teacher', '2025-10-04', 12),  
('Anu', 'Business', '2025-10-04', 11);

DELIMITER $$
USE `classicmodels`$$
CREATE TRIGGER trg_before_insert_empbit
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END$$
DELIMITER ;

-- Insert a record with negative working hours
INSERT INTO Emp_BIT VALUES ('Sam', 'Artist', '2025-10-05', -8);

SELECT * FROM Emp_BIT;


    
    
    
    