#include "lwp_umailbox.h"

#define INPUT_NOTIFICATION 0x1

/* lock free circle buffer */
static int buffer_full(rt_umb_t umb)
{
    return umb->output_ptr == ((umb->input_ptr + 1) % umb->len);
}

static int buffer_empty(rt_umb_t umb)
{
    return umb->input_ptr == umb->output_ptr;
}

static int buffer_enqueue(rt_umb_t umb, rt_ubase_t data)
{
    if (buffer_full(umb))
    {
        return -1;
    }

    umb->buff[umb->input_ptr] = data;
    umb->input_ptr = (umb->input_ptr + 1) % umb->len;

    return 0;
}

static int buffer_dequeue(rt_umb_t umb, rt_ubase_t *data)
{
    if (buffer_empty(umb))
    {
        return -1;
    }

    *data = umb->buff[umb->output_ptr];
    umb->output_ptr = (umb->output_ptr + 1) % umb->len;

    return 0;
}

/* mailbox with buffer */
static rt_list_t umb_list;
static rt_thread_t timer_tid = RT_NULL;
static void umb_timer_entry()
{
    while (1)
    {
        rt_umb_t umb;
        rt_thread_mdelay(1);
        unsigned now = rt_tick_get();
        rt_list_for_each_entry(umb, &umb_list, list)
        {
            if (!buffer_empty(umb) && (now - umb->last_tick > umb->timeout))
            {
                umb->last_tick = now;
                rt_mb_send(umb->mb, INPUT_NOTIFICATION);
            }
        }
    }
}

static int umb_system_init(void)
{
    rt_list_init(&umb_list);
    timer_tid = rt_thread_create("umb_timer", umb_timer_entry, RT_NULL, 1024, 25, 30); 
    if (timer_tid) rt_thread_startup(timer_tid);
    else return RT_ERROR;
    return RT_EOK;
}

rt_umb_t rt_umb_create(const char *name, int size, unsigned timeout)
{
    if (!timer_tid)
    {
        if (umb_system_init() != RT_EOK)
        {
            return RT_NULL;
        }
    }

    rt_umb_t umb = rt_malloc(sizeof(struct rt_umailbox));
    if (!umb)
    {
        return RT_NULL;
    }

    umb->mb = rt_mb_create(name, size, RT_IPC_FLAG_FIFO);
    if (!umb->mb)
    {
        return RT_NULL;
    }

    umb->input_ptr = 0;
    umb->output_ptr = 0;
    umb->buff = (rt_ubase_t *)rt_malloc(sizeof(rt_ubase_t) * size);
    rt_memset(umb->buff, 0, sizeof(rt_ubase_t) * size);
    umb->len = size;
    umb->timeout = timeout;
    umb->last_tick = rt_tick_get();

    rt_list_insert_after(&umb_list, &umb->list);

    return umb;
}

rt_err_t rt_umb_send(rt_umb_t umb, void *msg, int flag)
{
    if (!umb)
    {
        return RT_ERROR;
    }

    while (buffer_enqueue(umb, (rt_ubase_t)msg) == -1)
    {
        rt_mb_send(umb->mb, INPUT_NOTIFICATION);
    }

    if (flag == UNMB_SEND_IMMEDIATE)
    {
        rt_mb_send(umb->mb, INPUT_NOTIFICATION);
    }

    return RT_EOK;
}

rt_err_t rt_umb_recv(rt_umb_t umb, void **msg, unsigned timeout)
{
    if (!umb)
    {
        return RT_ERROR;
    }

    unsigned t = 0;
    if(timeout == 0)
        t = RT_WAITING_FOREVER;
    else
    {
        /* convirt msecond to os tick */
        if (timeout < (1000/RT_TICK_PER_SECOND))
            t = 1;
        else
            t = timeout / (1000/RT_TICK_PER_SECOND);
    }

    rt_err_t ret;
    do
    {
        ret = buffer_dequeue(umb, (rt_ubase_t*)msg);
        if (ret == 0)
        {
            return RT_EOK;
        } 
        ret = rt_mb_recv(umb->mb, (rt_ubase_t *)msg, t);
    } while (*msg == (void*)INPUT_NOTIFICATION);

    return ret;
}

void rt_umb_delete(rt_umb_t umb)
{
    if (!umb)
    {
        return;
    }

    rt_list_remove(&umb->list);
    rt_mb_delete(umb->mb);
    rt_free(umb->buff);
    rt_free(umb);

    if (rt_list_isempty(&umb_list))
    {
        rt_thread_delete(timer_tid);
        timer_tid = RT_NULL;
    }
}

void rt_umb_settimeout(rt_umb_t umb, unsigned timeout)
{
    if (!umb)
    {
        return;
    }

    umb->timeout = timeout;
}