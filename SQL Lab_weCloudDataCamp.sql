                                 -- WESAL HAWSAWI --

-- Show All Databases
show databases;
-- Switch to the Classicmodels Database
use Classicmodels;
-- Number of Tables
show tables;
-- Rows and Columns in Each Table
-- row
select count(*)
from customers;
-- cloumns
describe customers;

-- View the First 5 Rows of Each Table
select *
from customers 
limit 5;

-- Show the `customerNumber`, `customerName`, and `city` of all customers
select customerNumber,
customerName,
city
from customers
limit 5;

-- Show the `customerNumber`, `customerName`, and `city` of customers from Boston
select customerNumber,customerName,city
from customers
where city='Boston';

-- Show the `customerName` and `creditLimit` of customers with a credit limit greater than 200000
select customerName,
creditLimit
from customers
where creditLimit > 200000;

-- Which products are Ships and have an MSRP greater than 50 and less than 100?
select productName,
productLine,
MSRP 
from products 
where productLine= 'Ships' and MSRP between 50 and 100;

-- Based on the `productName`, which products are `Ford` models
select productName
from products 
where productName like '%Ford%';

-- Sort the orderdetails table by (lowest quantityOrdered) and (highest priceEach)
select *
from orderdetails 
order by quantityOrdered asc , priceEach desc ;

-- Which 3 products have the largest profit? Hint: You'll have to calculate profit and create the column
select productName,
MSRP - buyPrice as profit
from products 
order by profit desc
limit 3;

-- How many unique countries are the customers from
select count(distinct country) as numCountries
from customers;

-- How many customers are from North America? ('USA', 'Canada', 'Mexico')
select count(*) as NAmericaCount
from customers
where country in ('USA', 'Canada', 'Mexico');

-- In the customers table, how many NULL values are in the salesRepEmployeeNumber column?
select count(*)
from customers
where salesRepEmployeeNumber is null;

-- Are there any orders that were shipped late? What was the reason?
select orderNumber ,
comments
from orders 
where shippedDate > requiredDate ;

-- What is the average price of all products (Rounded to two decimal places)?
select round(avg(MSRP),2)
from products ;

-- How many years does the `orders` table span?
select distinct year(orderDate)
from orders ;

-- Create a new column to show whether a customerNumber is an even/odd number
select customerNumber,
customerNumber%2 as evencustomerNumber
from customers ;

-- Show a table with `Classic Cars` that are ordered from newest to oldest by year
select productName,
cast(substr(productName,1,4)as unsigned) as productYear 
from products
where productLine = 'Classic Cars'
order by productYear desc;

-- What is the newest `OrderDate`? What is the oldest `OrderDate`? How many days are there between the newest and oldest dates?
select max(OrderDate) as newestOrderDate,
min(OrderDate) as oldestOrderDate,
max(orderDate) - min(orderDate) as totalDays
from orders;

-- Imagine it takes 5 days to process a payment, using paymentDate, create a new column called paymentProcessedDate that is 5 days later
select paymentDate,
  date_add(paymentDate, interval 5 day) as paymentProcessedDate
from payments;

-- How many customers are there from each country?
select country, 
count(*)
from customers
group by country;

-- What are the top 5 customers by total payment amount?
select customerNumber,
sum(amount) as totalAmount
from payments
group by customerNumber
order by totalAmount desc
limit 5;

-- Which month overall has the most orders?
select month(orderDate) as orderMonth,
count(*) as totalOrders
from orders
group by orderMonth
order by totalOrders desc;

-- Which month of which year has the most orders?
select year(orderDate) as orderYear,
month(orderDate) as orderMonth,
count(*) as totalOrders
from orders
group by orderYear,orderMonth
order by totalOrders desc;

-- Which employees have more than 5 people working under them?
SELECT 
    reportsTo, COUNT(*) AS subordinateCount
FROM
    employees
GROUP BY reportsTo
HAVING subordinateCount > 5;

-- -------------------------------- join & Subqueries --------------------------------
-- Create a column to identify if a productName contains the brand "Ford"
select productName,
  case 
  when productName like '%Ford%' then 'yes'
  else 'no'
  end 
  as isFord
from products;

-- 2. Categorize the quantityInStock column of the products table into: 'High Quantity', 'Medium Quantity', or 'Low Quantity' based on whether the quantityInStock is greater than 2000, between 500-2000, or less than 500 respectively.
select quantityInStock,
case 
when quantityInStock >2000 then 'High Quantity'
when quantityInStock <= 2000 and quantityInStock>=500 then 'Medium Quantity'
else 'Low Quantity'
end
as quantityCategory
from products ;

-- Create a pivot table from the products with each row as productScale, each column as productLine and the values showing the total quantityInStock.
select productScale,
sum(case when productLine like '%Classic Cars%' then quantityInStock else 0 end) as classicCars,
sum(case when productLine like '%Motorcycles%' then quantityInStock else 0 end) as motorcycles,
sum(case when productLine like '%Planes%' then quantityInStock else 0 end) as planes,
sum(case when productLine like '%ships%' then quantityInStock else 0 end) as ships,
sum(case when productLine like '%Trains%' then quantityInStock else 0 end) as Trains
from products 
group by productScale;

-- Get the customerNames for customers that made exactly one payment greater than 100000
select distinct customerName
from customers 
join payments 
using(customerNumber)
where amount > 100000
group by customerName, customerNumber
having count(checkNumber) = 1;

-- Get the customerNames for customers that have made TOTAL payments greater than 100000.
select customerName
from customers
where customerNumber in (
  select customerNumber
  from payments
  group by customerNumber
  having sum(amount) > 100000
);

  
  --  What is the average number of customers that each salesRepEmployee has? (Hint: Use salesRepEmployeeNumber and don't count the NULLs)
select avg(customerCount) as avgSalesRepCustomerCount 
  from (select salesRepEmployeeNumber, 
  count(*) as customerCount
  from customers
  where salesRepEmployeeNumber is not null
  group by salesRepEmployeeNumber
)
 as salesRepCounts;
 
 -- ---------------------------------- joins ----------------------------------
select e.officeCode,
 firstName,
 city
from employees e
inner join offices o
using(officeCode);

-- Create the following table using multiple inner joins
select orderNumber,
  orderDate,
  customerName,
  orderLineNumber,
  productName,
  quantityOrdered,
  priceEach
from orders
inner join orderdetails
  using (orderNumber)
inner join products
  using (productCode)
inner join customers
  using (customerNumber);
  
-- Which customers have never made an order?
select c.customerNumber,
  customerName,
  orderNumber
from customers c
left join orders
  using(customerNumber) 
where orderNumber is null;
-- Get the 5 largest orders by totalSales that have been shipped. Where totalSales can be calculated from quantityOrdered and priceEach
select o.orderNumber,
o.status,
sum(quantityOrdered * priceEach) as totalSales
from orders o
inner join orderdetails od
using(orderNumber)
where status = 'Shipped'
group by o.orderNumber
order by totalSales desc
limit 5;

-- Create a summary table to show each employee's firstName, the customerName they represent, and the payment amount that customer has made. The table should have NULL values if an employee doesn't have a customer and if the customer hasn't made a payment.
select firstName,
  customerName,
  amount
from employees e
left join customers c on
  e.employeeNumber = c.salesRepEmployeeNumber
left join payments p 
using(customerNumber);

  
  

 


 
 