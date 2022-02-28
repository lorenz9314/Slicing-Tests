#include <stdio.h>
#include <stdlib.h>

int b(int y)
{
    int v = y + y;

    return y;
}

int a(int x)
{
    int u = 3 * x;

    return b(u);
}

int main(int argc, char *argv[])
{
    int x = 0;

    if (argc < 2) {
        return 1;
    } else {
        x = atoi(argv[1]);
    }

    x = a(x);

    fprintf(stdout, "%d\n", x);
	
	return 0;
}
