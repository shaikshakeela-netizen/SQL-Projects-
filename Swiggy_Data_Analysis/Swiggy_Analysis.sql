use swiggy_db;
select * from swiggy_data;

-- Data Validation & cleaning

-- null values
select 
sum(case when state is null then 1 else 0 end)as null_state,
sum(case when city is null then 1 else 0 end)as null_city ,
sum(case when order_date is null then 1 else 0 end)as order_Date,
sum(case when Restaurant_name is null then 1 else 0 end)as null_restuarant_name,
sum(case when location is null then 1 else 0 end)as null_location,
sum(case when category is null then 1 else 0 end)as null_category,
sum(case when dish_name is null then 1 else 0 end)as null_dish_name,
sum(case when Price_inr is null then 1 else 0 end)as null_price_inr,
sum(case when rating is null then 1 else 0 end)as null_rating,
sum(case when rating_count is null then 1 else 0 end)as null_rating_count
from swiggy_data;


-- Blank or empty Strings
select * from
swiggy_data
where state= '' or restaurant_name = '' or location ='' or city ='' or category = '' or dish_name = '';

--  Duplicate detection
select  state, city, order_date, restaurant_name, location, category, dish_name, price_inr, rating, rating_count,
count(*) as cnt
from swiggy_data
group by state, city, order_date, restaurant_name, location, category, dish_name, price_inr, rating, rating_count
having count(*) > 1

-- delete duplication
with cte as 
(
select * , row_number() over ( partition by  city, order_date, restaurant_name, location, category, dish_name, price_inr, rating, rating_count 
								order by (select null) ) as rn 
								from swiggy_data )
delete from cte where rn > 1;



-- creating the schema
-- dimension tables
-- date table
create table dim_date(
date_id int identity(1,1) primary key ,
FULL_DATE DATE,
YEAR INT,
MONTH INT,
MONTH_NAME VARCHAR(20),
QUARTER INT, 
DAY INT,
WEEK INT 
);

-- CREATING LOCATION TABLE
CREATE TABLE DIM_LOCATION(
location_id int identity(1,1) primary key,
state varchar(100),
city varchar(100),
location varchar(200)
);

-- dim_restuarent
create table dim_restuarant (
restuarant_id int identity(1,1) primary key,
restuarant_name varchar(200));

-- dim_dishtable
create table dim_dish(
dish_id int identity(1,1) primary key,
dish_name  varchar(200));

--dish category
create table dim_category (
category_id int identity( 1,1) primary key,
category varchar(200));


-- fact table 
create table fact_swiggy_orders(
order_id int identity(1,1) primary key,
date_id int,
price_inr decimal (10,2),
rating decimal(4,2), rating_count int,
location_id int, 
restuarant_id int,
category_id int, 
dish_id int,
foreign key (date_id) references dim_date(date_id),
foreign key ( location_id) references dim_location(location_id),
foreign key(restuarant_id) references dim_restuarant(restuarant_id),
foreign key (category_id) references dim_category(category_id),
foreign key ( dish_id ) references dim_dish(dish_id));

select * from fact_swiggy_orders;

-- inserting the data in the date table

-- dim_date
insert into dim_date(full_date, YEAR, MONTH ,MONTH_NAME,QUARTER , DAY ,WEEK )
select distinct order_date, 
year(order_date), 
month(order_date),
datename(month,order_date),
datepart( quarter , order_date), 
day(order_date), 
datepart(week, order_date) 
from swiggy_data
where order_date is not null;

select * from dim_date;
 
-- inserting the values into the dim_location
insert into dim_location(state, city, location)
select distinct state, city , location from swiggy_data;

select * from dim_location;

-- inserting data into the restuarant table
insert into dim_restuarant(restuarant_name)
select distinct restaurant_name from swiggy_data;

-- inserting data into the dish table
insert into dim_dish(dish_name)
select distinct dish_name from swiggy_data;

-- inserting data into the category
insert into dim_category (category)
select distinct category from swiggy_data;

