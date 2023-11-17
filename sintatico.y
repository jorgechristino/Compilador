%{
/* analisador sintático para uma calculadora */
/* com suporte a definição de variáveis */
#include <iostream>
#include <string>
#include <map>

using namespace std;

/* protótipos das funções */
int yylex(void);
int yyparse(void);
void yyerror(const char *);
int verificarDeclaracao(char *var);

enum Tipo { TIPO_INT, TIPO_FLOAT, TIPO_CHAR };

/* tabela de símbolos */
typedef struct {
    Tipo tipo;
	int intValor;
	double doubleValor;
	char charValor;
} Variavel;

map<string, Variavel> variaveis;

%}

%union {
	int inteiro;
	double real;
	char caractere;
	char var[16];
}

%token MAIN ENDMAIN INT FLOAT CHAR PRINT READ NOT AND OR
%token EQ NEQ GT LT GTEQ LTEQ
%token <inteiro> INTEIRO
%token <real> REAL
%token <caractere> CARACTERE
%token <var> VAR

%type <inteiro> VALOR
%type <real> EXPR
%type <inteiro> LOGICA
%type <inteiro> EXPR_RELAC

%left '+' '-'
%left '*' '/'
%left OR
%left AND
%left NOT

%start S

%%

S:  MAIN BLOCO ENDMAIN
	;

BLOCO: '{' COMANDOS '}'
	;

COMANDOS: COMANDOS COMANDO | COMANDO 
    ;

COMANDO: DECLARACAO | ATRIB | SAIDA | ENTRADA | LOGICA | EXPR_RELAC
	;

DECLARACAO: FLOAT VAR '=' EXPR ';'  
			{ 
				if(variaveis.find($2) == variaveis.end()){
					variaveis[$2].tipo = Tipo::TIPO_FLOAT;
					variaveis[$2].doubleValor = $4; 
				}else{
					yyerror("Variavel ja foi declarada!");
				}
			}
			| FLOAT VAR ';'  		   
			{ 
				if(variaveis.find($2) == variaveis.end()){
					variaveis[$2].tipo = Tipo::TIPO_FLOAT;
					variaveis[$2].doubleValor = 0;  
				}else{
					yyerror("Variavel ja foi declarada!");
				}
			}
			| INT VAR '=' EXPR ';'  
			{ 
				if(variaveis.find($2) == variaveis.end()){
					variaveis[$2].tipo = Tipo::TIPO_INT;
					variaveis[$2].intValor = $4; 
				}else{
					yyerror("Variavel ja foi declarada!");
				}
			}
			| INT VAR ';'  		   
			{ 
				if(variaveis.find($2) == variaveis.end()){
					variaveis[$2].tipo = Tipo::TIPO_INT;
					variaveis[$2].intValor = 0;  
				}else{
					yyerror("Variavel ja foi declarada!");
				}
			}
			| CHAR VAR '=' CARACTERE ';'  
			{ 
				if(variaveis.find($2) == variaveis.end()){
					variaveis[$2].tipo = Tipo::TIPO_CHAR;
					variaveis[$2].charValor = $4;  
				}else{
					yyerror("Variavel ja foi declarada!");
				}
			}
			| CHAR VAR ';'  		   
			{ 
				if(variaveis.find($2) == variaveis.end()){
					variaveis[$2].tipo = Tipo::TIPO_CHAR;
					variaveis[$2].charValor = ' ';  
				}else{
					yyerror("Variavel ja foi declarada!");
				}
			}
		;

ATRIB: VAR '=' EXPR ';'	
	{
		if(verificarDeclaracao($1)){
			if(variaveis[$1].tipo == Tipo::TIPO_INT){
				variaveis[$1].intValor = $3; 
			}else if(variaveis[$1].tipo == Tipo::TIPO_FLOAT){
				variaveis[$1].doubleValor = $3; 
			}else if(variaveis[$1].tipo == Tipo::TIPO_CHAR){
				variaveis[$1].charValor = $3; 
			}
		}
	} 	
	| VAR '=' CARACTERE ';' 	
	{ 
		if(verificarDeclaracao($1)){
			if(variaveis[$1].tipo == Tipo::TIPO_INT){
				variaveis[$1].intValor = $3; 
			}else if(variaveis[$1].tipo == Tipo::TIPO_FLOAT){
				variaveis[$1].doubleValor = $3; 
			}else if(variaveis[$1].tipo == Tipo::TIPO_CHAR){
				variaveis[$1].charValor = $3; 
			}
		}
	}
	; 

