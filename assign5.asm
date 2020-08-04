//Priyavart Rajain
// CPSC 355 Spring 2020
// University of Calgary

		.data										// write only part of the code
userinput:	.word 0										// stores user input
response:	.word 0										// stores user response to quit or continue
col_Num:	.word 0									 	// column number
element:	.word 0										// array element to write to log file
	
		.text										// read only part of the code
prompt:		.string "Enter a valid dimension of the table (2-10) :   "			// prompt teh user to entere a valid dimension
col_prompt:	.string "Enter a column number(0 to N) to sort by    "				// prompt teh user to choose a column
sort_display:	.string "Table sorted by column %d:"						// display sorted table
formatIn:	.string "%d"									// formatIn string for scanf
elem_fmt:	.string "%d  "									// to display the array
lineBreak:	.string "\n"
decide:		.string "Press 0 to quit the program now.\nPress 1  to continue sorting.  "	// decide whether to quit or continue
decision:	.string "Player response: %d"							// player response to store in logfile
err1:		.string "Error opening file\n"							// error checking for log file
err2:		.string "Error closing file\n"							// error chcking for log file
pn:		.string "assign5.log"								// log file name
voidString:	.string ""									// empty string for logging
Num:		.string " %d "									// num to store in log file
fp		.req	x29									// use fp for x29
lr		.req	x30									// use lr for x30


AT_FDCWD=	-100										// file descriptor
flagType=	02|0100|02000									// flag types to show the mode in which to handle the file
accessMode=	0700										// ccess mode specifier

maxDim=		10										// max dimension of array is 10
N_s=		16										// offset for storing N
N_size=		4										// size of N

response_s=	16+ N_size									// response offset 
response_size=	4										// size of response 

c_num_s=	16+ N_size+response_size							// column number offset
c_num_size=	4										// column numbetr size

table_s=	N_s+N_size+response_size+c_num_size						// table offset 
table_size=	10*10*4										// toral tabel size

var_size=	N_size+ response_size+ c_num_size+ table_size					// memory allocation for main
 
alloc=		-(16 + var_size)& -16								// memory allocation for main
dealloc=	-alloc										// memory deallocation for main

x19_size=	8										// x19 register size
x20_size=	8										// x20 register size
x21_size=	8										// x23 register size
x22_size=	8										// --
x23_size=	8										// -- 
x24_size=	8										// --
x25_size=	8										// -- 
x26_size=	8										// --
x27_size=	8										// --
x28_size=	8										// --

x19_s=		16										// x19 offset 
x20_s=		x19_s+x19_size									// x20 offset 8 bytes from x19 offset 
x21_s=		x20_s+x20_size									// --
x22_s=		x21_s+x21_size									// --
x23_s=		x22_s+x22_size									// --
x24_s=		x23_s+x23_size									// --
x25_s=		x24_s+x24_size									// --
x26_s=		x25_s+x25_size									// --
x27_s=		x26_s+x26_size									// --
x28_s=		x27_s+x27_size									// --
											
r_n_s=		16										// random number offset
r_m_s=		20										// multiplication offset	
rand_s=		24										// random number offset
udiv_s=		32										// unsign division result offset
		
r_n_size=	4										// r_n_size 4 bytes
r_m_size=	4										// r_m_size 4 bytes
rand_size=	8										// random number size 8 bytes
udiv_size=	8										// unsigned division 8 bytes

r_var_size=	r_n_size+ r_m_size+ rand_size+ udiv_size					// allocating memory for randnum function
r_alloc=	-(16+ r_var_size)& -16								// allicating memory for randNum function
r_dealloc=	-r_alloc									// deallocating memory 

i_var_size=	x21_size+ x22_size+ x23_size+ x24_size+ x25_size+x28_size			// allocating memory for initialize 
alloc2=	  	-(16+i_var_size)& -16								// allocatin meomory for initiaizr
dealloc2= 	-alloc2										// deallcoating memory for initiaize

