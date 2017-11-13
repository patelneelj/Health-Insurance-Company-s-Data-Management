create or replace TYPE SpArray AS OBJECT
    ( spid int,
      serviceAmount int
    ) ;


create or replace type spArrayListType as varray(2) of SpArray;


-------------------------------Feature 1----------------------------------

create or replace PROCEDURE registration (userType in varchar, name in varchar, address in varchar, phone in varchar, emailId in varchar, user_pswd in varchar, birthdate date,gender in varchar,cust_userId in Integer,relation in varchar,provider_type in varchar,serviceid in integer) 
IS
user_id integer;
BEGIN
     user_id:= return_userid(emailId, user_pswd);
     if(user_id = -1) then
        if(userType = 'Customer') then
            user_id := return_custuserid(name,emailId,user_pswd,address, phone, birthdate, gender);
            dbms_output.put_line('New User Id of customer is: ' || user_id);
         elsif (userType = 'Dependent') then
            user_id := return_dependuserid(name,emailId,user_pswd,address, phone, birthdate, gender,cust_userId,relation);
            dbms_output.put_line('New User Id of dependent is: ' || user_id); 
          elsif (userType = 'Service Provider') then
           user_id := return_provideruserid(name,emailId,user_pswd,address, phone,provider_type,serviceid);
           dbms_output.put_line('New User Id of service provider is: ' || user_id);    
         End if; 

     End if;
End;

---------------Procedure for Feature 2--------------------
----------------------------
Create or replace PROCEDURE login (emailId in varchar, user_pswd in varchar) 
IS
user_id integer;
BEGIN
	/* Calling the function to check the login */

     user_id:= check_login(emailId, user_pswd);
  
End;

-----------------------Procedure for Feature 3-------------------
----------------------------

Create or replace PROCEDURE read_message (user_id in integer,m_date in date) IS /* Fetches the message for the user with the starting date */

/* Cursor and Variable declaration */

Cursor c1 is select message_body 
from message where userid = user_id and message_date >= m_date;
m_body varchar(200);
BEGIN
Open c1;
Loop
	fetch c1 into m_body;
	exit when c1%notfound;

/*Prints the message */

	dbms_output.put_line('Mesage is: ' || m_body);
End loop;
exception
	WHEN OTHERS THEN
	dbms_output.put_line('Incorrect input parameters');
END;

------------------Procedure for Feature 4------------------------
----------------------------

create or replace PROCEDURE policy_number (user_id in number, planname in varchar, start_year in date) 
IS

/* Variable Declaration */

pol_id POLICY.POLICY_ID%type;
msg_id message.message_id%type;
usid number;
BEGIN
      select count(userid) into usid from userlogin where UT_ID = 1 and userid = user_id;
      if(usid > 0) then

      /* Calling the function to create policy for the customer.*/

      pol_id:= return_policyid(USER_ID,PLANNAME,START_YEAR);
      else

      /* Calling the function to create policy for the dependent.*/

       pol_id:= return_policyDepdid(USER_ID,PLANNAME,START_YEAR);
      end if;
     if(pol_id <> -1) then

     /* Calling the function to insert message.*/

        msg_id := insert_msg(user_id, pol_id);

     /* Printing that the message id. */

        dbms_output.put_line('Message is inserted successfully with message id '||msg_id);
     End if; 
End;

---------------------------------------Feature 5---------------------------------------------
create or replace procedure add_policydependent (dep_id IN number, pol_id IN number) --function to add a dependent to the policy dependent table for a user
IS
id number;
user_id userlogin.userid%type;
custid customer.cust_id%type;
msg_id message.message_id%type;
did dependent.d_id%type;
Begin
select d_id into did from dependent where d_id=dep_id;
id := get_existing_depid(dep_id,pol_id); --function call for checking if the dependent already exists for that policy
if (id= 0) then -- id=0 when an entry exists in the policy dependent table
dbms_output.put_line('Entry already exists.'); 
elsif(id = -1) then
dbms_output.put_line('Creating new entry');
    select cust_id into custid from dependent where d_id= dep_id; 
    select userid into user_id from customer where cust_id=custid;
    insert into policy_dependent values (pol_id,dep_id,user_id);
    msg_id := add_msg (user_id,dep_id,pol_id); --function for inserting the message into the message table
    dbms_output.put_line('Message is inserted successfully with message id '||msg_id);
  End if;
exception
	when no_data_found then
	dbms_output.put_line('No data found');
End;

