#include <stdio.h>
#include <stdlib.h>

extern int webnet_startup(int port, char *root);

int main(int argc, char** argv)
{
    webnet_startup(80, "/");

    return 0;
}
