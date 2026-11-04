%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

int linha_atual = 1;
int mostrar_tokens = 0;
int linha_comentario = 0;
int erros_lexicos = 0;

#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = linha_atual;

#define TOKEN(codigo, descricao) do { \
        if (mostrar_tokens) \
            printf("Token: %-30s | Valor: %-20s | Linha: %d\n", descricao, yytext, linha_atual); \
        return codigo; \
    } while (0)

static char *copiar_texto(const char *s) {
    char *copia = (char *) malloc(strlen(s) + 1);
    if (copia == NULL) {
        printf("Erro fatal: memoria insuficiente\n");
        exit(1);
    }
    strcpy(copia, s);
    return copia;
}

static void erro_lexico(const char *msg) {
    printf("[ERRO LEXICO] Linha %d: %s\n", linha_atual, msg);
    erros_lexicos++;
}
%}

%option noyywrap
%option nounput
%option noinput
%option never-interactive

%x COMENTARIO

%%
"/*"                { linha_comentario = linha_atual; BEGIN(COMENTARIO); }
<COMENTARIO>"\n"    { linha_atual++; }
<COMENTARIO>"*/"    { BEGIN(INITIAL); }
<COMENTARIO>.       { }
<COMENTARIO><<EOF>> {
                        printf("[ERRO LEXICO] Linha %d: comentario aberto com /* e nunca fechado\n", linha_comentario);
                        erros_lexicos++;
                        BEGIN(INITIAL);
                        return FIM_ARQUIVO;
                    }

"sensor"            { TOKEN(SENSOR, "Palavra-chave"); }
"atuador"           { TOKEN(ATUADOR, "Palavra-chave"); }
"porta"             { TOKEN(PORTA, "Palavra-chave"); }
"analogico"         { TOKEN(ANALOGICO, "Palavra-chave"); }
"digital"           { TOKEN(DIGITAL, "Palavra-chave"); }
"se"                { TOKEN(SE, "Palavra-chave"); }
"entao"             { TOKEN(ENTAO, "Palavra-chave"); }
"senao"             { TOKEN(SENAO, "Palavra-chave"); }
"fim_se"            { TOKEN(FIM_SE, "Palavra-chave"); }
"enquanto"          { TOKEN(ENQUANTO, "Palavra-chave"); }
"fim_enquanto"      { TOKEN(FIM_ENQUANTO, "Palavra-chave"); }
"ler"               { TOKEN(LER, "Palavra-chave"); }
"escrever"          { TOKEN(ESCREVER, "Palavra-chave"); }

"+"                 { TOKEN(MAIS, "Operacao de soma"); }
"-"                 { TOKEN(MENOS, "Operacao de subtracao"); }
"*"                 { TOKEN(VEZES, "Operacao de multiplicacao"); }
"/"                 { TOKEN(DIVIDIDO, "Operacao de divisao"); }
"<"                 { TOKEN(MENOR, "Menor que"); }
"<="                { TOKEN(MENOR_IGUAL, "Menor ou igual"); }
">"                 { TOKEN(MAIOR, "Maior que"); }
">="                { TOKEN(MAIOR_IGUAL, "Maior ou igual"); }
"=="                { TOKEN(IGUAL, "Comparacao igual"); }
"!="                { TOKEN(DIFERENTE, "Comparacao diferente"); }
"<-"                { TOKEN(ATRIBUICAO, "Operador de atribuicao"); }
"."                 { TOKEN(PONTO, "Separador de comandos"); }
":"                 { TOKEN(DOIS_PONTOS, "Separador de tipo"); }
","                 { TOKEN(VIRGULA, "Separador de declaracoes"); }
"("                 { TOKEN(ABRE_PAR, "Abre parenteses"); }
")"                 { TOKEN(FECHA_PAR, "Fecha parenteses"); }

[0-9]+[a-zA-Z_][a-zA-Z0-9_]* {
                        char msg[256];
                        snprintf(msg, sizeof(msg), "identificador invalido '%s' (nao pode comecar com numero)", yytext);
                        erro_lexico(msg);
                        yylval.texto = copiar_texto(yytext + strspn(yytext, "0123456789"));
                        TOKEN(IDENTIFICADOR, "Identificador invalido");
                    }

[0-9]+              {
                        yylval.numero = atoi(yytext);
                        TOKEN(NUMERO, "Numero inteiro");
                    }
[a-zA-Z_][a-zA-Z0-9_]* {
                        yylval.texto = copiar_texto(yytext);
                        TOKEN(IDENTIFICADOR, "Identificador");
                    }

\n                  { linha_atual++; }
[ \t\r]+            { }

.                   {
                        char msg[64];
                        snprintf(msg, sizeof(msg), "simbolo desconhecido '%s'", yytext);
                        erro_lexico(msg);
                    }
<<EOF>>             {
                        if (mostrar_tokens)
                            printf("Token: %-30s | Valor: %-20s | Linha: %d\n", "Fim de arquivo", "FDA", linha_atual);
                        return FIM_ARQUIVO;
                    }

%%