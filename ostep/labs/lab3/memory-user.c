#include <stdio.h>
#include <stdlib.h>
#include <time.h> //random
#include <unistd.h> //sleep

int main(int argc, char *argv[]) {
    srand(time(NULL));
    //printf("hello world\n");

    int size;
    sscanf (argv[1],"%d",&size);

    printf("U gave me array size: %d\n", size);

    int *A;
    A = (int*)malloc(size * sizeof(int));

    int i;
    //int r = rand() % 20;
    while(1) {
      for (i=0; i<size; i++) {
        int r = rand() % 20;
        A[i] = r;
      }
      /*printf("A[0]: %d\n", A[0]);
      for (i=0; i<size; i++)
        printf("%d\t", A[i]);
      sleep(1);
      */
    }
/*
    int i;
    int r;
    for (i=0; i<size; i++)
      scanf("%d", &A[i]);
*/
    return 0;
}
