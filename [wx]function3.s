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

//r0 - valuepack address
vp_not_act:
	push	{r4-r8, lr}

	vpAdr	.req	r4
	mov	r4, r0
	ldr	r5, [vpAdr]
	ldr	r6, [vpAdr, #4]
	mov	r0, r5
	mov	r1, r6
	bl	mapOffset
	
	mov	r5, r0
	mov	r6, r1

	//calculate the map offset r7 = r5*22+r6
	mov	r7, #22
	mul	r7, r5
	add	r7, r6

	ldr	r8, =gameMap
	ldrb	r8, [r8, r7]
	
	cmp	r8, #0		//valuepack.state = 1
	moveq	r5, #1	
	streq	r5, [vpAdr, #8]

	.unreq	vpAdr

	pop	{r4-r8, pc}

//clear previous value pack
//r0 - value pack address
.global	vp_clear_pre
vp_clear_pre:
	push	{r4-r8, lr}

	vpAdr	.req	r4
	mov	r4, r0
	ldr	r5, [vpAdr]		//valuepack.x
	ldr	r6, [vpAdr, #4]		//valuepack.y
	mov	r0, r5
	mov	r1, r6
	bl	mapOffset		
	
	mov	r5, r0		//tmp.x
	mov	r6, r1		//tmp.y

	//drawLeftBrick(tmp.x,tmp.y,gameMap[tmp.x][tmp.y]);
	//calculate the map offset r7 = r5*22+r6
	mov	r7, #22
	mul	r7, r5
	add	r7, r6
	ldr	r8, =gameMap
	ldrb	r8, [r8, r7]
	
	mov	r0, r5
	mov	r1, r6
	mov	r2, r8
	bl	drawLeftBrick

	//drawRightBrick(tmp.x,tmp.y+1,gameMap[tmp.x][tmp.y+1]);
	add	r7, #1
	add	r6, #1
	ldr	r8, =gameMap
	ldrb	r8, [r8, r7]
	mov	r0, r5
	mov	r1, r6
	mov	r2, r8
	bl	drawRightBrick
	
	.unreq	vpAdr

	pop	{r4-r8, pc}

//clear previous whole value pack
//r0 - valuepack address
.global vp_clear_whole
vp_clear_whole:
	push	{r4-r8, lr}

	vpAdr	.req	r4

	mov	r4, r0
	ldr	r5, [vpAdr]		//valuepack.x
	ldr	r6, [vpAdr, #4]		//valuepack.y
	mov	r0, r5
	mov	r1, r6
	bl	mapOffset		
	
	mov	r5, r0		//tmp.x
	mov	r6, r1		//tmp.y

	//drawLeftBrick(tmp.x,tmp.y,gameMap[tmp.x][tmp.y]);
	//calculate the map offset r7 = r5*22+r6
	mov	r7, #22
	mul	r7, r5
	add	r7, r6
	ldr	r8, =gameMap
	ldrb	r8, [r8, r7]
	
	mov	r0, r5
	mov	r1, r6
	mov	r2, r8
	bl	drawLeftBrick

	//drawRightBrick(tmp.x,tmp.y+1,gameMap[tmp.x][tmp.y+1]);
	add	r7, #1
	add	r6, #1
	ldr	r8, =gameMap
	ldrb	r8, [r8, r7]

	mov	r0, r5
	mov	r1, r6
	mov	r2, r8
	bl	drawRightBrick

	//drawLeftBrick(tmp.x+1,tmp.y,gameMap[tmp.x+1][tmp.y]);
	add	r5, #1
	sub	r6, #1
	//calculate the map offset r7 = r5*22+r6
	mov	r7, #22
	mul	r7, r5
	add	r7, r6
	ldr	r8, =gameMap
	ldrb	r8, [r8, r7]
	
	mov	r0, r5
	mov	r1, r6
	mov	r2, r8
	bl	drawLeftBrick

	//drawRightBrick(tmp.x+1,tmp.y+1,gameMap[tmp.x][tmp.y+1]);
	add	r6, #1
	//calculate the map offset r7 = r5*22+r6
	mov	r7, #22
	mul	r7, r5
	add	r7, r6
	ldr	r8, =gameMap
	ldrb	r8, [r8, r7]

	mov	r0, r5
	mov	r1, r6
	mov	r2, r8
	bl	drawRightBrick
	

	.unreq	vpAdr

	pop	{r4-r8, pc}


//extend paddle
.global vp_extend_paddle
vp_extend_paddle:
	push	{r4-r5, lr}
	
	ldr	r4, =curPaddle
	mov	r5, #160
	str	r5, [r4, #8]		//curPaddle.length = 160
	
	ldr	r4, =prePaddle		//prePaddle.length = 160
	mov	r5, #160
	str	r5, [r4, #8]

	ldr	r4, =stylePaddle	//stylePaddle = 2
	mov	r5, #2
	str	r5, [r4]

	pop	{r4-r5, pc}

//slow down ball
.global vp_slow_down
vp_slow_down:
	push	{r4-r5, lr}

	//plusMovement = 2
	ldr	r4, =plusMovement
	mov	r5, #2
	str	r5, [r4]
	
	//if(ballDirection.x > 0)ballDirection.x -= plusMovement;
	ldr	r4, =ballDirection
	ldr	r5, [r4]
	cmp	r5, #0
	subgt	r5, #2
	//else ballDirection.x += plusMovement;
	addle	r5, #2
	str	r5, [r4]

	//if(ballDirection.y > 0)ballDirection.y -= plusMovement;
	ldr	r4, =ballDirection
	ldr	r5, [r4, #4]
	cmp	r5, #0
	subgt	r5, #2
	//else ballDirection.y += plusMovement;
	addle	r5, #2
	str	r5, [r4, #4]
	
	pop	{r4-r5, pc}

//add one life
.global vp_add_life
vp_add_life:	
	push	{r4-r5, lr}

	ldr	r4, =lives
	ldr	r5, [r4]
	add	r5, #1
	str	r5, [r4]
	
	bl	drawLives	
		
	pop	{r4-r5, pc}

//judge if the paddle caught the value pack
//param: r0 - valuepack address
.global	vp_caught
vp_caught:
	push	{r4-r10, lr}
	
	mov	r4, r0
	mov	r0, #0		//default return 0
	
	ldr	r5, [r4, #4]	//vp.y
	cmp	r5, #816	//if vp.y > 816
	ble	vp_caught_done
	cmp	r5, #880	//if vp.y <880
	bge	vp_caught_done
	//if vp.x > curPaddle.x - 64
	ldr	r5, [r4]	//vp.x
	ldr	r6, =curPaddle
	ldr	r6, [r6]
	sub	r6, #64
	cmp	r5, r6
	ble	vp_caught_done
	//if vp.x < curPaddle.x + xurPaddle.length
	ldr	r8, =curPaddle
	ldr	r6, [r8]
	ldr	r7, [r8, #8]
	add	r6, r7
	cmp	r5, r6
	bge	vp_caught_done

	//vp.state = 2
	mov	r5, #2
	str	r5, [r4, #8]
	mov	r0, #1

vp_caught_done:
	pop	{r4-r10, pc}

// Check value pack states
// r0 - value-pack struct pointer
.global vp_checkState
vp_checkState:
	push	{r4-r10, lr}
	
	vpx	.req	r4
	vpy	.req	r5
	vpt	.req	r6
	vpa	.req	r7
	vpp	.req	r8	
	tmpAdr	.req	r9
	
	mov	vpp, r0
	ldr	vpx, [r0]
	ldr	vpy, [r0, #4]
	ldr	vpt, [r0, #8]
	ldr	vpa, [r0, #12]
	
//------------------if 0 == vp[2] //not activated-----------------//	
	cmp	vpt, #0		//not activated
	bne	vp_else1
	
	mov	r0, vpp
	bl	vp_not_act
	
	b	done		//return
	
//------------------if 1 == vp[2] //falling-----------------//
vp_else1:

	cmp	vpt, #1		//falling
	bne	vp_else2
	
	ldr	r10, =879
	cmp	vpy, r10	//if valuepack.y > 879, lost

	movgt	r10, #3
	strgt	r10, [vpp, #8]	//valuepack.state = 3, change state to lost
	bgt	done

	//judge if the paddle caught the value pack
	mov	r0, vpp
	bl	vp_caught
	cmp	r0, #1
	beq	done

vp_else1_continue:	
	//clear previous pack
	mov	r0, vpp
	bl	vp_clear_pre

	ldr	r10, [vpp, #4]		//valuepack.y+=2
	add	r10, #2
	str	r10, [vpp, #4]

	//draw current pack
	mov	r0, vpx
	add	r1, vpy, #2
	mov	r2, vpa
	bl	drawVP
		
	b	done		//return

//------------------if 2 == vp[2] //caught-----------------//
vp_else2:
	cmp	vpt, #2		//caught
	bne	done

	//clear previous pack
	mov	r0, vpp
	bl	vp_clear_whole

vp_ability1:
	//if valuepack.ability == 1	
	//extend paddle
	cmp	vpa, #1
	bne	vp_ability2

	bl	vp_extend_paddle

	b	vp_ability_done
	
vp_ability2:
	//else if valuepack.ability == 2
	//slow down the ball
	cmp	vpa, #2
	bne	vp_ability3

	bl	vp_slow_down

	b	vp_ability_done

vp_ability3:
	//else if valuepack.ability == 3
	//add one life
	bl	vp_add_life

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


//game process reset
.global	gp_reset
gp_reset:
	push	{r4-r10, lr}

	ldr	r0, =balldie
	bl	printf

	ldr	r4, =curBall
	mov	r5, #944
	str	r5, [r4]
	mov	r5, #832
	str	r5, [r4, #4]

	ldr	r4, =preBall
	mov	r5, #944
	str	r5, [r4]
	mov	r5, #832
	str	r5, [r4, #4]

	ldr	r4, =ballDirection
	mov	r5, #5
	str	r5, [r4]
	mov	r5, #-5
	str	r5, [r4, #4]

	ldr	r4, =plusMovement
	mov	r5, #0
	str	r5, [r4]

	bl	cleanPaddle

	ldr	r4, =prePaddle
	mov	r5, #888
	str	r5, [r4]
	mov	r5, #848
	str	r5, [r4, #4]
	mov	r5, #128
	str	r5, [r4, #8]

	ldr	r4, =curPaddle
	mov	r5, #888
	str	r5, [r4]
	mov	r5, #848
	str	r5, [r4, #4]
	mov	r5, #128
	str	r5, [r4, #8]

	ldr	r4, =stylePaddle
	mov	r5, #1
	str	r5, [r4]

	ldr	r4, =gameChoice
	mov	r5, #6
	str	r5, [r4]

	mov	r0, #944
	mov	r1, #832
	bl	drawABall

	mov	r0, #888
	mov	r1, #1
	bl	draw_paddle


	pop	{r4-r10, pc}



//judge if pause button pressed
.global gp_judge_pause
gp_judge_pause:
	push	{r4-r5, lr}
	
	ldr	r4, =pauseFlg
	ldr	r5, [r4]
	cmp	r5, #0		//if pauseFlg > 0
	beq	gp_jp_continue

	cmp	r5, #10		//if pauseFLg < 10, pauseFlg++
	addlt	r5, #1
	movge	r5, #0		//else, pauseFlg = 0

	str	r5, [r4]

gp_jp_continue:	

	ldr	r4, =pressed_button
	ldr	r4, [r4]
	cmp	r4, #4			//if pressed_button == 4
	bne	gp_jp_done
	ldr	r4, =pauseFlg
	ldr	r5, [r4]
	cmp	r5, #0			//&& if pauseFlg == 0
	bne	gp_jp_done
	mov	r5, #1			//pauseFlg = 1
	str	r5, [r4]
	ldr	r4, =gameChoice
	mov	r5, #2			//gameChoice = 2
	str	r5, [r4]
					
gp_jp_done:

	pop	{r4-r5, pc}


//game processing: judge if the ball hit the wall
.global	gp_hit_wall
gp_hit_wall:
	push	{r4-r7,lr}

	ldr	r4, =curBall
	ldr	r5, [r4]		//curBall.x
	ldr	r6, =634
	cmp	r5, r6			//if curBall.x > 634 && curBall.x < 1238 
	bge	gp_hit_wall_continue	//hit the wall
	ldr	r6, =1238
	cmp	r5, r6
	ble	gp_hit_wall_continue
	ldr	r4, =ballDirection
	ldr	r5, [r4]
	mov	r6, #-1
	mul	r5, r6
	str	r5, [r4]		//ballDirection.x *= -1

gp_hit_wall_continue:

	ldr	r4, =curBall
	ldr	r0, [r4]		
	ldr	r1, [r4, #4]
	bl	cleanBall		//cleanBall(curBall.x, curBall.y)

	ldr	r5, [r4]		
	ldr	r6, =ballDirection
	ldr	r7, [r6]
	add	r5, r7			//curBall.x += ballDirection.x
	str	r5, [r4]

	ldr	r5, [r4, #4]
	ldr	r7, [r6, #4]
	add	r5, r7
	str	r5, [r4, #4]		//curBall.y += ballDirection.y

	ldr	r0, [r4]
	ldr	r1, [r4, #4]
	
	ldr	r6, =preBall
	str	r0, [r6]
	str	r1, [r6, #4]		//preBall = curBall

	bl	drawABall		//draw current ball

	pop	{r4-r7, pc}



//gameProcessing main function
.global gameProcess
gameProcess:
	push	{r4-r10,lr}

	bl	gp_judge_pause
	
	ldr	r4, =score
	cmp	r4, #60
	bne	gp_else1
	ldr	r4, =gameChoice		//if score == 60
	mov	r5, #7			//gameChoice = 7
	str	r5, [r4]

	b	gp_done
gp_else1:
	ldr	r4, =curBall
	ldr	r5, [r4, #4]
	cmp	r5, #856		//if curBall.y >856
	ble	gp_else2
	//ldr	r5, [r4, #4]		//&&curBall.y < 910
	ldr	r6, =910
	cmp	r5, r6
	bge	gp_else2
	bl	gp_hit_wall

	b	gp_done
gp_else2:
	ldr	r4, =curBall
	ldr	r5, [r4, #4]		//if curBall.y > 856	//ball died
	cmp	r5, #856
	ble	gp_else3
	ldr	r4, =lives
	ldr	r5, [r4]
	sub	r5, #1
	str	r5, [r4]		//lives -- 

	ldr	r0, =debug
	mov	r1, r5
	bl	printf

	bl	drawLives
	cmp	r5, #0			//if lives == 0
	bne	gp_else2_next		//if lives != 0, reset
	ldr	r4, =gameChoice
	mov	r5, #5
	str	r5, [r4]		//gameChoice = 5
	bl	gp_done
	
gp_else2_next:
	bl	gp_reset
	
	b	gp_done
gp_else3:
	//normal ball movement
	//check valuepack
	//update ball
	//move and draw paddle
	ldr	r0, =valuepack1
	bl	vp_checkState
	ldr	r0, =valuepack2
	bl	vp_checkState
	ldr	r0, =valuepack3
	bl	vp_checkState

	bl	updateBall
	bl	movePaddle
	ldr	r0, =curPaddle
	ldr	r0, [r0]
	ldr	r1, =stylePaddle
	ldr	r1, [r1]
	bl	draw_paddle

gp_done:
	pop	{r4-r10, pc}



debug:	.ascii	"debug :%d\n"
balldie:	.ascii	"Ball has died!\n"


