-- install.sql
-- Purpose : installs the complete demo schema in order
-- (user, tables, sample data, package, triggers, views)
-- Usage   : docker compose exec oracle sqlplus /nolog @/workspace/install.sql

WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET VERIFY OFF

ACCEPT sys_pwd CHAR PROMPT 'SYSTEM password: ' HIDE
ACCEPT app_pwd CHAR PROMPT 'BANK_APP password: ' HIDE

SPOOL /tmp/install.log

pro    === Step 0: create user ===
CONNECT system/"&sys_pwd"@localhost:1521/FREEPDB1

@@00_setup_user.sql "&app_pwd"

pro    === Connect as BANK_APP ===
CONNECT bank_app/"&app_pwd"@localhost:1521/FREEPDB1

BEGIN
   IF user != 'BANK_APP' THEN
      raise_application_error(
         -20000,
         'Expected BANK_APP, but connected as ' || user
      );
   END IF;
END;
/

@@01_schema.sql
@@02_sample_data.sql

UNDEFINE sys_pwd app_pwd

SPOOL OFF
EXIT
