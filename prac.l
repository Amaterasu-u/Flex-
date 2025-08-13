%option noyywrap 

%{
#include<stdio.h>
int count=1;
%}


order "ORD"[0-9a-fA-F]{6}
name [A-Z]{1}[a-zA-Z]+" "[A-Z]{1}[a-zA-Z]+

blank [ \t\n]+
pc ,|;|\*
ws ({blank}|{pc})+

EM [a-z]{1}.+"@"[a-z]+"\."[a-z]+

%%
{ws} {}
{order} {fprintf(yyout,"Order ID : %s\n Order Serial : %d\n",yytext,count++);}
{name} {fprintf(yyout,"Customer Name : %s\n",yytext);}
{EM} {fprintf(yyout,"Customer Mail : %s\n",yytext);}
%%

int main(){

yyin = fopen("in.txt" , "r");
yyout = fopen("op.txt" , "w");

yylex();

fclose(yyin);
fclose(yyout);

}