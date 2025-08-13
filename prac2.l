%option noyywrap

%{
#include <stdio.h>
#include <ctype.h>

int count = 1;
%}


pass [^\n]+

%%

{pass} {
    int hasUp = 0, hasDig = 0, hasSpec = 0;

    for (int i = 0; i < yyleng; ++i) {
        unsigned char c = (unsigned char) yytext[i];
        if (isupper(c)) hasUp = 1;
        else if (isdigit(c)) hasDig = 1;
        else if (!isalnum(c)) hasSpec = 1;
    }

    if (yyleng > 8 && hasUp && hasDig && hasSpec) {
        printf("Password is : %s\nPassword Length : %d\n", yytext, yyleng);
    } else {
        printf("Password invalid:");
        if (yyleng <= 8) printf(" too short");
        if (!hasUp)      printf(" no uppercase");
        if (!hasDig)     printf(" no digit");
        if (!hasSpec)    printf(" no special");
        printf("\n");
    }
}



%%

int main() {
    yylex();
    return 0;
}
