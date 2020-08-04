// Priyavart Rajain
// University of Calgary
// CPSC 355 . Assg. 4
		
		.data							// The write part of the program

userinput:	.word 0							// user input variable

		.text							// read part of the program

fp		.req x29						// allows fp to be used in the code, instead of x29
lr		.req x30						// allows lr to be used in the code, instead of x30

maxDim=		10							// maximum dimension of array is 10 


array_size=	10*10*4							// size of integer array is 10*10*4 = 400 bytes
i_size=		4							// size of i loop counter
j_size=		4							// size of j loop counter
					
i_s=		16							// offset of i is 16 bytes from fp
j_s=		16 + i_size						// offset of j is 16+ 4 = 20 bytes from fp
array_base=	i_s + i_size + j_size					// array base is located at 24 bytes from fp
N_s=		array_base + array_size					// N_s is the offset for storing the user input / value of x19 register
N_size=		4							// size of n is 4 bytes
									
									// Thse variables are allocated memory later on, i.e they will be assigned by decrementing the stack later on
row_sum_s=	0						  	// struct variable sum is located at 0 bytes from the array base
row_min_s=	-4							// row_min is located at 4 bytes from the array base
row_max_s=	-8							// row_max is located at 8 bytes from the array base


row_array_base=		-4						// base of the row struct array is -4 bytes from fp
row_array_size=		12*maxDim					// size of this array is 12*10 = 120 bytes
row_struct_size= 	12						// size of individual struct is 12 bytes

column_sum_s=		0 						// offset for column sum
column_min_s=		-4 						// offset for column min
column_max_s=		-8 						// offset for column max

column_array_base=	row_array_base - row_array_size			// offset for column array
column_array_size=	12*maxDim					// size fo column arary 
column_struct_size=	12   						// size fo column struct 

	
allocatemem=		row_array_size + column_array_size	        // stors teh amount fo memory to be allocated later on

	
var_size=	array_size + i_size + j_size+ N_size			// size of memory allocated at the beginning 
alloc=		-(16+ var_size)& -16					// makes teh total memory to be assigned a multiple of 16, frame record of 16 bytes is also added to var_size
dealloc=	-alloc							// deallco will be used at teh end to deallcoate memoryt

input:		.string	"Enter the value of N:	"			// input string 
formatIn:	.string "%d"						// format string fro scanf
displayArray:	.string "The generated array is:\n\n"			// depicts the generation of array
lineBreak:	.string "\n"						// new line character
rowStats:	.string "\nRow stats:\n"				// depicts row stats
rowSum:		.string "Sum of row %d: %d\n"				// string for sum
rowMin:		.string "Min of row %d: %d\n"				// string for min
rowMax:		.string "Max of row %d: %d\n"				// string for max
columnStats:	.string "\nColumn stats:\n"				// string for column stats
colSum:		.string "Sum of column %d: %d\n"			// string for sum
colMin:		.string "Min of column %d: %d\n"			// strng for min
colMax:		.string "Max of column %d: %d\n"			// string for max
elem_fmt:	.string "%d   "						// string for printing elements
		
		.balign 4						// align teh instructions
		.global main
									// initially sp,fp,and lr, all are at the bottom of the stack
main:		stp 	fp, lr, [sp,alloc]!				// storing x29 and x30, alloc size of bytes from sp and updates sp
		mov 	fp, sp						// update fp by setting its value to sp. Now fp and sp both point to the top of the stack
prompt:		adrp 	x0, input					// prompt the user
		add 	x0, x0, :lo12:input				// add input string to lower bits of x0
		bl 	printf						// call printf
		
		adrp	x0, formatIn					// sets the string for scamf
		add	x0, x0, :lo12:formatIn				// adds formatIn string to lower 12 biyts of x0
		adr	x1, userinput					// store the passsed input to userinput location
		bl	scanf						// call scanf
		
		
		adr	x1,userinput					// grab teh address fo userinput 
		ldr	w19,[x1]					// load teh value of userinput to w19
		
		mov	w20, 10						// mov 10 to w20 
		cmp	w19, 10						// compare w19 with 10
		b.gt	prompt						// if greater than 10 , prompt user again
		b.le	store						// if less than 10
	