d_var_size=	x19_size+ x20_size+ x21_size+ x22_size+ x23_size+ x24_size			// specifying memory for display function 
d_alloc=	-(16+d_var_size)& -16								// allocating memory
d_dealloc=	-d_alloc									// deallciating memoryt 

s_var_size=	x19_size+ x20_size+ x21_size+ x22_size+ x23_size+ x24_size+ x25_size+x26_size+ x27_size+ x28_size		// specifying memory for sort function
s_alloc=	-(16+s_var_size)& -16												// allocating memory for sort 
s_dealloc=	-s_alloc													// deallcoating memory for sort 

l_var_size=	x19_size+ x20_size+ x21_size+ x22_size+ x23_size+ x24_size+ x25_size						// specifying memory for logFile 
l_alloc=	-(16+l_var_size)& -16												// allocating memory for logFile
l_dealloc=	-l_alloc													// deallocating memory for Ligfile

		.balign 4									// align instructions
		.global main									// make main gloablly accessibel

//----------RANDNUM------------------------

randNum:	stp	fp, lr, [sp, r_alloc]!							// allcatig memory for randNum on stack
		mov	fp, sp									// moving the sp to fp
		
		mov	x9, 0									// n						
		mov	x10, 10									// m
		
		mov	x11, 0  								// randNum
		mov	x12, 0  								// udiv
		
		str	x9, [fp, r_n_s]								// stroe x9 on stack 
		str	x10,[fp, r_m_s]								// store x10 on stack
		str	x11,[fp, rand_s]
		str	x12,[fp, udiv_s]
		
		bl	rand									// calling rand
		
		mov	w9, w0									// storing result in w9
		ldr	x10,[fp, r_m_s]								// laod value of x10 from stack
		ldr	x11,[fp, rand_s]							// load value of x11 from stack
		ldr	x12,[fp, udiv_s]		
		
		udiv	w12, w9, w10								// divide w9 by w10 and store in w12
		msub	w11, w12, w10, w9							// msub and stroe result in w11, 
		
		SXTW	x11, w11								// sign extend the random number

		mov	x0, x11									// pass the random number to x0  for returning 
		
		ldp	fp, lr, [sp], r_dealloc							// deallocating memory from stack
		ret										// return to calling code
		
		
//----------INITIALIZE----------------------

initialize:	stp	x29, x30, [sp, alloc2]!							// allocating memory on stack for initializr
		mov	x29, sp									// move fp pounts to sp
		
		str	x21,[fp,x21_s]								// srore x21 in stack 
		str	x22,[fp,x22_s]								// store x22 on stack 
		str	x23,[fp,x23_s]								// -- 
		str	x24,[fp,x24_s]								// --
		str	x25,[fp,x25_s]								// -- 
		str	x28,[fp,x28_s]								// --
				
		mov	w21, 0									// i	
		mov	w22, 0									// j
		mov	w23, 0									// table base address
		mov	w24, 0									// random number
		mov	w25, 0									// location
		mov	w28, 0									// N
		mov	x23, x0									// table base 
		mov	x28, x1 								// N

		b	outerLoopTest								// branh to outetrLooptest

loopBody:	bl	randNum									// call rand num function 

		mov	x24, x0									// store random number in x24
			
		mul	w25, w21, w28								// i*N
		add	w25, w25, w22								// i*N + j
		lsl	w25, w25, 2								// (i*N + j)*4
		
		str	w24, [x23, w25,SXTW]							// store rand
		
		add	w22, w22,1								// add 1 to j
		b	innerLoopTest								// branch back to innerLoopTest

innerLoopTest:	cmp	w22, w28								// compare j to N
		b.lt	loopBody								// if less tahn branch to loopBody
		b.ge	incrementI								// if greater than equal branch to incremenI

incrementI:	add	w21, w21, 1								// i = i+ 1
		mov	w22, 0									// j =0 
		b.ge	outerLoopTest 								// brancg to outerLoopTest

