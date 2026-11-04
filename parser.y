%{
#include <stdio.h>

int yylex(void);
void yyerror(const char *msg);
%}

%token FIM_ARQUIVO 0 "fim do arquivo"
%token SENSOR "sensor" ATUADOR "atuador" PORTA "porta"
%token ANALOGICO "analogico" DIGITAL "digital"
%token SE "se" ENTAO "entao" SENAO "senao" FIM_SE "fim_se"
%token ENQUANTO "enquanto" FIM_ENQUANTO "fim_enquanto"
%token LER "ler" ESCREVER "escrever"
%token MAIS "+" MENOS "-" VEZES "*" DIVIDIDO "/"
%token MENOR "<" MENOR_IGUAL "<=" MAIOR ">" MAIOR_IGUAL ">=" IGUAL "==" DIFERENTE "!="
%token ATRIBUICAO "<-"
%token PONTO "." DOIS_PONTOS ":" VIRGULA "," ABRE_PAR "(" FECHA_PAR ")"
%token NUMERO "numero" IDENTIFICADOR "identificador"

%start programa

%%

programa
    : declaracao_lista bloco
    | bloco
    ;

declaracao_lista
    : declaracao_lista declaracao
    | declaracao
    ;

declaracao
    : declaracao_sensor
    | declaracao_atuador
    ;

declaracao_sensor
    : SENSOR lista_sensores PONTO
    ;

lista_sensores
    : lista_sensores VIRGULA sensor
    | sensor
    ;

sensor
    : IDENTIFICADOR DOIS_PONTOS tipo_sensor_atuador ABRE_PAR PORTA NUMERO FECHA_PAR
    ;

tipo_sensor_atuador
    : ANALOGICO
    | DIGITAL
    ;

declaracao_atuador
    : ATUADOR lista_atuadores PONTO
    ;

lista_atuadores
    : lista_atuadores VIRGULA atuador
    | atuador
    ;

atuador
    : IDENTIFICADOR DOIS_PONTOS tipo_sensor_atuador ABRE_PAR PORTA NUMERO FECHA_PAR
    ;

bloco
    : bloco comando PONTO
    | comando PONTO
    ;

comando
    : comando_se
    | comando_enquanto
    | comando_atribuicao
    | comando_leitura
    | comando_escrita
    ;

comando_se
    : SE expressao_logica ENTAO bloco FIM_SE
    | SE expressao_logica ENTAO bloco SENAO bloco FIM_SE
    ;

comando_enquanto
    : ENQUANTO ABRE_PAR expressao_logica FECHA_PAR bloco FIM_ENQUANTO
    ;

comando_atribuicao
    : IDENTIFICADOR ATRIBUICAO expressao
    ;

comando_leitura
    : LER ABRE_PAR IDENTIFICADOR FECHA_PAR
    ;

comando_escrita
    : ESCREVER ABRE_PAR expressao FECHA_PAR
    ;

expressao_logica
    : ABRE_PAR expressao_logica FECHA_PAR
    | expressao op_relacional expressao
    ;

op_relacional
    : MENOR
    | MENOR_IGUAL
    | MAIOR
    | MAIOR_IGUAL
    | IGUAL
    | DIFERENTE
    ;

expressao
    : expressao soma termo
    | termo
    ;

soma
    : MAIS
    | MENOS
    ;

termo
    : termo multi fator
    | fator
    ;

multi
    : VEZES
    | DIVIDIDO
    ;

fator
    : ABRE_PAR expressao FECHA_PAR
    | IDENTIFICADOR
    | NUMERO
    ;


%{
#include <stdio.h>
#include <string.h>

int yylex(void);
void yyerror(const char *msg);

extern FILE *yyin;
extern int mostrar_tokens;
extern int erros_lexicos;

int erros_sintaticos = 0;
%}

%union {
    int numero;
    char *texto;
}

%locations
%define parse.error verbose

