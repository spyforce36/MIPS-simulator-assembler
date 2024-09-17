#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// a like can have 500 chars according to instructions
#define MAX_LINE 500
#define MAX_ROW_LENGTH 500
#define MAX_NUM_ROWS_MEMORY 4096
#define ROW_LENGTH_MEMORY 5
#define MAX_LABEL_LENGTH 50
#define SIGNEX(v, sb) ((v) | (((v) & (1 << (sb))) ? ~((1 << (sb))-1) : 0))
#define SIGNBIT_LOC 19

int max(int a, int b)
{
	if (a>b)
		return a;
	return b;
}

// first part - utility

// Label struct and related functions

// the label linked list will help us store info about the labels. it will be built at the first iteration and used and the second. then destroyed
typedef struct Label
{
    // name will store the name of the label
    char name[50];
    // location will store the line number and will be the immediate value in related jump and branch commands
    int location;
    // a pointer to the next label
    struct Label* next;
} label;

// this function creates a label from the given name and location
label* create_label(char name[50], int location)
{
    // allocate memory for the label and create a pointer to it
    label* new_label = (label*)malloc(sizeof(label));
    // if allocation successful. insert data to label
    if (new_label != NULL) {
        // use strcpy to insert a string
        strcpy(new_label->name,name);
        // the other insertions are easy
        new_label->location = location;
        new_label->next = NULL;
    }
    return new_label;
}

// adds a label to the front of an existing label list with given name and location.
// will be used in the first iteration
label* add(label* head, char name[50], int location) {
    // build the label and check for success. otherwise return a null
    label* new_label = create_label(name, location);    if (new_label == NULL)
        return NULL;
    // the next pointer will point to the original head
    new_label->next = head;
    return new_label;
}
// this will scan the label list "head" and look for "name". it will return it's location.
// this will be used in the second iteration
int find(label* head, char name[50]) {
    // current - the current label's name
    char current[50];
    // start with the head
	if (head==NULL)
		return -1;
    strcpy(current, head->name);
    // strcmp returns 0 if names are equal
    while (strcmp(current, name) != 0) {
        // go to next label
        head = head->next;
        // in case not found - return -1
        if (head == NULL) {
            return -1;
        }
        // update name to current name
        strcpy(current, head->name);
    }
    // return the current's location
    return head->location;
}

// destroys the list and frees the memory
void destroy(label* head)
{
    // temp - a pointer to a label we are going to destroy after updating head
    label* temp;
    // all the way to the end
    while (head != NULL)
    {
        // temp gets the current node while head advances
        temp = head;
        head = head->next;
        // we destroy temp and free the memory
        free(temp);
    }
}

// MemoryLine struct and related functions

// this struct will be used to save the memory lines
typedef struct MemoryLine {
    // the opcode of the command
    char opcode[6];
    // the registers
    char rd[6];
    char rs[6];
    char rt[6];
    // immediate value
    char imm[50];
    // position of character in line
    int pos;
	// is_I_command
	int is_I_command;
    // memory will also be a linked list to support infinite length programs
    struct MemoryLine* next;
}MemoryLine;

// creates new memory line with no "next"
MemoryLine* create_line(char opcode[6], char rd[6], char rs[6], char rt[6], char imm[50], int is_I_command, int pos) {
    // allocate memory for the label and create a pointer to it
    MemoryLine* new_line  = (MemoryLine*)malloc(sizeof(MemoryLine));
    // if allocation successful. insert data to label
    if (new_line != NULL) {
        // use strcpy to insert the strings
        strcpy(new_line->opcode, opcode);
        strcpy(new_line->rd, rd);
        strcpy(new_line->rs, rs);
        strcpy(new_line->rt, rt);
        strcpy(new_line->imm, imm);
        new_line->is_I_command = is_I_command;
        new_line->pos = pos;
        // no next defined
        new_line->next = NULL;
    }
    return new_line;
}

