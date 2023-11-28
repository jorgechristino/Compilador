%{ 
/* analisador léxico para uma calculadora básica */ 
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "sintatico.tab.h"
%}

%option yylineno
%option noyywrap

digito	        [0-9]
letra 	        [a-zA-Z]
separador       "|"
underscore      "_"
inteiro         [-+]?{digito}+ 
real            [-+]?{digito}+"."{digito}+
caractere       {separador}[a-zA-Z0-9/" "]{separador}

var             {letra}({letra}|{digito}|{underscore})*

%%

[\t ]+		 { /* ignora espaço em branco */ }
[\n]+        { /* Ignora quebras de linha */ }
"main"       { return MAIN; }
"endmain"    { return ENDMAIN; }
"int"        { return INT; }
"float"      { return FLOAT; }
"char"       { return CHAR; }
"print"      { return PRINT; }
"read"       { return READ; }
"not"        { return NOT; }
"and"        { return AND; }
"or"         { return OR; }
"=="         { return EQ; }
"!="         { return NEQ; }
">"          { return GT; }
"<"          { return LT; }
">="         { return GTEQ; }
"<="         { return LTEQ; }
"if"         { return IF; }
"else"       { return ELSE; }
"while"      { return WHILE; }
{inteiro}    { strcpy(yylval.var, yytext); return INTEIRO; }
{real}       { strcpy(yylval.var, yytext); return REAL; }
{caractere}  { strcpy(yylval.var, yytext); return CARACTERE; }
{var}	     { strcpy(yylval.var, yytext); return VAR; }

.            { return *yytext; }

%%