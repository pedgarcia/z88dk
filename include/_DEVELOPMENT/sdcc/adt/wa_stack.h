
// automatically generated by m4 from headers in proto subdir


#ifndef _ADT_WA_STACK_H
#define _ADT_WA_STACK_H

#include <stddef.h>

// DATA STRUCTURES

typedef struct wa_stack_s
{

   void       *data;
   size_t      size;
   size_t      capacity;

} wa_stack_t;

extern size_t wa_stack_capacity(wa_stack_t *s);
extern size_t wa_stack_capacity_fastcall(wa_stack_t *s) __z88dk_fastcall;
#define wa_stack_capacity(a) wa_stack_capacity_fastcall(a)


extern void wa_stack_clear(wa_stack_t *s);
extern void wa_stack_clear_fastcall(wa_stack_t *s) __z88dk_fastcall;
#define wa_stack_clear(a) wa_stack_clear_fastcall(a)


extern void wa_stack_destroy(wa_stack_t *s);
extern void wa_stack_destroy_fastcall(wa_stack_t *s) __z88dk_fastcall;
#define wa_stack_destroy(a) wa_stack_destroy_fastcall(a)


extern int wa_stack_empty(wa_stack_t *s);
extern int wa_stack_empty_fastcall(wa_stack_t *s) __z88dk_fastcall;
#define wa_stack_empty(a) wa_stack_empty_fastcall(a)


extern wa_stack_t *wa_stack_init(void *p,void *data,size_t capacity);
extern wa_stack_t *wa_stack_init_callee(void *p,void *data,size_t capacity) __z88dk_callee;
#define wa_stack_init(a,b,c) wa_stack_init_callee(a,b,c)


extern void *wa_stack_pop(wa_stack_t *s);
extern void *wa_stack_pop_fastcall(wa_stack_t *s) __z88dk_fastcall;
#define wa_stack_pop(a) wa_stack_pop_fastcall(a)


extern int wa_stack_push(wa_stack_t *s,void *item);
extern int wa_stack_push_callee(wa_stack_t *s,void *item) __z88dk_callee;
#define wa_stack_push(a,b) wa_stack_push_callee(a,b)


extern size_t wa_stack_size(wa_stack_t *s);
extern size_t wa_stack_size_fastcall(wa_stack_t *s) __z88dk_fastcall;
#define wa_stack_size(a) wa_stack_size_fastcall(a)


extern void *wa_stack_top(wa_stack_t *s);
extern void *wa_stack_top_fastcall(wa_stack_t *s) __z88dk_fastcall;
#define wa_stack_top(a) wa_stack_top_fastcall(a)



#endif