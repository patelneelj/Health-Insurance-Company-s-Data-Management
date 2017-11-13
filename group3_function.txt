-------------------Feature 1--------------------------------------
create or replace function return_userid (emailId in varchar,user_pswd in varchar) 
return integer
IS
user_id integer;
user_password varchar(50);
BEGIN
	select userid,pswd into user_id,user_password from userlogin where email_id = emailId;
--    if(user_password = user_pswd) then
--     dbms_output.put_line('Login Successful');

     dbms_output.put_line('User already exists.');
	return 0;
exception
	WHEN OTHERS THEN
	dbms_output.put_line('New User. Creating New User id......');
	return -1;
End;


create or replace function return_custuserid (name in varchar,emailId in varchar,user_pswd in varchar,cust_address in varchar, phone in varchar, birthdate in date, cust_gender in varchar) 
return integer
IS
user_id number;
userType_id usertype.ut_id%type;
BEGIN
    SELECT ut_id INTO userType_id FROM USERTYPE WHERE user_type='Customer';
    INSERT INTO userlogin VALUES (userid_seq.nextval, emailId, user_pswd,userType_id);
    SELECT userid INTO user_id FROM userlogin WHERE email_id = emailId;
    INSERT INTO customer VALUES (custId_seq.nextval, name, emailId,user_pswd, birthdate,cust_gender,cust_address,phone,user_id);
	return user_id;
exception
	WHEN OTHERS THEN
	dbms_output.put_line('Error in registration with Customer Type');
	return -1;
End;

create or replace function return_dependuserid (name in varchar,emailId in varchar,user_pswd in varchar,cust_address in varchar, phone in varchar, birthdate in date, cust_gender in varchar, cust_userId in integer,dependent_relation in varchar) 
return integer
IS
user_id number;
userType_id usertype.ut_id%type;
customer_id integer;
BEGIN
    SELECT ut_id INTO userType_id FROM USERTYPE WHERE user_type='Dependent';
    INSERT INTO userlogin VALUES (userid_seq.nextval, emailId, user_pswd,userType_id);
    SELECT userid INTO user_id FROM userlogin WHERE email_id = emailId;
    SELECT cust_id INTO customer_id FROM CUSTOMER WHERE userid = cust_userId;
    INSERT INTO dependent VALUES (did_seq.nextval,name,emailId,user_pswd, birthdate, cust_gender, cust_address, phone,user_id,dependent_relation,customer_id);
    dbms_output.put_line('Registration is done Successfully');
   return user_id;
exception
	WHEN OTHERS THEN
	dbms_output.put_line('Error in registration with Dependent Type');
	return -1;
End;

create or replace function return_provideruserid(name in varchar,emailId in varchar,user_pswd in varchar ,cust_address in varchar , phone in varchar ,provider_type in varchar,serviceid in varchar) 
return integer
IS
user_id integer;
userType_id usertype.ut_id%type;
serviceProvider_id integer;
BEGIN
    SELECT ut_id INTO userType_id FROM USERTYPE WHERE user_type='Service Provider';
    INSERT INTO userlogin VALUES (userid_seq.nextval, emailId, user_pswd,userType_id);
    SELECT userid INTO user_id FROM userlogin WHERE email_id = emailId;
  --  SELECT cust_id INTO customer_id FROM CUSTOMER WHERE userid = cust_userId;
    INSERT INTO SERVICE_PROVIDER VALUES (spid_seq.nextval,name,serviceid,userid_seq.currval, emailId, user_pswd,cust_address, phone,provider_type);
    dbms_output.put_line('Registration is done Successfully');
   return user_id;
exception
	WHEN OTHERS THEN
	dbms_output.put_line('Error in registration with Service Provider Type');
	return -1;
End;



---------------Functions for Feature 2----------------------------
---------------------------

Create or replace function check_login (emailId in varchar,user_pswd in varchar) /* Allows user to login. Checks whether email and password matches. */ 
return integer
IS

/* Variable declaration */

user_id integer;
user_password varchar(50);
BEGIN
	select userid,pswd into user_id,user_password from userlogin where email_id = emailId;

/* Check if logins successful */

    if(user_password = user_pswd) then
     dbms_output.put_line('Login Successful');
	return 1;

/* If password mis matches */

 elsif(user_password <> user_pswd) then
     dbms_output.put_line('Incorrect Password');
 
 return 0; 
  End if;
 exception
	WHEN OTHERS THEN

/* If emailid mis matches */

	dbms_output.put_line('Incorrect email id');
	return 0;
End;

---------------------Function for Feature 4------------------
------------------------
create or replace function checkUserExist (us_id in number, planname in varchar) 
return integer
IS
/* Variable Declaration*/

u_id integer;
pl_id integer;

BEGIN

/* Check for already existing plan */

	 select policy.user_id into u_id from plan,policy where plan.plan_id = policy.plan_id AND policy.user_id=us_id AND plan.plan_name=planname;
     select policy.plan_id into pl_id from plan,policy where plan.plan_id = policy.plan_id AND policy.user_id=us_id AND plan.plan_name=planname;
     dbms_output.put_line('User is already enroll with Insurance plan');
	return 0;
exception
	WHEN OTHERS THEN
	dbms_output.put_line('Inserting new insurance policy to respective user...........');
	return -1;
End;



create or replace function return_policyid (us_id in number, planname in varchar, start_year in date) /* Inserts a new policy into the policy table for the customer*/ 
return integer

/* Variable Declaration */