// adds line to memory structure. this line will be added to the end to let the writing run it like an array
MemoryLine* add_line(MemoryLine* head, char opcode[6], char rd[6], char rs[6], char rt[6], char imm[50], int is_I_command, int pos)
{
    // the last line as for now
    MemoryLine* tail;
    // create a line
    MemoryLine* new_line = create_line(opcode, rd, rs, rt, imm, is_I_command, pos);
    // if the new line is null. do nothing
    if (new_line == NULL)
        return NULL;
    // and return the current if no head supplied
    if (head == NULL)
        return new_line;
    // get the "tail" to the end of the list
    tail = head;
    while (tail->next != NULL)
        tail = tail->next;
    // add the new line
    tail->next = new_line;
    // return updated memory
    return head;
}

// destroy the memory line list and free the memory the assembler used
void destroy_memLine(MemoryLine* head) {
    // temp - a pointer to a line we are going to destroy after updating head
	MemoryLine* temp;
    // all the way to the end
    while (head != NULL)
    {
        // temp gets the current node while head advances
        temp = head;
        head = head->next;
        // we destroy temp and free the memory
        free(temp);
    }
}

// get the memory line at position. can return null if does not exist
MemoryLine* getAtPos(MemoryLine* head, int pos) {
    // go until you find
    while (head != NULL && head->pos != pos)
        head = head->next;    return head;
}

// Memory struct and related functions. it is used so the second iteration can return two values.
typedef struct Memory
{
    // head of memory line list
    MemoryLine* head;
    // position of last
    int last;
}Memory;

//create memory structure
Memory* create_mem(MemoryLine* head, int pos1)
{
	Memory* mem = (Memory*)malloc(sizeof(Memory));
	mem->head = head;
	mem->last = pos1;
	return(mem); //Return number of lines
}

// destroys the memory struct after use
void destroy_mem(Memory* mem) {
    // destroy the memory's line list
    destroy_memLine(mem->head);
    // free the memory object's own memory
    free(mem);
}

// part 2 - the iterations over the files
size_t is_in_char_list( char* char_list, size_t num_chars, char check )
{
    size_t ind;
    for (ind = 0; ind < num_chars; ind ++)
    {
        if (char_list[ind] == check)
        {
            return 1;
        }
    }
    return 0;
}

char* remove_chars(char str[], size_t str_length, char* chars_to_remove, size_t num_remove_chars)
{
    char line[MAX_ROW_LENGTH] = {'\0'};
    size_t ind = 0, ind_new_line = 0;
    size_t is_remove_char = 0; 

    for (ind = 0; ind < str_length; ind ++)
    {
       if (is_in_char_list( chars_to_remove, num_remove_chars, str[ind] ) == 0)
       {
            line[ind_new_line] = str[ind];
            ind_new_line++ ;
       } 

    }
	memcpy_s(str, str_length, line, ind );
    return str;
}


