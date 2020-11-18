/*
 * Copyright (c) 2006-2020, RT-Thread Development Team
 *
 * SPDX-License-Identifier: GPL-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2020-10-30     Bernard      the first version
 */

#include <stdio.h>
#include <rtthread.h>

RT_WEAK int wget(int argc, char** argv)
{
    return 0;
}

int main(int argc, char **argv)
{
    return wget(argc, argv);
}
