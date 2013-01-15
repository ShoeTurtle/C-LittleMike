#LEX = flex -I
#YACC = bison

CC = cc 

CLM: lex.yy.c y.tab.h y.tab.c
	$(CC) -o CLM lex.yy.c y.tab.c -ly -ll  

y.tab.c y.tab.h: Mike.y
	$(YACC) -dv Mike.y

lex.yy.c: Mike.l y.tab.h
	$(LEX) Mike.l
