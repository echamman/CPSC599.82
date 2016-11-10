#include <stdlib.h>
#include <curses.h>
#include <signal.h>
#include <string.h>
#include "duktape.h"

static void errorMove();
static void finish(int sig);
static void draw();
static void PlayerMove();
static void BertieMove();
static void stringToBoard();
static void boardToString();
static bool gameOver();
static char board[3][3]= {
    {' ',' ',' '},
    {' ',' ',' '},
    {' ',' ',' '}};
static char boardString[10] = {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '\0'};
static int row;
static int col;
static char letter;
static char number;
static bool finished = false;
static duk_context *ctx = NULL; //init duk
static char winner[10];

int main(int argc, char *argv[])
{
    /* initialize your non-curses data structures here */

    (void) signal(SIGINT, finish);      /* arrange interrupts to terminate */
    (void) initscr();      /* initialize the curses library */
    keypad(stdscr, TRUE);  /* enable keyboard mapping */
    (void) nonl();         /* tell curses not to do NL->CR/NL on output */
    //(void) cbreak();       /* take input chars one at a time, no wait for \n */
    (void) echo();         /* echo input - in color */

    ctx = duk_create_heap_default();
    if (!ctx) {
        printf("Failed to create a Duktape heap.\n");
        exit(1);
    }

    if (duk_peval_file(ctx, argv[1]) != 0) {
        printf("Error: %s\n", duk_safe_to_string(ctx, -1));
        printf("You need to use randy.js or ty.js for your AI.\n");
        duk_destroy_heap(ctx);
        finish(0);
    }

    //game code
    draw();
    while(!finished)
    {
        PlayerMove();
        draw();
        finished = gameOver();
        if(!finished){
            BertieMove();
            draw();
        }
        finished = gameOver();
    }

    draw();
    mvprintw(15,0,"                                             ");  //clear screen
    mvprintw(16,0,"                                             ");  //clear screen
    mvprintw(15, 0, "Game over, %s wins", winner);
    refresh();
    sleep(5);
    //game code

    finish(0);               /* we're done */
}

static bool gameOver(){
    //Checking for horizontal lines
    for(int x=0; x < 3; x++){
        if(board[x][0] == board[x][1] && board[x][0] == board[x][2] && board[x][0] != ' '){
            if(board[x][0] == 'X')
                strcpy(winner, "BERTIE");
            else
                strcpy(winner, "PLAYER");
            return true;
        }
    }

    //Checking for vertical lines
    for(int y=0; y < 3; y++){
        if(board[0][y] == board[1][y] && board[0][y] == board[2][y] && board[0][y] != ' '){
            if(board[0][y] == 'X')
                strcpy(winner, "BERTIE");
            else
                strcpy(winner, "PLAYER");
            return true;
        }
    }

    //Checking for diagonals
    if(board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != ' '){
        if(board[0][0] == 'X')
            strcpy(winner, "BERTIE");
        else
            strcpy(winner, "PLAYER");
        return true;
    }
    if(board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != ' '){
        if(board[0][2] == 'X')
            strcpy(winner, "BERTIE");
        else
            strcpy(winner, "PLAYER");
        return true;
    }

    //Check tie
    for(int i=0; i<3; i++){
        for(int j=0; j<3; j++){
            if(board[i][j] == ' '){
                return false;
            }
        }
    }
    strcpy(winner, "NO ONE");
    return true;
}
static void draw()
{
    int a = 196;
    char c = "-";

    mvprintw(0,7,"1");
    mvprintw(0,11,"2");
    mvprintw(0,15,"3");
    mvprintw(3,3,"A");
    mvprintw(7,3,"B");
    mvprintw(11,3,"C");

    for(int i = 6; i < 17; i++)   // horizontal lines
    {
        mvprintw(5,i,"-");
        mvprintw(9,i,"-");
    }
    for(int i = 2; i < 13; i++)   // vertical lines
    {
        mvprintw(i,9,"|");
        mvprintw(i,13,"|");
    }

    //print from board to spots....

    int k = 0;
    for (int i = 3; i < 12; i+=4)
    {
        int l = 0;
        for (int j = 7; j < 16; j+=4)
        {
            mvaddch(i,j,board[k][l]);
            l++;
        }
        k++;
    }
}

static void finish(int sig)
{
    endwin();

    /* do your non-curses wrapup here */

    exit(0);
}

static void PlayerMove()
{
    char *input[1];

    mvprintw(15,0,"                                             ");  //clear screen
    mvprintw(16,0,"                                             ");  //clear screen
    mvprintw(15,0,"Your move... letter? ");
    getstr(input);
    letter = input[0];
    mvprintw(15,21,input);

    mvprintw(16,0,"Your move... number? ");
    getstr(input);
    number = input[0];
    mvprintw(16,21,input);

    if((letter != 'a' && letter != 'b' && letter != 'c') || (number != '1' && number != '2' && number != '3'))
    {
        errorMove();
    }

    //update the 3x3
    int x = letter - 97;
    int y = number - 49;

    if(board[x][y] == ' ')
        board[x][y] = 'O';
    else
       errorMove();


}

static void errorMove()
{
    mvprintw(15,0,"                      ");  //clear screen
    mvprintw(16,0,"                      ");  //clear screen
    mvprintw(15,0,"Invalid Move!");
    refresh();
    sleep(2);
    mvprintw(15,0,"                      ");  //clear screen
    mvprintw(16,0,"                      ");  //clear screen
    PlayerMove();
}

static void BertieMove()
{
    mvprintw(15,0,"                      ");  //clear screen
    mvprintw(16,0,"                      ");  //clear screen
    mvprintw(15,0,"Bertie the Brain is thinking...");
    refresh();
    sleep(2);
    boardToString();              //Convert the board to a string to send
    duk_push_global_object(ctx);
    duk_get_prop_string(ctx, -1, "bertieMove");
    duk_push_string(ctx, boardString);              //send the board string to the AI
    if (duk_pcall(ctx, 1 /*nargs*/) != 0) {
                printf("Error: %s\n", duk_safe_to_string(ctx, -1));
            } else {
                //printf("%s\n", duk_safe_to_string(ctx, -1));
                strncpy(boardString, duk_safe_to_string(ctx, -1), 10); //Moves the response to the variable stringBoard
            }
    duk_pop(ctx);
    stringToBoard();        //Convert the string back to a board
}

static void boardToString(){

    for(int x=0; x<3; x++){
        for(int y=0; y<3; y++){
            boardString[(3*x + y)] = board[x][y];
        }
    }
}

static void stringToBoard(){

    for(int x=0; x<3; x++){
        for(int y=0; y<3; y++){
            board[x][y] = boardString[(3*x + y)];
        }
    }
}