outerLoopTest:	cmp	w21, w28								// i<N ?
		b.lt	innerLoopTest								// if less tahn go to innetrLoop
		b.ge	i_done									// else go to done

i_done:		ldr	x21,[fp, x21_s]								// load back value of x21
		ldr	x22,[fp, x22_s]								// load back teh balue of x22
		ldr	x23,[fp, x23_s]								// --
		ldr	x24,[fp, x24_s]								// --
		ldr	x25,[fp, x25_s]								// --
		ldr	x28,[fp, x28_s]								// -- 
								
		ldp	x29, lr, [sp], dealloc2							// dealloc memoryt from stack
		ret										// returm to calling code

//-------------S O R T-----------------------------
							
sort:		stp	fp, lr, [sp, s_alloc]!							// allocate memory on stack for sort function 
		mov	fp, sp									// fp points to top of stack 
		
		str	x19,[fp, x19_s]								// store x19 on stcak
		str	x20,[fp, x20_s]								// --
		str	x21,[fp, x21_s]								// --
		str	x22,[fp, x22_s]								// --
		str	x23,[fp, x23_s]								// --
		str	x24,[fp, x24_s]								// --
		str	x25,[fp, x25_s]								// --
		str	x26,[fp, x26_s]								// --
		str	x27,[fp, x27_s]								// --
		str	x28,[fp, x28_s]								// --
			
		mov	x27, x0	    								// table base
		mov	x19, x1	     								// col_Num
		mov	x23, x2	    								// N
		mov	x20, x19     								// j
		mov	x21, 0	     								// i
		mov	x22, 0	     								// k
		add	x22, x21, 1  								// k =i+1
		mov	x24, 0	     								// Temp
		mov	x25, 0
		mov	x26, 0
		mov	x28, 0	     								// next element in column
	
		b	s_outLoopTest								// branch to outer Loop

s_loopBody:	mul	w25, w21, w23								// w25 = i*N
		add	w25, w25, w20								// i*N + j
		lsl	w25, w25, 2								// (i*N + j)* 4
		ldr	w9,[x27, w25, SXTW]							// load array eleemnt at w25 to w9
		
		mul	w26, w22, w23								// w26 = (i+1)*N
		add	w26, w26, w20								// (i+1*N)+4 
		lsl	w26, w26, 2								// w26 * 4
		ldr	w28,[x27, w26, SXTW]							// stroe teh ele,memt at i+1 to w28

		cmp	w9, w28									// compate i  i+1 
		b.gt	if_body									// if gt , go to if_body 
		add	w22, w22, 1								// k  = k + 1
		b.le	s_kTest									// less tehn branch to s_kTest
		
//-------------SWAPPING------------

if_body:	mov	w24, w9									// w24 = w9	
		mov	w9, w28									// w9 = w28
		str	w28,[x27, w25, SXTW]							// storing w28 on stack 
		mov	w28, w24								// swapping 
		str	w28,[x27, w26, SXTW]							// sroeing w28 on stack 
		add	x22, x22, 1								// k = k + 1
		b	s_kTest									// brancg to s_kTest

s_kTest:	cmp	w22, w23								// compare w22 to w23
		b.lt	s_loopBody								// bracng to s_loopBody if lt 
		b.ge	s_incrementI								// ge to increment I 

s_incrementI:	add	w21, w21, 1								// i = i + 1
		add	w22, w21, 1								// j = j + 1 
		b.ge	s_inLoopTest								// b to inLoopTest 
		
s_inLoopTest:	cmp	w21, w23								// j < N ? 
		b.lt	s_kTest									// bracj to s_kest 
		add	x20, x20, 1 
		b.ge	s_outLoopTest

s_outLoopTest:	cmp	w20, w19								// compare w20 , w19 
		b.le	s_inLoopTest								// lt go to s_inLoopTest 
		b.ge	s_done									// ge go to s_done 

