use finance_project;


# using Joins

-- -- Year wise loan amount Stats
select issue_d_year,format(round(sum(loan_amnt),2),0) as loan_amount from finance1_updated group by issue_d_year order by issue_d_year asc;

# Grade and Sub Grade wise revol_bal
           
            select grade, sub_grade, format(round(sum(revol_bal),2),0) as Revolving_Bal
			from finance_1
            left join finance_2
            on finance_1.id = finance_2.id
            group by grade,sub_grade
            order by grade,sub_grade;       
                   
                 
# Total Payment for verified status and Non verified status

 with cte as (with e as  (SELECT 
    finance_1.verification_status AS status,
    round(sum(finance_2.total_pymnt),2) AS total_payment
FROM 
    finance_1
    JOIN finance_2 ON finance_2.id = finance_1.id
    -- where finance_1.verification_status in ('verified', 'not verified')
GROUP BY status) SELECT status, total_payment, 
round(total_payment * 100 / (SELECT SUM(total_payment) AS s FROM e)) AS `percent_of_total`
FROM e) select status, total_Payment, concat(percent_of_total,'%') as percentage from cte;

-- filtering verified and non verified status accounts

with M as (with cte as (with e as  (SELECT 
    finance_1.verification_status AS status,
    round(sum(finance_2.total_pymnt),2) AS total_payment
FROM 
    finance_1
    JOIN finance_2 ON finance_2.id = finance_1.id
    -- where finance_1.verification_status in ('verified', 'not verified')
GROUP BY status) SELECT status, total_payment, 
round(total_payment * 100 / (SELECT SUM(total_payment) AS s FROM e)) AS `percent_of_total`
FROM e) select status, total_Payment, concat(percent_of_total,'%') as percentage from cte) select * from M where status in ('Verified','Not Verified');



# State wise and last_credit_pull_d wise loan status
with e as (  select year(last_credit_pull_d) as year,addr_state,loan_status,count(loan_status) as count
		from finance_1 
        left JOIN finance_2_upd ON finance_1.id = finance_2_upd.id
        where year(last_credit_pull_d) <> ''
        group by addr_state, year(last_credit_pull_d),loan_status
        order by addr_state,last_credit_pull_d) select  e.addr_state,e.year,
MAX(CASE WHEN e.loan_status  = "Charged Off" THEN e.count END) "Charged Off",     
MAX(CASE WHEN e.loan_status = "Current" THEN e.count END) "Current",
MAX(CASE WHEN e.loan_status = "Fully Paid" THEN e.count END) "Fully Paid"
FROM e
GROUP BY e.addr_state,e.year
ORDER BY e.addr_state asc;

         
        -- method2
        select f1.addr_state, year(f5.last_credit_pull_d) as Last_credit_pull,
count(case when f1.loan_status = 'Charged Off' then f3.Fin2  end) as Charged_Off,
count(case when f1.loan_status = 'Current' then f4.Fin3 end) as Current_1,
count(case when f1.loan_status = 'Fully Paid' then  f2.Fin1  end) as Fully_Paid
from finance_1 f1  join 
(
	select addr_state, count(Loan_status) as Fin1 from finance_1
	where loan_status='Fully Paid'
	group by addr_state
) f2 on f2.addr_state=f1.addr_state
 join
(
	select addr_state, count(Loan_status) as Fin2 from finance_1
	where loan_status='Charged Off'
	group by addr_state
) f3 on f3.addr_state=f1.addr_state
 join
(
	select addr_state, count(Loan_status) as Fin3 from finance_1
	where loan_status='Current'
	group by addr_state
) f4 on f4.addr_state=f1.addr_state

join finance_2_upd f5 on f5.id=f1.id
-- where f4.addr_state = 'AK'
group by f1.addr_state, year(f5.last_credit_pull_d)
order by f1.addr_state,year(f5.last_credit_pull_d);

        
                     
	# Home ownership Vs last payment date stats
    -- below query gives first occurrance last payment amount as on respective Last_dates
    
    select home_ownership,max(last_pymnt_d) as Last_Date, last_pymnt_amnt as Last_Paymnt from finance_1
	JOIN finance_2_upd
	ON finance_1.id = finance_2_upd.id
    group by home_ownership
    order by home_ownership;
    
    
    -- gives sum of home_ownership last payment amount ason last date
    
     select home_ownership,max(last_pymnt_d) as Last_Date, format(round(sum(last_pymnt_amnt),2),0) as Last_Paymnt from finance_1
	JOIN finance_2_upd
	ON finance_1.id = finance_2_upd.id
    where home_ownership = 'Mortgage'  and last_pymnt_d = '2016-05-01'
    group by home_ownership
    order by home_ownership;
   
      
	select home_ownership,max(last_pymnt_d) as Last_Date,format(round(sum(last_pymnt_amnt),2),0) as Total_Paymnt from finance_1
	JOIN finance_2_upd
	ON finance_1.id = finance_2_upd.id
    group by home_ownership
    order by home_ownership;
    
    
     
  
	
            
        
	
        

        