----------------------------------------Feature 6-------------------------------------------------
create or replace procedure remove_policydependent (dep_name IN varchar, pol_id IN number) --function to remove a dependent to the policy dependent table for a user
IS
id number;
user_id userlogin.userid%type;
custid customer.cust_id%type;
msg_id message.message_id%type;
dep_id dependent.d_id%type;
Begin
select d_id into dep_id from dependent where d_name=dep_name;
id := get_existing_deptid(dep_id,pol_id); --function call for checking if the dependent already exists for that policy
if (id = 0) then --remove the entry based on the response from the user
dbms_output.put_line('Removing entry'); 	
    select cust_id into custid from dependent where d_id= dep_id; 
    select userid into user_id from customer where cust_id=custid;
    delete from policy_dependent where d_id=dep_id and policy_id=pol_id and userid=user_id;
    msg_id := add_msg1 (user_id,dep_id,pol_id); --function for inserting the message into the message table
    dbms_output.put_line('Message is inserted successfully with message id '||msg_id);
elsif(id = -1) then
	dbms_output.put_line('Entry does not exist.');
  End if;
exception
	when no_data_found then
	dbms_output.put_line('Invalid Dependent_name or policy_id');
End;

----------------Procedure for Feature 7---------------------------------
----------------------------
Create or replace PROCEDURE cal_premium (pol_id in number) 
IS
premium_amt PREMIUM.PREMIUM_AMOUNT%type;
BEGIN
	/* Calling the function to calculate the premium amount. */

     premium_amt:= calculate_premium (pol_id);
  
End;


----------------------------------------Feature 8-------------------------------------------------
create or replace procedure policy_coverage_details_8 (p_id in number,service_desc in varchar) IS
cursor c1 is
select coverage.coverage_id,coverage.service_id,coverage.max_service_peryear,coverage.allowed_service_charges,coverage.in_network_copay,coverage.in_network_coinsurance,coverage.out_network_copay,coverage.out_network_coinsurance from coverage,service,policy where coverage.service_id = service.service_id and policy.service_id=service.service_id and coverage.coverage_id= policy.coverage_id and policy.policy_id=p_id and service.service_description like service_desc;
--the above query selects the coverage_id,service_id, max_service_peryear, allowed_service charge, in_network_copay, in_network_coinsurance,out_network_copay,out_network_coinsurance from coverage table for the given policy id and string of service description.
c_id coverage.coverage_id%type;
s_id coverage.service_id%type;
max_service coverage.max_service_peryear%type;
allowed_service coverage.allowed_service_charges%type;
in_copay coverage.in_network_copay%type;
in_coinsurance coverage.in_network_coinsurance%type;
out_copay coverage.out_network_copay%type;
out_coinsurance coverage.out_network_coinsurance%type;
--variable declaration
begin 
open c1; --opens cursor
loop

fetch c1 into c_id,s_id,max_service,allowed_service,in_copay,in_coinsurance,out_copay,out_coinsurance; --selects the above values of c1 and stores into the variable here

if(c_id <> 0 ) then
dbms_output.put_line('coverage id = ' || c_id || ', service id is = ' || s_id||	', Allowed Service ' || allowed_service ||
'In network copay is = ' || in_copay|| 'in network coinsurance is' || in_coinsurance || 'out network copay is ' || out_copay||
' out network coinsurance is' || out_coinsurance);
else
DBMS_OUTPUT.PUT_LINE('Policy doesnot cover the required service');
end if;
 --print statement
EXIT when c1%notfound;     
--print statement


END LOOP; --loop ends

exception
	WHEN no_data_found THEN
	dbms_output.put_line('');
Close c1; --end of cursor
END;


----------------------------------------Feature 9-------------------------------------------------
create or replace procedure feature9_final_va (
checksp spArrayListType, prov_id in integer, pol_id in integer, patient_name in varchar, date_of_service in date)
--creating a procedure
IS

--variable declaration

case1 number;
case2 number;
case3 number;
case4 number;
case5 number;
case6 number;
case7 number;
case8 number;
case9 number;
case10 number;
case11 number;
case12 number;
case13 number;
case14 number;
case15 number;
case16 Number;
case17 number;
u_id number;
u_id1 number;
serv_id number;
amnt number;

--procedure begins
Begin

--for loop starts here for varray 

FOR i IN 1..checksp.count LOOP

----here all the functions are called and depending on their return value the entire calculation happens
  serv_id := checksp(i).spid;
  amnt:=checksp(i).serviceAmount;