s_done:		ldr	x19,[fp, x19_s]								// load back th evalues from teh stack 
		ldr	x20,[fp, x20_s]								// -- 
		ldr	x21,[fp, x21_s]								// --
		ldr	x22,[fp, x22_s]								// -- 
		ldr	x23,[fp, x23_s]								// -- 
		ldr	x24,[fp, x24_s]								// -- 
		ldr	x25,[fp, x25_s]								// -- 
		ldr	x26,[fp, x26_s]								// -- 
		ldr	x27,[fp, x27_s]								// -- 
		ldr	x28,[fp, x28_s]								// -- 
 
		mov	x0, 0
		mov	x1, 0
		mov	x2, 0
		ldp	fp, lr, [sp], s_dealloc							// dealllciat mmeory from stack 
		ret										// return to calling code


//-------------DISPLAY---------------------------

display:	stp	fp, lr, [sp, d_alloc]!							// allocate memory for display 
		mov	fp, sp									// sp point sto fp 
		
		str	x19, [fp, x19_s]							// store registers om the stack 
		str	x20, [fp, x20_s]
		str	x21, [fp, x21_s]
		str	x22, [fp, x22_s]
		
		mov	x19, 0
		mov	x20, 0
		mov	x21, 0
		mov	x22, 0
		mov	x23, 0
		mov	x24, 0
		
		mov	x19, x0
		mov	x20, x1
		
		b	d_outLoopTest
		
d_loopBody:	mul	w23, w21, w20
		add	w23, w23, w22
		lsl	w23, w23, 2
		
		ldr	w24, [x19, w23, SXTW]

		adrp	x0, elem_fmt
		add	x0, x0, :lo12:elem_fmt
		mov	w1, w24
		bl	printf
		
		add	w22, w22, 1
		b	d_inLoopTest 

d_inLoopTest:	cmp	w22, w20
		b.lt	d_loopBody
		b.ge	d_incrementI

d_incrementI:   add	w21, w21, 1
		adrp	x0, lineBreak
		add	x0, x0, :lo12:lineBreak
		bl	printf
		mov	w22, 0
		b.ge	d_outLoopTest	
		
d_outLoopTest:	cmp	w21, w20
		b.lt	d_inLoopTest	
		b.ge	d_done
		
d_done:		ldr	x19, [fp, x19_s]
		ldr	x20, [fp, x20_s]
		ldr	x21, [fp, x21_s]
		ldr	x22, [fp, x22_s]
		ldr	x23, [fp, x23_s]
		ldr	x24, [fp, x24_s]
		mov	x0, 0
		mov	x1, 0
		ldp	fp, lr, [sp],d_dealloc
		ret
		
//-------------logFile---------------------------

logFile:	stp	fp, lr, [sp, l_alloc]!
		mov	fp, sp
				
		str	x19,[fp, x19_s]	// file discriptor
		str	x20,[fp, x20_s] // table base address
		str	x21,[fp, x21_s]	// N
		str	x22,[fp, x22_s] // i
		str	x23,[fp, x23_s]	// j
		str	x24,[fp, x24_s] // offset
		str	x25,[fp, x25_s] // randNum
		

		mov	x19, x0		
		mov	x20, x1
		mov	x21, x2
		mov	x22, 0		// i
		mov	x23, 0		// j
		mov	x24, 0		// offset
		mov	x25, 0		// rand num
		
		mov	w0, AT_FDCWD
		ldr	x1, =pn
		mov	w2, flagType
		mov	w3, accessMode
		mov	x8, 56
		svc	0
        	mov 	w19, w0
		
		
		b	l_outerLoopTest

l_loopBody:	mul	w24, w22, w21 
		add	w24, w24, w23
		lsl	w24, w24, 2

		ldr	w25, [x20, w24,SXTW]
		
        	mov 	w0, w19
		add	w25, w25, '0'
		ldr	x1, =element
		str	w25,[x1]
		mov	x2, 1
		mov	x8, 64
		svc	0		

		add	w23, w23, 1
		b	l_inLoopTest

