-- QUESTIONS RELATED TO CUSTOMERS
use new_wheels_dumpfile;
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
     use new_wheels_dumpfile;
select count(customer_id) as number_of_statecustomer, state
from customer_t
group by state
order by 1 desc ;
/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
-- select avg(customer_feedback),quarter_number
-- from order_t
-- group by quarter_number;

With Avg_of_feedback AS
(select customer_feedback,quarter_number,
case
when customer_feedback = 'Very Bad' THEN 1
WHEN customer_feedback ='BAD' THEN 2
WHEN customer_feedback ='okay' THEN 3
When customer_feedback ='Good' THEN 4
WHEN customer_feedback ='Very Good' THEN 5
End as 'AVERAGE_OF_FEEDBACK'
from order_t)
select avg(AVERAGE_OF_FEEDBACK),quarter_number
 from AVG_of_feedback
 group by quarter_number;
 
 /* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. */

 
 SELECT QUARTER_NUMBER,
    SUM(CASE 
     WHEN Customer_feedback = 'very bad'then 1 ELSE 0
     END) AS VERY_BAD_COUNT,
    SUM(CASE WHEN customer_feedback = 'bad' then 1 else 0
     END ) as count_bad,
    SUM(CASE WHEN Customer_feedback ='okay' then 1 else 0
    end) as count_okay,
     SUM(CASE WHEN CUSTOMER_FEEDBACK ='GOOD' THEN 1 ELSE 0
    END)AS COUNT_GOOD,
     SUM(CASE WHEN CUSTOMER_FEEDBACK ='VERY GOOD' THEN 1 ELSE 0 END) AS COUNT_VERYGOOD,
     (SUM(CASE WHEN CUSTOMER_FEEDBACK ='VERY GOOD' THEN 1 ELSE 0 END)/COUNT(*)*100) AS VERYGOOD_PERCENTAGE,
     (SUM(CASE WHEN CUSTOMER_FEEDBACK ='GOOD' THEN 1 ELSE 0 END)/COUNT(*)*100) AS GOOD_PRECENTAGE,
     (Sum(CASE WHEN CUSTOMER_FEEDBACK ='OKAY' THEN 1 ELSE 0  END)/COUNT(*)*100) AS OKAY_PERCENTAGE,
      (Sum(CASE WHEN CUSTOMER_FEEDBACK ='BAD' THEN 1 ELSE 0  END)/COUNT(*)*100) AS BAD_PERCENTAGE,
      (Sum(CASE WHEN CUSTOMER_FEEDBACK ='VERY BAD' THEN 1 ELSE 0  END)/COUNT(*)*100) AS VERY_BAD_PERCENTAGE
    -- SUM(VERY_BAD_COUNT) AS TOTAL_VERYBADCOUNT,SUM(COUNT_BAD)AS TOTAL_BADCOUNT
   -- ,SUM(COUNT_GOOD)AS TOTAL_GOODCOUNT,SUM(COUNT_OKAY) AS TOTAL_OKAYCOUNT,SUM(COUNT_VERYGOOD)AS TOTAL_VERYGOODCOUNT
    FROM ORDER_T
	GROUP BY quarter_number ;
    
/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/    
    


select count(customer_id) as number_of_customer,vehicle_maker
from order_t inner join product_t
 using(product_id)
 group by 2
 order by 1 desc
 limit 5;
 
/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/
select *
from(
 select vehicle_maker,state,
 COUNT(customer_id) as total_count,
 rank() over (partition by state order by count(customer_id) desc) as rnk
from customer_t
 inner join order_t using(customer_id)
 inner join product_t using(product_id) 
 group by 2,1 ) as tbl
 where rnk<=3;
 
 

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/ 


SELECT COUNT( ORDER_ID),SUM(QUANTITY),QUARTER_NUMBER
FROM ORDER_T
GROUP BY 3
ORDER BY 1,2 ;
/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.*/
With quarters_revenue as
(select sum(quantity*vehicle_price*(1-discount)) as total_revenue,quarter_number
from order_t
group by 2
order by 1)
select total_revenue, 
LAG (total_revenue,1)OVER (ORDER BY quarter_number),
100* (LAG (total_revenue,1)OVER (ORDER BY quarter_number) - total_revenue ) /total_revenue    
from quarters_revenue;

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/
 SELECT SUM(vehicle_price*quantity*(1-discount))as quaterly_revenue,count(order_id),quarter_number
 from order_t
 group by quarter_number
 order by 1,2 ;
 
 
 /* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/


 select credit_card_type,avg(discount)*100 as avg_discount_byCC
from customer_t
inner join order_t using(customer_id)
group by 1
order by 2;
/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

select avg(datediff(ship_date,order_date) ) as no_of_days,quarter_number
from order_t
group by 2;


