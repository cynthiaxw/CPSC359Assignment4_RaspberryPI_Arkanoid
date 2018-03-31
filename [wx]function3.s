@ Code section
.section .text


// Calculate the gameMap offset
// Param:	r0 - x
//		r1 - y	(screen coordinates)
// Return:	r0 - x index
//		r1 - y index
// Note:	How return value works - gameMap[r0][r1]
.global mapOffset
mapOffset:	
	push	{r4, r5, lr}
	
	tmpx	.req	r4
	tmpy	.req	r5
	
	sub		tmpx, r1, #80		// r0 = tmpx = (r1 - 80)/32
	sub		tmpy, r0, #600		// r1 = tmpy = (r0 - 600)/32
	lsr		r0, tmpx, #5
	lsr		r1, tmpy, #5
	
	.unreq	tmpx
	.unreq	tmpy
	pop		{r4, r5, pc}


// Check value pack states
// r0 - value-pack struct pointer
.global vp_checkState
vp_checkState:
	push	{r4-r10, lr}
	
	vpx		.req	r4
	vpy		.req	r5
	vpt		.req	r6
	vpa		.req	r7
	vpp		.req	r8	
	tmpAdr	.req	r9
	
	mov	vpp, r0
	ldr	vpx, [r0]
	ldr	vpy, [r0, #4]
	ldr	vpt, [r0, #8]
	ldr	vpa, [r0, #12]
	
//------------------if 0 == vp[2] //not activated-----------------//	
	cmp	vpt, #0		//not activated
	bne	vp_else1
	
	mov	r0, vpx
	mov	r1, vpy
	bl	mapOffset		//get the corresponding map offset

	ldr	tmpAdr, =gameMap
	mov	r10, #22
	mul	r0, r10 //offset = r0*22 + r1	
	add	r0, r1
	ldr	r10, [tmpAdr, r0, lsl #2] //gameMap[tmpx][tmpy]
	
	cmp	r10, #0
	moveq	r10, #1
	ldreq	r10, [vpp, #8]	//valuepack.state = 1 - change state to falling
	
	b	done		//return
	
//------------------if 1 == vp[2] //falling-----------------//
vp_else1:
	cmp	vpt, #1		//falling
	bne	vp_else2
	
	ldr	r10, =879
	cmp	vpy, r10	//if valuepack.y > 879, lost
	movgt	r10, #3
	ldrgt	r10, [vpp, #8]	//valuepack.state = 3, change state to lost
	bgt	done

// caught if(vp[1] > 816 && vp[1] < 880 && vp[0] > curPaddle[0] - 64 && vp[0] < curPaddle[0] + curPaddle[2])
	cmp	vpy, #816
	ble	vp_else1_continue
	cmp	vpy, #880
	bge	vp_else1_continue
	ldr	tmpAdr, =curPaddle
	ldr	r10, [tmpAdr]		//curPaddle.x
	ldr	r7, [tmpAdr, #8]	//curPadlle.length
	sub	r10, #64
	cmp	vpx, r10
	ble	vp_else1_continue
	add	r10, #64
	add 	r10, r7
	cmp	vpx, r10
	bge	vp_else1_continue
	
	mov	r10, #2
	ldr	r10, [vpp, #8]	//valuepack.state = 2 - change state to caught
	b	done

vp_else1_continue:
	//clear previous pack
	push	{r4-r10}
	
	mov	r0, vpx
	mov	r1, vpy
	bl	mapOffset
	mov	r4, r0		//x offset
	mov	r5, r1		//y offset
	ldr	tmpAdr, =gameMap
	mov	r6, #22
	mul	r6, r4 //offset = r6*22 + r5	
	add	r6, r5
	ldr	r7, [tmpAdr, r6, lsl #2] //gameMap[x_off][y_off]
	
	mov	r0, r4
	mov	r1, r5
	mov	r2, r7
	bl	drawLeftBrick

	add	r5, #1
	mov	r6, #22
	mul	r6, r4 //offset = r6*22 + r5	
	add	r6, r5
	ldr	r7, [tmpAdr, r6, lsl #2] //gameMap[x_off][y_off+1]

	mov	r0, r4
	mov	r1, r5
	mov	r2, r7
	bl	drawRightBrick
	
	ldr	r10, [vpp, #4]		//valuepack.y+=2
	add	r10, #2
	str	r10, [vpp, #4]
	
	pop	{r4-r10}
		
	b	done		//return

//------------------if 2 == vp[2] //caught-----------------//
vp_else2:
	cmp	vpt, #2		//caught
	bne	done

	//clear previous value pack
	push	{r4-r10}
	mov	r0, vpx
	mov	r1, vpy
	bl	mapOffset
	
	mov	r4, r0		//x offset
	mov	r5, r1		//y offset
	ldr	tmpAdr, =gameMap

	mov	r6, #22
	mul	r6, r4 //offset = r6*22 + r5	
	add	r6, r5
	ldr	r7, [tmpAdr, r6, lsl #2] //gameMap[x_off][y_off]
	mov	r0, r4
	mov	r1, r5
	mov	r2, r7
	bl	drawLeftBrick	//drawLeftBrick(tmp.x,tmp.y,gameMap[tmp.x][tmp.y]);
	
	add	r5, #1
	mov	r6, #22
	mul	r6, r4 //r6 = offset = r6*22 + r5	
	add	r6, r5
	ldr	r7, [tmpAdr, r6, lsl #2] //gameMap[x_off][y_off+1]
	mov	r0, r4
	mov	r1, r5
	mov	r2, r7	
	bl	drawRightBrick	//drawRightBrick(tmp.x,tmp.y+1,gameMap[tmp.x][tmp.y+1]);

	add	r4, #1
	sub	r5, #1
	mov	r6, #22
	mul	r6, r4 //r6 = offset = r6*22 + r5	
	add	r6, r5
	ldr	r7, [tmpAdr, r6, lsl #2] //gameMap[x_off][y_off+1]
	mov	r0, r4
	mov	r1, r5
	mov	r2, r7	
	bl	drawLeftBrick	//drawLeftBrick(tmp.x+1,tmp.y,gameMap[tmp.x+1][tmp.y]);

	add	r5, #1
	mov	r6, #22
	mul	r6, r4 //r6 = offset = r6*22 + r5	
	add	r6, r5
	ldr	r7, [tmpAdr, r6, lsl #2] //gameMap[x_off][y_off+1]
	mov	r0, r4
	mov	r1, r5
	mov	r2, r7	
	bl	drawRightBrick//drawRightBrick(tmp.x+1,tmp.y+1,gameMap[tmp.x+1][tmp.y+1]);

	pop	{r4-r10}

vp_ability1:
	//if valuepack.ability == 1	
	//extend paddle
	cmp	vpa, #1
	bne	vp_ability2

	//curPaddle.length = 160
	ldr	tmpAdr, =curPaddle
	mov	r10, #160
	str	r10, [tmpAdr, #8]

	//prePaddle/length = 160
	ldr	tmpAdr, =prePaddle
	mov	r10, #160
	str	r10, [tmpAdr, #8]

	//stylePaddle = 2
	ldr	tmpAdr, =stylePaddle
	mov	r10, #2
	str	r10, [tmpAdr]

	b	vp_ability_done
	
vp_ability2:
	push	{r4-r10}
	//else if valuepack.ability == 2
	//slow down the ball
	cmp	vpa, #2
	bne	vp_ability3

	//plusMovement = 2
	ldr	tmpAdr, =plusMovement
	mov	r10, #2
	ldr	r10, [tmpAdr]

	//substract plusMovement from the abstract value of ball movement 
	ldr	tmpAdr, =ballDirection
	ldr	r4, [tmpAdr]		//ballDirection.x
	ldr	r5, [tmpAdr, #4]	//ballDirection.y

	cmp	r4, #0
	subgt	r4, #2			//if ballDirection.x > 0, -=2
	addle	r4, #2			//else, +=2
	str	r4, [tmpAdr]
	
	cmp	r5, #0
	subgt	r5, #2			//if ballDirection.y > 0, -=2
	addle	r5, #2			//else, +=2
	str	r5, [tmpAdr, #4]
 
	pop	{r4-r10}
	b	vp_ability_done

vp_ability3:
	//else if valuepack.ability == 3
	//add one life
	ldr	tmpAdr, =lives
	ldr	r10, [tmpAdr]
	add	r10, #1
	str	r10, [tmpAdr]
	bl	drawLives

vp_ability_done:
	mov	r10, #3
	str	r10, [vpp, #8]

done:					//lost
	.unreq	vpx
	.unreq	vpy
	.unreq	vpt
	.unreq	vpa
	.unreq	tmpAdr	
	pop		{r4-r10, pc}
