
* 1. Création de data à partir d'un nombre 19901204.

* Création d'une table contenant deux nombres

DATA LIST LIST /date1.
BEGIN DATA
19901204
20000131
END DATA.

* Affichange

LIST.

* Tranformation des valeurs numériques 

COMPUTE day1=MOD(date1,100).
COMPUTE month1=MOD(TRUNC(date1/100),100).
COMPUTE year1=TRUNC(date1/10000).
COMPUTE date2=DATE.DMY(day1,month1,year1).
FORMATS date2(SDATE10).
VARIABLE WIDTH date2(11).
EXECUTE.

* 2. Create a date variable from 3 numeric variables containing day, month and year.
DATA LIST LIST /year1 month1 day1.
BEGIN DATA
1999 12 07
2000 10 18
2000 07 10
2001 02 02
END DATA.
LIST.
COMPUTE mydate=DATE.DMY(day1,month1,year1).
FORMATS mydate(DATE11).
VARIABLE WIDTH mydate(11).
EXECUTE.

* Using an other date format.
COMPUTE mydate2=mydate.
FORMATS mydate2(ADATE11).
VARIABLE WIDTH mydate2(11).
EXECUTE.

* 3. Convert a string containing a date into a date variable.
DATA LIST LIST /datestr(A10).
BEGIN DATA
11/26/1966
01/15/1981
END DATA.
LIST.

* Method 1 (a general method).
COMPUTE mth=NUMBER(SUBSTR(datestr,1,2),F8.0).
COMPUTE day=NUMBER(SUBSTR(datestr,4,2),F8.0).
COMPUTE yr=NUMBER(SUBSTR(datestr,7),F8.0).
COMPUTE mydate=DATE.DMY(day,mth,yr).
FORMAT mydate(SDATE11).
VARIABLE WIDTH mydate (11).
EXECUTE.

* The date in the above string variable has the form mm/dd/yyyy. The code works as
* is if the initial format is mm.dd.yyyy or mm-dd-yyyy. It is easy to modify the above
* to handle variations such as yyyy/mm/dd, dd/mm/yyyy.

* method 2 (works only when data fit an existing SPSS date format).
COMPUTE mydate=NUMBER(datestr,ADATE10).
FORMATS mydate(ADATE10).
VARIABLE WIDTH mydate(10).  /* The purpose of this line is to display all 4 digits of
the year in the data editor */.
EXECUTE.

