@ floor - 640*770 - 592, 107
@ ball	- 15*15 - 
@ bricks*3 & valuepack - 60*30
@ startgame - 180*60
@ quit - 180*60
@ restart - 180*60
@ selection box - 200*80
@ penal - 148*28


@ Code section
.section .text

.global main
main:
	@ ask for frame buffer information
	ldr 		r0, =frameBufferInfo 	@ frame buffer information structure
	bl		initFbInfo

	@display floor
	mov		r4, #640		@ width
	mov		r5, #770		@ height
	ldr		r6, =floor		@ image address
	mov		r7, #592		@ x offset
	mov		r8, #107		@ y offset
	push		{r4-r8}
	bl		drawPicture

	@display startmenu
	mov		r4, #640		@ width
	mov		r5, #770		@ height
	ldr		r6, =startmenu		@ image address
	mov		r7, #592		@ x offset
	mov		r8, #107		@ y offset
	push		{r4-r8}
	bl		drawPicture

	@diapaly selection box
	mov		r4, #200		@ width
	mov		r5, #80			@ height
	ldr		r6, =box		@ image address
	mov		r7, #812		@ x offset
	mov		r8, #492		@ y offset
	push		{r4-r8}
	bl		drawPicture

	@display startgame button
	mov		r4, #180		@ width
	mov		r5, #60			@ height
	ldr		r6, =startgame		@ image address
	mov		r7, #822		@ x offset
	mov		r8, #502		@ y offset
	push		{r4-r8}
	bl		drawPicture


	@dispaly quit button
	mov		r4, #180		@ width
	mov		r5, #60			@ height
	ldr		r6, =quit		@ image address
	mov		r7, #822		@ x offset
	mov		r8, #622		@ y offset
	push		{r4-r8}
	bl		drawPicture



	mov		r4, #15		@ width
	mov		r5, #15			@ height
	ldr		r6, =ball		@ image address
	mov		r7, #790		@ x offset
	mov		r8, #502		@ y offset
	push		{r4-r8}
	bl		drawPicture

@b1:	mov 		r4, r0


haltLoop$:
	b	haltLoop$











@ Draw the character 'B' to (0,0)
DrawCharB:
	push		{r4-r8, lr}

	chAdr		.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask		.req	r8
	pxstr		.req	r9


	ldr		chAdr, =font		@ load the address of the font map
	@mov		r0, #'B'		@ load the character into r0
	add		chAdr,	r0, lsl #4	@ char address = font base + (char * 16)

	mov		py, r1		@ init the Y coordinate (pixel coordinate)
	mov		pxstr, r2

charLoop$:
	mov		px, pxstr		@ init the X coordinate

	mov		mask, #0x01		@ set the bitmask to 1 in the LSB
	
	ldrb		row, [chAdr], #1	@ load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		@ test row byte against the bitmask
	beq		noPixel$

	mov		r0, px
	mov		r1, py
	mov		r2, #0x00FF0000		@ red
	bl		DrawPixel		@ draw red pixel at (px, py)

noPixel$:
	add		px, #1			@ increment x coordinate by 1
	lsl		mask, #1		@ shift bitmask left by 1

	tst		mask,	#0x100		@ test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$

	add		py, #1			@ increment y coordinate by 1

	tst		chAdr, #0xF
	bne		charLoop$		@ loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask
	.unreq  pxstr

	pop		{r4-r8, pc}

@ Data section
.section .data

.align
.globl frameBufferInfo
frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen height

.align 4
font:		.incbin	"font.bin"
