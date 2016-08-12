* Definition d'une macro simple

DEFINE !stats (myvars=!CMDEND)
FREQUENCY VARIABLES= !myvars /ORDER= ANALYSIS.
!ENDDEFINE.

* Exécution de cette macro
!stats myvars=age sex status.

* Create a data file to work with.

INPUT PROGRAM.
LOOP id=1 TO 3.
VECTOR var(100A8).
LOOP cnt=1 TO 100.
COMPUTE var(cnt)="txt.abc".
END LOOP.
END CASE.
END LOOP.
END FILE.
END INPUT PROGRAM.
EXECUTE.

* The following approach using a loop does NOT work because SUBSTR needs an actual variable name.
* It does not recognize the vector v(cnt) as a variable name.

VECTOR v=var1 TO var100.
LOOP cnt=1 TO 100.
+ LOOP IF INDEX(v(cnt),".")>0.
+ COMPUTE SUBSTR(v(cnt),INDEX(v(cnt),"."),1)=",".
+ END LOOP.
END LOOP.
EXECUTE.

* Using DO REPEAT does work.
DO REPEAT v=var1 TO var100.
LOOP IF INDEX(v,".")>0.
+ COMPUTE SUBSTR(v,INDEX(v,"."),1)=",".
END LOOP.
END REPEAT.
EXECUTE.

* The following macro solution also works.
SET MPRINT=no.
*/////////////////////.
DEFINE !replace(vname=!TOKENS(1)
    /nbvars=!TOKENS(1)
    /oldchar=!TOKENS(1)
    /newchar=!TOKENS(1))
* To replace a character in many string variables.

!DO !cnt=1 !TO !nbvars
LOOP IF INDEX(!CONCAT(!vname,!cnt),!oldchar)>0.
+ COMPUTE SUBSTR(!CONCAT(!vname,!cnt),INDEX(!CONCAT(!vname,!cnt),!oldchar),1)=!newchar.
END LOOP.
!DOEND
EXECUTE.
!ENDDEFINE.
*/////////////////////.

SET MPRINT=yes.
* The macro is called as follows.
!replace vname=var nbvars=100 oldchar='.' newchar=','.


* The DO REPEAT solution is easier than the above macro solution, however, one has to remember that procedures are not allowed inside a DO REPEAT structure, the Macro solution is thus  more general.


* The most convenient way to handle this situation is when one has simply to give to a macro the name of the first and last variables which have to be processed.


* One of the macro Gems (see "Define list of variables between two variables.sps") can then be used.

* Create a data file.

INPUT PROGRAM.
LOOP id=1 TO 3.
STRING strone text34 str2 beta gamma alpha (A8).
DO REPEAT var=strone text34 str2 beta gamma alpha.
COMPUTE var="txt.ab.c".
END REPEAT PRINT.
END LOOP.
END CASE.
END FILE.
END INPUT PROGRAM.
EXECUTE.
SAVE OUTFILE='c:\temp\testdata.sav'.

* Suppose we want to process variables between text34 and gamma inclusively. This solution assumes we have hundreds of variables between these 2 variables. It is not convenient to list them manually.

* Note however that the following solution can also be used when you know that all variables after a given variables need to be processed but you do not know ahead of time the name of the last variable, in that case you simply create a new string variable and use that name as the "ending variable".

* Note: when you save the macro Gem in your macro folder, keep ONLY the macro definition, in other words, delete the data definition and the example of macro call, 
INCLUDE FILE='c:\Program Files\SPSS\macros\DefineListOfVariablesBetweenTwoVariables.sps'.

* Call the macro Gem to define a macro which gives the list of all variables between the 2 given variables.
!DefList var1=text34 var2=gamma fname='c:\temp\testdata.sav'.

* The macro is called as follows.
SET MPRINT=yes.
!rep_chr oldchar='.' newchar=',' vnames=!list1. 

* See Example 4 below for the definition of the macro !rep_chr.


* The same solution as in EXAMPLE 2 can be used.

* Create a data file.
INPUT PROGRAM.
LOOP id=1 TO 3.
STRING strone text34 str2 beta gamma (A8).
DO REPEAT var=strone text34 str2 beta gamma.
COMPUTE var="txt.ab.c".
END REPEAT PRINT.
END LOOP.
END CASE.
END FILE.
END INPUT PROGRAM.
EXECUTE.

* create a numeric variable between the first and last string variables.
COMPUTE numvar=2.
STRING alpha(A8).
COMPUTE alpha="txt.a.b.c".
SAVE OUTFILE='c:\temp\testdata.sav'.

INCLUDE FILE='c:\Program Files\SPSS\macros\DefineListOfVariablesBetweenTwoVariables.SPS'.

* Call the macro Gem to define a macro which gives the list of all variables between the 2 given variables.
!DefList var1=text34 var2=alpha fname='c:\temp\testdata.sav'.

* The macro is called as follows.
SET MPRINT=yes.
!rep_chr oldchar='.' newchar=',' vnames=!list1. 

* Note that *errors* will occur when the macro attempts to modify the numeric variables (variable numvar), as a result of that error, the command will not be executed. However, we do not care since we did not intend to modify numeric variables in any event.

* See Example 4 below for the definition of the macro !rep_chr.

* In this case, the names of each string variable which needs to be processed must be explicitly given to the macro.

INPUT PROGRAM.
LOOP id=1 TO 3.
STRING strone text34 str2 name alpha (A8).
DO REPEAT var=strone text34 str2 name alpha.
COMPUTE var="txt.ab.c".
END REPEAT PRINT.
END LOOP.
END CASE.
END FILE.
END INPUT PROGRAM.
EXECUTE.

* A macro can be used.

SET MPRINT=no.
*/////////////////////.
DEFINE !rep_chr(oldchar=!TOKENS(1)
    /newchar=!TOKENS(1)
    /vnames=!CMDEND)
/* To replace a character in many string variables */

!DO !vname !IN (!vnames)
LOOP IF INDEX(!vname,!oldchar)>0.
+ COMPUTE SUBSTR(!vname,INDEX(!vname,!oldchar),1)=!newchar.
END LOOP.
!DOEND
EXECUTE.
!ENDDEFINE.
*/////////////////////.

* Assume that for variables text34 str2 alpha we want to replace all dots by commas. (The variables are not consecutive in the file.)

* The macro is called as follows.
SET MPRINT=yes.
!rep_chr oldchar='.' newchar=',' vnames=text34 str2 alpha.

* Of course if you wanted to replace occurences of 'a' by 'b' you would call the macro as follows.

!rep_chr oldchar='a' newchar='b' vnames=text34 str2 alpha.