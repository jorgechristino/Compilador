# Compilador

Implementação de analisadores léxico e sintático para a criação de um compilador para uma linguagem de programação, usando as ferramentas Flex e Bison.

## Instalação

É necessário as ferramentas `flex`, `bison` e `gpp`.

## Execução

Comandos para a geração do compilador da linguagem e execução do programa exemplo.

```console
flex lexico.l
bison -d sinatico.y
gpp lex.yy.c sintatico.tab.c -o compiler
compiler.exe programa
```