case1 := feature9_get_existing_provid(prov_id);
case2 := feature9_get_existing_policyid(pol_id);
case3 := feature9_patientcheckincust(patient_name);
case4 := feature9_patientcheckindepd(patient_name);
case5 := feature9_patientpolicy_cust(pol_id,patient_name);
case6 := feature9_patientpolicy_depd(pol_id,patient_name);
case7 := feature9_checkdate(pol_id,date_of_service);
case8 := f9_check_serviceinpolicy_cust(patient_name,serv_id,pol_id);
case9 := f9_check_serviceinpolicy_depd(patient_name,serv_id,pol_id);
case10 := f9_3_check_duplicate_cust(patient_name,serv_id,date_of_service);
case11 := f9_3_check_duplicate_depd(patient_name,serv_id,date_of_service);
/*case12 := f9_4_Adjustcharge_cust(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service);
case13 := f9_4_adjustcharge_depd(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service);
case14 := f9_5_6_7_pay_cust(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service);
case15 := f9_5_6_7_pay_depd(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service);
case16 := Feature_message_9_8_Cust(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service);*/

--checks the return value of feature9_get_existing_provid(prov_id) to check if provider exists
if (case1 = -1) then
dbms_output.put_line('Provider doesnt exist');
insert into message values ( message_seq.nextval,'Service provider does not exist',sysdate,0);


--checks the return value of feature9_get_existing_polid(prov_id) to check if policy exists      
elsif(case2 = -1) then
	dbms_output.put_line('policy doesnt exist');
insert into message values ( message_seq.nextval,'Policy does not exist',sysdate,0);

--checks the return value of feature9_patientcheckincust(patient_name) and feature9_patientcheckindepd(patient_name) to check if patient exists   
elsif(case3 = -1 and case4 = -1) then
	dbms_output.put_line('patient doesnt exist in customer table');
insert into message values ( message_seq.nextval,'patient doesnt exist in records',sysdate,0);

--checks the return value of feature9_patientpolicy_cust and feature9_patientpolicy_cust to check if patient linked to policy     
elsif(case5 = -1 and case6 = -1) then
	dbms_output.put_line('patient not linked to policy case 5');
insert into message values ( message_seq.nextval,'Patient not linked to policy',sysdate,0);
   
--checks the return value of feature9_checkdate to check if date of service within allowable range or not     
elsif(case7 = -1) then
	dbms_output.put_line('date of service is outside of the acceptable plan dates');
insert into message values ( message_seq.nextval,'date of service is outside of the acceptable plan dates',sysdate,0);


elsif(case7=0) then
----checks the return value of f9_check_serviceinpolicy_cust and f9_check_serviceinpolicy_depd to see if the user exceeds max allowed service or not and if patient linked to service     
  if((case8 =2 and case9 = 3) or (case8 = 3 and case9 = 2))then
	dbms_output.put_line('Policy doesnt include mentioned service or more claims than allowed');
insert into message values ( message_seq.nextval,'Policy doesnt include mentioned service or more claims than allowed',sysdate,0);
    if (case8=-1) then
    select userid into u_id from customer where cust_name=patient_name;
    insert into claim_line values(claimid_seq.nextval,'Declined',amnt,0,0,0,0,0,message_seq.currval,serv_id,date_of_service,pol_id,sysdate,u_id,prov_id,2);
    elsif(case9=-1) then
    select userid into u_id from dependent where d_name=patient_name;
    insert into claim_line values(claimid_seq.nextval,'Declined',amnt,0,0,0,0,0,message_seq.currval,serv_id,date_of_service,pol_id,sysdate,u_id,prov_id,2);
    end if;
elsif(case8=0 and case9 =0) then

dbms_output.put_line('Exception');
insert into message values ( message_seq.nextval,'Exception',sysdate,0);

------checks for duplicate claim
elsif (case8 =1 or case9 =1) then
  if(case10 = -1 or case11 = -1) then
  dbms_output.put_line('Duplicate claim');
insert into message values ( message_seq.nextval,'Duplicate claim',sysdate,0);
  if (case10 = -1 and case11=0) then
    select userid into u_id from customer where cust_name=patient_name;
	----inserts into cliam_line for declined status
    insert into claim_line values(claimid_seq.nextval,'Declined',amnt,0,0,0,0,0,message_seq.currval,serv_id,date_of_service,pol_id,sysdate,u_id,prov_id,2);
  elsif (case11 = -1 and case10=0) then
    select userid into u_id from dependent where d_name=patient_name;
    --inserts into cliam_line for declined status
	insert into claim_line values(claimid_seq.nextval,'Declined',amnt,0,0,0,0,0,message_seq.currval,serv_id,date_of_service,pol_id,sysdate,u_id,prov_id,2);
  end if;

