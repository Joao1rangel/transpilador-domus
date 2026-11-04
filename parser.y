
%{
#include <stdio.h>
#include <string.h>
#include "tabela.h"

int yylex(void);
void yyerror(const char *msg);

extern FILE *yyin;
extern int mostrar_tokens;
extern int erros_lexicos;

int erros_sintaticos = 0;
int erros_semanticos = 0;

static const char *nome_categoria(Categoria c) {
    if (c == CAT_SENSOR) return "sensor";
    if (c == CAT_ATUADOR) return "atuador";
    return "variavel";
}

static void declarar(const char *nome, Categoria categoria, Tipo tipo, int porta, int linha) {
    Simbolo *s = ts_buscar(nome);
    if (s != NULL) {
        printf("[ERRO SEMANTICO] Linha %d: '%s' ja foi declarado na linha %d como %s\n",
               linha, nome, s->linha, nome_categoria(s->categoria));
        erros_semanticos++;
        return;
    }
    s = ts_buscar_porta(porta);
    if (s != NULL) {
        printf("[ERRO SEMANTICO] Linha %d: a porta %d ja esta sendo usada pelo %s '%s'\n",
               linha, porta, nome_categoria(s->categoria), s->nome);
        erros_semanticos++;
    }
    ts_inserir(nome, categoria, tipo, porta, linha);
}

static void atribuir(const char *nome, int linha) {
    Simbolo *s = ts_buscar(nome);
    if (s == NULL) {
        ts_inserir(nome, CAT_VARIAVEL, TIPO_INTEIRO, -1, linha);
    } else if (s->categoria == CAT_SENSOR) {
        printf("[ERRO SEMANTICO] Linha %d: o sensor '%s' nao pode receber valor (sensor e somente leitura)\n",
               linha, nome);
        erros_semanticos++;
    }
}

static void usar(const char *nome, int linha) {
    Simbolo *s = ts_buscar(nome);
    if (s == NULL) {
        printf("[ERRO SEMANTICO] Linha %d: '%s' foi usado sem ter recebido valor antes\n",
               linha, nome);
        erros_semanticos++;
    } else if (s->categoria == CAT_ATUADOR) {
        printf("[ERRO SEMANTICO] Linha %d: o atuador '%s' nao pode ser lido (atuador e somente escrita)\n",
               linha, nome);
        erros_semanticos++;
    }
}
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

%type <numero> tipo_sensor_atuador

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
        { declarar($1, CAT_SENSOR, $3, $6, @1.first_line); }
    ;

tipo_sensor_atuador
    : ANALOGICO { $$ = TIPO_ANALOGICO; }
    | DIGITAL   { $$ = TIPO_DIGITAL; }
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
        { declarar($1, CAT_ATUADOR, $3, $6, @1.first_line); }
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
        { atribuir($1, @1.first_line); }
    ;

comando_leitura
    : LER ABRE_PAR IDENTIFICADOR FECHA_PAR
        { atribuir($3, @3.first_line); }
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
    | IDENTIFICADOR { usar($1, @1.first_line); }
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
int main(int argc, char **argv) {
    const char *nome_arquivo = "testes/ExemploDomus.txt";
    FILE *arquivo;
    int i, resultado;

    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-t") == 0) {
            mostrar_tokens = 1;
        } else {
            nome_arquivo = argv[i];
        }
    }

    arquivo = fopen(nome_arquivo, "r");
    if (!arquivo) {
        printf("Erro: nao foi possivel abrir o arquivo '%s'\n", nome_arquivo);
        printf("Uso: %s [-t] arquivo_domus.txt\n", argv[0]);
        return 1;
    }

    yyin = arquivo;

    printf("Transpilador Domus\n");
    printf("Arquivo: %s\n\n", nome_arquivo);

    resultado = yyparse();
    fclose(arquivo);

    ts_imprimir();

    printf("\nErros lexicos: %d\n", erros_lexicos);
    printf("Erros sintaticos: %d\n", erros_sintaticos);
    printf("Erros semanticos: %d\n", erros_semanticos);

    if (resultado == 0 && erros_lexicos == 0 && erros_semanticos == 0) {
        printf("Analise concluida: o programa esta correto.\n");
        return 0;
    }
    printf("Analise NAO concluida: o programa tem erros.\n");
    return 1;
}
