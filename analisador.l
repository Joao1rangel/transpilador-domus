
%{
#include <stdio.h>
#include <string.h>
#include "tokens.h"

int linha_atual = 1;

#define YY_DECL int getToken()
%}

%x COMENTARIO

%%
"/*"                { BEGIN(COMENTARIO); }
<COMENTARIO>"\n"    { linha_atual++; }
<COMENTARIO>"*/"    { BEGIN(INITIAL); }
<COMENTARIO>.       { }

"sensor"            { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return SENSOR; }
"atuador"           { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return ATUADOR; }
"porta"             { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return PORTA; }
"analogico"         { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return ANALOGICO; }
"digital"           { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return DIGITAL; }
"se"                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return SE; }
"entao"             { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return ENTAO; }
"senao"             { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return SENAO; }
"fim_se"            { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return FIM_SE; }
"enquanto"          { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return ENQUANTO; }
"fim_enquanto"      { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return FIM_ENQUANTO; }
"ler"               { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return LER; }
"escrever"          { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return ESCREVER; }

"+"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Operacao de soma", yytext, linha_atual); return MAIS; }
"-"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Operacao de subtracao", yytext, linha_atual); return MENOS; }
"*"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Operacao de multiplicacao", yytext, linha_atual); return VEZES; }
"/"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Operacao de divisao", yytext, linha_atual); return DIVIDIDO; }
"<"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Menor que", yytext, linha_atual); return MENOR; }
"<="                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Menor ou igual", yytext, linha_atual); return MENOR_IGUAL; }
">"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Maior que", yytext, linha_atual); return MAIOR; }
">="                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Maior ou igual", yytext, linha_atual); return MAIOR_IGUAL; }
"=="                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Comparacao igual", yytext, linha_atual); return IGUAL; }
"!="                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Comparacao diferente", yytext, linha_atual); return DIFERENTE; }
"<-"                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Operador de atribuicao", yytext, linha_atual); return ATRIBUICAO; }
"."                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Separador de comandos", yytext, linha_atual); return PONTO; }
":"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Separador de tipo", yytext, linha_atual); return DOIS_PONTOS; }
","                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Separador de declaracoes", yytext, linha_atual); return VIRGULA; }
"("                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Abre bloco", yytext, linha_atual); return ABRE_PAR; }
")"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Fecha bloco", yytext, linha_atual); return FECHA_PAR; }

[0-9]+              { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Numero inteiro", yytext, linha_atual); return NUMERO; }
[a-zA-Z_][a-zA-Z0-9_]* { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Identificador", yytext, linha_atual); return IDENTIFICADOR; }

\n                  { linha_atual++; }
[ \t\r]+            { }

.                   { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Simbolo Desconhecido", yytext, linha_atual); return 1; }
<<EOF>>             { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Fim de arquivo", "FDA", linha_atual); return FIM_ARQUIVO; }

%%

int yywrap() {
    return 1;
}

int main(int argc, char **argv) {

    FILE *arquivo = fopen("testes/ExemploDomus.txt", "r");
    if (!arquivo) {
        printf("Erro: testes/ExemploDomus.txt\n");
        return 1;
    }

    yyin = arquivo;

    printf(" Início do Analisador Léxico. \n\n");

    int token;
    while ((token = getToken()) != FIM_ARQUIVO) {
        printf("Codigo retornado: %d\n", token);
    }

    printf("\n Final do Analisador Léxico. \n");
    fclose(arquivo);
    return 0;
}
