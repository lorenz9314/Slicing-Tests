int c(int u) {
    int y = u;

    return y;
}

int b(int v) {
    int y = c(v);

    return y;
}

int a(int w) {
    int y = b(w);

    return y;
}

int main(void) {
    int x = 42;

    return a(x);
}
