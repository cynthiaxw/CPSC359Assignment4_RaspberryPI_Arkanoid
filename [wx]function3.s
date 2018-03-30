pos mapOffset(int x, int y){
	pos tmp;
	tmp.x = (y - 80)/32;
	tmp.y = (x - 600)/32;
	return tmp;
}
// Calculate the gameMap offset
// Param:	r0 - x
//			r1 - y	(screen coordinates)
// Return:	r0 - x index
//			r1 - y index
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
global vp_checkstate
vp_checkState:
	push	{r4-r10, lr}
	
	vpx		.req	r4
	vpy		.req	r5
	vpt		.req	r6
	vpa		.req	r7
	tmpAdr	.req	r8
	
	ldr		vpx, [r0, #4]
	ldr		vpy, [r0, #8]
	ldr		vpt, [r0, #12]
	ldr		vpa, [r0, #16]
	
//------------------if 0 == vp[2] //not activated-----------------//	
	cmp		vpt, #0		//not activated
	bne		vp_else1
	
	mov		r0, vpx
	mov		r1, vpy
	bl		mapOffset		//get the corresponding map offset

	ldr		tmpAdr, =gameMap
		
	
	
	b		done		//return
	
//------------------if 1 == vp[2] //falling-----------------//
vp_else1:
	cmp		vpt, #1		//falling
	bne		vp_else2
	
	
	b		done		//return

//------------------if 2 == vp[2] //caught-----------------//
vp_else2:
	cmp		vpt, #2		//caught
	bne		done

done:					//lost
	.unreq	vpx
	.unreq	vpy
	.unreq	vpt
	.unreq	vpa
	.unreq	tmpAdr	
	pop		{r4-r10, pc}


void vp_checkState(int* vp){
	if(0 == vp[2]){	//not activated
		pos tmp;
		tmp = mapOffset(vp[0], vp[1]);	//get the corresponding map offset

		if(0 == gameMap[tmp.x][tmp.y]){	//brick cleared
			vp[2] = 1;	//change value pack state to falling 
		}
	}
	else if(1 == vp[2]){	//falling
		if(vp[1] > 879){	//lost
			vp[2] = 3;
			return;
		}
		else if(vp[1] > 816 && vp[1] < 880 && vp[0] > curPaddle[0] - 64 && vp[0] < curPaddle[0] + curPaddle[2]){	//hit paddle
			vp[2] = 2;	//caught
			return;
		}
		//clear previous pack
		pos tmp;
		tmp = mapOffset(vp[0], vp[1]);	//get the corresponding map offset
		drawLeftBrick(tmp.x,tmp.y,gameMap[tmp.x][tmp.y]);
		drawRightBrick(tmp.x,tmp.y+1,gameMap[tmp.x][tmp.y+1]);
		vp[1] += 2;
		printf("vp_y:%d\n", vp[1]);
		//draw current pack
		drawVP(vp[0], vp[1], vp[3]);
	}
	else if(2 == vp[2]){	//caught
		//clear previous pack
		pos tmp;
		tmp = mapOffset(vp[0], vp[1]);	//get the corresponding map offset
		drawLeftBrick(tmp.x,tmp.y,gameMap[tmp.x][tmp.y]);
		drawRightBrick(tmp.x,tmp.y+1,gameMap[tmp.x][tmp.y+1]);
		drawLeftBrick(tmp.x+1,tmp.y,gameMap[tmp.x+1][tmp.y]);
		drawRightBrick(tmp.x+1,tmp.y+1,gameMap[tmp.x+1][tmp.y+1]);

		if(1 == vp[3]){	//extend paddle
			curPaddle[2] = 160;
			prePaddle[2] = 160;
			stylePaddle = 2;
		}
		else if(2 == vp[3]){	//slow down ball
			plusMovement = 2;
			if(ballDirection[0] > 0)ballDirection[0] -= plusMovement;
			else ballDirection[0] += plusMovement;
			if(ballDirection[1] > 0)ballDirection[1] -= plusMovement;
			else ballDirection[1] += plusMovement;
		}
		else if(3 == vp[3]){	//add one life
			lives++;
			drawLives();
		}
		vp[2] = 3;
		return;
	}
	else if(3 == vp[2]){	//lost
		return;
	}	
}


void gameProcess(){
	
	if(pressed_button == 4){	//pause 	ST
		gameChoice = 2;
	}
	
	if(score == 60){	//win
		gameChoice = 7;
	}
	else if(curBall[1] > 856 && curBall[1] < 910){
		if(curBall[0] < 634 || curBall[0] > 1238){//hit left or right wall
			ballDirection[0] *= -1;
		}

		cleanBall(curBall[0], curBall[1]);
//Draw ball
		curBall[0] += ballDirection[0];
		curBall[1] += ballDirection[1];
		drawABall(curBall[0], curBall[1]);	
		preBall[0] = curBall[0];
		preBall[1] = curBall[1];
	}
	else if(curBall[1] > 856){
		lives --;
		drawLives();
		printf("lives: %d\n", lives);
		if(lives == 0){
			gameChoice = 5;
		}
		else{
			//updateBall();
			//cleanBall(curBall[0], curBall[1]);
			curBall[0] = 944;
			curBall[1] = 832;
			preBall[0] = 944;
			preBall[1] = 832;
			ballDirection[0] = 5;
			ballDirection[1] = -5;	
			plusMovement = 0;
					
			cleanPaddle();
								
			prePaddle[0] = 888;
			prePaddle[1] = 848;
			prePaddle[2] = 128;
			curPaddle[0] = 888;
			curPaddle[1] = 848;
			curPaddle[2] = 128;						
			stylePaddle = 1;			
			gameChoice = 6;			
			drawABall(curBall[0], curBall[1]);	
			draw_paddle(curPaddle[0], stylePaddle);
		}
	}
	else{
		vp_checkState(valuepack1);
		vp_checkState(valuepack2);
		vp_checkState(valuepack3);
		updateBall();
		movePaddle();
		draw_paddle(curPaddle[0], stylePaddle);
	}
}