// the code of the first iteration. goes trough the file row by row and looks for labels, then adds them to the label list
label* createLabelList(FILE *asembl) {
    // rowIndex-the code row's index. where the PC will go after reading the label
	// k is the char index for label name read, j is the index in the label name string we are building, only_label_line is determining if it's a label only line or a label + command line
	// counter will be the line number in the new hexadecimal code. it will go up when a line that gets translated is found
    int rowIndex = 0, k, j, only_label_line, counter = 0;
    // line the current line being read, tav1 is the first char and i used to check for remarks, // tav - current char when reading label name
	// label_line will contain the name of the label once iteration is complete, dots are used to say "this is a label"
	char line[MAX_LINE], tav1 ,tav, lable_line[50], dots[50];
    strcpy(dots, ":");
    label* head = NULL;  // the label list's head
    // go all the way trough the file
    while (!feof(asembl)) {
        fgets(line, MAX_LINE, asembl);  // read a command from the assembler file
        if (strstr(line, ".word") != NULL) continue;  //If line is .word, continue
		remove_chars(line, strlen(line), "\t ", 2);

        only_label_line = 0;  // reset only_label_line
        if (strcmp(line, "\n") == 0) continue;  //If line is blank, continue
        tav1 = line[0];
        if (tav1 == '#') continue;  //If line is Remark, continue
        if (strstr(line, dots) != NULL)  //If dots are found, this is a label
        {
            if (strstr(line, "#") != NULL) // however, ":" can be in a remark. so check for that as well, if so go to another line
                if ((strstr(line, dots)) > (strstr(line, "#"))) continue;
            k = 0; j = 0;  //Read the label name, first reset indexes
            do {
                tav = line[k];  // get current char
                // two dots is where it ends so skip
                if (tav != ':') {
                    if (tav != '\t' && tav != ' ')   // don't read tabs and spaces
                        { 
                            lable_line[j] = tav;  // grab the read char and put it in name string
                            j++;                            // increment name string index
                        }
                    k++;                    // increment reading index
                }
            } while (tav != ':');
            lable_line[j] = '\0';              // label name is null terminated
            k++;   // Check if the line is lable line only by seeing if there are only spaces and tabs till the end
            while ((line[k] == ' ') || (line[k] == '\t'))  k++;
			only_label_line = ((line[k] == '\n') || (line[k] == '#'));  // only_label_line is 1 on label only line, otherwise 0
            head = add(head, lable_line, counter);   // finally we add the label to label list
        }
        k = 0; // Check if the current line is space line using k - most commands in fib.asm and our files start with a tab or a space
        if ((line[k] == '\t') || (line[k] == ' '))  k++;
        if (line[k] == '\n')  continue;
        if (only_label_line == 1) continue;  // Only label line - do not change counter
        if (strstr(line, "$imm") != NULL)
        {
            counter = counter + 2; // I command
        }
        else
        {
            counter++;  // increment hexa file line counter
        }

    }
    return head;   // return the list
}

//helpful functions for the second iterations

// specialworld - uses .word commands to save in memory
// head - memory line list
// line - current line being read as a string
// pos1 - final line index
// k - index of character being read
// returns updated memory line list
MemoryLine *specialword(MemoryLine* head, char line[MAX_LINE], int *pos1, int *k) {
	char wordP[15], wordN[15]; // wordP - address, wordN - data
	int j = 0; // index for string we copy to
	int pos = 0; // pos - current line address, can be hexadecimal or decimal
	char nono[6] = "NONO"; // a string used to copy nono to required places. fifth char is null

	*k = 0;             // reset k index
	while (line[*k] != ' ') *k=*k+1;            // go past all the spaces
	*k = *k + 1;
	j = 0; //Copy Address. first reset j then copy char char until the next space
	while (line[*k] != ' ') {
		wordP[j] = line[*k];
		j = j + 1; *k = *k + 1;
	}
	wordP[j] = '\0'; *k = *k + 1;  // terminate string with null and increment end to next char
	j = 0; //Copy Data. using the same way.
	while (line[*k] != ' ') {
		if (line[*k] == '\n') break;// but detect an end of line string because after the data there can be a line end
		wordN[j] = line[*k];
		j = j + 1; *k = *k + 1;
	}
	wordN[j] = '\0';
	if (wordP[0] == '0') { //  change Address int. the if block considers an hexadecimal input
		if (wordP[1] == 'x' || wordP[1] == 'X') pos = strtol(wordP, NULL, 16);
	}
	else pos = atoi(wordP); // and the else blocks considers a decimal input
	pos = SIGNEX(pos, SIGNBIT_LOC);
	// now. we will save the command in the memory list. NONO will be used as an indicator when writing to turn the command into a .word
	strcpy(nono, "NONO"); 
	head = add_line(head, nono, nono, nono, nono, wordN, 0, pos);  // save line to line list. wordN - the immediate value, is used as the data
	if (pos > *pos1) *pos1 = pos;  // update the location of the end of the memory
	return head;
}
// reads opcode.
// line - line being read
// option - a string we copy the opcode to
// k - index in line being read
void readorder(char line[MAX_LINE], char *option, int *k){

	char tav; // current read char at index k
	int j = 0; // index of copied char
	do { // reading opcode should continue till dollar of first register
		tav = line[*k]; // read current
		if (tav != '$') // if it's not dollar
		{
			if (tav != '\t') // or whitespace
				if (tav != ' ')
				{
					option[j] = tav; // copy
					j = j + 1;
				}
			*k = *k + 1;
		}
	} while (tav != '$');
	option[j] = '\0'; // null terminate the opcode
}
// reads dollar sign in front of register name
// line - line being read
// k - current index
void readdollar(char line[MAX_LINE],int *k){
	while (line[*k] != '$') *k = *k + 1; // simply make your way to the dollar then stop
}
// reads register value
// line - current line being read
// rdst - register name. named so because it can be used for rd, rs or rt
void readrdst(char line[MAX_LINE], char *rdst, int *k){
	int j = 0; // Read rd
	while (line[*k] != ',')
	{
		if (line[*k] != ' ' && line[*k] != '\t') { // read if not a whitespace
			rdst[j] = line[*k];
			j=j+1;
		}
		*k=*k+1;
	}
	rdst[j] = '\0';// null terminate
}
// reads immediate value
// line - assembly line being read
// imm - pointer of string we copy to
// k - current line index
void readimmd(char line[MAX_LINE], char *imm, int *k){
	// go to immediate
	while ((line[*k] == ' ') || (line[*k] == '\t') || (line[*k] == ',')) {
		*k = *k + 1;
	}
	int j = 0; // index of char being copied in immediate string
	while (line[*k] != ' ')
	{
		if (line[*k] != ' ' && line[*k] != '\t') {
			if ((line[*k] == '\t') || (line[*k] == '#') || (line[*k] == '\n'))	break;
			imm[j] = line[*k];
			j=j+1;
		}
		*k=*k+1;
	}
	imm[j] = '\0';
}

