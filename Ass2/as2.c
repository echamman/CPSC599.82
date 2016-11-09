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
static void stringToBoard(char *inString);
static char *boardToString();
static char *board[3][3]= {
    {" "," "," "},
    {" "," "," "},
    {" "," "," "}};
static char *boardString[9];
static int row;
static int col;
static char *letter[1];
static char *number[1];
static bool finished = false;
static duk_context *ctx = NULL; //init duk

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

    if (duk_peval_file(ctx, "randy.js"/*argv[1]*/) != 0) {
        printf("Error: %s\n", duk_safe_to_string(ctx, -1));
        duk_destroy_heap(ctx);
        finish(0);
    }

    //game code
    draw();
    while(!finished)
    {
        PlayerMove();
        draw();
        BertieMove();
        draw();
    }


    //game code

    finish(0);               /* we're done */
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
            mvprintw(i,j,board[k][l]);
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

    mvprintw(15,0,"Your move... letter? ");
    getstr(input);
    letter[0] = input[0];
    mvprintw(15,21,input);

    mvprintw(16,0,"Your move... number? ");
    getstr(input);
    number[0] = input[0];
    mvprintw(16,21,input);

    if((strcmp(letter, "a") != 0 && strcmp(letter, "b") != 0 && strcmp(letter, "c") != 0) \
    || (strcmp(number, "1") != 0 && strcmp(number, "2") != 0 && strcmp(number, "3") != 0))
    {
        errorMove();
    }

    //update the 3x3
    int x = letter[0] - 'a';
    int y = number[0] - '1';

    if(strcmp(board[x][y]," ") == 0)
        board[x][y] = "O";
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
    *boardString = boardToString();              //Convert the board to a string to send
    duk_push_global_object(ctx);
    duk_get_prop_string(ctx, -1, "bertieMove");
    duk_push_string(ctx, boardString);              //send the board string to the AI
    if (duk_pcall(ctx, 1 /*nargs*/) != 0) {
                printf("Error: %s\n", duk_safe_to_string(ctx, -1));
            } else {
                printf("%s\n", duk_safe_to_string(ctx, -1));
            }
    duk_pop(ctx);
    stringToBoard(boardString);        //Convert the string back to a board
}

static char *boardToString(){
    char *ret[9];

    for(int x=0; x<2; x++){
        for(int y=0; y<2; y++){
            ret[3*x + y] = board[x][y];
        }
    }
    return *ret;
}

static void stringToBoard(char *inString){

    for(int x=0; x<2; x++){
        for(int y=0; y<2; y++){
            board[x][y] = inString[(3*x + y)];
        }
    }
}
