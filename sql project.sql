create database ecommerce_analysis;
use ecommerce_analysis;
create table customers(
customer_id int primary key,
custome_name varchar(100),
city varchar(50),
signup_date date
);
create table products(
product_id int primary key,
product_name varchar(100),
category varchar(100),
price decimal(10,2)
);
create table orders (
orders_id int primary key,
customer_id int,
order_date date,
status varchar(20),
payment_method varchar(50),

foreign key (customer_id)
references customers(customer_id)
);
alter table orders rename column orders_id to order_id;
create table order_items(
order_items_id int primary key,
order_id int,
product_id int,
quantity int,
discount decimal(5,2),

foreign key (order_id)
references orders(order_id),

foreign key (product_id)
references products(product_id)
); 
alter table customers drop column state;
alter table customers add state varchar(50)after city;
INSERT INTO customers VALUES
(1,'Arun Kumar','Chennai','Tamil Nadu','2025-01-10'),
(2,'Priya Raj','Coimbatore','Tamil Nadu','2025-01-15'),
(3,'Rahul Sharma','Bangalore','Karnataka','2025-02-05'),
(4,'Divya S','Madurai','Tamil Nadu','2025-02-20'),
(5,'Karthik M','Hyderabad','Telangana','2025-03-12'),
(6,'Sneha R','Chennai','Tamil Nadu','2025-03-18'),
(7,'Vijay Kumar','Mumbai','Maharashtra','2025-04-01'),
(8,'Anitha P','Pune','Maharashtra','2025-04-15'),
(9,'Suresh B','Delhi','Delhi','2025-05-10'),
(10,'Meena K','Trichy','Tamil Nadu','2025-05-20');

select * from customers;

INSERT INTO products VALUES
(101,'Laptop','Electronics',55000),
(102,'Smartphone','Electronics',25000),
(103,'Headphones','Electronics',2500),
(104,'Keyboard','Accessories',1500),
(105,'Mouse','Accessories',800),
(106,'Monitor','Electronics',15000),
(107,'Office Chair','Furniture',8500),
(108,'Table','Furniture',12000),
(109,'Backpack','Fashion',2000),
(110,'Shoes','Fashion',3500);

INSERT INTO orders VALUES
(1001,1,'2025-06-01','Completed','UPI'),
(1002,2,'2025-06-03','Completed','Credit Card'),
(1003,3,'2025-06-05','Completed','UPI'),
(1004,4,'2025-06-07','Cancelled','Cash'),
(1005,5,'2025-06-10','Completed','Debit Card'),
(1006,6,'2025-06-12','Completed','UPI'),
(1007,7,'2025-06-15','Completed','Credit Card'),
(1008,8,'2025-06-18','Cancelled','UPI'),
(1009,9,'2025-06-20','Completed','Debit Card'),
(1010,10,'2025-06-25','Completed','UPI'),
(1011,1,'2025-07-01','Completed','UPI'),
(1012,3,'2025-07-03','Completed','Credit Card'),
(1013,5,'2025-07-05','Completed','UPI'),
(1014,7,'2025-07-10','Completed','Debit Card'),
(1015,10,'2025-07-15','Completed','UPI');

INSERT INTO order_items VALUES
(1,1001,101,1,5),
(2,1001,103,2,0),

(3,1002,102,1,10),
(4,1002,105,2,5),

(5,1003,106,1,5),
(6,1003,104,1,0),

(7,1004,107,1,0),

(8,1005,101,1,8),
(9,1005,105,1,5),

(10,1006,103,2,0),
(11,1006,109,1,10),

(12,1007,108,1,5),
(13,1007,110,2,10),

(14,1008,102,1,0),

(15,1009,107,1,5),
(16,1009,104,2,0),

(17,1010,109,2,5),
(18,1010,110,1,0),

(19,1011,102,1,5),
(20,1011,103,1,0),

(21,1012,101,1,10),
(22,1012,105,1,5),

