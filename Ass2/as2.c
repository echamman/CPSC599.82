#include <stdlib.h>
#include <curses.h>
#include <signal.h>
#include <string.h>
#include "duktape.h"

static void finish(int sig);
static void draw();
static void PlayerMove();
static void BertieMove();
static char *board[3][3]= {
    {" "," "," "},
    {" "," "," "},
    {" "," "," "}};
static int row;
static int col;
static bool finished = false;

int main(int argc, char *argv[])
{
    /* initialize your non-curses data structures here */

    (void) signal(SIGINT, finish);      /* arrange interrupts to terminate */
    (void) initscr();      /* initialize the curses library */
    keypad(stdscr, TRUE);  /* enable keyboard mapping */
    (void) nonl();         /* tell curses not to do NL->CR/NL on output */
    (void) cbreak();       /* take input chars one at a time, no wait for \n */
    (void) echo();         /* echo input - in color */

    duk_context *ctx = NULL; //init duk
    ctx = duk_create_heap_default();
    if (!ctx) {
        printf("Failed to create a Duktape heap.\n");
        exit(1);
    }

    if (duk_peval_file(ctx, argv[1]) != 0) {
        printf("Error: %s\n", duk_safe_to_string(ctx, -1));
        duk_destroy_heap(ctx);
        finish(0);
    }

    //game code
    draw();
    while(!finished)
    {
        draw();
        PlayerMove();
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
    int c = getch();
}

static void BertieMove()
{


}
