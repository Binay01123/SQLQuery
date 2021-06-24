--------------------------------------------------------
-- Binay's Portfolio Project for SQL queries-----------
--------------------------------------------------------


-------------------------------------------------------------------------------------
-- Demonstartion of DML commands for Ad hoc data pulls from database for analysis---
------------------------------------------------------------------------------------

--- Using CASE statement to categorize products
Select ProductId, ProductName,
(case 
when ProductCost >100 and ProductCost < 201
then 'Medium cost'
when ProductCost >201
then 'High cost'
else 'low cost'
end) as costlevel,
productcost
from tblProduct

---Viewing two different tables
select * from tblProduct
go
select * from tblAncillary

--- Making union of two tables with identical number of columns
select * from tblProduct
union all
select * from tblAncillary  -- This table also includes duplicate rows

--- Merging two tables with distinct rows
select * from tblProduct
union
select * from tblAncillary

--INNER Join to produce the Matching Data between two table--
select * from tblCustomer C
inner join tblAddress A
on c.CustomerId = A. CustomerId


--Query that displays the customer name, Productname, Cost and SalesDate--
select C.CustomerName, 
		p.ProductName, 
		p.ProductCost, 
		pc.SalesDate
from tblProductCustomer pc
inner join tblCustomer c 
on pc.CustomerId_fk = c.CustomerId
inner join tblProduct p
on pc.Productid_fk = p.ProductId


--- Query for grouping by Product and their summary ---
select p.ProductName,
		sum(p.productcost) as totalsales, 
		count(*) as NumberofUnitsSold
from tblProductCustomer pc
inner join tblCustomer c 
on pc.CustomerId_fk = c.CustomerId
inner join tblProduct p
on pc.Productid_fk = p.ProductId
group by p.ProductName

--- Query for filtering By Groups ---
select p.ProductName,
		sum(p.productcost) as totalsales, 
		count(*) as NumberofUnitsSold
from tblProductCustomer pc
inner join tblCustomer c 
on pc.CustomerId_fk = c.CustomerId
inner join tblProduct p
on pc.Productid_fk = p.ProductId
group by p.ProductName
having count(*) > 1     

 ---- "Having" command is used for Group level filteration----- 
 ---- "Where" command is used for Row level filteration ---


 --- Determining the Customer referral 
 --[Both customerName and the referral's Name are in same table with their corresponsing ID]
 -- Thus, Using Self reference or Self-Join method as example
 select t1.CustomerName, 
 t2.CustomerName as referredBy
 from tblCustomer t1
 inner join tblCustomer t2
 on t1.CustomerReferenceId_fk = t2.CustomerId 

-- Finding "Direct walkins" in the same table
 select t1.CustomerName, 
 isnull(t2.CustomerName, 'Direct Walk-in') as referredBy
 from tblCustomer t1
 left join tblCustomer t2
 on t1.CustomerReferenceId_fk = t2.CustomerId 


 ------------------------------------------------------------------------
 ----Demonstration of Transaction and Locks---
 -------------------------------------------------------------------------


----TRANSACTION --- 

begin tran
insert into tblCustomer values (3, 'test1'); -- Inserting the value into 2 column table
insert into tblCustomer values (1, 'test1');
if(@@error > 0) ---Global variable for error
begin
	rollback tran   --- If there is an error in Transaction, revert back to the original form
end
else 
begin
	commit tran    --- If there is no error then save/commit the input into the table
end


---- Locking a Transaction---
---This exclusive lock prevents the concurrent second users to pull the data that is being modify/Update----

begin tran
	update tblcustomer set name = 'newtest'
	where id = 3  --- Here the lock is exclusive to row where ID=3
	waitfor delay '00:00:20' --Twenty seconds delay
	update tblcustomer set name = 'Newtest1'
	where id = 3
rollback tran

-- To Avoid deadlock where multiple transaction wants to access the exclusive rows, Updatelocks can be used--

begin tran
select * from tblCustomer 
with (updlock) where id=4 or id=3 
--Here we are locking multiple rows thus the concurrent transaction has to wait and execute; this avoids deadlock--
update tblCustomer set name='Update1'
where id=4
   waitfor delay '00:00:20'
update tblcustomer set name= 'update2'
   where id = 3 
commit tran 

----------------------------------------------
----- PIVOT TABLES IN SQL---
--------------------------------------

-- Defining the coulmn Names for pivot table
Select CustomerName, 
		[shoes] as shoes,
		[shirts] as shirts
---Fetching the data from the database tables
from (
	select CustomerName,
		   ProductName,
			Amount
	From [dbo].[tblProduct]
	) as PPivotData
--- Applying the Pivot function
Pivot
(
sum(amount) for productname in
(shoes,shirts)) as Pivoting
