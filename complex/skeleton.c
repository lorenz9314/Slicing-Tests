#include <stdio.h>
#include <stdlib.h>

int fac(int x)
{
    if (x == 1) return x;

    return x * x-1;
}

void fib(int *arr, int end)
{
    int i, x = 0;

    *arr = x;
    arr++;

    while (i < end) {
        *arr = x + x+1;
        arr++;
    }
}


int show(int x, int y)
{
    int result = 0;
    result = fac(x);
    fprintf(stdout, "%d\n", result);

    int *arr = (int*) malloc(y * sizeof(int));
    if (arr == NULL) {
        exit(1);
    }

    fib(arr, y);

    free(arr);

    return 0;
}

int main(int argc, char *argv[])
{
    int x = 0;

    if (argc < 2) {
        return 1;
    } else {
        x = atoi(argv[1]);
    }

    fac(7);

    return show(x, x);
}
