drop table PREMIUM;
drop table PREMIUM_LEVELS;
drop table MESSAGE;
drop table CLAIM_LINE;
drop table CLAIM;
drop table SERVICE_PROVIDER;
drop table POLICY_DEPENDENT;
drop table POLICY;
drop table PLAN;
drop table COVERAGE;
drop table SERVICE;
drop table DEPENDENT;
drop table CUSTOMER;
drop table USERLOGIN;
drop table USERTYPE;
------------------------------------------------------------------------

CREATE TABLE "USERTYPE" 
   (	"UT_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"USER_TYPE" VARCHAR2(50 BYTE), 
	 PRIMARY KEY ("UT_ID")
);

---------------------------------------------------------------------

CREATE TABLE "USERLOGIN" 
   (	"USERID" NUMBER(*,0) NOT NULL ENABLE, 
	"EMAIL_ID" VARCHAR2(255 BYTE), 
	"PSWD" VARCHAR2(255 BYTE), 
	"UT_ID" NUMBER(*,0) NOT NULL ENABLE, 
	 PRIMARY KEY ("USERID"),
 	 FOREIGN KEY ("UT_ID")
	  REFERENCES "USERTYPE" ("UT_ID") ENABLE
   );

---------------------------------------------------------------------------

CREATE TABLE "CUSTOMER" 
   (	"CUST_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"CUST_NAME" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"EMAIL_ID" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"PASSWORD" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"DOB" DATE NOT NULL ENABLE, 
	"GENDER" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
	"ADDRESS" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"PHONE_NO" VARCHAR2(15 BYTE), 
	"USERID" NUMBER(*,0) NOT NULL ENABLE, 
	 PRIMARY KEY ("CUST_ID"),
	 FOREIGN KEY ("USERID")
	  REFERENCES "USERLOGIN" ("USERID") ENABLE
   );

----------------------------------------------------------------------------

CREATE TABLE "DEPENDENT" 
   (	"D_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"D_NAME" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"EMAIL_ID" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"PASSWORD" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"DOB" DATE NOT NULL ENABLE, 
	"GENDER" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
	"ADDRESS" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"PHONE_NO" VARCHAR2(15 BYTE), 
	"USERID" NUMBER(*,0) NOT NULL ENABLE, 
	"RELATION" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"CUST_ID" NUMBER(*,0) NOT NULL ENABLE, 
	 PRIMARY KEY ("D_ID"),
  	 FOREIGN KEY ("USERID")
	  REFERENCES "USERLOGIN" ("USERID") ENABLE, 
	 FOREIGN KEY ("CUST_ID")
	  REFERENCES "CUSTOMER" ("CUST_ID") ENABLE
   );

------------------------------------------------------------------------------------

CREATE TABLE "SERVICE" 
   (	"SERVICE_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"SERVICE_DESCRIPTION" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("SERVICE_ID")
);

-----------------------------------------------------------------------------------

CREATE TABLE "COVERAGE" 
   (	"COVERAGE_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"MAX_SERVICE_PERYEAR" NUMBER(*,0) NOT NULL ENABLE, 
	"ALLOWED_SERVICE_CHARGES" NUMBER(*,0), 
	"IN_NETWORK_COPAY" NUMBER(*,0), 
	"OUT_NETWORK_COPAY" NUMBER(*,0), 
	"IN_NETWORK_COINSURANCE" NUMBER(*,0), 
	"OUT_NETWORK_COINSURANCE" NUMBER(*,0), 
	"SERVICE_ID" NUMBER(*,0) NOT NULL ENABLE, 
	 PRIMARY KEY ("COVERAGE_ID", "SERVICE_ID"),
 	 FOREIGN KEY ("SERVICE_ID")
	  REFERENCES "SERVICE" ("SERVICE_ID") ENABLE
   );
-------------------------------------------------------------------------------------------
CREATE TABLE "PLAN" 
   (	"PLAN_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"PLAN_NAME" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"PLAN_START_YEAR" DATE NOT NULL ENABLE, 
	"PLAN_TENURE_MONTH" NUMBER(*,0) NOT NULL ENABLE, 
	"DEDUCTABLE_AMOUNT" NUMBER(*,0), 
	"MAX_OPC_PERMEMBER" NUMBER(*,0) NOT NULL ENABLE, 
	"MAX_OPC_PERFAMILY" NUMBER(*,0) NOT NULL ENABLE, 
	"STANDARD_ANNUAL_RATE" NUMBER(*,0) NOT NULL ENABLE, 
	"COVERAGE_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"SERVICE_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"PLAN_END_DATE" DATE, 
	 PRIMARY KEY ("PLAN_ID", "COVERAGE_ID"),
	 FOREIGN KEY ("COVERAGE_ID", "SERVICE_ID")
	  REFERENCES "COVERAGE" ("COVERAGE_ID", "SERVICE_ID") ENABLE
   );

--------------------------------------------------------------------------------------------------