(23,1013,106,2,5),

(24,1014,108,1,10),
(25,1014,109,1,5),

(26,1015,110,2,10),
(27,1015,105,1,0);

SELECT *FROM products;
select*from products where price>10000;
select*from products where category='Electronics';
-- total revenue
select sum(p.price * oi.quantity * ( 1 - oi.discount/100)) as total_revenue;

-- revenue by category
select p.category, 
sum(
p.price*oi.quantity*(1-oi.discount/100)
) as revenue
from order_items oi 
join orders o on oi.order_id = o.order_id
join products p on oi.product_id=p.product_id where o.status= 'Completed'
group by category order by revenue desc;

-- top selliing products
select p.product_name, sum(oi.quantity) as units_sold
from order_items oi 
join orders o on oi.order_id= o.order_id
join products p on oi.product_id= p.product_id
where o.status = 'Completed' 
group by p.product_id,p.product_name
order by units_sold desc;

-- top 5 products by revenue 
select p.product_name,
sum( p.price * oi.quantity * (1- oi.discount/100)) as revenue 
from order_items oi
join orders o on oi.order_id = o.order_id
join products p on oi.product_id = p.product_id
where o.status = 'Completed'
group by p.product_id,p.product_name order by revenue desc limit 5;

alter table customers rename column custome_name to customer_name;
-- top customers by spending 
select 
c.customer_name, 
sum(p.price * oi.quantity * (1- oi.discount/100)) as total_spending
from customers c 
join orders o on c.customer_id = o.customer_id
join order_items oi on oi.order_id = o.order_id
join products p on oi.product_id= p.product_id
where o.status= 'Completed'
group by c.customer_id,c.customer_name
order by total_spending desc limit 1000;

-- Customers with more than one order
select 
c.customer_name,
count(o.order_id) as total_orders
from customers c 
join orders o on c.customer_id = o.customer_id
where o.status='Completed'
group by c.customer_id,c.customer_name 
having count(o.order_id) > 1;

-- Rank products by revenue
with product_sales as (
select p.product_name, 
sum( p.price * oi.quantity *(1- oi.discount/100)) as revenue
from order_items oi
join orders o on oi.order_id = o.order_id
join products p on oi.product_id= p.product_id
where o.status= 'Completed'
group by p.product_id,p.product_name
)
select 
	product_name, revenue, 
    rank() over (order by revenue desc) as revenue_rank 
from product_sales;

-- Rank products within each category 
with product_sales as (
select p.product_name, 
sum( p.price * oi.quantity *(1- oi.discount/100)) as revenue
from order_items oi
join orders o on oi.order_id = o.order_id
join products p on oi.product_id= p.product_id
where o.status= 'Completed'
group by p.product_id,p.product_name
)
select 
	product_name, revenue, 
    rank() over (partition by category order by revenue desc) as revenue_rank 
from product_sales;

-- Highest Revenue-Generating State
select  
c.state,sum( p.price * oi.quantity *(1- oi.discount/100) ) as revenue 
from customers c 
join orders o on c.customer_id = o.customer_id
join order_items oi on oi.order_id = o.order_id
join products p on p.product_id = oi.product_id
where o.status = 'Completed'
group by state
order by revenue desc limit 1;

-- Average Order Value
select avg(order_total) as average_order_value
from (select o.order_id ,sum( p.price* oi.quantity *(1-oi.discount/100)) as order_total
from orders o 
join order_items oi on o.order_id = oi.order_id
join products p on p.product_id = oi.product_id
where status = 'Completed'
group by o.order_id 
) as order_values;

-- Customer with the Highest Number of Orders

