/* Submitted by: Priyavart Rajain
UCID:		 30074184
Course:		 CPSC 355 Spring 2020 */

/* Assignment 3: assign3a*/
/* This program converts Binary to Decimal*/
/* Defining the macros for the registers */ 

define(pos_N,x19)					// pos_N is the macro for x19 					
define(decimal_N, x20)					// decimal_N is the macro for x20
define(i,x21)						// i is the macro for x21, the loop counter of the main loop
define(j,x22)						// j is the macro for x22, the loop counter for the loop that calculates pow_2
define(pow_2,x23)					// pow_2 is the macro for x23
define(negToPos, x25)					// negToPos is the macro for x25, It is used to find 2s complement if N is negative
define(checkNeg, x27)					// checkNeg is the macro for x27, checkNeg stores the input N , used to check whether N is positive or negative 

input:		.string "\nEnter an integer:    "	// input string to prompt user for N
formatIn:	.string "%d"				// format specifieer for scanf
output:		.string "Output:   %d\n"		// output string to display the result
				
		.data					// write part of the program
N:		.word 0				        // declare a variable N

		.text					// read only part of the program
		.balign 4				// aligns the instructions for proper execution
		.global main				// makes main globally accessible
		
main:		stp 	x29,x30,[sp, -16]!		// pre increment the stack pointer by 16 bytes
		mov	x29, sp				// move stack pointer register to x29

		adrp	x0, input			// moving input string to x0 for printf
		add	x0, x0, :lo12: input		// adding input string to lower bits of x0
		bl	printf				// calling printf

		adrp	x0, formatIn			// moving the formatIn string to x0 for sccanf
		add	x0,x0,:lo12:formatIn		// adding format spcifier string to lower 12 bits of x0
		adr	x1, N				// x1 stores the address of N i.e it's a pointer to N
		bl	scanf				// call scanf

		adr	x1,N				// moving the address of N into x1
		ldrsw	checkNeg,[x1]			// dereferencing x1 to get the value of N and load into checkNeg

compare:	cmp	checkNeg, xzr			// compare checkNeg to xzr to check if its negative
		b.lt	convert				// if checkNeg<0 branch to convert to find the two's complement
		b.ge	isPositive			// else, branch to isPositive

convert:	mov	negToPos, checkNeg		// mov the user input from checkNeg to negToPos
		mvn	negToPos, negToPos		// store one's complement of negToPos back into negToPos
		add	negToPos, negToPos, 0x1		// add one to the one's complement of negToPos
		mov	pos_N, negToPos			// pos_N now has the two's complent of N 
		b	continue			// branch to continue

isPositive:	adr	x1, N				// if N is already positive, store the address of N into x1
		ldr	pos_N,[x1]			// derefernce x1 and store the result into pos_N
		b	continue			// branch to continue

continue:	mov	decimal_N, 0			// decimal_N = 0
		mov	i, 0				// setting for loop counter i = 0
		mov	x26, 64				// storing 64 in x26 to check if the condition of loop is satisfied

		b	test				// branch to test

test:		cmp	i, x26				// check if i<64
		b.lt	body				// if true, branch to body of loop
		b.ge	done				// if i>64 branch to done

body:		tst	pos_N, 0x1			// bitwise and the 0th bit of pos_N with 0x1 i.e if pos_N(0) = 0x1
		b.eq	bitclear			// tst sets the zero flag to 0 if the result of AND is 0, so b.eq checks if Z==0, if true we branch to bitclear
		b	bitset				// else, Z!=0 ,i.e AND is true we branch to bitset to calculate the decimal_N

bitset:		mov	pow_2,0x1			// Calculating 2^n: to find decimal_N, we first need 2^i or pow_2 
		mov	j,0				// setting loop counter for the for loop to 0
		b	powTest				// branch to loop test

powTest:	cmp	j,i				// if j<i	//Note here i = n i.e iteration number of outer loop
		b.lt	calcPower			// if j<i , branch to calcPower to find pow_2
		b.ge	calcDec				// else branch to calcDec to add pow_2 to Decimal_N

calcPower:	lsl	pow_2, pow_2, 0x1		// pow_2 << 0x1	
		add	j, j , 1			// increment j 
		b	powTest				// branch back to inner loop test

calcDec:	add	decimal_N, decimal_N, pow_2	// Decimal_N = Decimal_N + 2^i
		b	bitclear			// branch to bitclear to right shift pos_N
		
bitclear:	lsr	pos_N, pos_N, 0x1		// pos_N >> 0x1
		add	i, i, 1				// increment outer loop counter 		
		b	test				// branch to outer loop test

done:		cmp	checkNeg, xzr			// compare checkNeg, that has N value to 0
		b.lt	makeNeg				// if N<0 branch to makeNeg
		b.ge	end				// else branch to end

makeNeg:	mvn	decimal_N, decimal_N		// find one's complement  of decimal_N
		add	decimal_N, decimal_N, 1		// adding one to get 2's complement 
		b	end				// branch to end for printing
		
end:		adrp	x0, output			// mov output to x0
		add	x0, x0,:lo12:output		// set the lower 12 bits of x0 as output
		mov	x1, decimal_N			// pass deciaml_N as argument to printf
		bl	printf				// branch to printf

		mov	w0,0				// restoring system state in next 3 lines
		ldp	x29, x30, [sp], 16		// deallocate memory from stack
		ret					// return 

