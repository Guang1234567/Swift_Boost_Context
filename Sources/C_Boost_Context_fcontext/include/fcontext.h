#ifndef SWIFT_BOOST_CONTEXT_FCONTEXT_H
#define SWIFT_BOOST_CONTEXT_FCONTEXT_H


#include <stddef.h>
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void *fcontext_t;

typedef struct {
    fcontext_t fctx;
    void *data;
} transfer_t;

fcontext_t make_fcontext(void *sp, size_t size, void (*fn)(transfer_t));

transfer_t jump_fcontext(fcontext_t const to, void *vp);

// based on an idea of Giovanni Derreta
transfer_t ontop_fcontext(fcontext_t const to, void *vp, transfer_t (*fn)(transfer_t));

#ifdef __cplusplus
}
#endif

#endif //SWIFT_BOOST_CONTEXT_FCONTEXT_H
