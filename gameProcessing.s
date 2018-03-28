.section .text

.global gameProcessing
gameProcessing:
	push	{r4-r10, lr}
	bl	movePaddle
	pop	{r4-r10, pc}



@ Move Paddle-------------------------
movePaddle:
	push	{r4-r10, lr}
	
@ load prePaddle coordinates and clean prePaddle 


@ r0 ---- global_address

	paddleAdr	.req	r6
	paddleX		.req	r7
	paddleY		.req	r8	
	pressButton	.req	r9
	paddleStyle	.req	r10

	ldr	r0, =prePaddle		@get prepaddle_x and prepaddle_y
	ldr	paddleX, [r0]
	ldr	paddleY, [r0, #4]

@--------------------cleanCell----------------------------
	mov	r10, #0	
	ldr	r4, =floor
	
	mov	r5, #632
	mov	r6, #848

cleanCell:	
	push	{r4-r10}
	bl	drawCell
	pop	{r4-r10}
	
	add	r5, #32
	add	r10, #1

	cmp	r10, #20
	blt	cleanCell
	

@---------------------------------------------------------	
MovePaddle:
	
	ldr	r0, =stylePaddle	@check the style of Paddle
	ldr	paddleStyle, [r0]

	ldr	r0, =prePaddle		@get prepaddle_x and prepaddle_y
	ldr	paddleX, [r0]

	ldr	r0, =pressed_button	@get pressed_button
	ldr	pressButton, [r0]

	mov	r3, #3			@right
	cmp	pressButton, r3
	beq	right_Paddle1
	
	mov	r3, #9			@right + A
	cmp	pressButton, r3
	beq	right_A_Paddle1

	mov	r3, #2			@left
	cmp	pressButton, r3
	beq	left

	mov 	r3, #8			@left + A
	cmp	pressButton, r3
	beq	leftA
	
	b	continue

right_Paddle1:  
	cmp	paddleStyle, #1		@check the style of Paddle1
	bne	right_Paddle2
	ldreq	r3, =1140
	cmp	paddleX, r3	
	addle	paddleX, #5
	b	continue

right_Paddle2:
	cmp	paddleStyle, #2		@check the style of Paddle2
	ldreq 	r3, =1108
	cmp	paddleX, r3	
	addle	paddleX, #5
	b	continue

right_A_Paddle1: 
	cmp	paddleStyle, #1		@check the style of Paddle1
	bne	right_A_Paddle2
	ldreq	r3, =1135		
	cmpeq	paddleX, r3		
	addle	paddleX, #10
	b	continue

right_A_Paddle2:
	cmp	paddleStyle, #2		@check the style of Paddle2
	ldreq	r3, =1103
	cmp	paddleX, r3	
	addle	paddleX, #10
	b	continue

left:
	ldr	r3, =634
	cmpeq	paddleX, r3	
	subge	paddleX, #5
	b	continue

leftA:
	ldr	r3, =639
	cmpeq	paddleX, r3	
	subge	paddleX, #10

continue:
	ldr	r0, =curPaddle
	str	paddleX, [r0]
	
	ldr	paddleY, [r0, #4]
	
	cmp	paddleStyle, #1			@check the style of Paddle1
	ldreq	paddleAdr, =paddle1
	moveq	r4, #128
	
	cmp	paddleStyle, #2			@check the style of Paddle2
	ldreq	paddleAdr, =paddle2
	moveq	r4, #160

	mov	r2, r4
	ldr 	r3, =curPaddle			@ store the new length in curPaddle
	str	r2, [r3, #8]

	mov	r5, #32

	push	{r4-r10}
	bl	drawPicture
	pop	{r4-r10}

	ldr	r0, =curPaddle
	ldr	paddleX, [r0]			@ x
	ldr	r2, [r0, #8]			@ length

	ldr	r0, =prePaddle
	str	paddleX, [r0]			@ x
	str	r2, [r0, #8]			@ length
	



@Test_checkGameover:
@	ldr	r0, =lives
@	ldr	r1, [r0]
@	mov	r1, #0
@	str	r1, [r0]
		
@	cmp	r1, #0
@	bne	done
@
@	ldr	r0, =gameChoice
@	ldr	r1, [r0]
@	mov	r1, #5
@	str	r1, [r0]


done:
	.unreq		paddleX
	.unreq		paddleY
	.unreq		paddleAdr
	.unreq		pressButton
	.unreq		paddleStyle
	pop	{r4-r10, pc}