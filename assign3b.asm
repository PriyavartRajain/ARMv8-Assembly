/* Submitted by: Priyavart Rajian
University of Calgary
Course:		 CPSC 355 Spring 2020*/

/* Assignment 3 : assign3b */
/* This program converts decimal to binary*/
/* Defining the macros for the registers */

define(pos_N, x19)							// pos_N is the macro for x19
define(binary_N, x20)							// binary_N is the macro for x20
define(quotient, x21)							// quotient is the macro for x21
define(remainder, x22)							// remainder is the macro for x22
define(i,x23)								// i is the macro for x24, shift count with eveery iteration of while loop
define(two, x24)							// two is the macro for x24, stores teh value 2
define(checkNeg, x26)							// checkNeg is the macro for x26, to check if N<0
define(negToPos, x27)							// negToPos is the macro for x27 to find the 2's complemnt of N

input:		.string "\nEnter a number in decimal system:	"	// input string to prompt the user for input
formatIn:	.string "%d"						// format specifier for scanf
output:		.string "\nOutput:    %d\n"				// output string for printing output

		.data							// write part of program
N:		.word 0							// declare variable N to take input from user
					
		.text							// read only part of the program
		.balign 4						// align the instructions for proper execution
		.global main						// make main gloablly accesible
						
main:		stp	x29,x30,[sp, -16]!				// allocate 16 bytes on stack for the program
		mov	x29, sp						// assign frame pointer the value of sp

		adrp	x0, input					// setting 1st argument for printf
		add	x0,x0,:lo12:input				// setting lower order 12 bits of x0 to printf
		bl 	printf						// call printf
						
		adrp	x0, formatIn					// setting the format specifier for scanf
		add	x0, x0, :lo12:formatIn				// setting the lower oder 12 bits of x0 to formatIn
		adr	x1, N						// assignong the address of N to x1
		bl	scanf						// calling scanf

		adr	x1, N						// assigning the address of N to x1
		ldrsw	checkNeg,[x1]					// dereferencing x1 to load the input value into checkNeg

compare:	cmp	checkNeg, xzr					// if checkNeg<0
		b.lt	convert						// branch to convert
		b.ge	isPositive					// else branch to isPositive

convert:	mov	negToPos, checkNeg				// move the value of checkNeg to negToPos
		mvn	negToPos, negToPos				// cacualate one's complement of negToPos
		add	negToPos, negToPos, 0x1				// adding one to get 2's complement of negToPos
		mov	pos_N, negToPos					// pos_N now has the 2's complemnt of N
		b	continue					// branch to continue
		
isPositive:	adr	x1, N						// x1 points to N
		ldr	pos_N, [x1]					// dereferencing x1 to load the value of N into pos_N
		
continue:	mov	binary_N, 0					// binary_N = 0
		mov	quotient, pos_N					// quotient = N
		mov	remainder, 0					// remainder = 0
		mov	i, 0						// shift count i
		mov	two, 2						// two = 2
		
test:		cmp	quotient, xzr					// compare quotient to xzr
		b.ne	body						// if quotient!=0 branch to body
		b.eq	done						// if quotient =0 branch to done
		
body:		and	remainder, quotient, 0x1			// getting the last bit of quotient when performed and with 0x1
		udiv	quotient, quotient, two				// quotient = quotient/2
				
		lsl	remainder, remainder, i				// remainder = remainder << i
		
		orr	binary_N, binary_N, remainder			// binary_N = binary_N | remainder
	
		add	i, i, 0x1					// i++

		b	test						// branch to loop test
		
done:		cmp	checkNeg, xzr					// compare user input with xzr
		b.lt 	isNegative					// if N<0 branch to isNegative
		b.ge	end						// if greater than or equal branch to end

isNegative:	mvn	binary_N, binary_N				// store one's complenet of binary_N in binary_N
		add	binary_N, binary_N, 1				// adding one to get 2's complement of binary_N
		b	end 						// branch to end
		
end:		adrp	x0, output					// first argument of printf is output string 
		add	x0,x0,:lo12:output				// adding output to lower 12 bits of x0
		mov	x1, binary_N					// pass binary_N as argument to printf

		bl	printf						// call printf

		mov	w0, 0						// return the system state
		ldp	x29, x30, [sp], 16				// deallocate memory from stack
		ret							// return
