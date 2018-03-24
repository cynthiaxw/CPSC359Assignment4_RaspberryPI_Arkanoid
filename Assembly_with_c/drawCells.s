@ Code section
.section .text

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@--------------------Modified on Sat. 3.24---------------------@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ r0 - x
@ r1 - y
@ screen coordinates
@ draw a floor cell
.global drawACell
drawACell:
	push	{lr}
	ldr	r2, = floor
	bl	drawPicture
	pop	{pc}


@ r0 - x
@ r1 - y
@ screen coordinates
@ draw a ball cell
.global drawABall
drawABall:
	push		{r4-r8, lr}
	px		.req	r4
	py		.req	r5
	imgAdr		.req	r6
	x_offset	.req	r7
	y_offset	.req	r8

	ldr imgAdr, =ball
	mov	x_offset, r0
	mov	y_offset, r1
	
	mov 	py, #0

columnLoop2$:
	mov	px, #0
	
rowLoop2$:
	
	@drawPixel
	add	r0, px, x_offset
	add	r1, py, y_offset
	ldr	r2, [imgAdr], #4
	ldr	r3, =0xffffff
	cmp	r2, r3
	blne	DrawPixel

	add	px, #1

	cmp	px, #32		@width
	bne	rowLoop2$

	add	py, #1
	cmp	py, #32		@height
	bne	columnLoop2$

	.unreq	px
	.unreq	py
	.unreq	imgAdr
	.unreq	x_offset
	.unreq	y_offset


	pop		{r4-r8, pc}