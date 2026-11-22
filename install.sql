-- install.sql
-- Purpose : installs the complete demo schema in order
-- (user, tables, sample data, package, triggers, views)
-- Usage   : docker compose exec oracle sqlplus /nolog @/workspace/install.sql

WHENEVER SQLERROR EXIT FAILURE
SET VERIFY OFF

ACCEPT sys_pwd CHAR PROMPT 'SYSTEM password: ' HIDE
ACCEPT app_pwd CHAR PROMPT 'BANK_APP password: ' HIDE

SPOOL /tmp/install.log

PROMPT === Step 0: create user ===
CONNECT system/"&sys_pwd"@//localhost/FREEPDB1
@@00_setup_user.sql "&app_pwd"

PROMPT === Connect as BANK_APP ===
CONNECT bank_app/"&app_pwd"@//localhost/FREEPDB1
BEGIN
  IF USER != 'BANK_APP' THEN
    RAISE_APPLICATION_ERROR(-20000, 'Expected BANK_APP, but connected as ' || USER);
  END IF;
END;
/

UNDEFINE sys_pwd app_pwd

SPOOL OFF
EXIT