CREATE TABLE "POLICY" 
   (	"POLICY_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"PLAN_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"COVERAGE_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"SERVICE_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"USER_ID" NUMBER(*,0) NOT NULL ENABLE, 
	 PRIMARY KEY ("POLICY_ID"),
  	 FOREIGN KEY ("USER_ID")
	  REFERENCES "USERLOGIN" ("USERID") ENABLE, 
	 FOREIGN KEY ("PLAN_ID", "COVERAGE_ID")
	  REFERENCES "PLAN" ("PLAN_ID", "COVERAGE_ID") ENABLE
   );
-------------------------------------------------------------------------------------------

CREATE TABLE "POLICY_DEPENDENT" 
   (	"POLICY_ID" NUMBER NOT NULL ENABLE, 
	"D_ID" NUMBER NOT NULL ENABLE, 
	"USERID" NUMBER NOT NULL ENABLE, 
	 PRIMARY KEY ("POLICY_ID", "D_ID"),
  	 FOREIGN KEY ("POLICY_ID")
	  REFERENCES "POLICY" ("POLICY_ID") ENABLE, 
	 FOREIGN KEY ("USERID")
	  REFERENCES "USERLOGIN" ("USERID") ENABLE, 
	 FOREIGN KEY ("D_ID")
	  REFERENCES "DEPENDENT" ("D_ID") ENABLE
   );
---------------------------------------------------------------------------------------------

CREATE TABLE "SERVICE_PROVIDER" 
   (	"SP_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"SP_DESCRIPTION" VARCHAR2(255 BYTE), 
	"SERVICE_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"USERID" NUMBER(*,0) NOT NULL ENABLE, 
	"EMAIL_ID" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"PASSWORD" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"ADDRESS" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	"PHONE_NO" VARCHAR2(15 BYTE), 
	"SP_TYPE" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("SP_ID", "SERVICE_ID"),
 	 FOREIGN KEY ("SERVICE_ID")
	  REFERENCES "SERVICE" ("SERVICE_ID") ENABLE, 
	 FOREIGN KEY ("USERID")
	  REFERENCES "USERLOGIN" ("USERID") ENABLE
   ) ;

---------------------------------------------------------------------------------------------------

CREATE TABLE "CLAIM" 
   (	"CID" NUMBER(*,0) NOT NULL ENABLE, 
	"TOTALCHARGEOFCUSTOMER" NUMBER(*,0) NOT NULL ENABLE, 
	"TOTALCHARGEOFINSURANCE" NUMBER(*,0) NOT NULL ENABLE, 
	 PRIMARY KEY ("CID")
     );

------------------------------------------------------------------------------------------

CREATE TABLE "CLAIM_LINE" 
   (	"CLAIM_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"STATUS" VARCHAR2(50 BYTE), 
	"PROVIDERS_CHARGE" NUMBER(*,0) NOT NULL ENABLE, 
	"AMOUNT_COPAY" NUMBER(*,0), 
	"AMOUNT_DEDUCTABLE" NUMBER(*,0), 
	"AMOUNT_OF_COINSURANCE" NUMBER(*,0), 
	"AMOUNT_PAID_BYINSURANCE" NUMBER(*,0), 
	"AMOUNT_PAID_BYCUSTOMER" NUMBER(*,0), 
	"MESSAGE_ID" NUMBER(*,0), 
	"SERVICE_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"SERVICE_DATE" DATE NOT NULL ENABLE, 
	"POLICY_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"CLAIM_DATE" DATE NOT NULL ENABLE, 
	"USER_ID" NUMBER(*,0), 
	"SP_ID" NUMBER(*,0), 
	"CID" NUMBER(*,0), 
	 PRIMARY KEY ("CLAIM_ID")
);

----------------------------------------------------------------

 CREATE TABLE "MESSAGE" 
   (	"MESSAGE_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"MESSAGE_BODY" VARCHAR2(255 BYTE), 
	"MESSAGE_DATE" DATE, 
	"USERID" NUMBER(*,0), 
	 PRIMARY KEY ("MESSAGE_ID"),
  	 FOREIGN KEY ("USERID")
	  REFERENCES "USERLOGIN" ("USERID") ENABLE
   );

------------------------------------------------------------------------

 CREATE TABLE "PREMIUM_LEVELS" 
   (	"LEVEL_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"LEVEL_DESCRIPTION" VARCHAR2(255 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("LEVEL_ID"));

---------------------------------------------------------------------

 CREATE TABLE "PREMIUM" 
   (	"PREMIUM_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"POLICY_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"LEVEL_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"PREMIUM_AMOUNT" NUMBER(*,0), 
	 PRIMARY KEY ("PREMIUM_ID"),
  	 FOREIGN KEY ("POLICY_ID")
	  REFERENCES "POLICY" ("POLICY_ID") ENABLE, 
	 FOREIGN KEY ("LEVEL_ID")
	  REFERENCES "PREMIUM_LEVELS" ("LEVEL_ID") ENABLE
   );
