#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "tabela.h"
#include "gerador.h"

char *juntar(const char *formato, ...) {
    va_list args;
    int tamanho;
    char *texto;

    va_start(args, formato);
    tamanho = vsnprintf(NULL, 0, formato, args);
    va_end(args);

    texto = (char *) malloc(tamanho + 1);
    if (texto == NULL) {
        printf("Erro: memoria insuficiente\n");
        exit(1);
    }

    va_start(args, formato);
    vsnprintf(texto, tamanho + 1, formato, args);
    va_end(args);
    return texto;
}

char *indentar(const char *texto) {
    const char *p;
    int linhas = 0;
    char *saida, *q;

    for (p = texto; *p != '\0'; p++) {
        if (*p == '\n') {
            linhas++;
        }
    }

    saida = (char *) malloc(strlen(texto) + 4 * linhas + 5);
    if (saida == NULL) {
        printf("Erro: memoria insuficiente\n");
        exit(1);
    }

    q = saida;
    p = texto;
    while (*p != '\0') {
        strcpy(q, "    ");
        q += 4;
        while (*p != '\0' && *p != '\n') {
            *q++ = *p++;
        }
        if (*p == '\n') {
            *q++ = *p++;
        }
    }
    *q = '\0';
    return saida;
}

char *codigo_identificador(const char *nome) {
    Simbolo *s = ts_buscar(nome);
    if (s != NULL && s->categoria == CAT_SENSOR) {
        return juntar("ler_sensor(&%s, \"%s\", %d, %d)", s->nome, s->nome, s->porta, s->tipo == TIPO_DIGITAL);
    }
    return juntar("%s", nome);
}

char *codigo_atribuicao(const char *nome, const char *expressao) {
    Simbolo *s = ts_buscar(nome);
    if (s != NULL && s->categoria == CAT_ATUADOR) {
        return juntar("acionar_atuador(&%s, \"%s\", %d, %d, %s);\n", s->nome, s->nome, s->porta, s->tipo == TIPO_DIGITAL, expressao);
    }
    return juntar("%s = %s;\n", nome, expressao);
}

int gerar_arquivo(const char *nome_arquivo, const char *corpo) {
    FILE *saida = fopen(nome_arquivo, "w");
    Simbolo *s;
    char *corpo_main;

    if (saida == NULL) {
        printf("Erro: nao foi possivel criar o arquivo '%s'\n", nome_arquivo);
        return 0;
    }

    fprintf(saida, "#include <stdio.h>\n\n");

    for (s = ts_primeiro(); s != NULL; s = s->prox) {
        fprintf(saida, "int %s = 0;\n", s->nome);
    }

    fprintf(saida, "\n");
    fprintf(saida, "int ler_inteiro(const char *nome) {\n");
    fprintf(saida, "    int valor;\n");
    fprintf(saida, "    printf(\"Digite o valor de %%s: \", nome);\n");
    fprintf(saida, "    if (scanf(\"%%d\", &valor) != 1) {\n");
    fprintf(saida, "        valor = 0;\n");
    fprintf(saida, "    }\n");
    fprintf(saida, "    return valor;\n");
    fprintf(saida, "}\n\n");

    fprintf(saida, "int ler_sensor(int *sensor, const char *nome, int porta, int digital) {\n");
    fprintf(saida, "    int valor;\n");
    fprintf(saida, "    do {\n");
    fprintf(saida, "        printf(\"[sensor %%s | porta %%d] valor lido: \", nome, porta);\n");
    fprintf(saida, "        if (scanf(\"%%d\", &valor) != 1) {\n");
    fprintf(saida, "            valor = 0;\n");
    fprintf(saida, "        }\n");
    fprintf(saida, "        if (digital && valor != 0 && valor != 1) {\n");
    fprintf(saida, "            printf(\"Sensor digital: informe 0 ou 1.\\n\");\n");
    fprintf(saida, "        }\n");
    fprintf(saida, "    } while (digital && valor != 0 && valor != 1);\n");
    fprintf(saida, "    *sensor = valor;\n");
    fprintf(saida, "    return valor;\n");
    fprintf(saida, "}\n\n");

    fprintf(saida, "void acionar_atuador(int *atuador, const char *nome, int porta, int digital, int valor) {\n");
    fprintf(saida, "    if (digital && valor != 0 && valor != 1) {\n");
    fprintf(saida, "        printf(\"[aviso] atuador digital %%s recebeu %%d e foi ajustado para 1\\n\", nome, valor);\n");
    fprintf(saida, "        valor = 1;\n");
    fprintf(saida, "    }\n");
    fprintf(saida, "    *atuador = valor;\n");
    fprintf(saida, "    printf(\"[atuador %%s | porta %%d] <- %%d\\n\", nome, porta, valor);\n");
    fprintf(saida, "}\n\n");

    corpo_main = indentar(corpo);
    fprintf(saida, "int main(void) {\n");
    fprintf(saida, "%s", corpo_main);
    fprintf(saida, "    return 0;\n");
    fprintf(saida, "}\n");

    fclose(saida);
    return 1;
}