select c.customer_name, count(o.order_id) as total_orders
 from customers c
 join orders o on c.customer_id = o.customer_id
 where o.status = 'Completed'
 group by c.customer_id,c.customer_name
 order by total_orders desc limit 1;
 
 -- Monthly Revenue 
 select year(o.order_date) as order_year,
 month(o.order_date) as order_month,
 sum(p.price* oi.quantity *(1-oi.discount/100)) as monthly_revenue
 from orders o 
 join order_items oi
 on o.order_id=oi.order_id
 join products p on oi.product_id = p.product_id
 where o.status= 'Completed'
 group by year(o.order_date), month(o.order_date)
 order by order_year, order_month;
 
 -- Best-Selling Category
 select p.category,sum(p.price* oi.quantity *(1-oi.discount/100)) as category_revenue
 from products p 
 join order_items oi
 on p.product_id=oi.product_id
 join orders o on o.order_id = oi.order_id
 where o.status= 'Completed'
 group by p.category
 order by category_revenue desc limit 1;
 
 -- Cancelled Order Percentage
 select
    round(
        100.0 * sum(
            case
                when status = 'Cancelled' then 1
                else 0
            end
        ) / count(*),
        2
    ) as cancellation_percentage
from orders;

-- Customers Who Never Placed an Order
select c.customer_id,c.customer_name 
from customers c
left join orders o on c.customer_id = o.customer_id
where o.order_id is null;

-- First Order Date for Each Customer
select c.customer_name, min(o.order_date) as first_order_date
from customers c
join orders o  on c.customer_id = o.customer_id
where o.status = 'Completed'
group by c.customer_id,c.customer_name
order by first_order_date;

-- Latest Order Date for Each Customer
select c.customer_name, max(o.order_date) as latest_order_date
from customers c
join orders o  on c.customer_id = o.customer_id
where o.status = 'Completed'
group by c.customer_id,c.customer_name
order by latest_order_date;

-- Second-Highest Revenue Product
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(
            p.price * oi.quantity *
            (1 - oi.discount / 100)
        ) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY p.product_id, p.product_name
),

ranked_products AS (
    SELECT
        product_name,
        revenue,
        DENSE_RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)

SELECT
    product_name,
    revenue
FROM ranked_products
WHERE revenue_rank = 2;

-- Top 3 Customers in Each State
WITH customer_sales AS (
    SELECT
        c.state,
        c.customer_id,
        c.customer_name,
        SUM(
            p.price * oi.quantity *
            (1 - oi.discount / 100)
        ) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
    GROUP BY
        c.state,
        c.customer_id,
        c.customer_name
),

ranked_customers AS (
    SELECT
        state,
        customer_name,
        total_spending,
        RANK() OVER (
            PARTITION BY state
            ORDER BY total_spending DESC
        ) AS customer_rank
    FROM customer_sales
)

SELECT
    state,
    customer_name,
    total_spending,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 3
ORDER BY state, customer_rank;

-- Month-over-Month Revenue Growth
WITH monthly_revenue AS (
    SELECT
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,
        SUM(
            p.price * oi.quantity *
            (1 - oi.discount / 100)
        ) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
),

revenue_with_previous AS (
    SELECT
        order_year,
        order_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY order_year, order_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)

SELECT
    order_year,
    order_month,
    revenue,
    previous_month_revenue,
    ROUND(
        100 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS growth_percentage
FROM revenue_with_previous;

-- Find Repeat Customers
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS completed_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) >= 2
ORDER BY completed_orders DESC;

-- Products Never Purchased
SELECT
    p.product_id,
    p.product_name,
    p.category
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

-- Product Contribution to Total Revenue
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(
            p.price * oi.quantity *
            (1 - oi.discount / 100)
        ) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY
        p.product_id,
        p.product_name
),

total_revenue AS (
    SELECT
        SUM(revenue) AS total
    FROM product_revenue
)

SELECT
    pr.product_name,
    pr.revenue,
    ROUND(
        100 * pr.revenue / tr.total,
        2
    ) AS revenue_contribution_percentage
FROM product_revenue pr
CROSS JOIN total_revenue tr
ORDER BY pr.revenue DESC;