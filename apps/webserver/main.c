#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int webnet_startup(int port, char *root);

int main(int argc, char** argv)
{
    char *webroot = "/";

    if (argc > 1)
    {
        if (strcmp(argv[1], "&") != 0)
        {
            webroot = argv[1];
        }
    }

    webnet_startup(80, webroot);

    return 0;
}
