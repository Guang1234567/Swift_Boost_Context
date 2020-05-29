/*

#define _XOPEN_SOURCE
#include <ucontext.h>
#undef _XOPEN_SOURCE
#include <stdio.h>

//main->f1->f2
//ut[0]->ut[1]->ut[2]


ucontext_t ut[3];


void f1()
{
    printf("f1() - start\n");
    for (int i = 0; i != 10; ++i)
    {
        printf("f1:%d\n", i);
        swapcontext(&ut[1], &ut[2]);
    }
    printf("f1() - end\n");
}

void f2()
{
    printf("f2() - start\n");
    for (int i = 0; i != 10; ++i)
    {
        printf("f2:%d\n", i);
        swapcontext(&ut[2], &ut[1]);
    }
    printf("f2() - end\n");
}

int main()
{
    char stack_buff[1024 * 32];
    char stack_buff2[1024 * 32];

    printf("getcontext ut[1]  - before\n");
    getcontext(&ut[1]);
    ut[1].uc_stack.ss_sp = stack_buff;
    ut[1].uc_stack.ss_size = sizeof(stack_buff);
    ut[1].uc_link = &ut[0];
    ut[1].uc_stack.ss_flags = 0;
    printf("getcontext ut[1]  - after\n");

    printf("makecontext f1  - before\n");
    makecontext(&ut[1], f1, 0);
    printf("makecontext f1  - after\n");


    printf("getcontext ut[2]  - before\n");
    getcontext(&ut[2]);
    ut[2].uc_stack.ss_sp = stack_buff2;
    ut[2].uc_stack.ss_size = sizeof(stack_buff2);
    ut[2].uc_link = &ut[0];
    ut[2].uc_stack.ss_flags = 0;
    printf("getcontext ut[2]  - after\n");

    printf("makecontext f2  - before\n");
    makecontext(&ut[2], f2, 0);
    printf("makecontext f2  - after\n");


    printf("swapcontext 0 -> 1  - before\n");
    swapcontext(&ut[0], &ut[1]);
    printf("swapcontext 0 -> 1  - after\n");
}

*/


/*#include <stdio.h>

#define _XOPEN_SOURCE
#include <ucontext.h>
#undef _XOPEN_SOURCE

int fib_res;
ucontext_t main_ctx, fib_ctx;

char fib_stack[1024 * 32];

void fib() {
    // (1)
    int a0 = 0;
    int a1 = 1;

    while (1) {
        fib_res = a0 + a1;
        a0 = a1;
        a1 = fib_res;

        // send the result to outer env and hand over the right of control.
        swapcontext(&fib_ctx, &main_ctx);  // (b)
        // (3)
    }
}

int main(int argc, char **argv) {
    // initialize fib_ctx with current context.
    getcontext(&fib_ctx);
    fib_ctx.uc_link = 0;  // after fib() returns we exit the thread.
    fib_ctx.uc_stack.ss_sp = fib_stack;  // specific the stack for fib().
    fib_ctx.uc_stack.ss_size = sizeof(fib_stack);
    fib_ctx.uc_stack.ss_flags = 0;
    makecontext(&fib_ctx, fib, 0);  // modify fib_ctx to run fib() without arguments.

    while (1) {
        // pass the right of control to fib() by swap the context.
        swapcontext(&main_ctx, &fib_ctx);  // (a)
        // (2)
        printf("%d\n", fib_res);
        if (fib_res > 100) {
            break;
        }
    }

    return 0;
}*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "fcontext.h"

#ifndef FCONTEXT_SIZE
// Default context size (used for fiber stacks)
//#define FCONTEXT_SIZE (1 << 18)  // 256KiB
//#define FCONTEXT_SIZE (1 << 17)  // 128KiB
#define FCONTEXT_SIZE (1 << 16)  // 64KiB
#endif

void f1(transfer_t tf) {
    printf("main ----> f1\n");
    //transfer_t resultF2ToF1 = jump_fcontext((fcontext_t)tf.data,0);
    //printf("f1 <---- f2  %s\n", resultF2ToF1.data);
    jump_fcontext(tf.fctx, "7654321");
}

void f2(transfer_t tf) {
    printf("f1 ----> f2\n");
    jump_fcontext(tf.fctx, "1234567");
    printf("f2 never returns !!!\n");
}

int main(int argc, char **argv) {
    uint8_t *sp1 = malloc(FCONTEXT_SIZE);

    printf("sp1 = %p \n", sp1);

    printf("sp1 + FCONTEXT_SIZE = %p \n", sp1 + FCONTEXT_SIZE);

    fcontext_t fc1 = make_fcontext(sp1 + FCONTEXT_SIZE, FCONTEXT_SIZE, f1);

    //void* sp2 = malloc(8192);
    //fcontext_t fc2 = make_fcontext(sp2, 1024 * 64, f2);

    transfer_t tf = jump_fcontext(fc1, 0);
    //printf("tf.fcxt = %p\n", tf.fctx);
    //printf("tf.data = %s\n", tf.data);
    free(sp1);
    printf("main <---- f1\n");
}
