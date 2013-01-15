/*Little Mike Parser*/
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "SimTab.h"
	#include "CodeGen.h"
	
	extern void yyerror(char *);
	int errors = 0;
	extern int yylineno;
	char str[100];
	
	
	/*Checks if the identifier already exists if not //
	//enters the identifier into the symbol table */
	int into_symrec(char *sym_name) 
	{
		symrec *flg = NULL;
		flg = (symrec *) getsym(sym_name);
		if(flg != 0) {
			printf("%s -- Symbol Already Exists\n", flg->name);
		}
		else {
			putsym(sym_name);
		}
	}
	
	/*Function to check if the identifier has been declared//
	//if the entry is not found at the symbol table an //
	//error code is generate and notified */
	int to_codegen(enum operation op, char *sym_name)
	{
		symrec *symptr = NULL;
		symptr = (symrec *) getsym(sym_name);
		if(symptr == 0) {
			errors++;
			//printf("\n%s -- is undeclared\n", sym_name);
			strcpy(str, sym_name);
			strcat(str, " is undeclared");
			yyerror(str);
		}
		else {
			//step into code generation//
			return(codegen(op, symptr->offset));
		}
	}

%}


%union 
{
	int intVal;
	char *id;
	struct cslabel *lbl;
};

%start PROGRAM

%token  <intVal>  NUMBER 
%token  <id> 	  IDENTIFIER
%token  <lbl>     WHILE IF

%token ASSIGNOP
%token _DECLARE _BEGIN _END READ WRITE 
%token DO DONE INTEGER
%token FI THEN SKIP ELSE 



%nonassoc IFY


%left '=' NE_
%left '<' '>' LE_ GE_ 
%left '+' '-'
%left '*' '/'
%left '(' ')'
%nonassoc IFX

%%

PROGRAM :  _DECLARE 	//points out to the data section//
			    declaration_list { codegen(DATA, next_data_location() - 1); }
	       _BEGIN
				commands 
	       _END			         { codegen(HALT, 0); } //end of program//  

//| { _yyerror("Missing 'declare'", 0); } declaration _BEGIN commands _END

//| _DECLARE %prec declaration { _yyerror("Missing 'begin'", 0); } commands _END

//| _DECLARE declaration _BEGIN commands { _yyerror("Missing 'end'", 0); }  
;


declaration_list : dec_seq   declaration		
     ;

dec_seq:  /*empty*/
|  dec_seq   declaration		  
;


declaration: 
	INTEGER id_seq IDENTIFIER ';' { into_symrec($3); } 
| { yyerror("Undeclared Identifier"); } id_seq IDENTIFIER ';' 
| INTEGER id_seq IDENTIFIER { yyerror("Missing ';'"); }
;


id_seq: /*empty*/
| id_seq IDENTIFIER ',' 	    { into_symrec($2); }
;


commands: /*empty*/     
|  commands command ';' 
;

command: SKIP
|  READ IDENTIFIER	            { to_codegen(READ_INT, $2);          }
|  READ							{ yyerror("Identifier required to Read from"); }
|  WRITE						{ yyerror("Expression or Identifier required to Write into"); }

|  IDENTIFIER				    { strcpy(str, "Do you mean to read or write ");
								  strcat(str, $1);
								  strcat(str, " !!!");
								  yyerror(str);                                }

|  WRITE expr			        { codegen(WRITE_INT, 0);               } 


|  IDENTIFIER ASSIGNOP expr 	{ to_codegen(STORE, $1);               }
|  IDENTIFIER ASSIGNOP          { yyerror("R-VAl missing"); }
|  IDENTIFIER expr				{ yyerror("Missing ':=' assignment operator"); }
|  IDENTIFIER '=' expr			{ yyerror("Missing ':=' assignment operator"); }


|  WHILE              			{ $1 = (label *) gen_label(); 
				                  $1->jmp_true = codeoffset;         } 
	expr			            { $1->jmp_false = next_code_line();  } 
   DO 				
	commands 
   DONE  	                    { codegen(GOTO, $1->jmp_true); 
    			 				  fix_jmp(JMP_FALSE, $1->jmp_false); }			                                                     	

//|  WHILE expr commands DONE     { yyerror("Missing do"); }

|  ifstat
;


/*ifstat: IF '(' expr ')' THEN commands 	FI		 { fix_shiftA($3, codeoffset);     }										
| IF '(' expr ')' THEN commands ELSE commands FI     { fix_shiftB($3, $6, codeoffset); }
;*/

ifstat: IF expr     { $1 = (label *)gen_label(); $1->jmp_false = next_code_line(); }
	THEN
		   commands { $1->jmp_true = next_code_line(); fix_jmp(JMP_FALSE, $1->jmp_false);  }
	ELSE
		   commands { fix_jmp(GOTO, $1->jmp_true); }
	FI
;



expr: NUMBER			{ codegen(LOAD_INT, $1);    }
|  IDENTIFIER			{ to_codegen(LOAD_VAR, $1); }
|  expr '+' expr		{ codegen(ADD, 0); 			}
|  expr '-' expr		{ codegen(SUB, 0);          }
|  expr '*' expr		{ codegen(MULT, 0);         }
|  expr '/' expr		{ codegen(DIV, 0);          }
|  expr '>' expr		{ codegen(GT, 0);      		}
|  expr '<' expr		{ codegen(LT, 0);     		}
|  expr '=' expr		{ codegen(EQ, 0);      		}
|  expr LE_ expr        { codegen(LE, 0);      		}
|  expr GE_ expr        { codegen(GE, 0);			}
|  expr NE_ expr		{ codegen(NE, 0);			}
|  '(' expr ')'
;
	

%%

/*Main Execution Block*/
int main(int argc, char * argv[]) {
	extern FILE *yyin;
	yyin = fopen(argv[1], "r");
	yyparse();
	
	if(!errors) {
		//printf("\nNo Errors Encountered\n");
		printcode();
		printf("---------------------------------\n");
	}
	else {
		printf("\n--------------------------------\n");
		printf("---Check Errors And Recompile---\n");
		printf("--------------------------------\n");
	}
	//printf("Total Line No %d", yylineno);
	printf("\n\n");	
}


/*Error Reporting Block*/
void yyerror(char *error) {
	printf("yyerror[%d]: %s @ Line No - %d\n", ++errors, error, yylineno);
}
