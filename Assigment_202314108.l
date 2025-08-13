%option noyywrap yylineno


%{
#include<stdio.h>  //Yeaser Ahmad 
int count=0;       //202314108
%}                 //CSE-23 B
delim [ \t\n]
ws {delim}+
digit [0-9]
digits {digit}+
Number {digits}?(\.{digits})?(E[+-]?{digits})?
alphanum [a-zA-Z0-9]+
ID [a-zA-Z]+
letter [a-zA-Z]
letter_ {letter}|_
var {letter_}({letter_}|{Number})*
keyword int|if|else|switch|case|while|for|float|double|break|default|void|continue
punc ;|:|,
parenth \(|\)
curly \{|\}
asop =|<<=|>>=|&=|^=|\|=
bitop >>|<<|&|^|\|
function printf|scanf|main
literal \"[^\n]*\"
scomment "//"[^\n]*
mcomment "/*"[^\*/]*"*/"
comment ({scomment}|{mcomment})
%%
{ws} {}
{keyword} {fprintf(yyout,"Token is <Keyword , %s>\n",yytext);}
{Number} {fprintf(yyout,"Token is <Number , %s>\n",yytext);}
{function} {fprintf(yyout,"Token:<Function , %s>\n",yytext);}
{var} {fprintf(yyout,"Token:<IDENTIFIER , %s>\n",yytext);}
{bitop} {fprintf(yyout,"Token:<BITWISE OPERATOR , %s >\n",yytext);}
{asop} {fprintf(yyout,"Token:<ASSIGNMENT OPERATOR , %s >\n",yytext);}
{punc} {fprintf(yyout,"Token:<Separator , %s>\n",yytext);}
{parenth} {fprintf(yyout,"Token:<Parentheses , %s>\n",yytext);}
{curly} {fprintf(yyout,"Token:< curly , %s>\n",yytext);}
{literal} {fprintf(yyout,"Token:<String Literal , %s>\n Line No: %d\n",yytext,yylineno);}
{comment} {fprintf(yyout,"Token:<Comment , %s>\n",yytext);}

%%

int main() {
    yyin = fopen("in.txt", "r");


    yyout = fopen("sample_output.txt", "w");


    yylex();


    fclose(yyin);
    fclose(yyout);

}