store:		str	w19, [fp, N_s]					// go to store and store w19 on stack
		
		mov	w20, 0						// set i = 0		
		str	w20, [fp, i_s]					// store i on stack
		
		mov	w21, 0		        			// set j = 0
		str	w21, [fp, j_s]					// stroe j on stack 
		
		mov	w26, 0x64					// store 100 in w26
		mov	w27, 0						// store 0 in w27
		mov	w28, 0						// store 0 in x28
		mov	x0, xzr						// store 0 in x0 for time
		bl	time						// call time 
		bl 	srand						// call srand
		
		b	outerLoopTest					// branch to outerLooptest to check if i<N

		
loopBody:	bl	rand						// call rand to 
									// generate a random number 
		udiv    w27, w0, w26					// store the result of unsigned division of rand and 100 in w22
		msub	w22, w27, w26, w0 				// store the resulyty of msub of w27 , w26 and the random number in w22
									// w22 now stores a random number between 0 and 100
		add	x23, fp, array_base				// storing base address of array in x23
				
		mul	w25, w20, w19					// offset = i*N
		add	w25, w25, w21					// offset = i*N + j
		lsl	w25, w25, 2					// offset = ((i*N)+j)*4
		
		str	w22, [x23, w25, SXTW]				// store random number at ((i*N)+j)*4 from x23 (the base address)	
	
		adrp	x0, elem_fmt					// grab the string elem_fmt for printding the array
		add	x0, x0, :lo12:elem_fmt				// add elem_fmt to lower 12 bits of x0
		mov	w1, w22						// pass teh random number to w1
		bl	printf						// call printf to print the number

		add	w21, w21, 1					// j++

		b	innerLoopTest					// branch to innerLoopTest to check if j<N

innerLoopTest:  cmp	w21, w19					// check if j<N
		b.lt	loopBody					// if yes then branch to body of loop
		b.ge	incrementI					// otehrwise go to increment i 

incrementI:	add	w20, w20, 1					// increment i by 1
		adrp	x0, lineBreak					// eneter a line break by printing lineBreak string 	
		add	x0,x0,:lo12:lineBreak				// sets lower 12 bits of x0 to line break
		bl	printf						// call printf
		mov	w21, 0						// set j to 0
		b.ge	outerLoopTest					// branch to outerLoop to check if i < N
		

outerLoopTest:	cmp	w20, w19					// check if i<N
		b.lt	innerLoopTest					// if true than branch to innerLoop to test j<N
		b.ge	rowStatCalc					// if i>N branch to rowStatCalc for calculating min , max , sum for each row
		
		
/*------------------------------------- Row Stat Calculation ----------------------------------------------- */

rowStatCalc:
		mov	w20, 0						// i
		mov	w21, 0						// j
		mov	w22, 0						// curr: stores current element 
		mov	x23, 0						// array base
		mov	w24, 0						// sum of row 
		mov	w26, 0		   				// min of row
		mov	w27, 0						// max of row
		mov	w25, 0						// cell Offset
		mov	w28, 0						// row array offset
	

		add	sp, sp, -allocatemem & -16			// allocating memory for structs and 2 1D arrays for those structs

		b	rowLoop_1Test					// branch to rowLoop_1Test to check if i<N

rowLoop_body:	add	x23, fp, array_base				//calculating array base address
		
		mul	w25, w20, w19					// offset = i*N
		add	w25, w25, w21					// offset = i*N + j
		lsl	w25, w25, 2					// offset = (i*N + j) * 4
		
		ldr	w22,[x23,w25, SXTW]				// moving a[i][j] into curr

		add	w24, w24, w22					// sum+=curr
		
		cmp	w21, wzr					// if ( j == 0 )
		b.eq	equal						// if true than branch to equal 
		b.ne	compare_1					// else go to compare_1
			
