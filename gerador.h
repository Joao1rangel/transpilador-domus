#ifndef GERADOR_H
#define GERADOR_H

char *juntar(const char *formato, ...);
char *indentar(const char *texto);
char *codigo_identificador(const char *nome);
char *codigo_atribuicao(const char *nome, const char *expressao);
int gerar_arquivo(const char *nome_arquivo, const char *corpo);

#endif 
