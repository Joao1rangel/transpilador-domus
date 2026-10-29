
%{
#include <stdio.h>
#include <string.h>
#include "tokens.h"

int linha_atual = 1;

#define YY_DECL int getToken()
#define TOKEN(codigo, descricao) do { \
    printf("Token: %-30s | Valor: %-20s | Linha: %d\n", descricao, yytext, linha_atual); \
    return (codigo); \
} while (0)
%}

%x COMENTARIO

%%
"/*"                { BEGIN(COMENTARIO); }
<COMENTARIO>"\n"    { linha_atual++; }
<COMENTARIO>"*/"    { BEGIN(INITIAL); }
<COMENTARIO>.       { }


"sensor"       { TOKEN(SENSOR, "Palavra-chave"); }
"atuador"      { TOKEN(ATUADOR, "Palavra-chave"); }
"porta"        { TOKEN(PORTA, "Palavra-chave"); }
"analogico"    { TOKEN(ANALOGICO, "Palavra-chave"); }
"digital"      { TOKEN(DIGITAL, "Palavra-chave"); }
"se"           { TOKEN(SE, "Palavra-chave"); }
"entao"        { TOKEN(ENTAO, "Palavra-chave"); }
"senao"        { TOKEN(SENAO, "Palavra-chave"); }
"fim_se"       { TOKEN(FIM_SE, "Palavra-chave"); }
"enquanto"     { TOKEN(ENQUANTO, "Palavra-chave"); }
"fim_enquanto" { TOKEN(FIM_ENQUANTO, "Palavra-chave"); }
"ler"          { TOKEN(LER, "Palavra-chave"); }
"escrever"     { TOKEN(ESCREVER, "Palavra-chave"); }



"+"     { TOKEN(MAIS, "Operacao de soma"); }
"-"     { TOKEN(MENOS, "Operacao de subtracao"); }
"*"     { TOKEN(VEZES, "Operacao de multiplicacao"); }
"/"     { TOKEN(DIVIDIDO, "Operacao de divisao"); }
"<"     { TOKEN(MENOR, "Menor que"); }
"<="    { TOKEN(MENOR_IGUAL, "Menor ou igual"); }
">"     { TOKEN(MAIOR, "Maior que"); }
">="    { TOKEN(MAIOR_IGUAL, "Maior ou igual"); }
"=="    { TOKEN(IGUAL, "Comparacao igual"); }
"!="    { TOKEN(DIFERENTE, "Comparacao diferente"); }
"<-"    { TOKEN(ATRIBUICAO, "Operador de atribuicao"); }
"."     { TOKEN(PONTO, "Separador de comandos"); }
":"     { TOKEN(DOIS_PONTOS, "Separador de tipo"); }
","     { TOKEN(VIRGULA, "Separador de declaracoes"); }
"("     { TOKEN(ABRE_PAR, "Abre parenteses"); }
")"     { TOKEN(FECHA_PAR, "Fecha parenteses"); }



[0-9]+                  { TOKEN(NUMERO, "Numero inteiro"); }
[a-zA-Z_][a-zA-Z0-9_]*  { TOKEN(IDENTIFICADOR, "Identificador"); }


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