IS
planid plan.plan_id%type;
coverageid PLAN.COVERAGE_ID%type;
serviceid PLAN.SERVICE_ID%type;
pol_id policy.policy_id%type;
myexec EXCEPTION;
u_id integer;
pl_id integer;
count1 number;
BEGIN
    SELECT plan_id, COVERAGE_ID, SERVICE_ID INTO planid, coverageid, serviceid FROM plan WHERE plan_name = planname;
   count1:= checkUserExist(us_id,planname);
 
    if( (count1 = 0)) then
    raise myexec;
    else
    INSERT INTO policy VALUES (policy_seq.nextval, planid, coverageid, serviceid,us_id);
    end if;
	return policy_seq.currval;
exception
	--WHEN OTHERS THEN
/* Printing the exception */
	--dbms_output.put_line('Error in adding the policy User');
  WHEN myexec THEN
   dbms_output.put_line('Policy already exists ');
	return -1;
End;



create or replace function return_policyDepdid(user_id in number, planname in varchar, start_year in date) /* Inserts a new policy into the policy table for the dependent*/ 
return integer

/* Variable Declaration */

IS
planid plan.plan_id%type;
coverageid PLAN.COVERAGE_ID%type;
serviceid PLAN.SERVICE_ID%type;
pol_id policy.policy_id%type;
cid number;
usid number;
deptid number;
BEGIN
    SELECT plan_id, COVERAGE_ID, SERVICE_ID INTO planid, coverageid, serviceid FROM plan WHERE plan_name = planname;
    
    /* Fetching the user id of the dependent's related customer and inserting a policy with that customer's user id.*/

    select cust_id into cid from dependent where userid = user_id;
    select userid into usid from customer where cust_id = cid;
    select d_id into deptid from dependent where userid = user_id;
    INSERT INTO policy VALUES (policy_seq.nextval, planid, coverageid, serviceid,usid);
    INSERT INTO POLICY_DEPENDENT values(policy_seq.currval, deptid, usid);
    
	return policy_seq.currval;
exception
	WHEN OTHERS THEN

/* Printing the exception */

	dbms_output.put_line('Error in adding the policy Dependent');
	return -1;
End;

create or replace function insert_msg(user_id in number, pol_id in number) /* Inserts into message table */
return number 
IS

/* Variable Declaration */

msg_id message.message_id%type;
begin
  insert into message values (message_seq.nextval,' The customer has been enrolled into the policy with the polic ID ' || pol_id,sysdate,user_id);
return message_seq.currval;
End;

------------------------------------------------Feature 5-------------------------------------------------
------------------------------------------------Function 1------------------------------------------------
create or replace function add_msg(user_id in number, dep_id in number, pol_id in number) --function for inserting message in the message table
return number
IS
msg_id message.message_id%type;
begin
  insert into message values (message_seq.nextval,' the dependent ' || dep_id || ' has been added to the policy ' || pol_id,sysdate,user_id); 
 -- select message_seq.currval into msg_id from message;
return message_seq.currval;
End;

-----------------------------------------------Function 2--------------------------------------------------

create or replace function get_existing_depid (dep_id in number, pol_id in number) --function for checking the existing entry of dependent in policy dependent
return number
IS
dep1_id dependent.d_id%type;
pol1_id POLICY_DEPENDENT.policy_id%type;
BEGIN
	Select d_id, policy_id into dep1_id, pol1_id from policy_dependent where d_id=dep_id and policy_id=pol_id;

  return 0; --if the dependent already exists for the policy in the policy dependent table
exception
	when others then

	return -1; --if the dependent does not exist for the policy in the policy dependent table
End;

------------------------------------------------Feature 6--------------------------------------------
------------------------------------------------Function 1-------------------------------------------
create or replace function get_existing_deptid (dep_id in number, pol_id in number) --function for checking the existing entry of dependent in policy dependent
return number
IS
dep1_id dependent.d_id%type;
pol1_id POLICY_DEPENDENT.policy_id%type;
BEGIN
	Select d_id, policy_id into dep1_id, pol1_id from policy_dependent where d_id=dep_id and policy_id=pol_id;
  return 0; --if the dependent already exists for the policy in the policy dependent table
exception
	when others then
	return -1; --if the dependent does not exist for the policy in the policy dependent table
End;

----------------------------------------------Function 2---------------------------------------------

create or replace function add_msg1(user_id in number, dep_id in number, pol_id in number) --function for inserting message in the message table
return number
IS
msg_id message.message_id%type;
begin
  insert into message values (message_seq.nextval,' the dependent ' || dep_id || ' has been removed from the policy ' || pol_id,sysdate,user_id);
 return message_seq.currval;
End;

------------------Function for Feature 7-------------------------------
------------------------
create or replace function checkPolicyExist (pol_id  in number) 
return integer
IS
po_id integer;

BEGIN
  select policy_id into po_id from policy where policy_id=pol_id;
	     dbms_output.put_line('Policy does not exists');
	return 0;
exception
	WHEN OTHERS THEN
	--dbms_output.put_line('Calculating Premium for the policy...........');
	return -1;
End;




create or replace function calculate_premium (pol_id in number) /* Calculating the premium amount for the given policy id. */
return integer
IS

/*Variable Declaration*/