-- insert the data into fact table
insert into fact_swiggy_orders(date_id,price_inr, rating, rating_count, location_id, restuarant_id, category_id, dish_id)
select 
dd.date_id,
s.price_inr, 
s.rating, s.rating_count, dl.location_id, dr.restuarant_id, dc.category_id, dsh.dish_id from swiggy_data s
join dim_date dd
on dd.full_date= s.order_date
 
 join dim_location dl
 on dl.state= s.state
 and dl.city =s.city
 and dl.location= s.location

 join dim_restuarant dr
 on dr.restuarant_name = s.restaurant_name

 join dim_category dc
 on dc.category= s.category
 
 join dim_dish dsh
 on dsh.dish_name= s.dish_name


 select * from fact_swiggy_orders;

 -- to see all the data like the entire table

 select * from fact_swiggy_orders f
 join dim_date dd on f.date_id = dd. date_id
 join dim_restuarant dr on f.restuarant_id= dr.restuarant_id
 join dim_location dl on f.location_id = dl.location_id
 join dim_category dc on f.category_id = dc.category_id
 join dim_dish dsh on f.dish_id = dsh.dish_id

 --KPI' S
 -- Total orders
 select count(order_id)  as total_orders from fact_swiggy_orders;

 -- revenue
 select sum(price_inr) as revenue
 from fact_swiggy_orders;

 --formating the revenue
 select format(sum(convert(float, price_inr))/1000000, 'N2') + ' INR million' as total_revenue from fact_swiggy_orders;

 -- average dish price
 select avg(price_inr) as revenue
 from fact_swiggy_orders;

 -- formatting the average dish price 
 select format(avg(convert(float, price_inr)), 'N2' ) + ' INR'  as avg_value from fact_swiggy_orders;

 -- average rating
 select avg(rating) as avg_rating from fact_swiggy_orders;

 -- Deep dive business analysis
 -- monthly order trends
 select 
 d.year,
 d.month,
 d.month_name,
 count(*) as total_orders
 from fact_swiggy_orders f
 join  dim_date d on f.date_id= d.date_id
 group by 
 d.year,
 d.month,
 d.month_name
 order by count(*) desc
  

  -- monthly revenue trend
 select 
 d.year,
 d.month,
 d.month_name,
 format(sum(convert(float,price_inr))/100000, 'N2') + 'INR Million'  as total_orders
 from fact_swiggy_orders f
 join  dim_date d on f.date_id= d.date_id
 group by 
 d.year,
 d.month,
 d.month_name
 order by  format(sum(convert(float,price_inr))/100000, 'N2') + 'INR Million'
 desc
    

-- QUARTERLY TREND OF ORDERS

select 
 d.year,
 d.quarter,
 count(*) as total_orders
 from fact_swiggy_orders f
 join  dim_date d on f.date_id= d.date_id
 group by 
 d.year,
 d.quarter
 order by count(*) desc
  