--calls the f9_4_Adjustcharge_cust and f9_4_Adjustcharge_depd function to adjust the min of charge
elsif(f9_4_Adjustcharge_cust(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service) = -1 and f9_4_Adjustcharge_depd(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service) = -1) then
	dbms_output.put_line('Amount not adjusted');
insert into message values ( message_seq.nextval,'Amount not adjusted',sysdate,0);

--calculates the amount
elsif(f9_5_6_7_pay_cust(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service) = -1 and f9_5_6_7_pay_depd(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service) = -1) then
	dbms_output.put_line('Adjustment and calculation error');
insert into message values ( message_seq.nextval,'Adjustment and calculation error',sysdate,0);

----inserts the message in message table with claim submit details for customer
elsif(Feature_message_9_8_Cust(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service)= 0) then
dbms_output.put_line('Claim submitted and message inserted into message table with message id' || message_seq.currval);


----inserts the message in message table with claim submit details for dependent
elsif(Feature_message_9_8_Cust(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service) =-1) then
      case17 := Feature_message_9_8_Depd(pol_id ,serv_id,prov_id,amnt, patient_name, date_of_service);
      dbms_output.put_line('Claim submitted and message inserted into message table with message id' || message_seq.currval);

else
  dbms_output.put_line('Claim submitted without message id');


end if;
end if;
end if;
end loop;
end;

-------------------Procedure for Feature 10---------------------------------
----------------------------
create or replace procedure search_ClaimDetails (u_id in integer,start_range in date,end_range in date) IS  /* Fetches claim ID, provider, patient name, service date for the given user and date range*/

/* Cursor and variable declaration */

cursor c1 is 
select case when exists (select 1 from customer where userid=u_id) then (select cust_name from customer where userid=u_id) else (select d_name from dependent where userid=u_id) end as PATIENT_NAME, CL.CLAIM_ID,SP.SP_DESCRIPTION,CLAIM_DATE
FROM CLAIM_LINE CL, SERVICE_PROVIDER SP where CL.sp_id = SP.Sp_ID and (claim_date BETWEEN start_range AND end_range) AND CL.USER_ID = u_id;
patient_name varchar(100);
claimid CLAIM_LINE.CLAIM_ID%type;
provider_name SERVICE_PROVIDER.SP_DESCRIPTION%type;
claimdate CLAIM_LINE.CLAIM_DATE%type;
myexec EXCEPTION;
begin
open c1;
loop
fetch c1 into patient_name,claimid,provider_name,claimdate;
if (claimid IS NULL AND provider_name IS NULL AND claimdate IS NULL) then
  RAISE myexec;
end if;
exit when c1%NOTFOUND;

/*Prints the message */

dbms_output.put_line('Claim ID = ' || claimid || ', Patient Name is = ' || patient_name || ', Service Provide Name is = ' || provider_name ||	', Claim date is = ' || claimdate);
END LOOP;
exception
	WHEN myexec THEN

/* Prints the exception */
   dbms_output.put_line('No Claims for Customer ID ' || u_id || ' for the year range ' || start_range || ' and ' || end_range );
Close c1;
END;


----------------------------------------
---------------------------------Feature 11-------------------------

create or replace PROCEDURE claimDetails (claimId in int) 
IS
countofcid int;
cursor c1 is select providers_charge,service_description, amount_copay,amount_deductable,amount_of_coinsurance, amount_paid_byinsurance,
amount_paid_byCustomer ,service_date from claim_line c join service s on s.service_id  = c.service_id where cid=claimId;
     pcharge claim_line.providers_charge%type;
     copay claim_line.amount_copay%type;
     deductable claim_line.amount_deductable%type;
     coinsurance claim_line.amount_of_coinsurance%type;
     byinsurance claim_line.amount_paid_byinsurance%type;
     bycustomer claim_line.amount_paid_byCustomer%type;
     sdate claim_line.service_date%type;
     service_name service.service_description%type;
begin
countofcid:= claimavailable(claimId);
if(countofcid <> 0)then
    open c1;
    loop
    fetch  c1 into pcharge,service_name,copay,deductable,coinsurance,byinsurance,bycustomer,sdate;
    exit when c1%notfound;
    dbms_output.put_line('Service date: '||sdate||' Service Name: '||service_name||' Service Provider Charge: '||pcharge||' Copay Amount: '||copay||' Deductable Amount: '||deductable||' Coinsurance Amount: '||
    coinsurance||' Amount paid by insurance: '||byinsurance||' Amount paid by customer: '||bycustomer);
    end loop;
    close c1;
    else
    dbms_output.put_line('No such claim present');
    end if;
