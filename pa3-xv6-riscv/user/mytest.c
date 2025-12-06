#include "kernel/types.h"
#include "kernel/param.h"
#include "kernel/riscv.h"
#include "user.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"

int main(int argc, char *argv[])
{
	int fd = open("README", O_RDONLY);
	if (fd < 0) {
		printf("파일 열기 실패\n");
		exit(1);
	}

	uint64 va = mmap(0, PGSIZE, PROT_READ, 0, fd, 0);

	if (va == 0){
		printf("mmap 실패\n");
		exit(1);
	}

	// vmfault
	char *p = (char*) va;

	printf("-fd data: ");
	write(1, &p[0], 1);
	write(1, &p[1], 1);
	write(1, &p[2], 1);
	printf("\n");

	munmap(va);
	close(fd);
	exit(0);

}
