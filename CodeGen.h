/*Code Generator File*/

enum operation { HALT, DATA, READ_INT, WRITE_INT, LOAD_VAR, LOAD_INT, STORE, ADD, MULT, DIV, SUB, GT, LT, EQ, GOTO, JMP_FALSE, JMP_TRUE, JMP, LE, NE, GE };

char *codeop[] = { "halt", "data_block", "in_int", "out_ac", "ld_var", "ld_int", "store", "add", "mult", "div", "sub", "gt", "lt", "eq", "goto", "jmp_false", "jmp_true", "jmp", "le", "ne", "ge" };

/*Code Line Generator for the code sheet*/
int codeoffset = 0;

int current_code_line() {
	return codeoffset;
}

int next_code_line() {
	return codeoffset++;
}


/*Label Generation*/
struct cslabel {
	int jmp_true;
	int jmp_false;
};
typedef struct cslabel label;

label * gen_label() {
	label *ptr;
	ptr = (label *) malloc(sizeof(label));
	return ptr;
}
	

/*Code Sheet Table*/
struct codesheet {
	enum operation inst;
	int data_pos;
};

struct codesheet code[999];

/*Filling the code sheet table*/
int codegen(enum operation op, int arg) {
	code[codeoffset].inst = op;
	code[codeoffset].data_pos = arg;
	codeoffset++;
	return codeoffset;
}


/*Fix Jump Position*/
void fix_jmp(enum operation op, int arg) {
	code[arg].inst = op;
	code[arg].data_pos = codeoffset;
}


/*Prints the instruction from the code sheet table*/
void printcode() {
	int i = 0;

	printf("\n|-------------------------------|");
	printf("\n|-------INTERMIDEATE CODE-------|\n");
	printf("|-------------------------------|\n");
	printf("|                               |\n");
	while(i < codeoffset) {
		printf("|   %-4d:  %-14s %-4d  |\n", i, codeop[(int)code[i].inst], code[i].data_pos);
		i++;
	}
}


/*Fixing conditional jump for single IF*/
void fix_shiftA(int xpos, int ypos) {
	int i;
	codeoffset++;
	
	for(i = ypos; i >= xpos; i--) {
		code[i+1].inst = code[i].inst;
		code[i+1].data_pos = code[i].data_pos;
	}	
		
	code[xpos].inst = JMP_FALSE;
	code[xpos].data_pos = ypos + 1;
}


/*Fixing conditional jump for IF ELSE*/
void fix_shiftB(int xpos, int ypos, int zpos) {
	int i;
	codeoffset+=2;
	
	for(i = zpos; i >= xpos; i--) {
		code[i+1].inst = code[i].inst;
		code[i+1].data_pos = code[i].data_pos;
	}
	
	code[xpos].inst = JMP_FALSE;
	code[xpos].data_pos = ypos + 2;
	
	for(i = zpos+1; i >= ypos+1; i--) {
		code[i+1].inst = code[i].inst;
		code[i+1].data_pos = code[i].data_pos;
	}
	
	code[ypos+1].inst = JMP;
	code[ypos+1].data_pos = zpos + 2;
}




