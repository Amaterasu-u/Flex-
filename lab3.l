%option noyywrap yylineno


%{
#include<stdio.h>  //Yeaser Ahmad 
#include<string.h>
char gp[] = "Grameenphone";   
char rb[] = "Robi"; 
char bl[] = "Banglalink"; 
%}              


PN1 ("\+88017"|"\+88013")[0-9]{1}"-"[0-9]{7}
PN2 ("\+88017"|"\+88013")[0-9]{8}
PN3 ("017"|"013")[0-9]{8}
PNG ({PN1}|{PN2}|{PN3})

PN4 "\+88018"[0-9]{1}"-"[0-9]{7}
PN5 "\+88018"[0-9]{8}
PN6 "018"[0-9]{8}
PNR ({PN4}|{PN5}|{PN6})

PN7 "\+88019"[0-9]{1}"-"[0-9]{7}
PN8 "\+88019"[0-9]{8}
PN9 "019"[0-9]{8}
PNB ({PN7}|{PN8}|{PN9})

ig1 [ \t\n]+
ig2 ;|,
ws ({ig1}|{ig2})+

EMF [a-z]{1}[a-zA-Z0-9_.]*[ \t]+[a-zA-Z0-9_.]*"@"[a-z]+"\."[a-z]+
EM1 [A-Z]{1}[a-zA-Z0-9_\.]+"@"[a-z]+"\."[a-z]+
EM [a-z]{1}[a-zA-Z0-9_\.]+"@"[a-z]+"\."[a-z]+


CG ([.0-3]\.[.0-9]{2})|"4\.00"

DAY (0[1-9]|[12][0-9]|3[01])
MONTH (0[1-9]|1[0-2])
YEAR ("199"[0-9]{1}|"20"[0-9]{2})
DATE {DAY}"\-"{MONTH}"\-"{YEAR}

%%
{ws} {}
{PNG} {printf("Phone Number Identified : %s\n and your operator is : %s",yytext,gp);}
{PNR} {printf("Phone Number Identified : %s\n and your operator is : %s",yytext,rb);}
{PNB} {printf("Phone Number Identified : %s\n and your operator is : %s",yytext,bl);}

{CG} {printf("CG is Identified : %s\n",yytext);}


{EMF} {printf("Email is Invalid! Whitespace not allowed! : %s\n",yytext);}
{EM1} {printf("Email is Invalid! First letter cannot be capital : %s\n",yytext);}
{EM} {printf("Email is valid : %s\n",yytext);}


{DATE} {printf("DATE is Identified : %s\n",yytext);}
%%

int main() {


    yylex();
	


}
