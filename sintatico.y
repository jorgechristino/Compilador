%{
/* analisador sintático */
#include <iostream>
#include <string>
#include <string.h>
#include <fstream>
#include <map>

using namespace std;

enum Tipo { TIPO_INT, TIPO_FLOAT, TIPO_CHAR };

map<string, Tipo> variaveis;
string codigo = "";

/* protótipos das funções */
int yylex(void);
int yyparse(void);
void yyerror(const char *);

%}

%union {
	char var[256];
}

%token MAIN ENDMAIN INT FLOAT CHAR PRINT READ NOT AND OR IF ELSE WHILE
%token EQ NEQ GT LT GTEQ LTEQ
%token <var> INTEIRO
%token <var> REAL
%token <var> CARACTERE
%token <var> VAR

%type <var> BLOCO 
%type <var> COMANDOS 
%type <var> COMANDO 
%type <var> EXPR 
%type <var> DECLARACAO 
%type <var> ATRIB 
%type <var> SAIDA 
%type <var> ENTRADA
%type <var> LOGICA
%type <var> VALOR
%type <var> EXPR_RELAC
%type <var> IF_COMANDO
%type <var> WHILE_COMANDO

%left '+' '-'
%left '*' '/'
%left OR
%left AND
%left NOT

%start S

%%

S:  MAIN BLOCO ENDMAIN 
	{
		codigo = "#include<stdio.h>\n";		
		codigo += "#include<stdlib.h>\n";		
		codigo += "int main () {\n";
		codigo += $2;
		codigo += "\treturn 0;\n";
		codigo += "}";
	}
	;

BLOCO: '{' COMANDOS '}' 
		{ 
			strncpy($$, $2, 256);
		} 
	;

COMANDOS: 	COMANDOS COMANDO 
			{
				strcat($$, $2);
			}
			| COMANDO
			{
				
			}
    ;

COMANDO: DECLARACAO | ATRIB | SAIDA | ENTRADA | IF_COMANDO | WHILE_COMANDO
	;

DECLARACAO: FLOAT VAR '=' EXPR ';'  
			{ 
				strcpy($$, "\tfloat ");
				strcat($$, $2);
				strcat($$, " = ");
				strcat($$, $4);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_FLOAT;
			}
			| FLOAT VAR ';'  		   
			{ 
				strcpy($$, "\tfloat ");
				strcat($$, $2);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_FLOAT;
			}
			| INT VAR '=' EXPR ';'  
			{ 
				strcpy($$, "\tint ");
				strcat($$, $2);
				strcat($$, " = ");
				strcat($$, $4);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_INT;
			}
			| INT VAR ';'  		   
			{ 
				strcpy($$, "\tint ");
				strcat($$, $2);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_INT;
			}
			| CHAR VAR '=' CARACTERE ';'  
			{ 
				strcpy($$, "\tchar ");
				strcat($$, $2);
				strcat($$, " = ");
				char caractere[5] = "'";
				caractere[1] = $4[1];
				caractere[2] = '\'';
				strcat($$, caractere);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_CHAR;
			}
			| CHAR VAR ';'  		   
			{ 
				strcpy($$, "\tchar ");
				strcat($$, $2);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_CHAR;
			}
		;



EXPR: EXPR '+' EXPR				
	{
		strcpy($$, $1);
		strcat($$, " + ");
		strcat($$, $3);
	}
	| EXPR '-' EXPR
	{
		strcpy($$, $1);
		strcat($$, " - ");
		strcat($$, $3);
	}
	| EXPR '*' EXPR
	{
		strcpy($$, $1);
		strcat($$, " * ");
		strcat($$, $3);
	}
	| EXPR '/' EXPR
	{
		strcpy($$, $1);
		strcat($$, " / ");
		strcat($$, $3);
	}
	| '(' EXPR ')'
	{
		strcpy($$, "(");
		strcat($$, $2);
		strcat($$, ")");
	}
	| VAR					
	| REAL	 	
	| INTEIRO    
	;


ATRIB: VAR '=' EXPR ';'	
	{
		strcpy($$, "\t");
		strcat($$, $1);
		strcat($$, " = ");
		strcat($$, $3);
		strcat($$, ";\n");
	} 	
	| VAR '=' CARACTERE ';' 	
	{ 
		strcpy($$, "\t");
		strcat($$, $1);
		strcat($$, " = ");
		char caractere[5] = "'";
		caractere[1] = $3[1];
		caractere[2] = '\'';
		strcat($$, caractere);
		strcat($$, ";\n");
	}
	; 

