#include <stdlib.h>
#include <stdio.h>

int inc(int* x)
{
    return *x+1;
}

int main(int argc, char *argv[])
{
    int x = 0;

    if (argc < 2)
        return 1;

    x = atoi(argv[1]);
    x = inc(&x);

    fprintf(stdout, "%d\n", x);
    
    return 0;
}
