/*
 * Copyright (c) 2006-2018, RT-Thread Development Team
 *
 * SPDX-License-Identifier: GPL-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2020-10-20     Bernard      The first version
 */

#include <stdio.h>
#include <lwp_shm.h>
#include <rtthread.h>

int main(int argc, char **argv)
{
    int i;
    int pong_ch;
    struct rt_channel_msg msg_text;
    char *str;

#ifdef RT_USING_USERSPACE
    int shmid;
#endif

    /* create the IPC channel for 'pong' */
    pong_ch = rt_channel_open("pong", O_CREAT);
    if (pong_ch == -1) {
        printf("Error: rt_channel_open: fail to create the IPC channel for pong!\n");
        return -1;
    }
    printf("\nPong: wait on the IPC channel: %d\n", pong_ch);

    /* respond to the the test messages from 'ping' */
    for (i = 0; i < 100; i++)
    {
        rt_channel_recv(pong_ch, &msg_text);

#ifdef RT_USING_USERSPACE
        shmid = (int)msg_text.u.d;
        if (shmid < 0 || !(str = (char *)lwp_shmat(shmid, NULL)))
        {
            msg_text.u.d = (void *)-1;
            printf("Pong: receive an invalid shared-memory page.\n");
            rt_channel_reply(pong_ch, &msg_text);   /* send back -1 */
            continue;
        }

        printf("Pong: receive %s\n", str);
        lwp_shmdt(str);
#else
        str = (char *)msg_test.u.d;
        printf("Pong: receive %s\n", str);
#endif

        /* prepare the reply message */
        printf("Pong: reply count = %d\n", i);
        msg_text.type = RT_CHANNEL_RAW;
        msg_text.u.d = (void *)i;
        rt_channel_reply(pong_ch, &msg_text);
    }

    rt_channel_close(pong_ch);

    return 0;
}
