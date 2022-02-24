#include <stdio.h>
#include <stdlib.h>

int a(int x);
int b(int x);
int c(int x);

int main(int argc, char *argv[])
{
    int argument;
    int result = 0;

    if (argc < 2) {
        exit(0);
    } else {
        argument = atoi(argv[1]);
    }

       
    result = a(argument);

    exit(result);
}

int a(int x) {
    int result = 0;

    result = x + x;

    return result;
}


int b(int x) {
    int i = 0;
    int j = 0;
    int result= 0;

    i = 2*x;
    j = 3*x;
    result = i + j;

    return result;
}

int c(int x) {

    if (x < 200) {
        fprintf(stdout, "%d\n", x);
    } else {
        fprintf(stderr, "%d\n", x);

        return 1;
    }

    return 0;
}