// reads line of memory and adds to memory line list "head
// line - what we read
// pos1 - number of last line of memin
// i - current instruction line index. might be more than pos1. is processed as we go so that's why a pointer
// head - the memory line list we add to
// k - index of char being read. is processed as we go so that's why a pointer
MemoryLine *readLine(char *line, int *pos1, int *i, MemoryLine *head, int *k) {
	char option[6], rd[6], rs[6], rt[6], imm[50]; // the line's properties
	int is_I_command = strstr(line, "$imm") != NULL; 

	readorder(line, option, k);					// read the opcode
	readrdst(line, rd, k);                       // Read rd
	readdollar(line, k);                           // wait for dollar sign
	readrdst(line, rs, k);                    // Read rs
	readdollar(line, k);                           // wait for dollar sign
	readrdst(line, rt, k);                    // Read rt
	readimmd(line, imm, k);                 //handle immediate

	head = add_line(head, option, rd, rs, rt, imm, is_I_command, *i);	*i = *i + 1;					// save line to line list
	if (*i > *pos1) *pos1 = *i;  //Update last line position
	return head;
}

// the second iteration - reads each line on the memory and 
// copies it to memory list
// FILE - assembly file being read
Memory* SecondRun(FILE* file) {
    // k - the index of the current char being read, i - the current position in the file
	// pos1 - the last line of the memory file, pos - the address in .word commands, as an int
    int k = 0, i = 0, pos1 = 0, last = 0, num_rows = 0;
	// char - line will house the current line. tav1 will save the first character of the line and option, rd, rs, rt and are the command's values
	// dots - used to detect labels. because something might be past them
	char *comment_char;
	char line[MAX_LINE], tav1, * dots = ":";
    MemoryLine* head = NULL;  // the Memory list's head. it will contain info about each memory line in the end
    while ((fgets(line, MAX_LINE, file)) != NULL) { // the loop reads the file line by line. and upon reaching null it stops as that's where the file ends
		char wo[6] = ".word"; // a string for comparison
		int isword = 0; // booleand for .world detection
		//printf("line in second run: %s \n", line);
		if ((comment_char = strchr(line, '#'))!=NULL)
		{
			*comment_char = '\n';
			*(comment_char+1) = '\0';
		}	
		if (strstr(line, wo) != NULL) { // in case of the special .word order
			isword = 1;
		}
		else
			remove_chars(line, strlen(line), "\t ", 2);

        if (strcmp(line, "\n") == 0) continue;  // in case of a Blank line, go
        tav1 = line[0];          // get first line
        if (tav1 == '#') continue;  // in case of a Remark line, go
		if (isword) { // in case of the special .word order
			head = specialword(head, line, &pos1, &k);
		}
		else if (strstr(line, dots) != NULL){     //in case of regular order and label
			if (strstr(line, "#") != NULL){       //now we check if the dots is remark and not a label
				if ((strstr(line, dots)) >= (strstr(line, "#"))) {        //label line- check if the line include only label or order
					goto mark; // start reading
				}
			} // the following code section will work if the there is mark # and apears aftre dots or if there isn't mark #
			k = 0;
			while (line[k] != ':') k++;
			k++;
			if (line[k] == '\n') continue;
			else
				while ((line[k] == ' ') || (line[k] == '\t')) k++;
			if (line[k] == '\n') continue;
			if (line[k] == '#')	continue;
			if (i > pos1) pos1 = i;  //Update last line position
		}

		else// Order line only
		{
			k = 0;
			while ((line[k] == ' ') || (line[k] == '\t')) k++;  // roll to end of spaces
			if (line[k] == '#')	continue;
			if (line[k] == '\n') continue;
		}
		if (isword) 
			last = max(last, pos1);		
		else{ // copy line in all not .world scenarios
		mark:
			head = readLine(line, &pos1, &i, head, &k);
			if (strstr(line, "$imm") != NULL) // I command
				num_rows+=2;
			else
				num_rows++;
		}
	}
	last = max(last, num_rows - 1);		
	return create_mem(head, last);  // create memory structure and return it to main function
}

