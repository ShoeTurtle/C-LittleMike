/*Little Mike Lexer*/
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "y.tab.h"
	
	extern YYSTYPE yylval;
	extern int yywrap(void);
	extern int yylineno;
%}

%%

[0-9]*    		{	yylval.intVal = atoi(yytext); return(NUMBER); }
"int"     		{	return(INTEGER);   }
":="      		{ 	return(ASSIGNOP);  }

"begin"		    {	return(_BEGIN);    }
"declare"  		{	return(_DECLARE);  }
"end"    		{	return(_END); 	   }

"read"    		{ 	return(READ);	   }
"write"   		{	return(WRITE);	   }

"while"   		{	return(WHILE);     }
"do"	  		{	return(DO);	       }
"done"    		{   return(DONE);	   }

"if"	  		{  return(IF);         }
"then"    		{  return(THEN);       }
"else"    		{  return(ELSE);       }
"fi"      		{  return(FI);         }

"skip"   		{  return(SKIP);       }

"<="      		{  return(LE_);        }
">="			{  return(GE_);		   }
"!="            {  return(NE_);        }

[a-z]+    		{  yylval.id = (char *) strdup(yytext); return(IDENTIFIER); }

[-()<>=+*/;{}.,]	{ return *yytext; }

[\n]		    {   yylineno++;        }
[ \t]

%%

int yywrap(void) {
	return 1;
}

