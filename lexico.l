%{ 
/* analisador léxico para uma calculadora básica */ 
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "sintatico.tab.h"
extern double variables[26];
%}

%option yylineno
%option noyywrap

digito	    [0-9]
letra	    [a-zA-Z]
separador   "|"
underscore  "_"
inteiro     [-+]?{digito}+ 
real        [-+]?{digito}+"."{digito}+
caractere   "|"[{letra}|{digito}|{" "}]"|"

var         {letra}({letra}|{digito}|{underscore})*

%%

[\t ]+		 { /* ignora espaço em branco */ }
[\n]+        { /* Ignora quebras de linha */ }
"main"       { return MAIN; }
"endmain"    { return ENDMAIN; }
"int"        { return INT; }
"float"      { return FLOAT; }
"char"       { return CHAR; }
"print"      { return PRINT; }
{inteiro}    { yylval.inteiro = atoi(yytext); return INTEIRO; }
{real}       { yylval.real = atof(yytext); return REAL; }
{caractere}  { yylval.caractere = yytext[1]; return CARACTERE; }
{var}	     { strcpy(yylval.var, yytext); return VAR; }

.            { return *yytext; }

%%