//helpful function for printdatatofile - prints rd,rs,rt into the memin file
// rdst - register name to print
// memin - current file pointer
// num - will be flipped to zero if it's a .world
void printrdrsrt(char *rdst, char *memin, int *num)
{ // basically a big if block that checks the name of the register and converts it to a number
	if (strcmp(rdst, "$zero") == 0)
		memcpy(memin, "0", 1);
	else if (strcmp(rdst, "$imm") == 0)
		memcpy(memin, "1", 1);
	else if (strcmp(rdst, "$v0") == 0)
		memcpy(memin, "2", 1);
	else if (strcmp(rdst, "$a0") == 0)
		memcpy(memin, "3", 1);
	else if (strcmp(rdst, "$a1") == 0)
		memcpy(memin, "4", 1);
	else if (strcmp(rdst, "$a2") == 0)
		memcpy(memin, "5", 1);
	else if (strcmp(rdst, "$a3") == 0)
		memcpy(memin, "6", 1);
	else if (strcmp(rdst, "$t0") == 0)
		memcpy(memin, "7", 1);
	else if (strcmp(rdst, "$t1") == 0)
		memcpy(memin, "8", 1);
	else if (strcmp(rdst, "$t2") == 0)
		memcpy(memin, "9", 1);
	else if (strcmp(rdst, "$s0") == 0)
		memcpy(memin, "A", 1);
	else if (strcmp(rdst, "$s1") == 0)
		memcpy(memin, "B", 1);
	else if (strcmp(rdst, "$s2") == 0)
		memcpy(memin, "C", 1);
	else if (strcmp(rdst, "$gp") == 0)
		memcpy(memin, "D", 1);
	else if (strcmp(rdst, "$sp") == 0)
		memcpy(memin, "E", 1);
	else if (strcmp(rdst, "$ra") == 0)
		memcpy(memin, "F", 1);
	else if (strcmp(rdst, "NONO") == 0)
		*num = 0;
	else
		memcpy(memin, "0", 1);
}

