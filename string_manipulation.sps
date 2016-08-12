* Encoding: UTF-8.

DATA LIST FIXED /name 1-25 (A).
BEGIN DATA
000John Doe /10.14.12
Mary Poppins /17.21
Billy Joe /21.25
Peter Pan /10.35
END DATA.


LIST.

* Definition de nouvelles variables 

STRING name1 TO name4 (A25).
VARIABLE LABEL name 'Original value'
    name1 'Without leading zeros' 
    name2 'Replace . by ,' 
    name3 'Delete up to "/"' 
    name4 'Delete from "/"'.
* 1. Suppression des zero

COMPUTE name1=LTRIM(name,"0").
* Affichage de le variable name1 et name 

LIST name name1.

* Remplacment de points par virgule 

COMPUTE name2=name1.

LOOP IF INDEX(name2,".")>0.
+ COMPUTE SUBSTR(name2,INDEX(name2,"."),1)=",".
END LOOP.

LIST name1 name2.

* Delete the "/" and everything to the left.

COMPUTE name3=SUBSTR(name1,INDEX(name1,"/")+1).

LIST name1 name3.

* Delete the "/" and everything to the right

COMPUTE name4=SUBSTR(name1,1,INDEX(name1,"/")-1).

LIST name1 name4.


* 5. To concatenate strings str1 and str2.
STRING str1 str2 str3 str4 (A2).
COMPUTE str1="A".
COMPUTE str2="B".
 
*------- Note that the following does NOT work.
COMPUTE str3=CONCAT(str1,str2).
* It does not work because str1 is actually equal to "A" followed by a space.
* Similarly, str2 is "B" followed by a space.
* Thus CONCAT(str1, str2) results in the 4 character strings "A B ". which
* is truncated to two character strings "A " to fit the dimension of str3.

*------- The following DOES work.
COMPUTE str4=CONCAT(RTRIM(str1),str2).
LIST str1 str2 str3 str4.
