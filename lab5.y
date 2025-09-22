%{
#include <bits/stdc++.h>


#include "SymbolTable.h"
using namespace std;

#define YYSTYPE SymbolInfo
int yylex(void);

/* accumulators */
SymbolInfo asmc;
extern SymbolTable Tb;
extern FILE *yyin;
ofstream fir("code.ir");
ofstream fasm("code.asm");

set<string> ids;
vector<string> temps;

/* keep your original newTemp */
char* newTemp(int i)
{
    char *tvar=(char*)malloc(15);
    sprintf(tvar,"t%d",i);
    return tvar;
}
int temp_counter = 1;

void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
}
%}

%error-verbose

%token NUMBER INT IDENTIFIER MAIN NEWLINE SEMICOLON LCURLY RCURLY ASSOP LPARAN RPARAN
%token ADD SUB MUL DIV MOD LAND LOR

%left ADD SUB
%left MUL DIV MOD
%left LPARAN RPARAN
%right ASSOP

%%

program:
    MAIN LPARAN RPARAN LCURLY optional_newlines stmt RCURLY
    {
       
        string data = ".DATA\n";
        for (const auto &id : ids) data += id + " DW ?\n";
        for (const auto &t : temps) data += t + " DW ?\n";

        string finalAsm;
        finalAsm += ".MODEL SMALL\n.STACK 100H\n";
        finalAsm += data;
        finalAsm += ".CODE\n";
        finalAsm += "MAIN PROC\n";
        finalAsm += "    MOV AX,@DATA\n    MOV DS,AX\n\n";
        finalAsm += asmc.code;
        finalAsm += "MAIN ENDP\nEND\n";
        fasm << finalAsm;
      
    }
;

optional_newlines:
      
    | optional_newlines NEWLINE
    ;

stmt:
      stmt line { }
    | line      { }
    ;

line:
      var_decl NEWLINE
    | expr_decl NEWLINE
    ;

var_decl:
    INT IDENTIFIER SEMICOLON
    {
        string var = $2.getSymbol();
        ids.insert(var);
        Tb.INSERT(var, "IDENTIFIER");
    }
;

expr_decl:
    IDENTIFIER ASSOP expr SEMICOLON
    {
        fir << $1.getSymbol() << " = " << $3.getSymbol() << endl;
        asmc.code += string("    MOV AX, ") + $3.getSymbol() + "\n";
        asmc.code += string("    MOV ") + $1.getSymbol() + ", AX\n";
    }
;

expr:
    expr ADD expr
    {
        char *c = newTemp(temp_counter);
        string t(c);
        temps.push_back(t);

        fir << t << " = " << $1.getSymbol() << " + " << $3.getSymbol() << endl;
        asmc.code += string("    MOV AX, ") + $1.getSymbol() + "\n";
        asmc.code += string("    MOV BX, ") + $3.getSymbol() + "\n";
        asmc.code += "    ADD AX, BX\n";
        asmc.code += string("    MOV ") + t + ", AX\n";
        temp_counter++;
        SymbolInfo tmp(t, "");
        $$ = tmp;
        free(c);
    }
  | expr SUB expr
    {
        char *c = newTemp(temp_counter);
        string t(c);
        temps.push_back(t);

        fir << t << " = " << $1.getSymbol() << " - " << $3.getSymbol() << endl;
        asmc.code += string("    MOV AX, ") + $1.getSymbol() + "\n";
        asmc.code += string("    MOV BX, ") + $3.getSymbol() + "\n";
        asmc.code += "    SUB AX, BX\n";
        asmc.code += string("    MOV ") + t + ", AX\n";
        temp_counter++;
        SymbolInfo tmp(t, "");
        $$ = tmp;
        free(c);
    }
  | expr MUL expr
    {
        char *c = newTemp(temp_counter);
        string t(c);
        temps.push_back(t);

        fir << t << " = " << $1.getSymbol() << " * " << $3.getSymbol() << endl;
        asmc.code += string("    MOV AX, ") + $1.getSymbol() + "\n";
        asmc.code += string("    MOV BX, ") + $3.getSymbol() + "\n";
        asmc.code += "    MUL BX\n";
        asmc.code += string("    MOV ") + t + ", AX\n";
        temp_counter++;
        SymbolInfo tmp(t, "");
        $$ = tmp;
        free(c);
    }
  | expr DIV expr
    {
        char *c = newTemp(temp_counter);
        string t(c);
        temps.push_back(t);

        fir << t << " = " << $1.getSymbol() << " / " << $3.getSymbol() << endl;
        asmc.code += string("    MOV AX, ") + $1.getSymbol() + "\n";
        asmc.code += string("    MOV BX, ") + $3.getSymbol() + "\n";
        asmc.code += "  DIV BX\n";
        asmc.code += string("    MOV ") + t + ", AX\n";
        temp_counter++;
        SymbolInfo tmp(t, "");
        $$ = tmp;
        free(c);
    }
  | LPARAN expr RPARAN { $$ = $2; }
  | NUMBER { $$ = $1; }
  | IDENTIFIER { $$ = $1; }
;

%%

int main(void)
{
    yyin = fopen("input.txt", "r");
    if (!yyin) {
        fprintf(stderr, "input.txt cannot open\n");
        return 1;
    }


    yyparse();
    fclose(yyin);

    fir.close();
    fasm.close();

    Tb.print();

}