premium_amt PREMIUM.PREMIUM_AMOUNT%type;
levelid POLICY.POLICY_ID%type;
planid PLAN.PLAN_ID%type;
std_annualrate PLAN.STANDARD_ANNUAL_RATE%type;
count1 number;
myexec Exception;
BEGIN
count1:= checkPolicyExist(pol_id);
if( (count1 <> 0)) then
    raise myexec;
    else    
    /* Fetching the level id */

    select level_id into levelid from premium where policy_id=pol_id;

    /* Fetching the plan id */

    select plan_id into planid from policy where policy_id=pol_id;

    /* Fetching the standard annual rate for that plan */

    select standard_annual_rate into std_annualrate from plan where plan_id=planid;

    /* Calculating the premium amount for the policy */
  
  
    premium_amt:= std_annualrate * levelid;
    dbms_output.put_line('The Premium Amount for policy ' || pol_id || ' with level id ' || levelid || ' with the standar annual rate of ' || std_annualrate || ' is: ' || premium_amt);
    return premium_amt;
    end if;
    exception
	--WHEN OTHERS THEN
/* Printing the exception */
	--dbms_output.put_line('Error in adding the policy User');
  WHEN myexec THEN
   dbms_output.put_line('Policy does not exists ');
	return -1;
End;


-------------------------------------------Feature 9-------------------------------------------------------------
------------------------------------------------Function 1------------------------------------------------
create or replace function feature9_get_existing_policyid (pol_id in number)
return number
IS
pol1 policy.policy_id%type;
-----------check if the policy exist
BEGIN
	Select policy_id into pol1 from policy where policy_id=pol_id;
  return 0;
exception
	when others then
	return -1;
End;

------------------------------------------------Function 2------------------------------------------------
create or replace function feature9_get_existing_provid (prov in number)
return number
IS
prov1 service_provider.sp_id%type;
----checks if the provider exists
BEGIN
	Select sp_id into prov1 from service_provider where sp_id=prov;
  return 0;
exception
	when others then
	return -1;
End;

------------------------------------------------Function 3------------------------------------------------
create or replace function feature9_patientcheckincust (patient_name in VARCHAR2)
return number
IS
patient1 number;
---checks for patient in customer table
BEGIN
select userid into patient1 from customer where cust_name=patient_name; 
return 0;
exception
when others then
return -1;
End;

------------------------------------------------Function 4------------------------------------------------
create or replace function feature9_patientcheckindepd (patient_name in VARCHAR2)
return number
IS
patient1 number;
-----------checks for patient in dependent table
BEGIN
select userid into patient1 from dependent where d_name=patient_name; 
return 0;
exception
when others then
return -1;
End;

------------------------------------------------Function 5------------------------------------------------
create or replace function feature9_patientpolicy_cust (pol_id in number,patient_name in VARCHAR2)
return number
IS
pol2 number;
patient1 number;
----------to check if the patient is linked to the policy
BEGIN
select userid into patient1 from customer,policy where policy.user_id=customer.userid and cust_name=patient_name; 

select policy_id into pol2 from policy where policy_id=pol_id and user_id=patient1;
return 0;
exception
when others then
return -1;
End;

------------------------------------------------Function 6------------------------------------------------
create or replace function feature9_patientpolicy_depd (pol_id in number,patient_name in VARCHAR2)
return number
IS
pol2 number;
patient1 number;
cid number;
uid number;
----------to check if the patient is linked to the policy

BEGIN
select d_id,cust_id into patient1,cid from dependent where d_name=patient_name;
select userid into uid from customer where cust_id = cid;
select policy_id into pol2 from POLICY_DEPENDENT where policy_id=pol_id and d_id=patient1;
return 0;
exception
when others then
return -1;
End;

------------------------------------------------Function 7------------------------------------------------
create or replace function feature9_checkdate (pol_id in number,date_of_service in date)
return number
IS
date1 claim_line.service_date%type;
BEGIN
---checks if the service date within allowed plan range 
select plan_start_year into date1 from plan p, policy q 
where p.plan_id = q.plan_id and  p.plan_start_year <=date_of_service and p.plan_end_date >=date_of_service and q.policy_id=pol_id; 
if (date1 is not null) then
return 0;
else return -1;
end if;
exception
when others then
return -1;
End;

------------------------------------------------Function 8------------------------------------------------
create or replace function f9_check_serviceinpolicy_cust (patient_name in varchar,serv_id in number,pol_id in number)
return number
IS
u_id number;
serial_1 number;
serial_2 number;
serial_3 number;
BEGIN
------------fetches customer userid and count of claim id for accepted claim
select userid into u_id from customer where cust_name=patient_name;
Select count(SERVICE_ID) into serial_1 from policy where service_id=serv_id and policy_id=pol_id;
Select Coverage.Max_Service_Peryear into serial_2 from policy, coverage where policy.service_id=serv_id and policy.policy_id=pol_id and policy.service_id=coverage.service_id; 
select count(claim_id) into serial_3 from claim_line where user_id=u_id and claim_line.service_id=serv_id and claim_line.STATUS='Accept';
---------checks if service linked to policy and if total services more than allowed number of accepted service
  
if (serial_1>0) then
    if (serial_3>serial_2) then
  return 2;
 else 
 return 1;
  end if;
else return 3;
end if;
exception
	when others then
	return 3;
End;

------------------------------------------------Function 9------------------------------------------------
create or replace function f9_check_serviceinpolicy_depd (patient_name in varchar,serv_id in number,pol_id in number)
return number
IS
u_id number;
serial_1 number;
serial_2 number;
serial_3 number;
BEGIN
------------fetches dependent userid and count of claim id for accepted claim
select userid into u_id from dependent where d_name=patient_name;
Select count(SERVICE_ID) into serial_1 from policy where service_id=serv_id and policy_id=pol_id;
Select Coverage.Max_Service_Peryear into serial_2 from policy, coverage where policy.service_id=serv_id and policy.policy_id=pol_id and policy.service_id=coverage.service_id; 
select count(claim_id) into serial_3 from claim_line where user_id=u_id and claim_line.service_id=serv_id and claim_line.STATUS='Accept';
---------checks if service linked to policy and if total services more than allowed number of accepted service

  if (serial_1>0) then
    if (serial_3>serial_2) then
  return 2;
 else 
 return 1;
  end if;