equal:		mov	w26, w22					// set min = curr if its the first iteration
		mov	w27, w22					// set max = curr if its teh first iteration 
		add	x21, x21, 1					// increment j by 1
		b	rowLoop_2Test					// branch to inner loop 

compare_1:	cmp	w22, w26					// else if ( curr < min )
		b.lt	newMin						// if true then branch to newMin to update min
		b	compare_2					// if false then branch to comapre_2
			
newMin:		mov	w26, w22					// min = curr
		add	x21, x21, 1					// increment j by 1
		b	rowLoop_2Test					// bracnh to inner Loop

compare_2:	cmp	w22, w27					// else if ( curr > max )
		b.gt	newMax						// if true than branch to newMax
		add	x21, x21, 1					// increment j by 1
		b	rowLoop_2Test					// branch to inner loop 

newMax:		mov	w27, w22					// max = curr
		add	x21, x21, 1					// increment j by 1
		b	rowLoop_2Test					// bracnh to inner loop


rowLoop_2Test:	cmp	w21, w19					// compare j to N
		b.lt	rowLoop_body					// if j < N tehn go to loop body 
		b.ge	incremI						// otherwise go to incerement i where teh min max and sum calculation takes place

incremI:	mov	w19, 0						// set w19 to 0, for reuse as it is already stored on teh stack  
		mov	x25, 0						// set x25 to 0 
		mov	w25, w20					// move teh value of i to w25
		add	x28, fp, row_array_base				// store array of struct for rows in x28
		mov	w10, 12						// mov	12 to w10
		mul	w25, w25, w10					// multiply w25 by 12 , which is the size of struct 
		SXTW	x19, w19					// sign extend w19
		mov	x19, -1						// stroe -1 in x19
		mul	w25, w25, w19					// negate  w25 
		SXTW	x25, w25					// sign extend w25 
	  	str	w24,[x28, w25, SXTW]				// store sum on teh stack 
		mov	x28, 0

		mov	w19, 0						// set x19 back to 0
		mov	w25, 0						// set w25 back to 0 
		mov	w25, w20					// set x25 to w20
		add	x28, fp, row_array_base				// store row array address im x28 
		mov	w10, 12						// mov 12 to w10	
		mul	w25, w25, w10					// multiply w25 by w10
		SXTW	x19, w19					// Sign extend w19 
		mov	x19, -1						// mov -1 to x19 
		mul	w25, w25, w19					// negate x25
		SXTW	x25, w25					// sign extend w25 
		add	x25, x25, row_min_s				// calculate row min variable address in teh struct 
		str	w26, [x28, w25, SXTW]				// stroe min at that address
		mov	x28, 0						// set w28 back to 0 
				
		mov	w19, 0
		mov	w25, 0
		mov	w25, w20
		add	x28, fp, row_array_base
		mov	w10, 12
		mul	w25, w25, w10
		SXTW	x19, w19
		mov	x19, -1
		mul	w25, w25, w19
		SXTW	x25, w25
		add	x25, x25, row_max_s
		str	w27, [x28, w25, SXTW]				// store max at offset of 8 in the struct 
		
		mov	x28, 0
		mov	w24, 0
		mov	w25, 0
		mov	w22, 0
		mov	w26, 0
		mov	w27, 0

		add	w20, w20, 1		// i++
		mov	w21,0			// set j=0 everytime i increases
		ldr	w19, [fp, N_s]
		b.ge	rowLoop_1Test

rowLoop_1Test:  cmp	w20, w19
		b.lt	rowLoop_2Test
		b.ge	rowStatDisplay

/*------------------------------Display the array of structs for rows---------------------------------------------*/

rowStatDisplay:		mov	w20, 0

rowdisTest:		cmp	w20, w19
			b.lt	rowsdisplayLoop
			b.ge	colStatCalc


