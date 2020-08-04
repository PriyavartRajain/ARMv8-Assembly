													/*ASSIGNMENT 1*/

/* Submitted by : Priyavart Rajain
CPSC 355 University of Calgary*/

#include<stdio.h>
#include<stdlib.h>

/*The initialize function has two parameters: The pointer to the table and the dimension of the table.
It then iterates through the 2D array using a nested for loop and sets each element to be a random number between 0 and 9 by calling the randomNum function */

int *initialize(int *table,int N){
    srand(time(0));               	          	// Uses current time as seed for the generation of random numbers.
    for(int i=0;i<N;i++){               	    	// The outer loop for i'th row in the table
        for(int j=0;j<N;j++){               		// The inner loop for each element in that row, the j'th element in the i'th row
            *(table+i*N+j) = randomNum(0,9,N);  	// table points to the [0][0] element of the 2D array. Adding i*N to it points to the 0th element of i'th row, and adding j to it pointts to table[i][j], 
							// Dereferencing table+i*N + j gives the element at index [i][j] in table.  
             }                           
                                        	        // Every incrementation of j, makes the pointer jump 4 bytes in memory ( bcause int occupies 4 bytes ), and every incrementation of i, represents
         }                                  		// a 4*N bytes of jump, this is because every i'th row has N elements, and i increments only when N elements
                                            		// have been written to memory, so if the table is 4*4, 4 bytes are written in memory everytime j increments,
                                            		// by the time 4 elements have been written to a row, the row would have occupied 4*4 = 16 bytes in memory and then i increments by 1.
return table;                               		// At the end, the pointer to the table is returned,
}


/*randomNum, Generates a random number , between n and m*/

int randomNum(int n, int m,int N){			// Takes 3 arguments, lowerbound n, upperbound m, and dimension of table, N.
    int randNum;	
    int count = N*N;					// Setting count to N*N because our table has a total of N*N elements, and thus we need N*N random numbers 
    for(int i=0; i<count; i++ ){
        randNum = (rand()%(m-n +1))+n;			// In our case since m is 0 and n is 9, we get (rand()%(10))
    }

    return randNum;					// At last we return the random number
}

/*sort function : Takes in the pointer to the table, the column number to sort c_num and dimension N of table as parameters*/

int *sort(int *table,int c_num, int N){
    int temp;				        	// temp variable stores the element table[i][j] when we need to interchange table[i][j] and table[i+1][j]
    for(int j=c_num;j<=c_num;j++){              	// uter loop will run for the c_num column. This means that j in table[i][j] will be set to c_num and i will increment until it reaches N.
        for(int i=0;i<N;i++){           		// table[0][c_num], table[1][c_num], table[2][c_num], .... table[N][c_num].
            for(int k = i+1;k<N;k++){   		// k is used to iterate over the c_num column, starting from the second element in the column ( i.e table[1][c_num] ),then third element and so on; going on until it reaches N.

                if(*(table+i*N+j) > *(table+k*N+j)){    // comparing table[0][c_num] with table[1][c_num], then table[1][c_num] with table[2][c_num] and so on
                                                        // switching two adjacent column elements if first element is greater than the next one.
                temp = *(table+i*N+j);                  // if table[i][c_num] > table[k][c_num] , we store the value of table[i][j] in temp.
                *(table+i*N+j) = *(table+k*N+j);        // then we assign the value of second element to the first one ( because we are sorting in ascending order)
                *(table+k*N+j)  = temp;                 // finally we assign the second element the value of first element ( because we stored the value of first element in temp in step 1)
                }
            }
        }
    }

    return table;					// Once all the elements have been sorted in column c_num, i.e j has become greater than c_num, we return the pointer to table
}

/*Display function: Takes in pointer to the table and dimension of the table as parameters and displays the table*/

void display(int *table,int N){
    for(int i =0; i<N; i++){				// Outer loop to iterate over N rows
        for(int j=0; j<N; j++){				// Inner loop to iterate over each element in i'th row
            printf(" %d ", *(table+i*N+j) );		// printing the value of table[i][j]
        }
        printf("\n");					// Adding new line everytime a row or in other words, the i value increments
    }
    printf("\n");
}

