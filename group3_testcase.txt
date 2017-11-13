-------Feature 1------------------------------------

-- New Customer Entry

set SERVEROUTPUT ON;
exec registration ('Customer', 'Jeel', 'USA', '444-789-7495', 'jeel@gmail.com', 'jeel123', date '1991-01-02','Male',null,null,null,null); 
select * from userlogin
select * from customer;

-- Duplicate Customrer Entry
set SERVEROUTPUT ON;
exec registration ('Customer', 'Jeel', 'USA', '444-789-7495', 'jeel@gmail.com', 'jeel123', date '1991-01-02','Male',null,null,null,null); 
select * from userlogin
select * from customer;


--New Dependent Entry
set SERVEROUTPUT ON;
exec registration ('Dependent', 'Lissa', 'USA', '444-789-7495', 'Lissa@gmail.com', 'Lissa123', date '1991-01-02','Female',16,'Sister',null,null); 
select * from userlogin
select * from dependent;


--Duplicate Dependent Entry
set SERVEROUTPUT ON;
exec registration ('Dependent', 'Lissa', 'USA', '444-789-7495', 'Lissa@gmail.com', 'Lissa123', date '1991-01-02','Female',16,'Sister',null,null); 
select * from userlogin
select * from dependent;


-- New Service Provider
set SERVEROUTPUT ON;
exec registration ('Service Provider', 'Red cross', 'USA', '444-789-7495', 'redcross@gmail.com', 'redc123', date '1991-01-02',null,null,null,'Out-network',3);
select * from userlogin 
select * from SERVICE_PROVIDER;	


-- Duplicate Service Provider
set SERVEROUTPUT ON;
exec registration ('Service Provider', 'Red cross', 'USA', '444-789-7495', 'redcross@gmail.com', 'redc123', date '1991-01-02',null,null,null,'Out-network',3);
select * from userlogin 
select * from SERVICE_PROVIDER;

/* Feature:2 */
/*--------------*/

/* Allows user to login */

set serveroutput on;
exec login('bspa@gmail.com','bspa@45');

/* Incorrect Password */

set serveroutput on;
exec login('bspa@gmail.com','b@45');
 
/* Incorrect email id*/

set serveroutput on;
exec login('bspa@gmail.m','bspa@45');

/* Feature:3 */
/*--------------*/

/* Allows user to read the message */
/*-------------------------------- */

set serveroutput on;
exec read_message (4, date '2016-01-01');

/* Feature: 4 */
/*-------------- */

/*Inserting into the policy table for customer*/

set serveroutput on;
exec policy_number (16,'Family First', date '2013-01-01');

/* Inserting into the policy table for dependent */
/*Insert into the policy with the user id of the related customer. Dependent 37 is related to customer 36.*/

set serveroutput on;
exec policy_number (37,'Family First', date '2013-01-01');

/* Check for existing policy */

set serveroutput on;
exec policy_number (16,'Family First', date '2013-01-01');

--------------------Feature 5--------------------------------------

--Case 1: Adding a new dependent to the policy
set serveroutput on;
exec add_policydependent(4,1);

--Case 2: Trying to add an existing dependent to the policy
set serveroutput on;
exec add_policydependent(4,1);

-----------------------Feature 6----------------------------------
--Case 3: Removing a dependent from the table whose entry exists in the table
set serveroutput on;
exec remove_policydependent('Britny Spassky',1);

--Case 4: Removing a dependent from the table whose entry does not exist in the table
set serveroutput on;
exec remove_policydependent('Britny Spassky',1);

/* Feature: 7 */
/*-------------- */

/* Calculating Premium for the given policy id */

set serveroutput on;
exec cal_premium(5);

/* Checking if the policy exists or not */

set serveroutput on;
exec cal_premium(50);

-----------------------Feature 8----------------------------------
--Case1: When the sub string of service description exists with given policy id.

set serveroutput on;
exec policy_coverage_details_8(2,'%e%');