////helpful function for printdatatofile - prints opcode
// opc - opcode string
// memin - output file pointer
// returns 1 if opcode was printed
int printopcode(char *opc, char *memin)
{
	if (strcmp(opc, "add") == 0) {
		memcpy(memin, "00", 2); return 1;}
	else if (strcmp(opc, "sub") == 0) {
		memcpy(memin, "01", 2); return 1;}
	else if (strcmp(opc, "mul") == 0) {
		memcpy(memin, "02", 2); return 1;}
	else if (strcmp(opc, "and") == 0) {
		memcpy(memin, "03", 2); return 1;}
	else if (strcmp(opc, "or") == 0) {
		memcpy(memin, "04", 2); return 1;}
	else if (strcmp(opc, "xor") == 0) {
		memcpy(memin, "05", 2); return 1;}
	else if (strcmp(opc, "sll") == 0) {
		memcpy(memin, "06", 2); return 1;}
	else if (strcmp(opc, "sra") == 0) {
		memcpy(memin, "07", 2); return 1;}
	else if (strcmp(opc, "srl") == 0) {
		memcpy(memin, "08", 2); return 1;}
	else if (strcmp(opc, "beq") == 0) {
		memcpy(memin, "09", 2); return 1;}
	else if (strcmp(opc, "bne") == 0) {
		memcpy(memin, "0A", 2); return 1;}
	else if (strcmp(opc, "blt") == 0) {
		memcpy(memin, "0B", 2); return 1;}
	else if (strcmp(opc, "bgt") == 0) {
		memcpy(memin, "0C", 2); return 1;}
	else if (strcmp(opc, "ble") == 0) {
		memcpy(memin, "0D", 2); return 1;}
	else if (strcmp(opc, "bge") == 0) {
		memcpy(memin, "0E", 2); return 1;}
	else if (strcmp(opc, "jal") == 0) {
		memcpy(memin, "0F", 2); return 1;}
	else if (strcmp(opc, "lw") == 0) {
		memcpy(memin, "10", 2); return 1;}
	else if (strcmp(opc, "sw") == 0) {
		memcpy(memin, "11", 2); return 1;}
	else if (strcmp(opc, "reti") == 0) {
		memcpy(memin, "12", 2); return 1;}
	else if (strcmp(opc, "in") == 0) {
		memcpy(memin, "13", 2); return 1;}
	else if (strcmp(opc, "out") == 0) {
		memcpy(memin, "14", 2); return 1;}
	else if (strcmp(opc, "halt") == 0) {
		memcpy(memin, "15", 2); return 1;}
	else // on .word
		return 0;
}

//gets memory head and output file indicator. prints the memory into file
void PrintDataToFile(Memory* mem, FILE *memin)
{
	// i - memory index, num - word for .word
	MemoryLine *currentLine;
	char memory_code[MAX_NUM_ROWS_MEMORY][ROW_LENGTH_MEMORY];
	char * print_char;
	int i = 0, num = 0, flag=0, idx_line_in_memory = 0;
	int is_word = 0;

	currentLine = mem->head;
	while (currentLine != NULL)	{
		is_word = 0;
		// get the current line's data once. this will reduce the code's execution time. allowing it to build apps much more quickly
		// Printing Opcode. if data for the ith row does not exist print a zero
		if (currentLine == NULL) 
		{
			memcpy(memory_code[idx_line_in_memory], "00", 2);
		}
		// if no opcode print 2 zeros
		else flag=printopcode(currentLine->opcode, memory_code[idx_line_in_memory]); // print the opcode and return if it was printed
		if (!flag && currentLine != NULL) {// if there is no opcode. this block of code is used to get the word for the .word command
			if ((strcmp(currentLine->opcode, "NONO") == 0)) {
				if ((currentLine->imm[0] == '0') && ((currentLine->imm[1] == 'x') || (currentLine->imm[1] == 'X'))) 	
					num = strtol(currentLine->imm, NULL, 16);
				else  //Imiddiate is decimal
					num = atoi(currentLine->imm);	
				num = SIGNEX(num, SIGNBIT_LOC);

				sprintf(memory_code[currentLine->pos], "%05X", num & 0xFFFFF);  //Print immidiate in hex
				is_word = 1;
			}
		}
		else if (!flag) // if there is nothing print a zero
			memcpy(&memory_code[idx_line_in_memory][2], "00", 2); 
		if (currentLine == NULL) memory_code[idx_line_in_memory][2] = '0'; // Printing Rd
		else printrdrsrt(currentLine->rd, &memory_code[idx_line_in_memory][2],&num);
		if (currentLine == NULL) memory_code[idx_line_in_memory][3] = '0'; 		// Printing Rs
		else printrdrsrt(currentLine->rs, &memory_code[idx_line_in_memory][3],&num);
		if (currentLine == NULL) memory_code[idx_line_in_memory][4] = '0'; 		// Printing Rt
		else printrdrsrt(currentLine->rt, &memory_code[idx_line_in_memory][4],&num);
		// a check wheter to print the immediate and skip .word lines
		if ((currentLine != NULL) && (currentLine->is_I_command == 1))  // now print if satisfied
		{
			idx_line_in_memory ++;
			//fprintf(memin, "\n");
			if ((currentLine->imm[0] == '0') && ((currentLine->imm[1] == 'x') || (currentLine->imm[1] == 'X'))) num = strtol(currentLine->imm, NULL, 16);  //Check if immidiate in hex
			else num = atoi(currentLine->imm);
			num = SIGNEX(num, SIGNBIT_LOC);
			sprintf(memory_code[idx_line_in_memory], "%05X", num & 0xfffff);			
			//Print immidiate in hex. the & 0xfff is supposed to shorte negative numbers to 3 hexadecimal digits or 12 bits
		}
		if (is_word==0)
			idx_line_in_memory++;
		currentLine = currentLine->next;
	}

	for (i=0; i<mem->last; i++)
	{
		if (memory_code[i][0] == '\0')
		{
			fprintf(memin, "%05X\n", 0);
		}
		else
			fprintf(memin, "%c%c%c%c%c\n", memory_code[i][0], memory_code[i][1], memory_code[i][2], memory_code[i][3], memory_code[i][4]);
	}
	fprintf(memin, "%c%c%c%c%c", memory_code[i][0], memory_code[i][1], memory_code[i][2], memory_code[i][3], memory_code[i][4]);
}

