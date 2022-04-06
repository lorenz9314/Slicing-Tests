int add_by_value(int i, int j)
__attribute__ ((optnone))
{
        return i + j;
}

int *add_by_addr(int *a, int *b, int *r)
__attribute__ ((optnone))
{
        *r = *a + *b;

        return r;
}

int main()
__attribute__ ((optnone))
{
        int *p, *q, *r;
        int x, y, z = 42;

        p = &x;                         // STORE
        q = p;                          // COPY
        y = *q;                         // LOAD

        z = add_by_value(x, y);         // CALL DPARA / DRET
        r = add_by_addr(q, p, r);       // CALL IPARA / IRET

        return 0;
}
