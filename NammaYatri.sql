select * from assembly 

select * from timing 

select * from payment 

select * from trip_details_FilterDatabase


select * from trip_details     

select * from trips;      


-- zero results as there's no duplicate records or any sort of multiple records with same tripid 

select tripid, count(tripid) from trip_details
group by tripid
having count(tripid) > 1;


-- Total drivers 

select count(distinct driverid) from trips;

-- Total Distinct Customers

select count(distinct custid) from trips;

-- Total Earnings 

select sum(fare) as 'Total Earnings' from trips;

-- Total Searches 

select count(searches) from trip_details;

-- Total searches which got estimates

select sum(searches_got_estimate) from trip_details

-- Total searches which got quotes 

select sum(searches_for_quotes) from trip_details

-- Trips cancelled by drivers 

select count(1) - sum(driver_not_cancelled) as 'Trips Driver Cancelled' from trip_details

-- Trips cancelled by Customers

select count(1) - sum(customer_not_cancelled) as 'Trips Customer Cancelled' from trip_details

-- Total OTP entered

select sum(otp_entered) from trip_details;

-- Total Completed Trips 

select sum(end_ride) from trip_details


-- These all metrics will give us the idea about the customer journey.

--Average Distance per Trip 

select AVG(distance) as 'Avg Distance' from trips 

-- Average Fare Per Trip

select AVG(fare) as 'Avg Fare' from trips 

-- Frequency of Different Payment Methods

select faremethod as 'Payment Method', count(tripid) as 'No of Times Used' 
from trips 
group by faremethod
order by count(tripid) desc;

select * from payment

-- Most used payment method 

SELECT p.Method
FROM payment p
INNER JOIN (
    SELECT top 1 faremethod, COUNT(tripid) AS TripCount
    FROM trips
    GROUP BY faremethod
	order by count(tripid) desc
) AS t ON p.id = t.faremethod;


-- Which Two locations had the most trips 

select * from
(select *, dense_rank() over (order by TripCount desc) Rnk
from 
(select Loc_from, Loc_to , count(distinct tripid) as TripCount from trips
group by loc_from, loc_to) as A ) as B
where Rnk=1;

-- Timings with the most rides 

select * from
(select *, DENSE_RANK() over (order by Num_Of_Trips desc) as Rnk
from
(select duration as 'Timing Id', count(distinct tripid) as Num_Of_Trips from trips
group by duration) as A ) as B
where Rnk = 1;

-- Driver and Customer pair with highest frequency

select * from
(select *, DENSE_RANK() over (order by Cnt desc) as Rnk
from
(select driverid, custid, count(distinct tripid) Cnt from trips 
group by driverid, custid )as A ) as B
where Rnk = 1; 

-- Conversion Percentage at each Stage 

-- Estimate to Searches Rates

select sum(searches_got_estimate)*100/sum(searches) from trip_details 

-- Searches For Quote to Estimates Rates 

select sum(searches_for_quotes)*100/sum(searches_got_estimate) from trip_details

-- Quote Acceptance Ratio 

select sum(searches_got_quotes)*100/sum(searches_for_quotes) from trip_details

-- Quote to Booking Rate 

select sum(searches_got_quotes)*100/sum(searches_for_quotes) from trip_details

-- Conversion Rate 

select sum(end_ride)*100/sum(searches) from trip_details

-- Which Area Got Highest Trips in That Duration 

select * from
(select *, RANK() over (partition by duration order by Cnt desc) as Rnk 
from
(select duration, loc_from, count(distinct tripid) as Cnt 
from trips 
group by duration, loc_from) as A ) as B
where Rnk = 1 ;

-- Which Duration Got Highest trips in that area 

select * from
(select *, RANK() over (partition by loc_from order by Cnt desc) as Rnk 
from
(select loc_from, duration, count(distinct tripid) as Cnt 
from trips 
group by duration, loc_from) as A ) as B
where Rnk = 1 ;

-- Which Areas Got Highest Sum of Fares.

select * from (select *, RANK() over ( order by Fare desc) as Rnk 
from
(select loc_from, sum(fare) as fare from trips 
group by loc_from) as A ) as B
where Rnk = 1 ;

-- Which Areas Got Highest Driver Cancellation.

select * from 
(select *, rank() over (order by CnCL desc ) as Rnk
from 
(select Loc_from, count(*) - Sum(driver_not_cancelled) as CnCL
from trip_details  
group by loc_from ) as A ) as B
where Rnk = 1;

-- Which Areas Got Highest Customer Cancellation.

select * from 
(select *, rank() over (order by CnCL desc ) as Rnk
from 
(select Loc_from, count(*) - Sum(customer_not_cancelled) as CnCL
from trip_details  
group by loc_from ) as A ) as B
where Rnk = 1;

-- Which Areas Got Highest Trips 

select * from (select *, RANK() over ( order by Num_Trips desc) as Rnk 
from
(select loc_from, count(distinct tripid) as Num_trips from trips 
group by loc_from) as A ) as B
where Rnk = 1 ;



-- ABOUT DRIVERS

-- Counting trips of each driver 

select driverid as 'Driver Id' , count (driverid) as 'Trip Count'
from trips 
group by driverid 
order by driverid desc; 

-- Individual Driver Earnings 

select driverid as 'Driver Id', sum(fare) as Earnings
from trips 
group by driverid
order by driverid desc;

-- Top 5 Earning Drivers 

select * from
(select *, DENSE_RANK() over( order by Earnings desc) Rnk
from
(select driverid, Sum(fare) as Earnings 
from trips 
group by driverid) as A ) as B 
where Rnk < 6;

-- Individual Driver Distance 

select driverid as 'Driver Id', sum(distance) as 'Total Travelled'
from trips 
group by driverid
order by driverid desc;

-- These will tell us about the performances of the drivers 