/*The logFile function takes in pointer to the table, the dimension N of table, and the pointer to the open file as parameters*/

void logFile(int *table,int N, FILE *fptr){		

    for(int i =0; i<N; i++){				// Similar to display function, it has a nested for loop to iterate over the 2D array
    for(int j=0; j<N; j++){					
            fprintf(fptr," %d ", *(table+i*N+j) );	// fprintf prints the arguments into the file to which fptr is a pointer. 
        }
        fprintf(fptr,"\n");
    }
    fprintf(fptr,"\n");

}


/*main function is the entry point to the program. It takes in two parameters, argc, the argument count, and a character array, argv[] which stores the arguments passed to the function*/

int main(int argc, char *argv[]){
    int N;                             			// N stores the argument passed by the user.
    int c_num;                          		// c_num stores the column number to be sorted.
    char response;                      		// stores the user's response if he/she wants to continue or quit
    if(argc==1){                        		// If argument count is 1, this implies that user has only passed the program name and not the dimension of the array, return 0
        printf("Please enter the value of N\n");
        return 0;
    }
    else if(argc>2){					// If more than 2 arguments are supplies, return 0
    	printf("Please enter one argument, the value of N\n");	
	return 0;
    }

    N = atoi(argv[1]);		                        // argv[] is a character array and thus, N is infact a string, atoi converts it to an integer.
    int array[N][N];                      		// Creating the N X N array
    int (*table)[N] = array;            		// declaring and initializing the pointer to the N x N array.
                                         		// array now has two names, array and table,
                                        		// table points to the 1st element in the 1st row i.e [0][0], the rest of the elements can be accessed by adding integers to it.

    /*Opening the file*/

    FILE *fptr;						// declares a pointer fptr of type FILE
    fptr = fopen("assign1.log","a");			// fptr now points to assign1.log file, and access mode is 'a', append. 
    if(fptr == NULL){					// if fptr returns NULL, that means that the computer couldn't open assign1.log
        printf("Error opening file");
        exit(1);					// return exit code 1
    }
							// If the file was opened successfully then continue  

    table = initialize((int*)table,N);        		// calling the initialize function, which takes in the pointer to our table and dimensions as an argument, pointer table now points to the table returned by initialize function.
    printf("\nThe initial table:\n");			
    display((int*)table,N);				// calling the display function, passing the pointer to table and N as arguments
    fprintf(fptr,"The initial table:\n");		// fprintf writes whatever is passed to the log file.
    logFile((int*)table,N,fptr);			// calling logFile function to write the table into the log file

    while(response!= 'q'){				// unless the user presses  q, to quit the program, iterate over the following set of code over and over again. 

        printf("\nEnter a column number: ");				
        scanf("%d",&c_num);						// Store the column number to sort by in c_num
        getchar();							// getchar catches the newline left by the scanf function. 

        if(c_num<0 || c_num>=N){					// The column number should be a positive number and less than the dimension of the table. 
        printf("Please enter a valid column number\n");
        fprintf(fptr,"User chose invalid column number: %d\n",c_num);
        continue;							// If an invalid column number is supplied, go back to the top of the loop. 
        }

        table = sort((int*)table,c_num,N);				// Call the sort function to sort the table by the designated column number, c_num. 
        printf("\n");
        printf("Table sorted by column %d:\n",c_num);												
        fprintf(fptr,"User chose to sort the table by column number: %d\n",c_num);								
        display((int*)table,N);															// Display the sorted table on the console
        logFile((int*)table,N,fptr);														// write the sorted table to the log file using logFile function. 
        printf("Press q and hit enter to quit the program now!\nPress any other key and hit enter to continue sorting.\nYour response: ");		
        scanf("%c",&response);															// Store the user's response in response
        if(response!='q')															// If the response was not q, the user decided to sort another column
            fprintf(fptr,"User chose to continue sorting\n");
        else if(response=='q'){															// If the user selected q, print the final table into the log file
            fprintf(fptr,"User chose to exit the program\nThe final table:\n");
            logFile((int*)table,N,fptr);
        }
    }

    fclose(fptr);							// Close the opened file
    return 0;								// returns 0 at the end of execution of the program. 
}
