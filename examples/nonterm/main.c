int main(int argc, char *argv[])
{
    int x = argc;
    int y = 1;

    if (x > 1) {
        return 0;
    }
    
    while(y);

    // Never reached but would lead to out of bounds access of argv if
    // that is if y is not sliced away.
    return (int) *argv[2];
}
