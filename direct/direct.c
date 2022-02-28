int a(int x, int y)
{
    return x+y;
}

int b(int x, int y)
{
    return a(x, y);
}

int main(void)
{
	return a(b(1, 1), 1);
}
