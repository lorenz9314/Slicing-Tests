int c(int x, int y)
{
    return x + y;
}

int b(int u, int v)
{
    return c(u, v);
}

int a(int u, int v)
{
    return c(u, v);
}

int main()
{
    int x = 1;

    return a(x, b(x, x));
}
