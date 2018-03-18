
@ Code section
.section .text

.global drawPicture

@DrawPicture
@	pushed para: width, height, imgAdr, x_offset, y_offset	

drawPicture:

	width		.req	r4
	height		.req	r5
	px		.req	r6
	py		.req	r7
	imgAdr		.req	r8
	x_offset	.req	r9
	y_offset	.req	r10

	pop		{width, height, imgAdr, x_offset, y_offset}

	push		{r4-r10, lr}
	
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

	cmp	px, width
	bne	rowLoop1$

	add	py, #1
	cmp	py, height
	bne	columnLoop1$

	.unreq	width
	.unreq	height
	.unreq	px
	.unreq	py
	.unreq	imgAdr
	.unreq	x_offset
	.unreq	y_offset


	pop		{r4-r10,pc}

@ Draw Pixel
@  r0 - x
@  r1 - y
@  r2 - colour
.global DrawPixel
DrawPixel:
	push		{r4, r5}

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

	pop		{r4, r5}
	bx		lr
