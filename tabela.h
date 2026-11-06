#ifndef TABELA_H
#define TABELA_H

typedef enum {
    CAT_SENSOR,
    CAT_ATUADOR,
    CAT_VARIAVEL
} Categoria;

typedef enum {
    TIPO_ANALOGICO,
    TIPO_DIGITAL,
    TIPO_INTEIRO
} Tipo;

typedef struct Simbolo {
    char *nome;
    Categoria categoria;
    Tipo tipo;
    int porta;
    int linha;
    struct Simbolo *prox;
} Simbolo;

Simbolo *ts_buscar(const char *nome);
Simbolo *ts_buscar_porta(int porta);
Simbolo *ts_inserir(const char *nome, Categoria categoria, Tipo tipo, int porta, int linha);
Simbolo *ts_primeiro(void);
void ts_imprimir(void);

#endif