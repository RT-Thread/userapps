#include <lwp_umailbox.h>
#include <rtthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

rt_umb_t umb;
rt_mailbox_t mb;
int count = 0;

void umb_entry1()
{
    while(1)
    {
        rt_umb_send(umb, (void*)10, UNMB_SEND_QUEUE);
    }
}

void umb_entry2()
{
    void *data;
    while(1)
    {
        rt_umb_recv(umb, &data, 0);
        count++;
    }
}

void mb_entry1()
{
    while(1)
    {
        rt_mb_send(mb, 10);
    }
}

void mb_entry2()
{
    void *data;
    while(1)
    {
        rt_mb_recv(mb, (rt_ubase_t *)&data, RT_WAITING_FOREVER);
        count++;
    }
}

int main(int argc, char **argv)
{
    if (argc != 4)
    {
        printf("umailbox [type mailbox/umailbox] [mailbox size 2048] [second 3]\n");
        return 0;
    }

    int size = atoi(argv[2]);
    int second = atoi(argv[3]);
    
    rt_thread_t tid1, tid2;
    if (strcmp(argv[1], "mailbox") == 0)
    {
        mb = rt_mb_create("test_mbox", size, RT_IPC_FLAG_FIFO);
        if (!mb)
        {
            printf("create error\n");
            return 0;
        }

        tid1 = rt_thread_create("mb_entry1", mb_entry1, RT_NULL, 4096, 25, 30); 
        tid2 = rt_thread_create("mb_entry2", mb_entry2, RT_NULL, 4096, 25, 30); 
    }
    else if (strcmp(argv[1], "umailbox") == 0)
    {
        umb = rt_umb_create("test_umbox", size, 1);
        if (!umb)
        {
            printf("create error\n");
            return 0;
        }

        tid1 = rt_thread_create("umb_entry1", umb_entry1, RT_NULL, 4096, 25, 30); 
        tid2 = rt_thread_create("umb_entry2", umb_entry2, RT_NULL, 4096, 25, 30); 
    }

    if (tid1) rt_thread_startup(tid1);
    else return 0;

    if (tid2) rt_thread_startup(tid2);
    else return 0;

    rt_thread_mdelay(second * 1000);

    rt_thread_delete(tid1);
    rt_thread_delete(tid2);

    if (strcmp(argv[1], "mailbox") == 0)
    {
        printf("[mailbox] mails per second: %d\n", count / second);
        rt_mb_delete(mb);
    }
    else if (strcmp(argv[1], "umailbox") == 0)
    {
        printf("[umailbox] mails per second: %d\n", count / second);
        rt_umb_delete(umb);
    }
    
    return 0;
}