End;


------------------------Procedure for Feature 12--------------------------------------------------
----------------------------
create or replace PROCEDURE check_totalCost_1 (u_id in integer, planyear IN integer) /* total amount paid in a given plan year, the total deductible paid, the total co-pay paid, the total co-insurance paid, the total out-of-pocket cost for each member on the plan, and the total out-of-pocket cost for the whole family */
IS

/* Variable Declaration */

totalamtpaid_cust CLAIM_LINE.AMOUNT_PAID_BYCUSTOMER%type;
totaldeductible_cust CLAIM_LINE.AMOUNT_DEDUCTABLE%type;
totalcopay_cust CLAIM_LINE.AMOUNT_COPAY%type;
totalcoinsurance_cust CLAIM_LINE.AMOUNT_OF_COINSURANCE%type;
opcper_family number;
opcper_member number;
planid PLAN.PLAN_ID%type;
myexec EXCEPTION;

BEGIN
select sum(max_opc_permember) into opcper_member from plan pl
join 
policy p 
on p.plan_id = pl.plan_id
where extract( year from plan_start_year) = planyear and p.user_id =u_id ;

select 
sum(AMOUNT_PAID_BYCUSTOMER),sum(AMOUNT_DEDUCTABLE), sum(AMOUNT_COPAY), sum(AMOUNT_OF_COINSURANCE), sum(AMOUNT_PAID_BYCUSTOMER) INTO totalamtpaid_cust,totaldeductible_cust, totalcopay_cust ,totalcoinsurance_cust, opcper_family
FROM CLAIM_LINE WHERE extract (YEAR from claim_date) = planyear AND CLAIM_LINE.USER_ID = u_id AND CLAIM_LINE.STATUS = 'Accept';

if (totalamtpaid_cust IS NULL AND totaldeductible_cust IS NULL AND totalcopay_cust IS NULL AND totalcoinsurance_cust IS NULL) then
RAISE myexec;
end if;

/* Printing the values*/

dbms_output.put_line('The total amount paid = ' || totalamtpaid_cust || ', the total deductible paid = ' || totaldeductible_cust ||	', the total co-pay paid = ' || totalcopay_cust 
|| ', the total co-insurance paid = ' || totalcoinsurance_cust || ' The out-of-pocket cost per family = ' || opcper_family || ' The out-of-pocket cost per member = ' || opcper_member);
exception
	WHEN myexec THEN

/* Printing the exception */

   dbms_output.put_line('No details for customer id ' || u_id || ' for plan year ' || planyear);
END;


-----------------------------------Feature 13-----------------------

create or replace PROCEDURE displayPolicydetails (uid in int) 
IS
cursor c1 is select extract(year from plan_start_year)  ,count(p.policy_id)  ,
sum(premium_amount)  
from plan pl
join policy po
on
pl.plan_id = po.plan_id
join
PREMIUM p
on
p.policy_id = po.POLICY_ID
where extract(year from plan_start_year) <= 2016 and extract(year from plan_start_year) >= 2001
group by extract(year from plan_start_year);
Last5year int;
totalNoOfPolicy number;
totalAmountpaidpremium int;  
begin
    open c1;
    loop
    fetch  c1 into Last5year,totalNoOfPolicy,totalAmountpaidpremium;
    exit when c1%notfound;
    dbms_output.put_line('Year: '||Last5year||', Total No of Policy: '||totalNoOfPolicy||', Total premium Amount: '||totalAmountpaidpremium);
    end loop;
    close c1;  
End;


create or replace PROCEDURE displayClaim (uid in int) 
IS
cursor c1 is select extract(year from service_date) , count(claim_id), sum(amount_paid_bycustomer),
sum(cl.AMOUNT_PAID_BYINSURANCE)
from coverage c
join
policy p
on
p.coverage_id = c.coverage_id
join
claim_line cl
on
cl.policy_id = p.policy_id
where extract(year from service_date) <= 2016 and extract(year from service_date)>=2010
group by extract(year from service_date);
Last5year int;
claimCount number;
paidbycustomer number;
paidbyInsurance number;
begin
    open c1;
    loop
    fetch  c1 into Last5year,claimCount,paidbycustomer,paidbyInsurance;
    exit when c1%notfound;
    dbms_output.put_line('Year: '||Last5year||', Total no of claim: '||claimCount||', Total amount paid by customer: '||paidbycustomer||', Toal amount paid by Insurance: '||paidbyInsurance);
    end loop;
    close c1;  
