int add(int x, int y)
{
    return x+y;
}

int sub(int x, int y)
{
    return x-y;
}

int main(void)
{
    int x = 1;
    int y = 2;

    int u = 0;
    int v = 0;

    int (*f)(int, int) = &add;

    u = (*f)(x, y);
    v = sub(x, y);
    
    return add(u, v);
}
