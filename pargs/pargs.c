int inc(int* x)
{
    return *x+1;
}

int main(void)
{
    int a = 42;
    
    return inc(&a);
}
