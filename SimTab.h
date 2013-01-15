/*Symbol Table Entry*/

struct symtable {
	char *name;
	int offset;
	struct symtable *symlink;
};

typedef struct symtable symrec;
int dataoffset = 0;

int next_data_location() {
	return dataoffset++;
}

symrec *currentNode = (symrec *)0;


/*creates a new node and adds it to the existing sym chain*/
symrec* putsym(char *sym_name) {
	symrec * newNode;
	newNode = (symrec *) malloc(sizeof(symrec));
	newNode->name = (char *) malloc(sizeof(sym_name) + 1);
	strcpy(newNode->name, sym_name);
	newNode->offset = next_data_location();
	newNode->symlink = (symrec *) currentNode;
	currentNode = newNode;
}


/*Returns the pointer of the matching entry*/
symrec* getsym(char *sym_name) {
	symrec *tmp;
	tmp = currentNode;	
	while(tmp) {
		if(strcmp(tmp->name, sym_name) == 0)
			return(tmp);
		tmp = tmp->symlink;
	}
	return 0;
}


/*printing the symbol table entries*/
void printsymrec() {
	symrec *tmp;
	tmp = currentNode;

	while(tmp) {
		printf("%s -- %d\n", tmp->name, tmp->offset);
		tmp = tmp->symlink;
	}
}