End;


create or replace PROCEDURE displayResult_feature13 (uid in int)
IS
totalNoOfCustomer number;
totalNoOfSP number;
Last5year number;
totalNoOfPolicy number;
totalAmountpaidpremium int;
Begin
--Display Total Customer
select count(*) into totalNoOfCustomer from userlogin ul
join 
usertype ut
on
ut.ut_id = ul.ut_id
and ut.user_type = 'Customer';

--Display in-network service provider
select count(*) into totalNoOfSP from USERLOGIN ul
join
usertype ut
on
ut.ut_id = ul.ut_id
join
service_provider sp
on
sp.userid=ul.userid
where sp.sp_type = 'In-network' 
and ut.user_type = 'Service Provider';

dbms_output.put_line('Total No of Customer: '||totalNoOfCustomer||', Total no of in-n/w sp: '||totalNoOfSP);
---Display no of  policies, total amount received in past 5 years
displayPolicydetails (uid) ;
--Display total Claims in past 5 years
displayClaim(uid);
exception
when no_data_found then
dbms_output.put_line('No data found');
end;


-----------------------------------Procedure for Feature 14----------------------------
----------------------------

create or replace procedure cal_medserv_details_14_1 (year in integer) /* Computes the number of services appeared in claims each year */
IS

/* Cursor and variable Declaration */

cursor c1 is 
select extract(year from service_date),count(service_id),service_id from claim_line
where extract(year from service_date) <= 2017 and extract(year from service_date)>=2013
group by 
extract(year from service_date),service_id;
servicedate number;
serviceid CLAIM_LINE.SERVICE_ID%type;
no_of_service integer;
BEGIN
OPEN C1;
LOOP
FETCH C1 into servicedate,no_of_service,serviceid;
exit when c1%NOTFOUND;

/* Printing the data */

dbms_output.put_line('The services id ' || serviceid || ' has appeared ' || no_of_service || ' times' || ' in the year ' ||servicedate );  
END LOOP;
CLOSE C1;
END;


create or replace procedure cal_medserv_details_14_2 (top_k in integer) /* Computes the top K (K as an integer input) services with the most claims in each year in the past 5 years */
IS

/* Cursor and variable Declaration */

cursor c2 is
select datec,service_id from
(select count(service_id), service_id ,extract (year from claim_Date) as datec
from Claim_line where (extract(year from claim_date)=extract(year from sysdate)) group by extract(year from claim_date), service_id order by count(service_id) desc) where rownum<=top_k
UNION ALL
select datec, service_id from
(select count(service_id), service_id ,extract (year from claim_Date) as datec
from Claim_line where (extract(year from claim_date)=extract(year from sysdate)-1) group by extract(year from claim_date), service_id order by count(service_id) desc) where rownum<=top_k
UNION ALL
select datec, service_id from
(select count(service_id), service_id ,extract (year from claim_Date) as datec
from Claim_line where (extract(year from claim_date)=extract(year from sysdate)-2) group by extract(year from claim_date), service_id order by count(service_id) desc) where rownum<=top_k
UNION ALL
select datec, service_id from
(select count(service_id), service_id ,extract (year from claim_Date) as datec
from Claim_line where (extract(year from claim_date)=extract(year from sysdate)-3) group by extract(year from claim_date), service_id order by count(service_id) desc) where rownum<=top_k
UNION ALL
select datec, service_id from
(select count(service_id), service_id ,extract (year from claim_Date) as datec
from Claim_line where (extract(year from claim_date)=extract(year from sysdate)-4) group by extract(year from claim_date), service_id order by count(service_id) desc) where rownum<=top_k;
serviceid CLAIM_LINE.SERVICE_ID%type;
no_of_service integer;
claimdate number;
BEGIN
OPEN C2;
LOOP
FETCH C2 INTO claimdate, serviceid;
EXIT WHEN C2%NOTFOUND;

/* Printing the data */

dbms_output.put_line('The top services id is ' || serviceid || ' in the year ' || claimdate); 
END LOOP;
CLOSE C2;
END;


create or replace procedure search_medserv_details_14_3 (med_year in integer) IS /* Computes percentage of patients (customers and their dependents) who have used the service at least once in each year and the highest percentage of patients each year in past 5 years. */

/* Variable Declaration*/

c integer;
n integer;
PERCENTAGE integer;
begin
 select (n/c)*100 into PERCENTAGE
