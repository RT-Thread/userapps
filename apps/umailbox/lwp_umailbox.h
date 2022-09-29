#ifndef LWP_UNMAILBOX_H_
#define LWP_UNMAILBOX_H_

#include <rtthread.h>

enum
{
    UNMB_SEND_IMMEDIATE,
    UNMB_SEND_QUEUE
};

struct rt_umailbox
{
    rt_list_t list;

    rt_mailbox_t mb;
    
    rt_ubase_t *buff;
    int input_ptr;
    int output_ptr;
    int len;
    unsigned timeout;
    unsigned last_tick;
};
typedef struct rt_umailbox *rt_umb_t;

#ifdef __cplusplus
extern "C" {
#endif

rt_umb_t rt_umb_create(const char *name, int size, unsigned timeout);
rt_err_t rt_umb_send(rt_umb_t umb, void *msg, int flag);
rt_err_t rt_umb_recv(rt_umb_t umb, void **msg, unsigned timeout);
void rt_umb_delete(rt_umb_t umb);
void rt_umb_settimeout(rt_umb_t umb, unsigned timeout);


#ifdef __cplusplus
}
#endif

#endif