SAIDA:  PRINT '(' VAR ')' ';' 
		{
			if(variaveis[$3] == Tipo::TIPO_INT){
				strcpy($$, "\tprintf(\"\%d\",");
			}else if(variaveis[$3] == Tipo::TIPO_FLOAT){
				strcpy($$, "\tprintf(\"\%f\",");
			}else{
				strcpy($$, "\tprintf(\"\%c\",");
			}
				strcat($$, $3);
				strcat($$, ");\n");
		}
		| PRINT '(' INTEIRO ')' ';'  	
		{ 
			strcpy($$, "\tprintf(\"\%d\",");
			strcat($$, $3);
			strcat($$, ");\n"); 
		}
		| PRINT '(' REAL ')' ';'
		{
			strcpy($$, "\tprintf(\"\%f\",");
			strcat($$, $3);
			strcat($$, ");\n");
		}
		| PRINT '(' CARACTERE ')' ';'
		{
			strcpy($$, "\tprintf(\"\%c\",");
			char caractere[5] = "'";
			caractere[1] = $3[1];
			caractere[2] = '\'';
			strcat($$, caractere);
			strcat($$, ");\n");
		}
		;

ENTRADA:  	READ '(' VAR ')' ';'
			{
				if(variaveis[$3] == Tipo::TIPO_INT){
					strcpy($$, "\tscanf(\"\%d\",&");
				}else if(variaveis[$3] == Tipo::TIPO_FLOAT){
					strcpy($$, "\tscanf(\"\%f\",&");
				}else{
					strcpy($$, "\tscanf(\"\%c\",&");
				}
				strcat($$, $3);
				strcat($$, ");\n");
			}
		;

LOGICA: NOT LOGICA 			
		{ 
			strcpy($$, "!");
			strcat($$, $2);
		}
      	| LOGICA AND LOGICA   
	  	{
			strcpy($$, $1);
			strcat($$, "&&");
			strcat($$, $3);
	  	}
      	| LOGICA OR LOGICA    
	  	{ 
			strcpy($$, $1);
			strcat($$, "||");
			strcat($$, $3);
	  	}
      	| '(' LOGICA ')'  	
	  	{
			strcpy($$, "(");
			strcat($$, $2);
			strcat($$, ")");
	  	}
	  	| EXPR_RELAC
	  	| VALOR 
      	;

VALOR: 	VAR | INTEIRO | REAL 
		;

EXPR_RELAC: VALOR EQ VALOR   
			{ 
				strcpy($$, $1);
				strcat($$, "==");
				strcat($$, $3);
			}
			| VALOR NEQ VALOR
			{ 
				strcpy($$, $1);
				strcat($$, "!=");
				strcat($$, $3);
			}
			| VALOR GT VALOR
			{ 
				strcpy($$, $1);
				strcat($$, ">");
				strcat($$, $3);
			}
			| VALOR LT VALOR
			{ 
				strcpy($$, $1);
				strcat($$, "<");
				strcat($$, $3);
			}
			| VALOR GTEQ VALOR
			{ 
				strcpy($$, $1);
				strcat($$, ">=");
				strcat($$, $3);
			}
			| VALOR LTEQ VALOR
			{ 
				strcpy($$, $1);
				strcat($$, "<=");
				strcat($$, $3);
			}
			;

IF_COMANDO: IF '(' LOGICA ')' BLOCO ELSE BLOCO
			{
				strcpy($$, "\tif(");
				strcat($$, $3);
				strcat($$, "){\n");
				strcat($$, $5);
				strcat($$, "}else{\n");
				strcat($$, $7);
				strcat($$, "}\n");
			}
			| IF '(' LOGICA ')' BLOCO
			{ 
				strcpy($$, "\tif(");
				strcat($$, $3);
				strcat($$, "){\n");
				strcat($$, $5);
				strcat($$, "}\n");
			}
		;

WHILE_COMANDO:  WHILE '(' LOGICA ')' BLOCO
				{
					strcpy($$, "\twhile(");
					strcat($$, $3);
					strcat($$, "){\n");
					strcat($$, $5);
					strcat($$, "}\n");
				}
	;
%%

/* definido pelo analisador léxico */
extern FILE * yyin;  

int main(int argc, char ** argv)
{
	/* se foi passado um nome de arquivo */
	if (argc > 1)
	{
		FILE * file;
		file = fopen(argv[1], "r");
		if (!file)
		{
			cout << "Arquivo " << argv[1] << " não encontrado!\n";
			exit(1);
		}
		
		/* entrada ajustada para ler do arquivo */
		yyin = file;
	}

	yyparse();

	ofstream output("output.c");
	if (output.is_open()) {
        // Inserir codigo no arquivo
        output << codigo << endl;

        // Fechar o arquivo
        output.close();
    }
}

void yyerror(const char * s)
{
	/* variáveis definidas no analisador léxico */
	extern int yylineno;    
	extern char * yytext;   
	
	/* mensagem de erro exibe o símbolo que causou erro e o número da linha */
    cout << "Erro (" << s << "): símbolo \"" << yytext << "\" (linha " << yylineno << ")\n";
	exit(1);
}
