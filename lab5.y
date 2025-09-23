%{
#include <bits/stdc++.h>


#include "SymbolTable.h"
using namespace std;

#define YYSTYPE SymbolInfo
int yylex(void);


SymbolInfo asmc;
extern SymbolTable Tb;
extern FILE *yyin;
ofstream fir("code.ir");
ofstream fasm("code.asm");

set<string> ids;
vector<string> temps;


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

%token NUMBER INT IDENTIFIER MAIN NEWLINE SEMICOLON LCURLY RCURLY ASSOP LPARAN RPARAN MANH PRINT COMMA
%token ADD SUB MUL DIV MOD LAND LOR

%left ADD SUB
%left MUL DIV MOD
%left LPARAN RPARAN
%right ASSOP

%%

program:
    MAIN LPARAN RPARAN LCURLY optional_newlines  stmt RCURLY
    {
       
        string data = ".DATA\n";
        for (const auto &id : ids) data += id + " DW 0\n";
        for (const auto &t : temps) data += t + " DW 0\n";

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
	| func_decl NEWLINE
	|func_call NEWLINE
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
func_decl:
IDENTIFIER ASSOP MANH LPARAN IDENTIFIER COMMA IDENTIFIER COMMA IDENTIFIER COMMA IDENTIFIER RPARAN SEMICOLON {
ids.insert($5.getSymbol());
ids.insert($7.getSymbol());
ids.insert($9.getSymbol());
ids.insert($11.getSymbol());
char *c = newTemp(temp_counter);
string t1(c);
temps.push_back(t1);
fir<<t1<<" = "<<$5.getSymbol()<<" - "<<$7.getSymbol()<<endl;

temp_counter++;

char *d = newTemp(temp_counter);
string t2(d);
temps.push_back(t2);
fir<<t2<<" = "<<$9.getSymbol()<<" - "<<$11.getSymbol()<<endl;

temp_counter++;

char *e = newTemp(temp_counter);
string t3(e);
temps.push_back(t3);
fir<<t3<<" = "<<t1<<" + "<<t2<<endl;


temp_counter++;

fir<<"distance"<<" = "<<t3<<endl;



asmc.code+=string(" ;CALL manhattan_distance proc\n");
asmc.code+=string(" MOV AX, ")+$5.getSymbol() + "\n"; 
asmc.code+=string(" MOV BX, ")+$7.getSymbol() + "\n";
asmc.code+=string(" SUB AX,BX ")+"\n";
asmc.code+=string(" CMP AX,0 ")+"\n";
asmc.code+=string(" JL L1 ")+"\n";


asmc.code+=string(" BACK: ")+"\n"; 

asmc.code+=string(" MOV CX, ")+$9.getSymbol() + "\n"; 
asmc.code+=string(" MOV DX, ")+$11.getSymbol() + "\n";
asmc.code+=string(" SUB CX,DX ")+"\n";
asmc.code+=string(" CMP CX,0 ")+"\n";
asmc.code+=string(" JL L2 ")+"\n";
asmc.code+=string(" JMP EXIT ")+"\n";

asmc.code+=string("  L1: ")+"\n";
asmc.code+=string(" NEG AX ")+"\n";
asmc.code+=string(" JMP BACK ")+"\n";


asmc.code+=string("  L2: ")+"\n";
asmc.code+=string(" NEG CX ")+"\n";

asmc.code+=string(" EXIT: ")+"\n";
asmc.code+=string(" ADD AX,CX ")+"\n";
asmc.code+=string(" MOV distance,AX ")+"\n";
free(c);
free(d);
free(e);
}
;

func_call:
PRINT LPARAN IDENTIFIER RPARAN SEMICOLON{
asmc.code+=string(" ;CALL PRINT proc\n");
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
