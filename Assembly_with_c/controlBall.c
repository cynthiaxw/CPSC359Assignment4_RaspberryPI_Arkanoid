#include <stdio.h>
#include <stdlib.h>

//Function prototypes
void drawABall(int x, int y);	//param: x,y - draw ball on (x,y)
void drawACell(int x, int y);	//param: x,y - draw floor on (x,y)


//floor 32*32 cell
//ball 32*32

int ball_x;
int ball_y;
int d_x;	//direction x
int d_y;	//direction y
int preBall_x;
int preBall_y;
int moveFlg;
extern void ballMove();


//draw all floors and a ball
void drawInitGameSate(){
	//draw floor
	for(int i = 600; i<=1304; i+=32){
		for(int j = 80; j<=944; j+=32){
			drawACell(i,j);	
		}
	}
	//at last, draw ball
	drawABall(ball_x, ball_y);
}

//clean previous ball position
//previous position(cell) draw floor 
void cleanPreBall(){	
	//calculus last cell coordinates according to pre ball screen position
	int cell_x = ((preBall_x - 600)/32)*32 + 600;
	int cell_y = ((preBall_y - 80)/32)*32 + 80;
	drawACell(cell_x, cell_y);
	drawACell(cell_x, cell_y+32);
	if(cell_x + 32 < 1305)
	{
		drawACell(cell_x+32, cell_y);
		drawACell(cell_x+32, cell_y+32);
	}
	printf("pre ball: %d, %d\n", preBall_x, preBall_y);
	printf("cell: %d, %d\n", cell_x, cell_y);
}

void ballMove(){
	int i=0;
	int j = 0;
	ball_x = 936;
	ball_y = 816;
	preBall_x = 936;
	preBall_y = 816;
	d_x = 4;	//init move right
	moveFlg = 0;
	drawInitGameSate();
	getchar();
	while(1){
/*
		char c = getchar();
		if(c=='D'){
			ball_x+=d_x;
			moveFlg = 1;
		}
		else if(c == 'A'){
			ball_x -= d_x;
			moveFlg = 1;
		}
		if(moveFlg == 1){	//ball has moved
			cleanPreBall();
			drawABall(ball_x, ball_y);
			preBall_x = ball_x;
			preBall_y = ball_y;
			moveFlg = 0;
		}
*/
		if(i == 10000){
			i = 0;
			j++;
		}

		if(j == 100){	//ball move per 10000*10000 iterations
			if(d_x > 0 && ball_x>1303){	//move right and touch the right wall
				d_x = -4;	//change to move left
			}
			else if(d_x < 0 && ball_x < 601){	//move left and touch the left wall
				d_x = 4;
			}
			ball_x+=d_x;
			moveFlg = 1;	//set movement flag
			j = 0;
		}

		if(moveFlg == 1){	//ball has moved
			cleanPreBall();
			drawABall(ball_x, ball_y);
			preBall_x = ball_x;
			preBall_y = ball_y;
			moveFlg = 0;
		}
		++i;

	}
}