l_inLoopTest:	cmp	w23, w21
		b.lt	l_loopBody
		b.ge	l_incrementI

l_incrementI:	add	w22, w22, 1
		mov	w23, 0

		mov	w0, w19
		ldr	x1, =lineBreak
		mov	x2, 1
		mov	x8, 64
		svc 	0
		b.ge	l_outerLoopTest

l_outerLoopTest: cmp	w22, w21
		 b.lt	l_inLoopTest
		 b.ge	l_done
		
l_done:		ldr	x19,[fp, x19_s]
		ldr	x20,[fp, x20_s]
		ldr	x21,[fp, x21_s]
		ldr	x22,[fp, x22_s]
		ldr	x23,[fp, x23_s]
		ldr	x24,[fp, x24_s]	
		ldr	x25,[fp, x25_s]

		mov	w0, w19
		mov	x8, 57
		svc	0
		
l_exit:		mov	w0, 0
		mov	w1, 0
		mov	w2, 0
		ldp	fp, lr, [sp], l_dealloc
		ret

//--------------MAIN------------------------------
		
main:		stp	fp, lr, [sp, alloc]!
		mov	fp, sp
		
		ldr	x0, [x1, 8]
		bl	atoi
		
		mov	x19, x0
		mov	x20, 10
compare:	cmp	x19, x20
		b.gt	validate
		b.le	store		

validate:	adrp	x0, prompt
		add	x0, x0, :lo12:prompt
		bl	printf
		
		adrp	x0, formatIn
		add	x0, x0, :lo12:formatIn
		
		adr	x1, userinput
		bl	scanf
		
		adr	x1, userinput
		ldr	w19, [x1]
		SXTW	x19, w19
		b	compare

store:		str	x19, [fp, N_s]	
		
		mov	x0, xzr
		bl	time
		bl	srand
		
		add	x0, fp, table_s
		mov	x1, x19

		bl	initialize
		
		ldr	x19, [fp, N_s]
		mov	x0, 0
		mov	x1, 0

		add	x0, fp, table_s
		mov	x1, x19
		
		bl	display	
		
//--------------LOGGING-------------------------
					
		
		mov	w23, AT_FDCWD
		SXTW	x23, w23
		mov	x0, x23		 //file descriptor
		add	x1, fp, table_s  // table base
		mov	x2, x19		 // N
		bl	logFile
		
		adr	x1, response
		ldr	x21, [x1]
		mov	x22, 1
		
promptCol:	cmp	x22, x21
		b.eq	loopEnd

		adrp	x0, col_prompt
		add	x0, x0, :lo12:col_prompt
		bl	printf

		adrp	x0, formatIn
		add	x0, x0, :lo12:formatIn
		adr	x1, col_Num
		bl	scanf

		adr	x1, col_Num
		ldr	w20, [x1]
		SXTW	x20, w20		
		
		ldr	w19, [fp, N_s]
		SXTW	x19, w19

		cmp	x20, x19
		b.ge	promptCol	

		add	x0, fp, table_s
		mov	x1, x20
		mov	x2, x19
		bl	sort
		
		add	x0, fp, table_s
		mov	x1, x19
		bl	display
		
		mov	x0, x23
		add	x1, fp, table_s
		mov	x2, x19
		bl	logFile
		
		adrp	x0, decide
		add	x0, x0, :lo12:decide
		bl	printf

		adrp	x0, formatIn
		add	x0, x0, :lo12:formatIn
		adr	x1, response
		bl	scanf	
				
		adr	x1, response
		ldr	x22, [x1]
		b	promptCol	

loopEnd:	mov	w0, 0
		mov	w1, 0
		ldp	fp, lr, [sp], dealloc
		ret		

