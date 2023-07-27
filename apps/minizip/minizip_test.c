/*
 * Copyright (c) 2006-2018, RT-Thread Development Team
 *
 * SPDX-License-Identifier: GPL-2.0
 *
 * Change Logs:
 * Date           Author        Notes
 * 2023-05-17     wcx1024979076 The first version
 */

#include "stdio.h"
#include "minizip/zip.h"

int main()
{
    // 文件名
    const char *zipfile = "example.zip";
    // 需要压缩的文件
    const char *file = "example.txt";

    zipFile zf = zipOpen(zipfile, APPEND_STATUS_CREATE);
    if (zf == NULL)
    {
        printf("Error creating  %s \n", zipfile);
        return 1;
    }

    // 压缩文件
    int err = zipOpenNewFileInZip(zf, file, NULL, NULL, 0, NULL, 0, NULL, Z_DEFLATED, Z_BEST_COMPRESSION);
    if (err != ZIP_OK)
    {
        printf("Error adding %s to %s \n", file, zipfile);
        return 1;
    }

    // 读取文件并压缩
    FILE *f = fopen(file, "rb");
    char buf[1024];
    int len;
    while ((len = fread(buf, 1, sizeof(buf), f)) > 0)
    {
        zipWriteInFileInZip(zf, buf, len);
    }
    fclose(f);

    zipCloseFileInZip(zf);
    zipClose(zf, NULL);

    printf("Successfully created %s \n", zipfile);
    return 0;
}
