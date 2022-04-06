#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

unsigned int fac(unsigned int i) {
    if (i <= 1)
        return 1;
    
    return i * fac(i-1);
}

int main(int argc, char *argv[])
{
    unsigned int x = 0;

    if (argc < 2)
        return 1;

    x = (unsigned int) atoi(argv[1]);
    x = fac(x);

    fprintf(stdout, "%d\n", x);

    return 0;
}
