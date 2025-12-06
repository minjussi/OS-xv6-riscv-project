#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/riscv.h"
#include "user/user.h"

int main () {

    char *mem;
    int a, b;
    int c, d;
    swapstat(&a, &b);
    printf("a: %d, b: %d\n", a, b);

    for (int i = 0; i < 3000; i++){
    	mem = sbrk(PGSIZE);
	mem[0] = 1; // 요소에 접근 
	if (i%100 == 0) printf("%d 로그 찍기 ..\n", i);
    }
    swapstat(&c, &d);
    printf("c: %d, d: %d\n", c, d);
    if (d > b) printf("Success\n");

    exit(0);
}
