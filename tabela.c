#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h"

static Simbolo *inicio = NULL;
static Simbolo *fim = NULL;

Simbolo *ts_buscar(const char *nome) {
    Simbolo *s;
    for (s = inicio; s != NULL; s = s->prox) {
        if (strcmp(s->nome, nome) == 0) {
            return s;
        }
    }
    return NULL;
}

Simbolo *ts_inserir(const char *nome, Categoria categoria, Tipo tipo, int porta, int linha) {
    Simbolo *s = (Simbolo *) malloc(sizeof(Simbolo));
    if (s == NULL) {
        printf("Erro: memoria insuficiente\n");
        exit(1);
    }
    s->nome = (char *) malloc(strlen(nome) + 1);
    if (s->nome == NULL) {
        printf("Erro: memoria insuficiente\n");
        exit(1);
    }
    strcpy(s->nome, nome);
    s->categoria = categoria;
    s->tipo = tipo;
    s->porta = porta;
    s->linha = linha;
    s->prox = NULL;

    if (fim == NULL) {
        inicio = s;
    } else {
        fim->prox = s;
    }
    fim = s;
    return s;
}

static const char *nome_categoria(Categoria c) {
    if (c == CAT_SENSOR) return "sensor";
    if (c == CAT_ATUADOR) return "atuador";
    return "variavel";
}

static const char *nome_tipo(Tipo t) {
    if (t == TIPO_ANALOGICO) return "analogico";
    if (t == TIPO_DIGITAL) return "digital";
    return "inteiro";
}

void ts_imprimir(void) {
    Simbolo *s;
    int n = 0;

    printf("\nTABELA DE SIMBOLOS\n");
    printf("---------------------------------------------------------------\n");
    printf("| %-3s | %-20s | %-9s | %-9s | %-5s | %-5s |\n",
           "#", "Identificador", "Categoria", "Tipo", "Porta", "Linha");
    printf("---------------------------------------------------------------\n");

    for (s = inicio; s != NULL; s = s->prox) {
        n++;
        if (s->categoria == CAT_VARIAVEL) {
            printf("| %-3d | %-20s | %-9s | %-9s | %-5s | %-5d |\n",
                   n, s->nome, nome_categoria(s->categoria), nome_tipo(s->tipo), "-", s->linha);
        } else {
            printf("| %-3d | %-20s | %-9s | %-9s | %-5d | %-5d |\n",
                   n, s->nome, nome_categoria(s->categoria), nome_tipo(s->tipo), s->porta, s->linha);
        }
    }
    if (n == 0) {
        printf("| %-66s |\n", "(tabela vazia)");
    }
    printf("---------------------------------------------------------------\n");
    printf("Total de simbolos: %d\n", n);
}