#include <stdio.h>
#include <stdlib.h>

int fac(int i) {
    if (i == 1) {
        return 1;
    }
    
    return fac(i * i-1);
}

int main(int argc, char *argv[])
{
    int x = 0;

    if (argc < 2) {
        return 1;
    } else {
        x = atoi(argv[1]);
    }

    fprintf(stdout, "%d\n", fac(x));
	
	return 0;
}