else return 3;
end if;
exception
	when others then
	return 3;
End;

------------------------------------------------Function 10------------------------------------------------
create or replace function f9_3_check_duplicate_cust (patient_name in varchar,serv_id in number,date_of_service in date)
return number
IS
--variable declaration
u_id number;
claimid number;
BEGIN

---fetches user id of the customer
select userid into u_id from customer where cust_name=patient_name;
---fetches claim_id from claim_line for accept status and same date to check for duplicate claim
select claim_id into claimid from claim_line where service_date=date_of_service and status='Accept' and user_id=u_id;
---if claimid is not null means duplicate claim
if (claimid is not null) then
  return -1;
  else 
  return 1;
end if;
exception
	when others then
	return 0;
End;

------------------------------------------------Function 11------------------------------------------------
create or replace function f9_3_check_duplicate_depd (patient_name in varchar,serv_id in number,date_of_service in date)
return number
IS
u_id number;
claimid number;
BEGIN
--fetches user id of the dependent
select userid into u_id from dependent where d_name=patient_name;
select claim_id into claimid from claim_line where service_date=date_of_service and status='Accept' and user_id=u_id;
---if claimid is not null means duplicate claim
if (claimid is not null) then
  return -1;
  else 
  return 1;
end if;
exception
	when others then
	return 0;
End;

------------------------------------------------Function 12------------------------------------------------
create or replace function f9_4_Adjustcharge_cust (pol_id in number,serv_id in number,prov_id in number,amnt in number, patient_name in varchar, date_of_service in date)
return number
IS
u_id number;
sew number;

BEGIN

select userid into u_id from customer where cust_name=patient_name;
--fetches the allowed service charge
select allowed_service_charges into sew from policy,coverage 
where policy.coverage_id=coverage.COVERAGE_ID and policy.POLICY_ID=pol_id and policy.user_id=u_id;
----compares the allowed service charge and providers charge
---if providers charge is lower than allowed charge, then providers charge is providers charge else allowed charge
if(sew >= amnt) then 
  insert into claim_line(claim_id,service_id,policy_id,user_id,service_date,claim_date,sp_id,providers_charge) values(claimid_seq.nextval,serv_id,pol_id,u_id,date_of_service,sysdate,prov_id,amnt);
  return 0;
else
  insert into claim_line(claim_id,service_id,policy_id,user_id,service_date,claim_date,sp_id,providers_charge) values(claimid_seq.nextval,serv_id,pol_id,u_id,date_of_service,sysdate,prov_id,sew);
  return 0;
End if;
exception
	when others then
	return -1;
End;

------------------------------------------------Function 13------------------------------------------------
create or replace function f9_4_Adjustcharge_depd (pol_id in number,serv_id in number,prov_id in number,amnt in number, patient_name in varchar, date_of_service in date)
return number
IS
u_id number;
sew number;
BEGIN
select userid into u_id from dependent where d_name=patient_name;
select allowed_service_charges into sew from policy,coverage 
where policy.coverage_id=coverage.COVERAGE_ID and policy.POLICY_ID=pol_id and policy.user_id=u_id;
----compares the allowed service charge and providers charge
---if providers charge is lower than allowed charge, then providers charge is providers charge else allowed charge

if(sew >= amnt) then
  insert into claim_line(claim_id,service_id,policy_id,user_id,service_date,claim_date,sp_id,providers_charge) values(claimid_seq.nextval,serv_id,pol_id,u_id,date_of_service,sysdate,prov_id,amnt);
  return 0;
else
  insert into claim_line(claim_id,service_id,policy_id,user_id,service_date,claim_date,sp_id,providers_charge) values(claimid_seq.nextval,serv_id,pol_id,u_id,date_of_service,sysdate,prov_id,sew);
  return 0;
End if;
exception
	when others then
	return -1;
End;

------------------------------------------------Function 14------------------------------------------------
create or replace Function F9_5_6_7_Pay_CUST (Pol_Id In Number,Serv_Id In Number,Prov_Id In Number,Amnt In Number, Patient_Name In Varchar, Date_Of_Service In Date)
Return Number
Is
--variable declaration
sum20 integer;
var1 integer;
onci integer;
PD integer;
sew integer;
INCI integer;
U_Id integer;
Total_Cust integer;
Serv_Prov_Type Varchar(255);
Difference1 integer;
Mopm integer;
Onc integer;
Inc integer;
Sum1 integer;
Diff2 integer;
AMNT_copay integer;
amnt_coinsurance integer;
sum2 integer;
sum3 integer;
DIFF8 integer;
DIFF7 integer;
sum6 integer;
sum5 integer;
diff4 integer;
diff5 integer;
diff6 integer;
diff3 integer;
total integer;
sum4 integer;
sum7 integer;
calc1 integer;
sum8 integer;
diff9 integer;
diff10 integer;
diff11 integer;
amount_coinsurance integer;
sum21 integer;
var2 integer;
sum22 integer;
diff20 integer;
Begin
----select queries to fetch user id, maximum out of pocket, total amount paid by customer till date, service provider type, plan deductable and providers charge
Select Userid Into U_Id From Customer Where Cust_Name=Patient_Name;
Select Max_Opc_Permember Into Mopm From Plan, Policy Where Plan.Plan_Id=Policy.Plan_Id And Policy.Policy_Id=Pol_Id;
Select Sum(Amount_Paid_Bycustomer) Into Total_Cust From Claim_Line Where User_Id=U_Id;
Select Sp_Type Into Serv_Prov_Type From Service_Provider Where Sp_Id=Prov_Id And Service_Id=Serv_Id;
Select Plan.Deductable_Amount Into Pd From Plan,Policy Where Policy.Plan_Id=Plan.Plan_Id And Policy.Policy_Id=Pol_Id;
Select Providers_Charge Into Sew From Claim_Line Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;

