# Compilador

Implementação de analisadores léxico e sintático para a criação de um compilador para uma linguagem de programação, usando as ferramentas Flex e Bison.

# Integrantes

Felipe Faustino Brito
Felipe Queiroz Flores Quintão Bachetti
Jorge Christino dos Santos Ferreira

## Instalação

É necessário as ferramentas `flex`, `bison` , `gpp` e `gcc`.

## Execução

Comandos para a geração do compilador da linguagem e execução do programa exemplo.

```console
flex lexico.l
bison -d sintatico.y
g++ lex.yy.c sintatico.tab.c -o compiler
.\compiler.exe programa.ç
gcc output.c
.\a.exe
```