from ( select sum(amount) as c from
(
select count(cust_id) amount from customer union all select count(d_id) amount from dependent
)) 
, ( select count(user_id) n from claim_line where ((extract(year from claim_date)=2017)));
dbms_output.put_line('The highest percentage of patient is ' || PERCENTAGE || '%' || ' in the year 2017');  
       
select (n/c)*100 into PERCENTAGE
from ( select sum(amount) as c from
(
select count(cust_id) amount from customer union all select count(d_id) amount from dependent
)) 
, ( select count(user_id) n from claim_line where ((extract(year from claim_date)=2016)));
dbms_output.put_line('The highest percentage of patient is ' || PERCENTAGE || '%' || ' in the year 2016');  

select (n/c)*100 into PERCENTAGE
from ( select sum(amount) as c from
(
select count(cust_id) amount from customer union all select count(d_id) amount from dependent
)) 
, ( select count(user_id) n from claim_line where ((extract(year from claim_date)=2015)));
dbms_output.put_line('The highest percentage of patient is ' || PERCENTAGE || '%' || ' in the year 2015');  

select (n/c)*100 into PERCENTAGE
from ( select sum(amount) as c from
(
select count(cust_id) amount from customer union all select count(d_id) amount from dependent
)) 
, ( select count(user_id) n from claim_line where ((extract(year from claim_date)=2014)));
dbms_output.put_line('The highest percentage of patient is ' || PERCENTAGE || '%' || ' in the year 2014');  

select (n/c)*100 into PERCENTAGE
from ( select sum(amount) as c from
(
select count(cust_id) amount from customer union all select count(d_id) amount from dependent
)) 
, ( select count(user_id) n from claim_line where ((extract(year from claim_date)=2013)));
dbms_output.put_line('The highest percentage of patient is ' || PERCENTAGE || '%' || ' in the year 2013');  

END;

create or replace PROCEDURE yearly_statistics(top_k in integer) 
IS
user_id integer;
BEGIN

/* Calling the procedures */

     cal_medserv_details_14_1 (top_k);
     cal_medserv_details_14_2 (top_k);
     search_medserv_details_14_3 (top_k);
  
End;

-------------------Feature 15------------------------------------
create or replace procedure findFraudPolicies_15(threshold in number,thresholdAverage in number, typeOfUser in varchar)
is
 TYPE fraudTableType IS RECORD (
     pid        number(10),
     nextpid number(10),
     claimYear       number(10),
     byinsurance number(10),
     difference number(10)
  );
   TYPE fraudTableType_tab IS TABLE OF fraudTableType;
   fraudTableType_rec fraudTableType_tab;

    TYPE fraudTableType_sp IS RECORD (
     spid        number(10),
     nextspid number(10),
     claimYear       number(10),
     byinsurance number(10),
     difference number(10)
  );
    TYPE fraudTableType_tab_sp IS TABLE OF fraudTableType_sp;
   fraudTableType_rec_sp fraudTableType_tab_sp;
username varchar2(50);   
begin
if(typeOfUser = 'Customer') then

select policy_id, lead(POLICY_ID,1) over (order by policy_id,extract(year from service_date)) as nextpid ,extract(year from service_date) as year,
sum(amount_paid_byInsurance) as totalpaidbyinsurance,
lead(sum(amount_paid_byInsurance),1) over (order by policy_id,extract(year from service_date))  - sum(amount_paid_byInsurance)  as difference
BULK COLLECT INTO fraudTableType_rec
from claim_line where status = 'Accept'
group by extract(year from service_date),policy_id
order by policy_id,extract(year from service_date);

for i in 1..fraudTableType_rec.count 
loop
if((fraudTableType_rec(i).pid = fraudTableType_rec(i).nextpid) AND fraudTableType_rec(i).difference > threshold ) then
select cname into username from (
select cust_name as cname  from customer c
join 
policy p
on p.user_id = c.USERID where p.policy_id = fraudTableType_rec(i).pid
union
select d_name as cname from dependent d
join 
policy p
on 
p.user_id = d.USERID where p.policy_id = fraudTableType_rec(i).pid);

     dbms_output.put_line('Condition 1:Customer ');
    dbms_output.put_line( 'Policy id: '||fraudTableType_rec(i).pid||', Username is: '||username||', Year: '||fraudTableType_rec(i).claimYear||', Difference in insurance amount: '||fraudTableType_rec(i).difference);
    dbms_output.put_line('------------------------------------------------------------- ');
    end if;
  END LOOP;

