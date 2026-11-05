USE swiggydb

SELECT * FROM Swiggy_Data



--WE HAVE 4 STEPS FOR ANALYSIS 
--import data
--filter data
--Process data
--Analyse data


--DATA VALIDATION AND CLEANING


--NULL CHECK

SELECT
SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
SUM(CASE WHEN Order_date IS NULL THEN 1 ELSE 0 END ) AS null_order,
SUM(CASE WHEN restaurant_name IS NULL THEN 1 ELSE 0 END) AS null_restaurant,
SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS null_location,
SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
SUM(CASE WHEN dish_name IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
SUM(CASE WHEN price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,
SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
SUM(CASE WHEN Rating_count IS NULL THEN 1 ELSE 0 END) AS null_count
FROM swiggy_data

--EMPTY STRINGS

SELECT*FROM swiggy_data
WHERE
State=''OR city=''OR Order_date=''OR Restaurant_Name=''OR Location=''OR Category=''OR Dish_name='' OR Price_INR=''
OR Rating=''OR Rating_Count=''

SELECT COUNT(*) AS empty
FROM swiggy_data
WHERE Rating_count=''

--DUPLICATE DETECTION

SELECT
State,city,order_date,Restaurant_name,Location,Category,Dish_name,Price_INR,Rating,Rating_Count, 
COUNT(*) AS Duplicate_count
FROM swiggy_data
GROUP BY State,city,order_date,Restaurant_name,Location,Category,Dish_name,Price_INR,Rating,Rating_Count
HAVING COUNT(*)>1

--REMOVE DUPLICATES

WITH CTE AS(
SELECT*,ROW_NUMBER() OVER (PARTITION BY State,city,order_date,Location,Restaurant_name,Category,Dish_name,
Price_INR,Rating,Rating_Count
ORDER BY(SELECT NULL) 
) AS RN
FROM swiggy_data
)
DELETE FROM CTE
WHERE RN>1


--CREATING TABLES

CREATE TABLE date_table(
date_id INT IDENTITY (1,1) PRIMARY KEY,
Full_date DATE,
Year INT,
Month INT,
Month_name VARCHAR (20),
Quarter INT,
Day INT,
week INT
)

CREATE TABLE Location_table(
Location_id INT IDENTITY(1,1) PRIMARY KEY,
State VARCHAR(100),
City VARCHAR(100),
Location VARCHAR(200)
)

CREATE TABLE restaurant_table(
Restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
Restaurant_name VARCHAR(200)
)

CREATE TABLE Category_table(
Category_id INT IDENTITY(1,1) PRIMARY KEY,
Category VARCHAR(200)
)

CREATE TABLE Dish_table(
Dish_id INT IDENTITY(1,1) PRIMARY KEY,
Dish_name VARCHAR(200)
)

drop table swiggy_orders

CREATE TABLE Swiggy_orders(
Order_id INT IDENTITY(1,1) PRIMARY KEY,
Date_id INT,
Price_INR varchar(max),
Rating varchar(max),
Rating_count varchar(max),
Location_id INT,
Restaurant_id INT,
Category_id INT,
Dish_id INT,
FOREIGN KEY (date_id) REFERENCES date_table(date_id),
FOREIGN KEY (location_id) REFERENCES location_table(location_id),
FOREIGN KEY (restaurant_id) REFERENCES Restaurant_table (restaurant_id),
FOREIGN KEY (Category_id) REFERENCES category_table(category_id),
FOREIGN KEY (Dish_id) REFERENCES dish_table(dish_id)
)

SELECT*FROM swiggy_orders


--INSERT DATA INTO TABLE

--DATE TABLE

INSERT INTO Date_table (Full_date,Year,Month,Month_name,Quarter,Day,Week)
SELECT DISTINCT
Order_date,
YEAR(Order_date),
MONTH(Order_date),
DATENAME(MONTH,order_date),
DATEPART(QUARTER, order_date),
DAY(order_date),
DATEPART(WEEK, order_date)
FROM swiggy_data
WHERE order_date IS NOT NULL 

SELECT*FROM Date_table

--LOCATION TABLE

INSERT INTO Location_table( State, city, location)
SELECT DISTINCT
State,
City,
location
FROM swiggy_data

--RESTAURANT TABLE

INSERT INTO restaurant_table(Restaurant_name)
SElECT DISTINCT
Restaurant_name
FROM swiggy_data

--CATEGORY TABLE

INSERT INTO Category_table(category)
SELECT DISTINCT
category
FROM Swiggy_data

--DISH TABLE

INSERT INTO Dish_table(Dish_name)
SELECT DISTINCT
Dish_name
FROM swiggy_data

--SWIGGY ORDER TABLE

INSERT INTO Swiggy_orders
(
    date_id,
    Price_INR,
    Rating,
    Rating_count,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)
SELECT
    dd.date_id,
    s.Price_INR,
    s.Rating,
    s.Rating_count,
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
FROM Swiggy_Data s

JOIN Date_table dd
    ON dd.Full_Date = s.Order_Date

JOIN location_table dl
    ON dl.State = s.State
    AND dl.City = s.City
    AND dl.location = s.location

JOIN restaurant_table dr
    ON dr.restaurant_name = s.restaurant_name

JOIN Category_table dc
    ON dc.category = s.category

JOIN Dish_table dsh
    ON dsh.Dish_name = s.Dish_Name

    SELECT * FROM Swiggy_Orders f

    JOIN date_table d ON f.date_id = d.date_id
    JOIN location_table l ON f.location_id = l.location_id
    JOIN restaurant_table r ON f.restaurant_id = r.restaurant_id
    JOIN category_table c ON f.category_id = c.category_id
    JOIN dish_table di ON f.dish_id  = di.dish_id;

    DROP table swiggy_data


 --KPI's
 -- Total orders

 SELECT COUNT(*) AS Total_orders
 FROM Swiggy_orders

 SELECT COUNT(*) AS Total_orders
 FROM Swiggy_data

 -- Total Revenue

 SELECT FORMAT (
 SUM(TRY_CONVERT(DECIMAL(18,4),Price_INR))/1000000,'N2')+'M Million'
 AS Total_Revenue
 FROM swiggy_orders

 -- AVG DISH PRICE

 SELECT FORMAT(AVG(TRY_CONVERT(DECIMAL(18,4),Price_INR)),'N2')+'INR'
 AS Avg_price
 FROM Swiggy_orders

 --AVG RATING

 SELECT FORMAT(AVG(TRY_CONVERT(DECIMAL(2,1),Rating)),'N2')AS Avg_Rating
 FROM swiggy_orders

 --DATA BASED ANALYSIS

 --MONTHLY ORDER ANALYSIS

 SELECT*FROM Date_table


 SELECT
 d.year,
 d.Month,
 d.Month_name,
 COUNT(*)AS Total_orders
 FROM swiggy_orders f
 JOIN Date_table d
 ON f.date_id=d.date_id
 GROUP BY 
 d.year,
 d.month,
 d.Month_name
 ORDER BY COUNT(*) DESC

 -- QUARTERLY ORDER ANALYSIS

 SELECT
 d.year,
 d.Quarter,
 COUNT(*) AS Total_Orders
 FROM swiggy_orders f
 JOIN date_table d
 ON f.date_id=d.date_id
 GROUP BY 
 d.year,
 d.quarter
 ORDER BY COUNT(*) DESC

 --WEEKDAYS ANALYSIS

SELECT
DATENAME(WEEKDAY,d.Full_date) AS Day_name,
COUNT(*) AS Total_orders
FROM swiggy_orders f
JOIN Date_table d
ON f.date_id=d.date_id
GROUP BY 
DATENAME(WEEKDAY,d.Full_date), DATEPART(WEEKDAY, d.full_date)
ORDER BY DATEPART(WEEKDAY, d.full_date) 

--YEARLY ORDER ANALYSIS

SELECT
YEAR(d.full_date) AS order_Year,
COUNT(*) AS Total_orders
FROM Swiggy_orders f
JOIN date_table d
On f.date_id=d.date_id
GROUP BY 
YEAR(d.full_date)
ORDER BY Order_year ASC

--TOP 10 CITIESS BY ORDERS

SELECT TOP 10
l.city,
COUNT(f.order_id) AS Total_orders
FROM swiggy_orders f
JOIN Location_table l
ON f.Location_id=l.Location_id
GROUP BY
l.city
ORDER BY Total_orders DESC

--BTTOM 5 CITIES BY ORDERS

SELECT TOP 5
l.city,
COUNT(f.order_id) AS Total_orders
FROM swiggy_orders f
JOIN Location_table l 
ON f.Location_id=l.Location_id
GROUP BY 
l.city
ORDER BY Total_orders ASC

-- REVENUE CONTRIBUTION BY STATES

SELECT
l.State,FORMAT(
SUM(TRY_CONVERT(DECIMAL (18,4), f.Price_INR))/1000000,'N2')+ 'M'
AS Total_Revenue
FROM Swiggy_orders f
JOIN Location_table l
ON l.location_id=f.location_id
GROUP BY l.State
ORDER BY SUM(TRY_CONVERT( DECIMAL(18,4),f.Price_INR)) DESC

--TOP 10 RESTURANTS BY ORDERS

SELECT TOP 10
r.Restaurant_name,
COUNT(*) AS Total_orders
FROM Swiggy_orders f
JOIN Restaurant_table r
ON r.Restaurant_id=f.Restaurant_id
GROUP BY r.Restaurant_name
ORDER BY COUNT(*) DESC

--TOP 10 RESTAURANTS BY REVENUE

SELECT TOP 10
r. Restaurant_name,
SUM(TRY_CONVERT (DECIMAL(18,2),f.price_INR))
AS Total_revenue
FROM swiggy_orders f
JOIN Restaurant_table r
ON r.restaurant_id=f.restaurant_id
GROUP BY r.restaurant_name
ORDER BY SUM(TRY_CONVERT(DECIMAL(18,2),f.Price_INR)) DESC

--TOP CATEGORIES BY ORDERS

SELECT 
c.category,
COUNT(*) AS Total_orders
FROM swiggy_orders f
JOIN Category_table c
ON c.Category_id=F.category_id
GROUP BY c.category
ORDER BY COUNT(*) DESC

--MOST ORDERED DISHES

SELECT
d.dish_name,
COUNT(*) AS Total_orders
FROM swiggy_orders f
JOIN Dish_table d
ON d.dish_id=f.dish_id
GROUP BY d.dish_name
ORDER BY Total_orders DESC

--CUISINE PERFORMANCE -> ORDERS + AVG RATING

SELECT
c.category,
COUNT(*) AS Total_orders,
AVG(TRY_CONVERT(DECIMAL(2,1), f.rating)) AS Order_rating
FROM swiggy_orders f
JOIN Category_table c
ON c.category_id=f.category_id
GROUP BY c.Category
ORDER BY COUNT(*) DESC

--PRICE RANGE ORDER

SELECT 
CASE
WHEN TRY_CONVERT(DECIMAL(18,4),Price_INR)<100 THEN 'UNDER 100'
WHEN TRY_CONVERT(DECIMAL(18,4),Price_INR)BETWEEN 100 AND 199 THEN '100-199'
WHEN TRY_CONVERT(DECIMAL(18,4),Price_INR)BETWEEN 200 AND 299 THEN '200-299'
WHEN TRY_CONVERT(DECIMAL(18,4),Price_INR)BETWEEN 300 AND 499 THEN '300-499'
ELSE '500+'
END AS Price_range,
COUNT(*) AS Total_orders
FROM Swiggy_orders
GROUP BY 
CASE
WHEN TRY_CONVERT(DECIMAL(18,4),Price_INR)<100 THEN 'UNDER 100'
WHEN TRY_CONVERT(DECIMAL(18,4),Price_INR)BETWEEN 100 AND 199 THEN '100-199'
WHEN TRY_CONVERT(DECIMAL(18,4),Price_INR)BETWEEN 200 AND 299 THEN '200-299'
WHEN TRY_CONVERT(DECIMAL(18,4),Price_INR)BETWEEN 300 AND 499 THEN '300-499'
ELSE '500+'
END 
ORDER BY Total_orders DESC



