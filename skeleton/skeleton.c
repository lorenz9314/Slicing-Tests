#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    int x = 0;

    if (argc < 2) {
        return 1;
    } else {
        x = atoi(argv[1]);
    }

    fprintf(stdout, "%d\n", x);
	
	return 0;
}