-- quarterly trend of the revenue
select 
 d.year,
 d.quarter,
 format(sum(convert(float,price_inr))/100000, 'N2') + 'INR Million'  as total_orders
 from fact_swiggy_orders f
 join  dim_date d on f.date_id= d.date_id
 group by 
 d.year,
 d.quarter
 order by  format(sum(convert(float,price_inr))/100000, 'N2') + 'INR Million'
 desc

 -- YEARLY TREND
 select 
 d.year, 
 count(*) as total_orders
 from fact_swiggy_orders f
 join  dim_date d on f.date_id= d.date_id
 group by 
 d.year 
 order by count(*) desc

 -- yearly revenue trend
 select 
 d.year, 
 format(sum(convert(float,price_inr))/100000, 'N2') + 'INR Million'  as total_orders
 from fact_swiggy_orders f
 join  dim_date d on f.date_id= d.date_id
 group by 
 d.year 
 order by  format(sum(convert(float,price_inr))/100000, 'N2') + 'INR Million'
 desc


 -- orders of the day of week
 use swiggy_db;
 select 
 datename(weekday, d.full_date) as day_name,count(*) as total_orders
 from fact_swiggy_orders f join 
 dim_date d on f.date_id = d.date_id
 group by datename(weekday, d.full_date) ,datepart(weekday, d.full_date) 
 order by datepart(weekday, d.full_date) 

 -- top 10 cities by order volumes
 select  top 10 l.city, count(*) as total_orders
 from fact_swiggy_orders f join dim_location l on f.location_id = l.location_id
 group by l.city 
 order by count(*) desc 

 -- bottom 10 cities 
 select  top 10 l.city, count(*) as total_orders
 from fact_swiggy_orders f join dim_location l on f.location_id = l.location_id
 group by l.city 
 order by count(*) asc


 -- sum of the sales on top 10 cities
 select  top 10 l.city,format(sum(convert(float,price_inr))/100000, 'N2') + ' INR Million' as total_revenue
 from fact_swiggy_orders f join dim_location l on f.location_id = l.location_id
 group by l.city 
 order by format(sum(convert(float,price_inr))/100000, 'N2') + 'INR Million' desc 

 -- sum of sales on the bottom 10 cities 
  select  top 10 l.city,format(sum(convert(float,price_inr))/100000, 'N2') + ' INR Million' as total_revenue
 from fact_swiggy_orders f join dim_location l on f.location_id = l.location_id
 group by l.city 
 order by format(sum(convert(float,price_inr))/100000, 'N2') + 'INR Million' asc


 --  revenue contribution by state  top 10 
 select  top 10 l.state,format(sum(convert(float,price_inr))/100000, 'N2') + ' INR Million' as total_revenue
 from fact_swiggy_orders f join dim_location l on f.location_id = l.location_id
 group by l.state 
 order by format(sum(convert(float,price_inr))/100000, 'N2') + 'INR Million' desc 

 --food performance 
 -- top 10 restuarants by revenue
 select  top 10 r.restuarant_name,format(sum(convert(float,price_inr))/100000, 'N2') + ' INR Million' as total_revenue
 from fact_swiggy_orders f join dim_restuarant r on f.restuarant_id = r.restuarant_id
 group by r.restuarant_name 
 order by format(sum(convert(float,price_inr))/100000, 'N2') + 'INR Million' desc 

 -- top 10 categories
  select  top 10 c.category, count(*) as total_orders
 from fact_swiggy_orders f join dim_category c on c.category_id = f.category_id
 group by c.category
 order by count(*) desc


 --  top 10 most ordered dish
  select  top 10 dsh.dish_name, count(*) as total_orders
 from fact_swiggy_orders f join dim_dish dsh on f.dish_id = dsh.dish_id
 group by dsh.dish_name
 order by count(*) desc

 -- cuisine performance

 select  c.category,cast(avg(f.rating)as decimal(10,2)) as avg_rating ,  count(*) as total_orders
 from fact_swiggy_orders f join dim_category c on c.category_id = f.category_id
 group by c.category
 order by total_orders desc

 -- customer spending insights
 select case 
 when convert(float, price_inr) < 100 then 'under 100'
 when convert(float, price_inr) between 100 and 199 then ' 100 - 199'
  when convert(float, price_inr) between 200 and 299 then ' 200 - 299'
 when convert(float, price_inr) between 300 and 499 then ' 300 - 499'
 else '500+'
 end as price_range
 , count(*) as total_orders
 from fact_swiggy_orders
 group by case
 when convert(float, price_inr) < 100 then 'under 100'
 when convert(float, price_inr) between 100 and 199 then ' 100 - 199'
  when convert(float, price_inr) between 200 and 299 then ' 200 - 299'
 when convert(float, price_inr) between 300 and 499 then ' 300 - 499'
 else '500+'
 end
 order by total_orders desc;

 -- rating count distribution
 select rating, 
 count(*) as rating_count
 from fact_swiggy_orders
 group by rating 
 order by rating     desc