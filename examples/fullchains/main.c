int by_value(int a, int b)
{
    int c = a + b;

    return c;
}

int *by_address(int *a, int *b, int *c)
{
    *c = *a + *b;

    return c;
}

int main(int argc, char **argv)
{
    int *x;
    int *y;
    int *r;

    *x = 42;
    *y = 0;

    int u, v = 0;

    u = 5;
    v = argc;
    u = v * u;

    if (argc > 2) {
        u = by_value(*x, 2);
        v = 1;
    } else if (argc > 1) {
        y = by_address(x, y, r);
        v = 0;
    } else {
        u = v;
    }

    return by_value(u, v);
}
