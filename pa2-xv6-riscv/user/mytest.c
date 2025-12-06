#include "kernel/types.h"
#include "user/user.h"
#include "kernel/stat.h"

int main()
{
	int pid = 0;
	int i;

	ps(0);
	printf("\n");

	for (i = 0; i < 2; i++)
	{
		pid = fork();

		if (pid < 0)
		{
			printf("forked failed");
			exit(1);
		}

		if (pid == 0) // 자식 프로세스
		{
			setnice(getpid(), i*10);
			ps(0);
			printf("\n");
			exit(0); // 종료 status가 0 == 정상 종료

		} 

	
	}

	ps(0);

	for (i = 0; i < 2; i++)
	{
		wait(0);
	}

	exit(0);

}
