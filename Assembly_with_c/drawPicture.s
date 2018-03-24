
@ Code section
.section .text

.global drawPaddle
@	Paddle
@	pushed para: width, height, imgAdr, x_offset, y_offset

drawPaddle:
	push		{r4-r10, lr}
	width		.req	r4
	height		.req	r5
	px		.req	r6
	py		.req	r7
	imgAdr		.req	r8
	x_offset	.req	r9
	y_offset	.req	r10

	ldr width, [sp, #(8*4)]
	ldr height, [sp, #(9*4)]
	ldr imgAdr, [sp, #(10*4)]
	ldr x_offset, [sp, #(11*4)]
	ldr y_offset, [sp, #(12*4)]
	@pop		{width, height, imgAdr, x_offset, y_offset}
	
	mov 	py, #0

columnLoop3$:
	mov	px, #0
	
rowLoop3$:
	
	@drawPixel
	add	r0, px, x_offset
	add	r1, py, y_offset
	ldr	r2, [imgAdr], #4
	ldr	r3, =0xffffff
	cmp	r2, r3
	blne	DrawPixel

	add	px, #1

	cmp	px, width
	bne	rowLoop3$

	add	py, #1
	cmp	py, height
	bne	columnLoop3$

	.unreq	width
	.unreq	height
	.unreq	px
	.unreq	py
	.unreq	imgAdr
	.unreq	x_offset
	.unreq	y_offset


	pop		{r4-r10, pc}




.global drawBall
@	drawBall
@	pushed para: width, height, imgAdr, x_offset, y_offset	

drawBall:
	push		{r4-r10, lr}
	width		.req	r4
	height		.req	r5
	px		.req	r6
	py		.req	r7
	imgAdr		.req	r8
	x_offset	.req	r9
	y_offset	.req	r10

	ldr width, [sp, #(8*4)]
	ldr height, [sp, #(9*4)]
	ldr imgAdr, [sp, #(10*4)]
	ldr x_offset, [sp, #(11*4)]
	ldr y_offset, [sp, #(12*4)]
	
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

	cmp	px, width
	bne	rowLoop2$

	add	py, #1
	cmp	py, height
	bne	columnLoop2$

	.unreq	width
	.unreq	height
	.unreq	px
	.unreq	py
	.unreq	imgAdr
	.unreq	x_offset
	.unreq	y_offset


	pop		{r4-r10, pc}



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@--------------------Modified on Sat. 3.24---------------------@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global drawPicture

@ DrawPicture
@ param: 
@ r0 - x
@ r1 - y
@ r2 - imgAdr
@ Draw a cell on screen coordinates (x,y) 

drawPicture:
	push {r4-r8, lr}	// 8 pushed

	px		.req	r4
	py		.req	r5
	imgAdr		.req	r6	@r2
	x_offset	.req	r7	@r0
	y_offset	.req	r8	@r1
	
	mov	x_offset, r0
	mov	y_offset, r1
	mov	imgAdr, r2

	
	mov 	py, #0

columnLoop1$:
	mov	px, #0
	
rowLoop1$:
	
	@drawPixel
	add		r0, px, x_offset
	add		r1, py, y_offset
	ldr	r2, [imgAdr], #4
	bl	DrawPixel

	add	px, #1

	cmp	px, #32		@width
	bne	rowLoop1$

	add	py, #1
	cmp	py, #32		@height
	bne	columnLoop1$

	.unreq	px
	.unreq	py
	.unreq	imgAdr
	.unreq	x_offset
	.unreq	y_offset


	pop		{r4-r8, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@--------------------Modified on Sat. 3.24---------------------@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Draw Pixel
@  r0 - x
@  r1 - y
@  r2 - colour
.global DrawPixel
DrawPixel:
	push		{r4, r5, lr}

	offset		.req	r4

	ldr		r5, =frameBufferInfo	

	@ offset = (y * width) + x
	
	ldr		r3, [r5, #4]		@ r3 = width
	mul		r1, r3
	add		offset,	r0, r1
	
	@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	lsl		offset, #2

	@ store the colour (word) at frame buffer pointer + offset
	ldr		r0, [r5]		@ r0 = frame buffer pointer
	str		r2, [r0, offset]

	pop		{r4, r5, pc}
