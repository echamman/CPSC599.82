#include <stdlib.h>
#include <curses.h>
#include <signal.h>
#include <string.h>
#include "duktape.h"

static void finish(int sig);
static void PlayerMove();
static void BertieMove();
static char *board[3][3];
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
    if (duk_peval_file(ctx, "randy.js") != 0) {
        printf("Error: %s\n", duk_safe_to_string(ctx, -1));
        duk_destroy_heap(ctx);
        finish(0);
    }



    //game code

    while(!finished)
    {
        PlayerMove();
    }
    int c = getch();     /* refresh, accept single keystroke of input */


    //game code

    finish(0);               /* we're done */
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
