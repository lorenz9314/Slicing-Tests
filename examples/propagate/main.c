int c(int x) {
    int y = x;

    return y;
}

int b(int x) {
    int y = c(x);

    return y;
}

int a(int x) {
    int y = b(x);

    return y;
}

int main(void) {
    int x = 42;

    return a(x);
}
