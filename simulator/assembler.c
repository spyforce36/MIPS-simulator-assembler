// ConsoleApplication1.cpp : This file contains the 'main' function. Program execution begins and ends there.
//#define _CRT_SECURE_NO_WARNINGS

#define MAX_ROW_LENGTH 500
#define MAX_NUM_ROWS_MEMORY 10 //4096
#define ROW_LENGTH_MEMORY 5
#define MAX_LABEL_LENGTH 50

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

size_t find_label(char* buffer, size_t curr_row, char** intermediate_parsing, char** labels,
	size_t* label_rows, size_t* num_labels, size_t* is_I_command)
{
	//char label[MAX_LABEL_LENGTH];
	char* label_end;
	label_end = strchr(buffer, ':');
	if (label_end != NULL) // if it's not null that means that the label exists
	{
		*label_end = '\0';
		labels[*num_labels] = buffer;
		buffer = label_end + 1; // remove label from char
		label_rows[*num_labels] = curr_row;
		*num_labels = *num_labels + 1;
	}
	intermediate_parsing[curr_row] = buffer;
	if (strlen(buffer) == 0)
	{
		return curr_row;
	}
	is_I_command[curr_row] = strstr(buffer, "$imm") != NULL;
	return is_I_command[curr_row] + 1;
}



size_t parse_line(char* buffer, size_t curr_row, char ** intermediate_parsing, char ** labels,
	size_t * label_rows, size_t * num_labels, size_t * is_I_command)
{
	/*
	*	input: buffer: line
	*	output: curr_row - add 1 if r command, 2 if I command
	*	Save command to intermediate_parsing command, save labels and labels_rows if exist 
	*/
	//char * tokens;
	size_t num_rows_of_this_command = 0;
	char* hash_occurrence; 
	// remove hashtag
	hash_occurrence = strchr(buffer, '#');
	if (hash_occurrence != NULL)
	{
		*hash_occurrence = '\0';
	}
	if (strlen(buffer) == 0)
	{
		return curr_row;
	}

	//strtok(buffer, ",", MAX_ROW_LENGTH, &tokens);
	//tokens2 = strtok(tokens, ",");
	
	num_rows_of_this_command = find_label(buffer, curr_row, 
		intermediate_parsing, labels, label_rows, num_labels, is_I_command);
	return curr_row + num_rows_of_this_command;
	
}



int convert_full_file(FILE * asm_ptr, FILE * machine_code_ptr)
{
	size_t curr_row = 0, next_row = 0, num_labels = 0; // the current row in the memory file not input file
	char all_buffers[MAX_NUM_ROWS_MEMORY][MAX_ROW_LENGTH]; // the sentence we read from the file.asm
	//char * parsed_line; 
	char* intermediate_parsing[MAX_NUM_ROWS_MEMORY]; // all the sentences after removing hashtag and empty rows etc
	char* labels[MAX_NUM_ROWS_MEMORY]; // list of labels in our c code
	size_t label_rows[MAX_NUM_ROWS_MEMORY]; // list of rows numbers of labels in memory file
	size_t is_I_command[MAX_NUM_ROWS_MEMORY]; // list of is I command for each command
	size_t ind_row_program_asm = 0, new_row = 0;

	while (fgets(all_buffers[ind_row_program_asm], MAX_ROW_LENGTH, asm_ptr)) {
		printf("%s", all_buffers[ind_row_program_asm]);
		new_row = parse_line(all_buffers[ind_row_program_asm], curr_row, 
			intermediate_parsing, labels, label_rows, &num_labels, is_I_command);
		//write_line();
		if (new_row > curr_row)
		{
			curr_row = new_row;
			++ind_row_program_asm;
		}

	}	


	return 0;
}

int main(int argc, char **argv)
{ // argv: assembler.exe program.asm memin.txt
	FILE *asm_ptr = NULL, *machine_code_ptr  = NULL;

	if (argc < 3)
	{
		printf("not enough outputs\n ");
		return 1;
	}
		
	fopen_s(&machine_code_ptr, argv[2], "w");
	if (machine_code_ptr == NULL)
	{
		printf("cannot open machine code file\n ");
		return 2;
	}

	fopen_s(&asm_ptr,argv[1], "r");
	if (asm_ptr == NULL)
	{ 
		printf("cannot open assembly file\n ");
		return 2;
	}

	convert_full_file(asm_ptr, machine_code_ptr);

	if (asm_ptr != NULL)
	{
		fclose(asm_ptr);
	}
	if (machine_code_ptr != NULL)
	{
		fclose(machine_code_ptr);
	}
	return 0;

}



// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or Project > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file



