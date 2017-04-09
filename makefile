CC = gcc

all: lex
	${CC} lex.yy.c -o scanner
debug: dlex
	${CC} lex.yy.c -o scanner
lex:
	lex scanner.l

dlex:
	lex -d scanner.l
