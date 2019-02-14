#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    FILE *f = fopen("file", "w");
    fprintf(f, "Hello");
    fclose(f);
    return 0;
}
