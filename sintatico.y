%{
/* analisador sintático */
#include <iostream>
#include <string>
#include <string.h>
#include <fstream>
#include <map>

using namespace std;

enum Tipo { TIPO_INT, TIPO_FLOAT, TIPO_CHAR, TIPO_STRING };

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

%token MAIN ENDMAIN INT FLOAT CHAR T_STRING PRINT READ NOT AND OR IF ELSE WHILE FOR UNTIL DO
%token ATRIBUICAO SOMA SUB MULT DIV MOD DELIMITADOR 
%token ABRE_PARENTESES FECHA_PARENTESES ABRE_CHAVES FECHA_CHAVES
%token EQ NEQ GT LT GTEQ LTEQ
%token <var> INTEIRO
%token <var> REAL
%token <var> CARACTERE
%token <var> STRING
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
%type <var> FOR_COMANDO

%left SOMA SUB
%left MULT DIV
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

BLOCO: ABRE_CHAVES COMANDOS FECHA_CHAVES
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

COMANDO: DECLARACAO | ATRIB | SAIDA | ENTRADA | IF_COMANDO | WHILE_COMANDO | FOR_COMANDO
	;

DECLARACAO: FLOAT VAR ATRIBUICAO EXPR DELIMITADOR 
			{ 
				strcpy($$, "\tfloat ");
				strcat($$, $2);
				strcat($$, " = ");
				strcat($$, $4);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_FLOAT;
			}
			| FLOAT VAR DELIMITADOR		   
			{ 
				strcpy($$, "\tfloat ");
				strcat($$, $2);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_FLOAT;
			}
			| INT VAR ATRIBUICAO EXPR DELIMITADOR  
			{ 
				strcpy($$, "\tint ");
				strcat($$, $2);
				strcat($$, " = ");
				strcat($$, $4);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_INT;
			}
			| INT VAR DELIMITADOR  		   
			{ 
				strcpy($$, "\tint ");
				strcat($$, $2);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_INT;
			}
			| CHAR VAR ATRIBUICAO CARACTERE DELIMITADOR 
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
			| CHAR VAR DELIMITADOR 		   
			{ 
				strcpy($$, "\tchar ");
				strcat($$, $2);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_CHAR;
			}
			| T_STRING VAR ATRIBUICAO STRING DELIMITADOR
			{ 
				strcpy($$, "\tchar * ");
				strcat($$, $2);
				strcat($$, " = \"");
				char str[strlen($4)];
				int i_str = 0;
				for (int i = 0; i < strlen($4); i++) {
					if ($4[i] != '|' && $4[i] != '\0') {
						str[i_str] = $4[i];
						i_str++;
					}
				}
				strcat($$, str);
				strcat($$, "\";\n");
				variaveis[$2] = Tipo::TIPO_STRING;
			}
			| T_STRING VAR DELIMITADOR  		   
			{ 
				strcpy($$, "\tchar * ");
				strcat($$, $2);
				strcat($$, ";\n");
				variaveis[$2] = Tipo::TIPO_STRING;
			}
		;



EXPR: EXPR SOMA EXPR				
	{
		strcpy($$, $1);
		strcat($$, " + ");
		strcat($$, $3);
	}
	| EXPR SUB EXPR
	{
		strcpy($$, $1);
		strcat($$, " - ");
		strcat($$, $3);
	}
	| EXPR MULT EXPR
	{
		strcpy($$, $1);
		strcat($$, " * ");
		strcat($$, $3);
	}
	| EXPR DIV EXPR
	{
		strcpy($$, $1);
		strcat($$, " / ");
		strcat($$, $3);
	}
	| ABRE_PARENTESES EXPR FECHA_PARENTESES
	{
		strcpy($$, "(");
		strcat($$, $2);
		strcat($$, ")");
	}
	| VAR					
	| REAL	 	
	| INTEIRO    
	;


ATRIB: VAR ATRIBUICAO EXPR DELIMITADOR	
	{
		strcpy($$, "\t");
		strcat($$, $1);
		strcat($$, " = ");
		strcat($$, $3);
		strcat($$, ";\n");
	} 	
	| VAR ATRIBUICAO CARACTERE DELIMITADOR 	
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
	| VAR ATRIBUICAO STRING DELIMITADOR 	
	{ 
		strcpy($$, "\t");
		strcat($$, $1);
		strcat($$, " = \"");
		char str[strlen($3)];
		int i_str = 0;
		for (int i = 0; i < strlen($3); i++) {
			if ($3[i] != '|' && $3[i] != '\0') {
				str[i_str] = $3[i];
				i_str++;
			}
		}
		strcat($$, str);
		strcat($$, "\";\n");
	}
	; 

SAIDA:  PRINT ABRE_PARENTESES VAR FECHA_PARENTESES DELIMITADOR 
		{
			if(variaveis[$3] == Tipo::TIPO_INT){
				strcpy($$, "\tprintf(\"\%d\",");
			}else if(variaveis[$3] == Tipo::TIPO_FLOAT){
				strcpy($$, "\tprintf(\"\%f\",");
			}else if(variaveis[$3] == Tipo::TIPO_CHAR){
				strcpy($$, "\tprintf(\"\%c\",");
			}else{
				strcpy($$, "\tprintf(\"\%s\",");
			}
				strcat($$, $3);
				strcat($$, ");\n");
		}
		| PRINT ABRE_PARENTESES INTEIRO FECHA_PARENTESES DELIMITADOR  	
		{ 
			strcpy($$, "\tprintf(\"\%d\",");
			strcat($$, $3);
			strcat($$, ");\n"); 
		}
		| PRINT ABRE_PARENTESES REAL FECHA_PARENTESES DELIMITADOR
		{
			strcpy($$, "\tprintf(\"\%f\",");
			strcat($$, $3);
			strcat($$, ");\n");
		}
		| PRINT ABRE_PARENTESES CARACTERE FECHA_PARENTESES DELIMITADOR
		{
			strcpy($$, "\tprintf(\"\%c\",");
			char caractere[5] = "'";
			caractere[1] = $3[1];
			caractere[2] = '\'';
			strcat($$, caractere);
			strcat($$, ");\n");
		}
		| PRINT ABRE_PARENTESES STRING FECHA_PARENTESES DELIMITADOR
		{
			strcpy($$, "\tprintf(\"\%s\",");
			strcat($$, "\"");
			char str[strlen($3)];
			int i_str = 0;
			for (int i = 0; i < strlen($3); i++) {
				if ($3[i] != '|' && $3[i] != '\0') {
					str[i_str] = $3[i];
					i_str++;
				}
			}
			strcat($$, str);
			strcat($$, "\");\n");
			}
		;

ENTRADA:  	READ ABRE_PARENTESES VAR FECHA_PARENTESES DELIMITADOR
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
      	| ABRE_PARENTESES LOGICA FECHA_PARENTESES 	
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

IF_COMANDO: IF ABRE_PARENTESES LOGICA FECHA_PARENTESES BLOCO ELSE BLOCO
			{
				strcpy($$, "\tif(");
				strcat($$, $3);
				strcat($$, "){\n");
				strcat($$, $5);
				strcat($$, "}else{\n");
				strcat($$, $7);
				strcat($$, "}\n");
			}
			| IF ABRE_PARENTESES LOGICA FECHA_PARENTESES BLOCO
			{ 
				strcpy($$, "\tif(");
				strcat($$, $3);
				strcat($$, "){\n");
				strcat($$, $5);
				strcat($$, "}\n");
			}
		;

WHILE_COMANDO:  WHILE ABRE_PARENTESES LOGICA FECHA_PARENTESES BLOCO
				{
					strcpy($$, "\twhile(");
					strcat($$, $3);
					strcat($$, "){\n");
					strcat($$, $5);
					strcat($$, "}\n");
				}
		;

FOR_COMANDO:  FOR ABRE_PARENTESES VALOR UNTIL LOGICA DO VAR ATRIBUICAO EXPR FECHA_PARENTESES BLOCO
				{
					strcpy($$, "\tfor(");
					strcat($$, $3);
					strcat($$, ";");
					strcat($$, $5);
					strcat($$, ";");
					strcat($$, $7);
					strcat($$, "=");
					strcat($$, $9);
					strcat($$, "){\n");
					strcat($$, $11);
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
