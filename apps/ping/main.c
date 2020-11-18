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
#include <string.h>
#include <lwp_shm.h>
#include <rtthread.h>

#ifdef RT_USING_USERSPACE
/**
 * With separate address spaces, we transfer the id of the shared-memory page
 * which contains the string, instead of the pointer to the string directly.
 */
rt_inline int prepare_data(void *data, size_t len)
{
    int shmid;
    void *shm_vaddr;

    /* use the current thread ID to label the shared memory */
    size_t key = (size_t) rt_thread_self();

    shmid = lwp_shmget(key, len, 1);    /* create a new shm */
    if (shmid == -1)
    {
        printf("Fail to allocate a shared memory!\n");
        return -1;
    }

    /* get the start address of the shared memory */
    shm_vaddr = lwp_shmat(shmid, NULL);
    if (shm_vaddr == RT_NULL)
    {
        printf("The allocated shared memory doesn't have a valid address!\n");
        lwp_shmrm(shmid);
        return -1;
    }

    /* put the data into the shared memory */
    memcpy(shm_vaddr, data, len);
    lwp_shmdt(shm_vaddr);

    return shmid;
}
#endif

int main(int argc, char **argv)
{
    int i;
    int pong_ch;

    /* the string to transfer */
    char ping[256] = { 0 };
    size_t len = 0;

    /* channel messages to send and return back */
    struct rt_channel_msg ch_msg, ch_msg_ret;

    /* open the IPC channel created by 'pong' */
    pong_ch = rt_channel_open("pong", 0);
    if (pong_ch == -1)
    {
        printf("Error: rt_channel_open: could not find the \'pong\' channel!\n");
        return -1;
    }

    /* try to communicate through the IPC channel */
    for (i = 0; i < 100; i++)
    {
        printf("\n");

        /* initialize the message to send */
        ch_msg.type = RT_CHANNEL_RAW;
        snprintf(ping, 255, "count = %d", i);
        len = strlen(ping) + 1;
        ping[len] = '\0';

#ifdef RT_USING_USERSPACE
        int shmid = prepare_data(ping, len);
        if (shmid < 0)
        {
            printf("Ping: fail to prepare the ping message.\n");
            continue;
        }
        ch_msg.u.d = (void *)shmid;
#else
        ch_msg.u.d = ping;
#endif

        printf("Ping: send %s\n", ping);
        rt_channel_send_recv(pong_ch, &ch_msg, &ch_msg_ret);
        printf("Ping: receive the reply %d\n", (int) ch_msg_ret.u.d);

#ifdef RT_USING_USERSPACE
        lwp_shmrm(shmid);
#endif
    }

    /* get rid of the channel and the shared memory */
    rt_channel_close(pong_ch);

    return 0;
}