rowsdisplayLoop:	adrp	x0, rowStats
			add	x0, x0, :lo12:rowStats
			bl	printf
//------------------------------------------------			
			mov	w19, 0
			mov	w25, 0
			mov	w25, w20
			add	x28, fp, row_array_base
			mov	w10, 12
			mul	w25, w25, w10
			SXTW	x19, w19
			mov	x19, -1
			mul	w25, w25, w19
			SXTW	x25, w25
	  		ldr	w24,[x28, w25, SXTW]
			mov	x28, 0

			adrp	x0, rowSum
			add	x0, x0, :lo12:rowSum
			mov	w1, w20
			mov	w2, w24
			bl	printf
//-----------------------------------------------
			mov	w19, 0
			mov	x25, 0
			mov	w25, w20
			add	x28, fp, row_array_base
			mov	w10, 12
			mul	w25, w25, w10
			SXTW	x19, w19
			mov	x19, -1
			mul	w25, w25, w19
			SXTW	x25, w25
			add	x25, x25, row_min_s
			ldr	w26, [x28, w25, SXTW]
			mov	x28, 0
			
		 	adrp	x0, rowMin
			add	x0, x0, :lo12:rowMin
			mov	w1, w20
			mov	w2, w26
			bl	printf
			
//-------------------------------------------------
			mov	w19, 0
		 	mov	w25, 0
			mov	w25, w20
			add	x28, fp, row_array_base
			mov	w10, 12
			mul	w25, w25, w10
			SXTW	x19, w19
			mov	x19, -1
			mul	w25, w25, w19
			SXTW	x25, w25
			add	x25, x25, row_max_s
			ldr	w27, [x28, w25, SXTW]

			mov	x28, 0			
			adrp	x0, rowMax
			add	x0, x0, :lo12:rowMax
			mov	w1, w20
			mov	w2, w27
			bl	printf

//--------------------------------------------------
			ldr	w19,[fp, N_s]
			add	x20, x20, 1
			b	rowdisTest


			
		

/*----------------------------------------- Column Stat Calculation-------------------------------------------*/

// The functionality of this fragment of code is the same as the one for row calculation except that j and i are flipped


colStatCalc:
		mov	w20, 0			// i
		mov	w21, 0			// j
		mov	w22, 0			// curr
		mov	x23, 0			// array base
		mov	w24, 0			// sum
		mov	w26, 0		   	// min
		mov	w27, 0			// max
		mov	w25, 0			// cell Offset
		mov	w28, 0			// column array offset

		b	colLoop_1Test

colLoop_body:	add	x23, fp, array_base		//calculating array base address
		
		mul	w25, w20, w19
		add	w25, w25, w21
		lsl	w25, w25, 2
		
		ldr	w22,[x23,w25, SXTW]			// moving a[i][j] into curr

		add	w24, w24, w22			// sum+=curr
		
		cmp	w20, wzr			// if ( i == 0 )
		b.eq	c_equal
		b.ne	compare_1C

c_equal:	mov	w26, w22			// min = curr
		mov	w27, w22			// max = curr
		add	x20, x20, 1
		b	colLoop_2Test

compare_1C:	cmp	w22, w26			// else if ( curr < min )
		b.lt	newMin_c			
		b	compare_2C

newMin_c:	mov	w26, w22			// min = curr
		add	w20, w20, 1
		b	colLoop_2Test

compare_2C:	cmp	w22, w27			// else if ( curr > max )
		b.gt	newMax_c
		add	w20, w20, 1
		b	colLoop_2Test

newMax_c:	mov	w27, w22
		add	w20, w20, 1		        // max = curr
		b	colLoop_2Test


colLoop_2Test:	cmp	w20, w19
		b.lt	colLoop_body
		b.ge	incremJ_c

