#include <stdio.h>
#include <string.h>
#include <zlib.h>

int main()
{
    int r = 0;

    unsigned char str_src[]   = "hello world\n";
    unsigned char buf[32]     = {0};
    unsigned char str_dst[32] = {0};
    unsigned long src_len     = sizeof(str_src);
    unsigned long buf_len     = sizeof(buf);
    unsigned long dst_len     = sizeof(str_dst);

    compress(buf, &buf_len, str_src, src_len);
    uncompress(str_dst, &dst_len, buf, buf_len);

    printf("%s\n", str_dst);

    return 0;
}
