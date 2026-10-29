%{
#include <stdio.h>
#include <string.h>

int linha_atual = 1;

#define YY_DECL int getToken()
%}


%x COMENTARIO

%%
"/*"                { BEGIN(COMENTARIO); }
<COMENTARIO>"\n"    { linha_atual++; }
<COMENTARIO>"*/"    { BEGIN(INITIAL); }
<COMENTARIO>.       { }

"sensor"            { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"atuador"           { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"porta"             { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"analogico"         { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"digital"           { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"se"                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"entao"             { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"senao"             { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"fim_se"            { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"enquanto"          { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"fim_enquanto"      { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"ler"               { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }
"escrever"          { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Palavra-chave", yytext, linha_atual); return 1; }

"+"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Operacao de soma", yytext, linha_atual); return 1; }
"-"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Operacao de subtracao", yytext, linha_atual); return 1; }
"*"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Operacao de multiplicacao", yytext, linha_atual); return 1; }
"/"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Operacao de divisao", yytext, linha_atual); return 1; }
"<"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Menor que", yytext, linha_atual); return 1; }
"<="                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Menor ou igual", yytext, linha_atual); return 1; }
">"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Maior que", yytext, linha_atual); return 1; }
">="                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Maior ou igual", yytext, linha_atual); return 1; }
"=="                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Comparacao igual", yytext, linha_atual); return 1; }
"!="                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Comparacao diferente", yytext, linha_atual); return 1; }
"<-"                { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Operador de atribuicao", yytext, linha_atual); return 1; }
"."                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Separador de comandos", yytext, linha_atual); return 1; }
":"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Separador de tipo", yytext, linha_atual); return 1; }
","                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Separador de declaracoes", yytext, linha_atual); return 1; }
"("                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Abre bloco", yytext, linha_atual); return 1; }
")"                 { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Fecha bloco", yytext, linha_atual); return 1; }

[0-9]+              { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Numero inteiro", yytext, linha_atual); return 1; }
[a-zA-Z_][a-zA-Z0-9_]* { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Identificador", yytext, linha_atual); return 1; }

\n                  { linha_atual++; }
[ \t\r]+            { }

.                   { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Simbolo Desconhecido", yytext, linha_atual); return 1; }
<<EOF>>             { printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Fim de arquivo", "FDA", linha_atual); return 0; }

%%

int yywrap() {
    return 1;
}

int main(int argc, char **argv) {
    
    FILE *arquivo = fopen("ExemploDomus.txt", "r");
    if (!arquivo) {
        printf("Erro: ExemploDomus.txt\n");
        return 1;
    }
    
    yyin = arquivo;
    
    printf(" Início do Analisador Léxico. \n\n");
    
    while (getToken()) {
       
    }
    
    printf("\n Final do Analisador Léxico. \n");
    fclose(arquivo);
    return 0;
}