select  policy_id,lead(POLICY_ID,1) over (order by policy_id,extract(year from service_date)) as nextpid,extract(year from service_date) as year,
sum(amount_paid_byInsurance)/count(policy_id) as totalAveragepaidbyInsurance,
lead(sum(amount_paid_byInsurance)/count(policy_id),1) over (order by policy_id,extract(year from service_date))  - (sum(amount_paid_byInsurance))/count(policy_id) as difference
BULK COLLECT INTO fraudTableType_rec
from claim_line where status = 'Accept'
group by extract(year from service_date), policy_id
order by policy_id,extract(year from service_date);

for i in 1..fraudTableType_rec.count 
loop
if((fraudTableType_rec(i).pid = fraudTableType_rec(i).nextpid) AND fraudTableType_rec(i).difference > thresholdAverage ) then
select cname into username from (
select cust_name as cname  from customer c
join 
policy p
on p.user_id = c.USERID where p.policy_id = fraudTableType_rec(i).pid
union
select d_name as cname from dependent d
join 
policy p
on 
p.user_id = d.USERID where p.policy_id = fraudTableType_rec(i).pid);

     dbms_output.put_line('Condition 2:Customer ');
    dbms_output.put_line( 'Policy id: '||fraudTableType_rec(i).pid||', Username is: '||username||', Year: '||fraudTableType_rec(i).claimYear||', Difference in insurance amount: '||fraudTableType_rec(i).difference);
    dbms_output.put_line('------------------------------------------------------------- ');
    end if;
  END LOOP;  
End if;
if(typeOfUser = 'Service Provider') then



select sp_id,lead(sp_id,1) over (order by sp_id,extract(year from service_date)) as nextspid, extract(year from service_date) as year,
sum(amount_paid_byInsurance) as totalpaidbyInsurance,
lead(sum(amount_paid_byInsurance),1) over (order by sp_id,extract(year from service_date))  - (sum(amount_paid_byInsurance)) as difference
BULK COLLECT INTO fraudTableType_rec_sp
from claim_line where status = 'Accept'
group by extract(year from service_date),sp_id
order by sp_id,extract(year from service_date);

for i in 1..fraudTableType_rec_sp.count 
loop
if((fraudTableType_rec_sp(i).spid = fraudTableType_rec_sp(i).nextspid) AND fraudTableType_rec_sp(i).difference >  threshold ) then
select distinct(sp_description) into username from 
service_provider sp
join 
claim_line cl
on 
sp.sp_id = cl.sp_id  where cl.sp_id = fraudTableType_rec_sp(i).spid;



     dbms_output.put_line('Condition 1:Service Provider ');
    dbms_output.put_line( 'Service Provider id: '||fraudTableType_rec_sp(i).spid||', Service Provider Name: '||username||', Year: '||fraudTableType_rec_sp(i).claimYear||', Difference in insurance amount: '||fraudTableType_rec_sp(i).difference);
     dbms_output.put_line('------------------------------------------------------------- ');
    end if;
  END LOOP;


select  sp_id,lead(sp_id,1) over (order by sp_id,extract(year from service_date)) as nextspID,extract(year from service_date) as claimYear,
sum(amount_paid_byInsurance)/count(sp_id) as averagepaidbyInsuranceAmount,
lead(sum(amount_paid_byInsurance)/(count(sp_id)),1) over (order by sp_id,extract(year from service_date))  - (sum(amount_paid_byInsurance))/count(sp_id) as difference
BULK COLLECT INTO fraudTableType_rec_sp
from claim_line where status = 'Accept'
group by extract(year from service_date), sp_id
order by sp_id,extract(year from service_date); 

for i in 1..fraudTableType_rec_sp.count 
loop
if((fraudTableType_rec_sp(i).spid = fraudTableType_rec_sp(i).nextspid) AND fraudTableType_rec_sp(i).difference >  thresholdAverage ) then
select distinct(sp_description) into username from 
service_provider sp
join 
claim_line cl
on 
sp.sp_id = cl.sp_id  where cl.sp_id = fraudTableType_rec_sp(i).spid;

    dbms_output.put_line('Condition 2:Service Provider ');
    dbms_output.put_line( 'Service Provider id: '||fraudTableType_rec_sp(i).spid||', Service Provider Name: '||username||', Year: '||fraudTableType_rec_sp(i).claimYear||', Difference in insurance amount: '||fraudTableType_rec_sp(i).difference);
     dbms_output.put_line('------------------------------------------------------------- ');
    end if;
  END LOOP;

end if;
end;