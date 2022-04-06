int foo(int a, int b) {
    if (a == b) return 0;

    if (a > b) {
       return 1;
    } else {
        return -1;
    }
}

int nomain()
{
    int x = 42;
    int y = 7;

    return foo(x, y);
}