// a label switch function that runs between the second run and the write. changes label names in the memory structure to thier locations taken
// from the label structure
// this function also changes immediate to zero if the register name $zero was recorded in the immediate field
void LableChange(MemoryLine* head, label* lb)
{
	char temp[50];
	// the current memory line
	MemoryLine *current = head;
	while (current != NULL) {
		// find if there is a label on the immediate and if it exists
		int loc = find(lb,current->imm);
		// if found
		if (loc != -1) {
			_itoa(loc, temp, 10); // Changes int to string and puts in temp
			strcpy(current->imm, temp); // Copy label location number to immidiate
		}
		if (strcmp(current->imm, "$zero") == 0) // If immidiate is &zero
		{
			strcpy(current->imm, "0"); // Changes immidiate to "0"
		}
		current = current->next;
	}
}

// part 3 - the main function

// the main takes two arguments, the input file and the output file. indexes start with 1 because argv[0] is the program itself
int main(int argc , char *argv[] ) { //{//, char *argv[]
	//char *argv[] = {"asm.exe", "a.asm", "memin.txt"};

    // open the input file. doing so in the main function will allow us to have infinite length file names
    // why i call it "asembl"? because of what it is
    FILE *asembl = fopen(argv[1], "r");
	//FILE *asembl = fopen("program.asm", "r");
    // leave if null file is supplied
    if (asembl == NULL) {
        exit(1);
    }
    // the first iteration, locate the labels and write thier locations to the linked list
    label* labels = createLabelList(asembl);
    // close the file from the first iteration
    fclose(asembl);
    // and reopen it for the second
    asembl = fopen(argv[1], "r");
    // another null check in case something happend
    if (asembl == NULL) {
        exit(1);
    }
    // start the second iteration
    Memory *memory = SecondRun(asembl);

    fclose(asembl);
	LableChange(memory->head, labels); // Change labels from words to numbers

	// Write Data to file
	FILE* memin = fopen(argv[2], "w");
	if (memin == NULL)
		exit(1);
	PrintDataToFile(memory, memin);
	fclose(memin);
	// End of file writing

    // free the memory taken by the label list and memory structure
    destroy(labels);
    destroy_mem(memory);
}