-----computes various values like checking the total paid by customer and current charge
Sum1:= Total_Cust+Sew;
----checks mam out of pocket and how much customer paid
Difference1 := Mopm - Total_Cust;
Diff2 := Mopm - Total_Cust;
---checks the provider type
 If(Serv_Prov_Type = 'In-network') Then
---selects the amount copay and coinsurance
  Select In_Network_Copay Into Inc From Policy,Plan,Coverage Where Policy.Plan_Id=Plan.Plan_Id And Plan.Coverage_Id=Coverage.Coverage_Id And Policy.Policy_Id=Pol_Id;
  Select In_Network_Coinsurance Into Inci From Policy,Plan,Coverage Where Policy.Plan_Id=Plan.Plan_Id And Plan.Coverage_Id=Coverage.Coverage_Id And Policy.Policy_Id=Pol_Id;
----amount copay is fetched
  Amnt_Copay:=Inc;
----calculates amount of coinsurance
  Amnt_Coinsurance:=((Sew-Amnt_Copay)*Inci)/100;
----sum of total paid by customer and copay
  Sum2:=Amnt_Copay+Total_Cust;
----computes total copay, amount paid till date and coinsurance
-----below are various computations to calculate copay and coinsurance in various cases  
Sum3:=Amnt_Coinsurance+Sum2;
  Diff4:=Sum3-Mopm;
  Sum4:=Inc+Diff4;
  Diff3:= Mopm-Sum2;
  Diff5:=Mopm - Sum2;
  Diff6:=Sew-Sum4;
  Sum5:=amnt_coinsurance+Inc;
  Diff7:=Sew-Sum5;
  Sum6:=Total_Cust+Sew;
  Diff8:=Pd-Total_Cust;
  diff20:=sew-diff8;
  Sum7:=Diff8+Inc;
  Calc1:=((Sew-Sum7)*Inci)/100;
  Sum8:=Inc+Calc1+Diff8;
  Diff9:=Sew-Sum8;
  Diff10:=Mopm-Total_Cust; 
  Diff11:=Sew-Diff10;
  var1:=sum1-pd;
  sum20:= var1+diff8;
  sum21 := diff8 + inc;
  var2 := sew - sum21;
  sum22 := sum21 + var2;
        ---------checks if total paid by customer > max out of pocket and policy deductable
	If (Total_Cust >= Mopm And Total_Cust>Pd) Then
        Update Claim_Line Set Amount_Copay = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_Paid_Bycustomer = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_Paid_Byinsurance = Sew Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service; 
        Return 1;
	---------checks if current copay, coinsurance more than max out of pocket expense and more than policy deductable
        Elsif (Sum3 >= Mopm  And Sum2 >= Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Diff10 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Diff10 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff11 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        Return 2;
        -----------if after adding coinsurance, patient pays more than max out of pocket and less if only copay is paid
	    Elsif(Sum3>Mopm And Sum2 < Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Inc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = Diff4 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum4 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff6 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;     
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        return 3;
            --------------------after adding copay and coinsrance total amnt less than max out of pocket	
	    Elsif(Sum3<=Mopm And Sum2 < Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Inc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = amnt_coinsurance Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum5 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff7 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
 return 4;       
        -------------if total cust less than policy deductable and even after current charge it doesnt exist policy deductable
	Elsif (total_cust < pd and Sum1<= Pd ) Then
            Update Claim_Line Set Amount_Copay = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sew Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            if (sew > diff8) then
            update claim_line set amount_deductable = (sew-diff8) where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service; 
            else
            update claim_line set amount_deductable = (diff8-sew) where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service; 
            end if;
            Return 5;
        ------if total cust less than policy deductable and after current charge, it exceeds policy deductable
	Elsif(Total_Cust <Pd And Sum6 > Pd ) then
            if(var1<inc ) then
            Update Claim_Line Set Amount_Copay = var1 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum20 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            return 6;
            elsif (var1 > inc and var2 < amnt_coinsurance) then
            Update Claim_Line Set Amount_Copay = inc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = var2 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum22 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            Return 16;
            else
            Update Claim_Line Set Amount_Copay = inc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = Calc1 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum8 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff9 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            Return 17;
        end if;
  End If;
-------checks for out network
 Elsif(Serv_Prov_Type='Out-network') Then
  Select Out_Network_Copay Into Onc From Policy,Plan,Coverage Where Policy.Plan_Id=Plan.Plan_Id And Plan.Coverage_Id=Coverage.Coverage_Id And Policy.Policy_Id=Pol_Id;
  Select Out_Network_Coinsurance Into Onci From Policy,Plan,Coverage Where Policy.Plan_Id=Plan.Plan_Id And Plan.Coverage_Id=Coverage.Coverage_Id And Policy.Policy_Id=Pol_Id;
  Amnt_Copay:=Onc;
  Amnt_Coinsurance:=((Sew-Amnt_Copay)*Onci)/100;
  Sum2:=Amnt_Copay+Total_Cust;
  Sum3:=Amnt_Coinsurance+Sum2;
  Diff4:=Sum3-Mopm;
  Sum4:=Onc+Diff4;
  Diff3:=Mopm-Sum2;
  Diff5:=Mopm - Sum2;
  Diff6:=Sew-Sum4;
  Sum5:=amnt_coinsurance+Onc;
  Diff7:=Sew-Sum5;
  Sum6:=Total_Cust+Sew;
  Diff8:=Pd-Total_Cust;
  diff20:=sew-diff8;
  Sum7:=Diff8+Onc;
  Calc1:=((Sew-Sum7)*Onci)/100;
  Sum8:=Onc+Calc1+Diff8;
  Diff9:=Sew-Sum8;
  Diff10:=Mopm-Total_Cust; 
  Diff11:=Sew-Diff10;
  var1:=sum1-pd;
  sum20:= var1+diff8;
  sum21 := diff8 + onc;
  var2 := sew - sum21;
  sum22 := sum21 + var2;
        ----------------if total paid by customer already exceeds max out of pocket expense
	If (Total_Cust >= Mopm And Total_Cust>Pd) Then
        Update Claim_Line Set Amount_Copay = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_Paid_Bycustomer = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_Paid_Byinsurance = Sew Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;  
        update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        Return 8;
        ----------------------if after current charge, coinsurance and copay, it exceeds max out of pocket expense
	Elsif (Sum3 >= Mopm And Sum2 >= Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Diff10 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Diff10 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff11 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;    
        Return 9;
	-----------------if after coinsurance, person pays more than max out of pocket but not with copay
        Elsif(Sum3>Mopm And Sum2 < Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Onc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = Diff4 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum4 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff6 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            return 10;
	-------------check if after current charge, copay and coinsurance, it exceed total max out of pocket and it already exceeds policy deductable
        Elsif(Sum3<=Mopm And Sum2 < Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Onc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = amnt_coinsurance Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum5 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff7 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            return 11;
        ------------if total cust less than policy deductable and after current charge more than policy deductable
	Elsif (total_cust < pd and Sum1<= Pd ) Then
            Update Claim_Line Set Amount_Copay = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sew Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            if (sew > diff8) then
            update claim_line set amount_deductable = (sew-diff8) where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service; 
            else
            update claim_line set amount_deductable = (diff8-sew) where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service; 
            end if;
            Return 12;
        ------if total cust less than policy deductable and after current charge, it exceeds policy deductable
	Elsif(Total_Cust <Pd And Sum1 > Pd) then
            if(var1<onc and var2 < onci) then
            Update Claim_Line Set Amount_Copay = var1 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = sum20 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            return 13;
            elsif (var1 > onc and var2 < amnt_coinsurance) then
            Update Claim_Line Set Amount_Copay = Onc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = var2 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum22 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            Return 14;
            else
            Update Claim_Line Set Amount_Copay = Onc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = Calc1 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum8 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff9 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            Return 15;
end if;  
else
return -2;
  End If;
End If;

Exception
When Others Then
Return -1;
End;

------------------------------------------------Function 15------------------------------------------------
create or replace Function F9_5_6_7_Pay_DEPD (Pol_Id In Number,Serv_Id In Number,Prov_Id In Number,Amnt In Number, Patient_Name In Varchar, Date_Of_Service In Date)
Return Number
Is

--variable declaration
sum20 integer;
var1 integer;
onci integer;
PD integer;
sew integer;
INCI integer;
U_Id integer;
Total_Cust integer;
Serv_Prov_Type Varchar(255);
Difference1 integer;
Mopm integer;
Onc integer;
Inc integer;
Sum1 integer;
Diff2 integer;
AMNT_copay integer;
amnt_coinsurance integer;
sum2 integer;
sum3 integer;
DIFF8 integer;
DIFF7 integer;
sum6 integer;
sum5 integer;
diff4 integer;
diff5 integer;
diff6 integer;
diff3 integer;
total integer;
sum4 integer;
sum7 integer;
calc1 integer;
sum8 integer;
diff9 integer;
diff10 integer;
diff11 integer;
amount_coinsurance integer;
sum21 integer;
var2 integer;
sum22 integer;
diff20 integer;
Begin
----select queries to fetch user id, maximum out of pocket, total amount paid by customer till date, service provider type, plan deductable and providers charge

Select Userid Into U_Id From Dependent Where d_Name=Patient_Name;
Select Max_Opc_Permember Into Mopm From Plan, Policy Where Plan.Plan_Id=Policy.Plan_Id And Policy.Policy_Id=Pol_Id;
Select Sum(Amount_Paid_Bycustomer) Into Total_Cust From Claim_Line Where User_Id=U_Id;
Select Sp_Type Into Serv_Prov_Type From Service_Provider Where Sp_Id=Prov_Id And Service_Id=Serv_Id;
Select Plan.Deductable_Amount Into Pd From Plan,Policy Where Policy.Plan_Id=Plan.Plan_Id And Policy.Policy_Id=Pol_Id;
Select Providers_Charge Into Sew From Claim_Line Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
-----computes various values like checking the total paid by customer and current charge

Sum1:= Total_Cust+Sew;

----checks mam out of pocket and how much customer paid

Difference1 := Mopm - Total_Cust;
Diff2 := Mopm - Total_Cust;
---checks the provider type

 If(Serv_Prov_Type = 'In-network') Then
  Select In_Network_Copay Into Inc From Policy,Plan,Coverage Where Policy.Plan_Id=Plan.Plan_Id And Plan.Coverage_Id=Coverage.Coverage_Id And Policy.Policy_Id=Pol_Id;
  Select In_Network_Coinsurance Into Inci From Policy,Plan,Coverage Where Policy.Plan_Id=Plan.Plan_Id And Plan.Coverage_Id=Coverage.Coverage_Id And Policy.Policy_Id=Pol_Id;
  Amnt_Copay:=Inc;
  Amnt_Coinsurance:=((Sew-Amnt_Copay)*Inci)/100;
  Sum2:=Amnt_Copay+Total_Cust;
  Sum3:=Amnt_Coinsurance+Sum2;
  Diff4:=Sum3-Mopm;
  Sum4:=Inc+Diff4;
  Diff3:= Mopm-Sum2;
  Diff5:=Mopm - Sum2;
  Diff6:=Sew-Sum4;
  Sum5:=amnt_coinsurance+Inc;
  Diff7:=Sew-Sum5;
  Sum6:=Total_Cust+Sew;
  Diff8:=Pd-Total_Cust;
  diff20:=sew-diff8;
  Sum7:=Diff8+Inc;
  Calc1:=((Sew-Sum7)*Inci)/100;
  Sum8:=Inc+Calc1+Diff8;
  Diff9:=Sew-Sum8;
  Diff10:=Mopm-Total_Cust; 
  Diff11:=Sew-Diff10;
  var1:=sum1-pd;
  sum20:= var1+diff8;
  sum21 := diff8 + inc;
  var2 := sew - sum21;
  sum22 := sum21 + var2;
                ---------checks if total paid by customer > max out of pocket and policy deductable

	If (Total_Cust >= Mopm And Total_Cust>Pd) Then
        Update Claim_Line Set Amount_Copay = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_Paid_Bycustomer = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_Paid_Byinsurance = Sew Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service; 
        Return 1;
---------checks if current copay, coinsurance more than max out of pocket expense and more than policy deductable
        
        Elsif (Sum3 >= Mopm  And Sum2 >= Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Diff10 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Diff10 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff11 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        Return 2;
                -----------if after adding coinsurance, patient pays more than max out of pocket and less if only copay is paid

	Elsif(Sum3>Mopm And Sum2 < Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Inc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = Diff4 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum4 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff6 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;     
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        return 3;
	            --------------------after adding copay and coinsrance total amnt less than max out of pocket	

        Elsif(Sum3<=Mopm And Sum2 < Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Inc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = amnt_coinsurance Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum5 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff7 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;

 return 4;       
        -------------if total cust less than policy deductable and even after current charge it doesnt exist policy deductable

        Elsif (total_cust < pd and Sum1<= Pd ) Then
            Update Claim_Line Set Amount_Copay = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sew Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            if (sew > diff8) then
            update claim_line set amount_deductable = (sew-diff8) where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service; 
            else
            update claim_line set amount_deductable = (diff8-sew) where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service; 
            end if;
            Return 5;
                ------if total cust less than policy deductable and after current charge, it exceeds policy deductable

	Elsif(Total_Cust <Pd And Sum6 > Pd ) then
            if(var1<inc ) then
            Update Claim_Line Set Amount_Copay = var1 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum20 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            return 6;
            elsif (var1 > inc and var2 < amnt_coinsurance) then
            Update Claim_Line Set Amount_Copay = inc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = var2 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum22 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            Return 16;
            else
            Update Claim_Line Set Amount_Copay = inc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = Calc1 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum8 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff9 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            Return 17;
        end if;
  End If;
-------checks for out network

 Elsif(Serv_Prov_Type='Out-network') Then
  Select Out_Network_Copay Into Onc From Policy,Plan,Coverage Where Policy.Plan_Id=Plan.Plan_Id And Plan.Coverage_Id=Coverage.Coverage_Id And Policy.Policy_Id=Pol_Id;
  Select Out_Network_Coinsurance Into Onci From Policy,Plan,Coverage Where Policy.Plan_Id=Plan.Plan_Id And Plan.Coverage_Id=Coverage.Coverage_Id And Policy.Policy_Id=Pol_Id;
  Amnt_Copay:=Onc;
  Amnt_Coinsurance:=((Sew-Amnt_Copay)*Onci)/100;
  Sum2:=Amnt_Copay+Total_Cust;
  Sum3:=Amnt_Coinsurance+Sum2;
  Diff4:=Sum3-Mopm;
  Sum4:=Onc+Diff4;
  Diff3:=Mopm-Sum2;
  Diff5:=Mopm - Sum2;
  Diff6:=Sew-Sum4;
  Sum5:=amnt_coinsurance+Onc;
  Diff7:=Sew-Sum5;
  Sum6:=Total_Cust+Sew;
  Diff8:=Pd-Total_Cust;
  diff20:=sew-diff8;
  Sum7:=Diff8+Onc;
  Calc1:=((Sew-Sum7)*Onci)/100;
  Sum8:=Onc+Calc1+Diff8;
  Diff9:=Sew-Sum8;
  Diff10:=Mopm-Total_Cust; 
  Diff11:=Sew-Diff10;
  var1:=sum1-pd;
  sum20:= var1+diff8;
  sum21 := diff8 + onc;
  var2 := sew - sum21;
  sum22 := sum21 + var2;
	----------------if total paid by customer already exceeds max out of pocket expense
        If (Total_Cust >= Mopm And Total_Cust>Pd) Then
        Update Claim_Line Set Amount_Copay = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_Paid_Bycustomer = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        Update Claim_Line Set Amount_Paid_Byinsurance = Sew Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
        update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;  
        update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
        Return 8;
	        ----------------------if after current charge, coinsurance and copay, it exceeds max out of pocket expense

        Elsif (Sum3 >= Mopm And Sum2 >= Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Diff10 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Diff10 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff11 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;    
        Return 9;
	-----------------if after coinsurance, person pays more than max out of pocket but not with copay

        Elsif(Sum3>Mopm And Sum2 < Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Onc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = Diff4 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum4 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff6 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            return 10;
	-------------check if after current charge, copay and coinsurance, it exceed total max out of pocket and it already exceeds policy deductable

        Elsif(Sum3<=Mopm And Sum2 < Mopm And Total_Cust>Pd) Then
            Update Claim_Line Set Amount_Copay = Onc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = amnt_coinsurance Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum5 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff7 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            return 11;
        ------------if total cust less than policy deductable and after current charge more than policy deductable
        
Elsif (total_cust < pd and Sum1<= Pd ) Then
            Update Claim_Line Set Amount_Copay = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sew Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            if (sew > diff8) then
            update claim_line set amount_deductable = (sew-diff8) where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service; 
            else
            update claim_line set amount_deductable = (diff8-sew) where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service; 
            end if;
            Return 12;
        ------if total cust less than policy deductable and after current charge, it exceeds policy deductable
        
Elsif(Total_Cust <Pd And Sum1 > Pd) then
            if(var1<onc and var2 < onci) then
            Update Claim_Line Set Amount_Copay = var1 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = sum20 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            return 13;
            elsif (var1 > onc and var2 < amnt_coinsurance) then
            Update Claim_Line Set Amount_Copay = Onc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = var2 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum22 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = 0 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            Return 14;
            else
            Update Claim_Line Set Amount_Copay = Onc Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_of_Coinsurance = Calc1 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Bycustomer = Sum8 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            Update Claim_Line Set Amount_Paid_Byinsurance = Diff9 Where User_Id=U_Id And Policy_Id=Pol_Id And Service_Id=Serv_Id And Sp_Id=Prov_Id And Service_Date=Date_Of_Service;
            update claim_line set amount_deductable = 0 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set status = 'Accept' where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            update claim_line set cid=2 where user_id=u_id and policy_id=pol_id and service_id=serv_id and sp_id=prov_id and service_date=date_of_service;
            Return 15;
end if;  
else
return -2;
  End If;
End If;

Exception
When Others Then
Return -1;
End;

------------------------------------------------Function 16------------------------------------------------
create or replace function feature_message_9_8_cust(Pol_Id In Number,Serv_Id In Number,Prov_Id In Number,Amnt In Number, Patient_Name In Varchar, Date_Of_Service In Date)
return number
IS
msg_id message.message_id%type;
u_id integer;
serv_desc varchar(255);
amnt_servchrg integer;
pc integer;
amnt_cp integer;
amnt_ded integer;
amnt_coinc integer;
amnt_bycust integer;
amnt_byins integer;
begin
-----fetches data from claim line table for the accepted claim and inserts in message table 
Select Userid Into U_Id From Customer Where Cust_Name=Patient_Name;
select service_description into serv_desc from service where service_id=serv_id;
select allowed_service_charges into amnt_servchrg from coverage where service_id=serv_id;
select providers_charge into pc from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
select amount_copay into amnt_cp from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id ;
select amount_deductable into amnt_ded from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
select amount_of_coinsurance into amnt_coinc from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
select amount_paid_bycustomer into amnt_bycust from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
select amount_paid_byinsurance into amnt_byins from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
insert into message values (message_seq.nextval,' service identification number ' || serv_id ||' service description ' || serv_desc || ' allowed service charge ' || amnt_servchrg || ' providers charge ' || pc || ' amount copay ' || amnt_cp ||' amount deductable ' || amnt_ded ||' amount of coinsurance ' || amnt_coinc ||' amount paid by customer ' || amnt_bycust ||' amount paid by insurance ' || amnt_byins,sysdate,u_id);
update claim_line set message_id = message_seq.currval where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
return 0;

exception
	when others then
	return -1;

End;

------------------------------------------------Function 17------------------------------------------------
create or replace function feature_message_9_8_depd(Pol_Id In Number,Serv_Id In Number,Prov_Id In Number,Amnt In Number, Patient_Name In Varchar, Date_Of_Service In Date)
return number
IS
msg_id message.message_id%type;
u_id integer;
serv_desc varchar(255);
amnt_servchrg integer;
pc integer;
amnt_cp integer;
amnt_ded integer;
amnt_coinc integer;
amnt_bycust integer;
amnt_byins integer;
begin
 
-----fetches data from claim line table for the accepted claim and inserts in message table
Select Userid Into U_Id From dependent Where d_name=Patient_Name;
select service_description into serv_desc from service where service_id=serv_id;
select allowed_service_charges into amnt_servchrg from coverage where service_id=serv_id;
select providers_charge into pc from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
select amount_copay into amnt_cp from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id ;
select amount_deductable into amnt_ded from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
select amount_of_coinsurance into amnt_coinc from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
select amount_paid_bycustomer into amnt_bycust from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
select amount_paid_byinsurance into amnt_byins from claim_line where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
insert into message values (message_seq.nextval,' service identification number ' || serv_id ||' service description ' || serv_desc || ' allowed service charge ' || amnt_servchrg || ' providers charge ' || pc || ' amount copay ' || amnt_cp ||' amount deductable ' || amnt_ded ||' amount of coinsurance ' || amnt_coinc ||' amount paid by customer ' || amnt_bycust ||' amount paid by insurance ' || amnt_byins,sysdate,u_id);
update claim_line set message_id = message_seq.currval where policy_id=pol_id and sp_id=prov_id and service_date=date_of_service and user_id=u_id;
return 0;
End;




------------Feature 11-------------------------------------------------

create or replace function claimavailable(claimId in int)
return number
is
countofcid claim.cid%type;
begin
select count(*) into countofcid from claim where cid = claimId;
return countofcid;
end;


