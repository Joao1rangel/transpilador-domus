
/*
 * tokens.h - codigos dos tokens da linguagem Domus
 * Cada token tem um numero unico. Comeca em 258 (padrao do Bison:
 * de 0 a 255 ficam reservados para caracteres soltos).
 */
#ifndef TOKENS_H
#define TOKENS_H

enum Token {
    FIM_ARQUIVO = 0,

    /* palavras-chave */
    SENSOR = 258, ATUADOR, PORTA, ANALOGICO, DIGITAL,
    SE, ENTAO, SENAO, FIM_SE, ENQUANTO, FIM_ENQUANTO,
    LER, ESCREVER,

    /* operadores */
    MAIS, MENOS, VEZES, DIVIDIDO,
    MENOR, MENOR_IGUAL, MAIOR, MAIOR_IGUAL, IGUAL, DIFERENTE,
    ATRIBUICAO,

    /* separadores */
    PONTO, DOIS_PONTOS, VIRGULA, ABRE_PAR, FECHA_PAR,

    /* numeros e nomes */
    NUMERO, IDENTIFICADOR
};

typedef union {
    int numero;
    char *texto;
} YYSTYPE;

extern YYSTYPE yylval;

#endif
