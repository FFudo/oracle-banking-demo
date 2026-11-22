-- 00_setup_user.sql
-- Purpose : creates the BANK_APP user
-- Run as  : SYSTEM connected to FREEPDB1
-- Usage   : @00_setup_user.sql <bank_app_password>
-- Warning : drops BANK_APP and all data

WHENEVER SQLERROR EXIT FAILURE
SET VERIFY OFF
DEFINE app_password = '&1'
SET SERVEROUTPUT ON

PROMPT Dropping user BANK_APP if it exists...
DECLARE
  e_user_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_user_not_found, -1918);
BEGIN
  EXECUTE IMMEDIATE 'DROP USER bank_app CASCADE';
  DBMS_OUTPUT.PUT_LINE('User BANK_APP dropped.');
EXCEPTION
  WHEN e_user_not_found THEN
    DBMS_OUTPUT.PUT_LINE('User BANK_APP does not exist - nothing to drop.');
END;
/

PROMPT Creating user BANK_APP...
CREATE USER bank_app
  IDENTIFIED BY "&app_password"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA 100M ON USERS;


PROMPT Granting privileges...
GRANT CREATE SESSION,
      CREATE TABLE,
      CREATE VIEW,
      CREATE PROCEDURE,
      CREATE TRIGGER,
      CREATE SEQUENCE
   TO bank_app;

PROMPT Privileges of BANK_APP:
SELECT privilege FROM dba_sys_privs WHERE grantee = 'BANK_APP' ORDER BY privilege;

UNDEFINE app_password
