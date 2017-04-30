alpha [a-zA-Z]
digit [0-9]
%{
#include "y.tab.h"
#include <string.h>
%}
%%
[ \t]		;
[ \n]   { yylineno = yylineno + 1;}
int	return INT;
float return FLOAT;
char return CHAR;
double return DOUBLE;
if	{cond=1;return IF;};
else	{econd=1;cond=0;return ELSE;};
printf  return PRINTF;
printfn return PRINTLN;
{digit}+       {yylval.Int=atoi(yytext);return NUM;};
{alpha}({alpha}|{digit})* {strcpy(yylval.String,yytext) ;return ID;};
"<="    return LE;
">="    return GE;
"=="    return EQ;
"!="    return NE;
">"	    return GT;
"<"	    return LT;
"&"     return AND;
"|"     return OR;
"<<"    return LS;
">>"    return RS;
\/\/.* ;
\/\*(.*\n)*.*\*\/ ;
.       return yytext[0];
["][^\n"]*["]   {strncpy(yylval.String,yytext+1,yyleng-2);return SENTENCE;};
%%
