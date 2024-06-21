// ConsoleApplication1.cpp : This file contains the 'main' function. Program execution begins and ends there.
//
#define MAX_ROW_LENGTH 500

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int convert_full_file(FILE * asm_ptr, FILE * machine_code_ptr)
{
	/*
	for each_row
	{
		read_line();
		parse_line();
		write_line();
	}
	*/
	return 0;
}


int main(int argc, char **argv)
{
	FILE *asm_ptr, *machine_code_ptr;

	if (argc < 3)
	{
		printf("not enough outputs\n ");
		return 1;
	}
		
	fopen_s(&asm_ptr,argv[1], 'r');
	fopen_s(&machine_code_ptr, argv[2], 'w');

	printf("%s\n", argv[1]);
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
