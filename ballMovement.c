#include <stdio.h>
#include <stdlib.h>

//Function prototypes
void drawABall(int x, int y);	//param: x,y - draw ball on (x,y)
void drawACell(int x, int y);	//param: x,y - draw floor on (x,y)


//floor 32*32 cell
//ball 32*32

extern int ball_x;
extern int ball_y;
extern int d_x;	//direction x
extern int d_y;	//direction y
extern int preBall_x;
extern int preBall_y;
extern int moveFlg;
extern ballMove();


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
	int cell_x = ((preBall_x - 600)>>5)<<5+600;
	int cell_y = ((preBall_y - 80)>>5)<<5+80;
	drawACell(cell_x, cell_y);
}

int ballMove(){
	int i=0;
	ball_x = 936;
	ball_y = 816;
	preBall_x = 936;
	preBall_y = 816;
	d_x = 1;	//init move right
	moveFlg = 0;
	drawInitGameSate();
	while(1){
		if(i == 1000){	//ball move per 1000 iterations
			if(d_x > 0 && ball_x>1304){	//move right and touch the right wall
				d_x = -1;	//change to move left
			}
			else if(d_x < 0 && ball_x < 600)	//move left and touch the left wall
				d_x = 1;
			}
			ball_x+=d_x;
			moveFlg = 1;	//set movement flag
			i = 0;
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
	return 0;
}