%token FIM_ARQUIVO 0 "fim do arquivo"
%token SENSOR "sensor" ATUADOR "atuador" PORTA "porta"
%token ANALOGICO "analogico" DIGITAL "digital"
%token SE "se" ENTAO "entao" SENAO "senao" FIM_SE "fim_se"
%token ENQUANTO "enquanto" FIM_ENQUANTO "fim_enquanto"
%token LER "ler" ESCREVER "escrever"
%token MAIS "+" MENOS "-" VEZES "*" DIVIDIDO "/"
%token MENOR "<" MENOR_IGUAL "<=" MAIOR ">" MAIOR_IGUAL ">=" IGUAL "==" DIFERENTE "!="
%token ATRIBUICAO "<-"
%token PONTO "." DOIS_PONTOS ":" VIRGULA "," ABRE_PAR "(" FECHA_PAR ")"
%token <numero> NUMERO "numero"
%token <texto> IDENTIFICADOR "identificador"

%start programa

%%

programa
    : declaracao_lista bloco
    | bloco
    ;

declaracao_lista
    : declaracao_lista declaracao
    | declaracao
    ;

declaracao
    : declaracao_sensor
    | declaracao_atuador
    ;

declaracao_sensor
    : SENSOR lista_sensores PONTO
    ;

lista_sensores
    : lista_sensores VIRGULA sensor
    | sensor
    ;

sensor
    : IDENTIFICADOR DOIS_PONTOS tipo_sensor_atuador ABRE_PAR PORTA NUMERO FECHA_PAR
    ;

tipo_sensor_atuador
    : ANALOGICO
    | DIGITAL
    ;

declaracao_atuador
    : ATUADOR lista_atuadores PONTO
    ;

lista_atuadores
    : lista_atuadores VIRGULA atuador
    | atuador
    ;

atuador
    : IDENTIFICADOR DOIS_PONTOS tipo_sensor_atuador ABRE_PAR PORTA NUMERO FECHA_PAR
    ;

bloco
    : bloco comando PONTO
    | comando PONTO
    ;

comando
    : comando_se
    | comando_enquanto
    | comando_atribuicao
    | comando_leitura
    | comando_escrita
    ;

comando_se
    : SE expressao_logica ENTAO bloco FIM_SE
    | SE expressao_logica ENTAO bloco SENAO bloco FIM_SE
    ;

comando_enquanto
    : ENQUANTO ABRE_PAR expressao_logica FECHA_PAR bloco FIM_ENQUANTO
    ;

comando_atribuicao
    : IDENTIFICADOR ATRIBUICAO expressao
    ;

comando_leitura
    : LER ABRE_PAR IDENTIFICADOR FECHA_PAR
    ;

comando_escrita
    : ESCREVER ABRE_PAR expressao FECHA_PAR
    ;

expressao_logica
    : ABRE_PAR expressao_logica FECHA_PAR
    | expressao op_relacional expressao
    ;

op_relacional
    : MENOR
    | MENOR_IGUAL
    | MAIOR
    | MAIOR_IGUAL
    | IGUAL
    | DIFERENTE
    ;

expressao
    : expressao soma termo
    | termo
    ;

soma
    : MAIS
    | MENOS
    ;

termo
    : termo multi fator
    | fator
    ;

multi
    : VEZES
    | DIVIDIDO
    ;

fator
    : ABRE_PAR expressao FECHA_PAR
    | IDENTIFICADOR
    | NUMERO
    ;

%%

void yyerror(const char *msg) {
    const char *p = msg;
    erros_sintaticos++;
    printf("[ERRO SINTATICO] Linha %d: ", yylloc.first_line);
    if (strncmp(p, "syntax error", 12) == 0) {
        p += 12;
    }
    if (strncmp(p, ", unexpected ", 13) == 0) {
        p += 13;
        printf("encontrado ");
    } else if (*p == '\0') {
        printf("erro de sintaxe");
    }
    while (*p != '\0') {
        if (strncmp(p, ", expecting ", 12) == 0) {
            printf(", mas era esperado ");
            p += 12;
        } else if (strncmp(p, " or ", 4) == 0) {
            printf(" ou ");
            p += 4;
        } else {
            putchar(*p);
            p++;
        }
    }
    printf("\n");
}

%%
