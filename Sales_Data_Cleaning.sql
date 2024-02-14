Use SalesDB;

-- DATA CLEANING STEPS


-- Step 1: Filtering those valvues where there is no NULL Value in Sales
Select Count(SALES) as Total_rows from Sales;
Select Count(SALES) as Not_Null_rows from Sales
where Sales IS NOT NULL;

-- From the above query, it is clear that there are no NULL Sales data in the dataset. Thus we can filter without hesitation
Select * from Sales
where Sales IS NOT NULL;

-- STEP 2: Removing unwanted Columns.
-- In the dataset, there are 3 columns which is of no use to us. 1. Postal Code and 2. State 3. Phone
-- In state column there are too many blank columns which will be complicated to fill as it is State Code
Select Count(STATE) as Blank_rows from Sales
where STATE ='';									--  This query shows that there are 667 blank rows in State Column
Select Count(CITY) as Blank_rows from Sales
where CITY ='';										--  This query shows that there are 954 blank rows in City Column
-- During inspection in dataset, it was found that data City column had was entered into State Column.
-- Thus by using below condition, table was updated. This way only State column needs to be removed and we can keep CITY column.
Update Sales
Set City = State
where City='';

Alter table Sales
Drop column State, PostalCode;
Alter table Sales
Drop column PostalCode;
Alter Table Sales
Drop Column Phone;

-- STEP 3: Merging Coumns for better visiblity
Select addressline1 + ' ' + ADDRESSLINE2 as Address from Sales; -- Just To check the query synatx
Alter Table Sales                                  -- Another column is added by the  name Address
Add Address varchar(500)

Update Sales                                       -- Address Column is updated with the merge syntaxt checked in above line
Set Address = addressline1 + ' ' + ADDRESSLINE2;

Alter Table Sales                                  -- Once 2 columns were merged, old columnns were dropped.
Drop Column AddressLine1, AddressLine2

-- STEP 4: Cleaning Country, City Column
-- Data in Country, City, Territory column is mis managed, as there are wrong values.

-- In order to correct Country Column, inner join was used with a different table with Demographic details
Alter table sales                                  -- Dropping column country
drop column country;
Alter table sales                                  -- Dropping city, territory column
drop column city,territory;
Alter table sales                                  -- Dropping names column
drop column ContactLastname, contactfirstname;

Select distinct* from Sales
inner join Demographics
on Sales.Ordernumber = Demographics.ORDERNUMBER;

-- STEP 5: Formating Dealsize column
-- In this column, order size is mentioned (Small, medium or large), but in data in some of the rows, there are mixed strings
-- To remove that, first I created a column OrderSize and splitted the dealsize column based on delimiter (,)
-- After that updated the data in ordersize column based on the values in 2 columns.
Alter table sales
add Ordersize varchar(80);
update sales
 set Ordersize = REVERSE(PARSENAME(REPLACE(REVERSE(DEALSIZE), ',', '.'), 1))
 where REVERSE(PARSENAME(REPLACE(REVERSE(DEALSIZE), ',', '.'), 2)) is null; 

update sales
 set Ordersize = REVERSE(PARSENAME(REPLACE(REVERSE(DEALSIZE), ',', '.'), 2))
 where REVERSE(PARSENAME(REPLACE(REVERSE(DEALSIZE), ',', '.'), 2)) is NOT null; 

Select distinct sales.ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, trim(substring(orderdate,1,len(orderdate)-5)) as Orderdate, STATUS, QTR_ID,
				MONTH_ID, YEAR_ID, PRODUCTLINE, MSRP, PRODUCTCODE, CUSTOMERNAME, Ordersize, demographics.COUNTRY, demographics.CITY, 
				Demographics.TERRITORY
from Sales
inner join Demographics
on Sales.Ordernumber = Demographics.ORDERNUMBER;



















 /*
select isnumeric(Country), TERRITORY from sales
where isnumeric(Country)=1;

update sales
set Country = TERRITORY
where exists 
		(select isnumeric(Country) from sales
		where isnumeric(Country)=1);
*/