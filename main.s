
@ Code section
.section .text

.global main
main:
	@ ask for frame buffer information
	ldr 		r0, =frameBufferInfo 	@ frame buffer information structure
	bl		initFbInfo

	mov		r4, #199		@ width
	mov		r5, #199		@ height
	ldr		r6, =image		@ image address
	mov		r7, #200		@ x offset
	mov		r8, #200		@ y offset
	push		{r4-r8}
	bl		drawPicture

	mov		r4, #199		@ width
	mov		r5, #199		@ height
	ldr		r6, =image		@ image address
	mov		r7, #400		@ x offset
	mov		r8, #400		@ y offset
	push		{r4-r8}
	bl		drawPicture

	@ stop
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
