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