--Case2: When the sub string of service description does not exists with given policy id.

set serveroutput on;
exec policy_coverage_details_8(3,'%e%');

-----------------------Feature 9----------------------------------
--Case1: When service provider doesnt exist

set serveroutput on;
exec feature9_final_va(sparraylisttype(sparray(3,225)),40,7,'Smit',date'2006-04-30');

--Case2: When policy doesnt exist

set serveroutput on;
exec feature9_final_va(sparraylisttype(sparray(3,225)),4,70,'Smit',date'2006-04-30');

--Case3: When date range is outside acceptable plan dates

set serveroutput on;
exec feature9_final_va(sparraylisttype(sparray(3,225)),4,7,'Smit',date'2016-04-30');

select * from message;

--Case4: To check whether a provider and policy exists and submit a new claim with existing customer for policy owner

set serveroutput on;
exec feature9_final_va(sparraylisttype(sparray(3,225)),4,7,'Smit',date'2006-04-30');

--Case5: To check whether a provider and policy exists and submit a duplicate claim with same service id, policy id, service date for policy owner

set serveroutput on;
exec feature9_final_va(sparraylisttype(sparray(3,225)),4,7,'Smit',date'2006-04-30');

--Case6: When policy deductable is not reached and a new bill is submitted 

set serveroutput on;
exec feature9_final_va(sparraylisttype(sparray(3,225)),4,7,'Smit',date'2006-05-01');

--Case7: Another claim submission to reach maximum allowed service

set serveroutput on;
exec feature9_final_va(sparraylisttype(sparray(3,225)),4,7,'Smit',date'2006-05-02');

--Case8: When submitting more claims than allowed per year, message should be displayed that more claims than allowed and enter a declined claim into claim_line table.

set serveroutput on;
exec feature9_final_va(sparraylisttype(sparray(3,225)),4,7,'Smit',date'2006-05-03');

--Case9: When dependent not linked to policy

exec feature9_final_va(sparraylisttype(sparray(3,225)),4,7,'Boris Spassky',date'2006-05-01');

--Case10: When date of service is outside acceptable plan date for dependent

set serveroutput on;
exec feature9_final_va(sparraylisttype(sparray(2,225)),2,2,'Boris Spassky',date'2016-05-09');

--Case11: Submit a new claim with existing customer for policy dependent

set serveroutput on;
exec feature9_final_va(sparraylisttype(sparray(2,300)),2,2,'Boris Spassky',date'2002-05-16');

--Case12: Submit a duplicate claim with same service id, policy id, service date for policy dependent

set serveroutput on;
exec feature9_final_va(sparraylisttype(sparray(2,300)),2,2,'Boris Spassky',date'2002-05-16');


/* Feature: 10 */
/*-------------- */

/* Allows user to search for claims */

set serveroutput on;
exec search_ClaimDetails (4, date '2016-01-01',date '2017-06-26');

/* No Claims for the given Customer */ 
set serveroutput on;
exec search_ClaimDetails (12, date '2017-01-01',date '2017-06-26');

----------------------Feature 11 ------------------------------------
-- Entry is present
set serveroutput on;
exec claimDetails(2);

-- No claim Present
set serveroutput on;
exec claimDetails(2);


/* Feature: 12 */
/*-------------- */

/* Calculating totals for the customer */

set serveroutput on;
exec check_totalCost_1(12,2015);

/* No details for given customer */

set serveroutput on;
exec check_totalCost_1(12,2016);


---------------------Feature 13----------------------------------
--Year from 2001 to 2016--Statistic Result 

set serveroutput on;
exec displayResult_feature13 (2);



/* Feature: 14 */
/*-------------- */

/* compute the yearly usage statistics for the past 5 years */

set serveroutput on;
exec yearly_statistics(2);



-----------------------Feature 15-------------------------------
set serveroutput on;
exec findFraudPolicies_15(900,400,'Customer');
exec findFraudPolicies_15(900,400,'Service Provider');