EXPR: EXPR '+' EXPR				{ $$ = $1 + $3; }
	| EXPR '-' EXPR   			{ $$ = $1 - $3; }
	| EXPR '*' EXPR				{ $$ = $1 * $3; }
	| EXPR '/' EXPR			
	{ 
		if ($3 == 0)
			yyerror("Divisão por zero");
		else
			$$ = $1 / $3; 
	}
	| '(' EXPR ')'			{ $$ = $2; }
	| VAR					
	{
		if(verificarDeclaracao($1)){
			if(variaveis[$1].tipo == Tipo::TIPO_INT){
				$$ = variaveis[$1].intValor;
			}else if(variaveis[$1].tipo == Tipo::TIPO_FLOAT){
				$$ = variaveis[$1].doubleValor;
			}
		}
	}
	| REAL	 	
	| INTEIRO    {$$ = (float)$1; }
	;

SAIDA:  PRINT '(' VAR ')' ';' 
		{
			if(verificarDeclaracao($3)){
				if(variaveis[$3].tipo == Tipo::TIPO_INT){
					cout << variaveis[$3].intValor; 
				}
				else if(variaveis[$3].tipo == Tipo::TIPO_FLOAT){
					cout << variaveis[$3].doubleValor; 
				}
				else if(variaveis[$3].tipo == Tipo::TIPO_CHAR){
					cout << variaveis[$3].charValor; 
				}
			}
		}
		| PRINT '(' INTEIRO ')' ';'  	{ cout << $3; }
		| PRINT '(' REAL ')' ';'  		{ cout << $3; }
		| PRINT '(' CARACTERE ')' ';'  	{ cout << $3; }

ENTRADA:  READ '(' VAR ')' ';'
    {
        if(verificarDeclaracao($3)){
            if(variaveis[$3].tipo == Tipo::TIPO_INT){
                int v;
                cin >> v;
                variaveis[$3].intValor = v;
            }
            else if(variaveis[$3].tipo == Tipo::TIPO_FLOAT){
                float v;
                cin >> v;
                variaveis[$3].doubleValor = v;
            }
            else if(variaveis[$3].tipo == Tipo::TIPO_CHAR){
                char v;
                cin >> v;
                variaveis[$3].charValor = v;
            }
        }
    }

LOGICA: NOT LOGICA 			{ $$ = !$2; }
      | LOGICA AND LOGICA   { $$ = $1 && $3; }
      | LOGICA OR LOGICA    { $$ = $1 || $3;  }
      | '(' LOGICA ')'  	{ $$ = $2; }
	//   | EXPR_RELAC
	  | VALOR 
      ;

VALOR: 	VAR
		{
			if(verificarDeclaracao($1)){
				if(variaveis[$1].tipo == Tipo::TIPO_INT){
					$$ = variaveis[$1].intValor;
				}
				else if(variaveis[$1].tipo == Tipo::TIPO_FLOAT){
					$$ = (int)variaveis[$1].doubleValor; 
				}
				else if(variaveis[$1].tipo == Tipo::TIPO_CHAR){
					$$ = (int)variaveis[$1].charValor; 
				}
			}
		}
		| INTEIRO
		| REAL 	{$$ = (int)$1; }
		;

EXPR_RELAC:   VALOR EQ VALOR   { $$ = ($1 == $3) ? 1 : 0; cout << $$ << endl;}
			| VALOR NEQ VALOR  { $$ = ($1 != $3) ? 1 : 0; cout << $$ << endl;}
			| VALOR GT VALOR   { $$ = ($1 > $3) ? 1 : 0; cout << $$ << endl;}
			| VALOR LT VALOR   { $$ = ($1 < $3) ? 1 : 0; cout << $$ << endl;}
			| VALOR GTEQ VALOR { $$ = ($1 >= $3) ? 1 : 0; cout << $$ << endl;}
			| VALOR LTEQ VALOR { $$ = ($1 <= $3) ? 1 : 0; cout << $$ << endl;}
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

/* função para verificar se a variável foi declarada */
int verificarDeclaracao(char * var){
	if(variaveis.find(var) != variaveis.end()){
		return 1;
	}else{
		yyerror("Variavel nao foi declarada!");
		return 0;
	}
}
