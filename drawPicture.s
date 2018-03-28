
@ Code section
.section .text

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
	@pop		{width, height, imgAdr, x_offset, y_offset}
	
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



.global drawCell

@DrawCell
@	pushed para: width, height, imgAdr, x_offset, y_offset	

drawCell:
	push {r4-r10, lr}	// 8 pushed

	px		.req	r4
	py		.req	r5
	imgAdr		.req	r6
	x_offset	.req	r7
	y_offset	.req	r8

	width		.req	r9
	height		.req	r10

	mov		width, #32
	mov		height, #32

	ldr imgAdr, [sp, #(8*4)]
	ldr x_offset, [sp, #(9*4)]
	ldr y_offset, [sp, #(10*4)]
		
	@pop		{imgAdr, x_offset, y_offset}

	@push		{lr}

	
	mov 	py, #0

columnLoop1$:
	mov	px, #0
	
rowLoop1$:
	
	@drawPixel
	add	r0, px, x_offset
	add	r1, py, y_offset
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


	pop		{r4-r10, pc}


.global drawPicture

@DrawPicture
@	pushed para: width, height, imgAdr, x_offset, y_offset	

drawPicture:
	push 		{r4-r10, lr}	// 8 pushed

	px		.req	r4
	py		.req	r5
	imgAdr		.req	r6
	x_offset	.req	r7
	y_offset	.req	r8
	width		.req	r9
	height		.req	r10


	ldr	width, [sp, #(8*4)]
	ldr 	height, [sp, #(9*4)]
	ldr 	imgAdr, [sp, #(10*4)]
	ldr 	x_offset, [sp, #(11*4)]
	ldr 	y_offset, [sp, #(12*4)]
	
	mov 	py, #0

columnMenu$:
	mov	px, #0
	
rowMenu$:
	
	@drawPixel
	add	r0, px, x_offset
	add	r1, py, y_offset
	ldr	r2, [imgAdr], #4
	ldr	r3, =0xffffff
	cmp	r2, r3
	blne	DrawPixel

	add	px, #1

	cmp	px, width
	bne	rowMenu$

	add	py, #1
	cmp	py, height
	bne	columnMenu$

	.unreq	width
	.unreq	height
	.unreq	px
	.unreq	py
	.unreq	imgAdr
	.unreq	x_offset
	.unreq	y_offset

	pop		{r4-r10, pc}

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