incremJ_c:	mov	w19, 0
		mov	x25, 0
		mov	w25, w21
		add	x28, fp, column_array_base
		mov	w10, 12
		mul	w25, w25, w10
		SXTW	x19, w19
		mov	x19, -1
		mul	w25, w25, w19
		SXTW	x25, w25
	  	str	w24,[x28, w25, SXTW]
		mov	x28, 0

		mov	w19, 0
		mov	w25, 0
		mov	w25, w21
		add	x28, fp, column_array_base
		mov	w10, 12
		mul	w25, w25, w10
		SXTW	x19, w19
		mov	x19, -1
		mul	w25, w25, w19
		SXTW	x25, w25
		add	x25, x25, column_min_s
		str	w26, [x28, w25, SXTW]
		mov	x28, 0

		mov	w19, 0
		mov	w25, 0
		mov	w25, w21
		add	x28, fp, column_array_base
		mov	w10, 12
		mul	w25, w25, w10
		SXTW	x19, w19
		mov	x19, -1
		mul	w25, w25, w19
		SXTW	x25, w25
		add	x25, x25, column_max_s
		str	w27, [x28, w25, SXTW]
		
		mov	x28, 0
		mov	w24, 0
		mov	w25, 0
		mov	w22, 0
		mov	w26, 0
		mov	w27, 0

		add	w21, w21, 1		// j++
		mov	w20,0			// set i=0 everytime i increases
		ldr	w19, [fp, N_s]
		b.ge	colLoop_1Test


colLoop_1Test:  cmp	w21, w19
		b.lt	colLoop_2Test
		b.ge	colStatDisplay

/*--------------------------------------------Display the struct for columns----------------------------------------------*/

colStatDisplay:		mov	w20, 0

coldisTest:		cmp	w20, w19
			b.lt	colsdisplayLoop
			b.ge	done


colsdisplayLoop:	adrp	x0, columnStats
			add	x0, x0, :lo12:columnStats
			bl	printf
//------------------------------------------------			
			mov	w19, 0
			mov	w25, 0
			mov	w25, w20
			add	x28, fp, column_array_base
			mov	w10, 12
			mul	w25, w25, w10
			SXTW	x19, w19
			mov	x19, -1
			mul	w25, w25, w19
			SXTW	x25, w25
	  		ldr	w24,[x28, w25, SXTW]
			mov	x28, 0

			adrp	x0, colSum
			add	x0, x0, :lo12:colSum
			mov	w1, w20
			mov	w2, w24
			bl	printf
//-----------------------------------------------
			mov	w19, 0
			mov	x25, 0
			mov	w25, w20
			add	x28, fp, column_array_base
			mov	w10, 12
			mul	w25, w25, w10
			SXTW	x19, w19
			mov	x19, -1
			mul	w25, w25, w19
			SXTW	x25, w25
			add	x25, x25, column_min_s
			ldr	w26, [x28, w25, SXTW]
			mov	x28, 0
			
			adrp	x0, colMin
			add	x0, x0, :lo12:colMin
			mov	w1, w20
			mov	w2, w26
			bl	printf
			 
//-------------------------------------------------
			mov	w19, 0
			mov	w25, 0
			mov	w25, w20
			add	x28, fp, column_array_base
			mov	w10, 12
			mul	w25, w25, w10
			SXTW	x19, w19
			mov	x19, -1
			mul	w25, w25, w19
			SXTW	x25, w25
			add	x25, x25, column_max_s
			ldr	w27, [x28, w25, SXTW]
			mov	x28, 0
			 
			adrp	x0, colMax
			add	x0, x0, :lo12:colMax
			mov	w1, w20
			mov	w2, w27
			bl	printf

//--------------------------------------------------
			ldr	w19, [fp, N_s]
			add	w20, w20, 1
			b	coldisTest




done:		add	sp,sp, 240			// deallcoate memory from the stack 
		mov	w0, 0				// restore system state
		ldp	fp, lr, [sp], dealloc		// deallocate memory allocated to main 
		ret					// return 
