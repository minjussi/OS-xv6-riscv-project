#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h" // 프로세스가 가지는 자료구조
#include "defs.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];

// mmap_area는 최대 64(param.h에 정의)
struct mmap_area mmap_areas[NAREA];

// 동기화를 위한 새로운 락 정의
struct spinlock map_lock; 

// 프로세스 테이블 전체에 lock 걸기
// 새로운 프로세스들어오는 것 막아서 정확히 계산
struct spinlock proct_lock;

struct proc *initproc;

int nextpid = 1;
// 프로세스 생성할 때 다른 프로세스와 아이디 겹치는 거 방지
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// wait로 영원히 잠드는 것 방지 
struct spinlock wait_lock;

// eevdf scheduler
// 가중치 미리 계산해서 배열로 넣어두기
int weight[] = {88761, 71755, 56483, 46273, 36291,
		29154, 23254, 18705, 14949, 11916,
		 9548,  7620,  6100,  4904,  3906,
		 3121,  2501,  1991,  1586,  1277,
		 1024,   820,   655,   526,   423,
		  335,   272,   215,   172,   137,
		  110,    87,    70,    56,    45,
		   36,    29,    23,    18,    15};

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table.
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid()
{
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;
  p->priority = 20; 		// 우선순위 값 초기화
  p->weight = weight[20];	// 가중치 초기화
  p->runtime = 0;		// 일단 실제 실행 시간은 0
  p->vruntime = 0;		// 초기화는 0
  p->vdeadline = 5000;		// 초기화는 5000
  p->is_eligible = 1;		// 초기화는 true
  p->remain_time = 5;		// remain_time은 5로 초기화

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    //freeproc(p);
    p->state = UNUSED;
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    //freeproc(p);
    kfree(p->trapframe);
    p->trapframe = 0;
    p->state = UNUSED;
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
}

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// mmap 시스템콜 정의
// map_lock을 정의-> mmap_area에 적는 거 보호
// mmap을 프로세스가 호출하면 mmap_area에 정보를 저장하게 됨
#define MASK ~(1UL << 0) // 0번째만 0이고 나머지는 1
uint64
mmap(uint64 addr, int length, int prot, int flags, int fd, int offset)
{
	uint64 va; // 가상 페이지 주소
	uint64 top = MMAPBASE; // mmap 공간에서 어디까지 채워졌는지를 나타내는 변수
	struct proc *p = myproc();
	int idx = -1;
	int page_num = 0;
	// 유효성 검사하기 
	if (length <= 0) return 0;
	if (offset < 0) return 0;
	if (length % PGSIZE != 0) return 0;
	page_num = length / PGSIZE;
	// lock 잡고 시작
	acquire(&map_lock);
	// mmap_areas를 순회해서 빈 슬롯 찾기
	for (int i = 0; i < NAREA; i++){
		if (mmap_areas[i].p == p){
			uint64 end_addr = MMAPBASE +  mmap_areas[i].addr + mmap_areas[i].length;
			if (end_addr > top){
				top = end_addr;
			}
		}
		else if (mmap_areas[i].p == 0){
			if (idx = -1) idx = i;
		}
	}

	va = top + addr; // 가샹 주소 결정

	// MAP_ANONYMOUS가 주어짐
	if (flags & MAP_ANONYMOUS){
		// 유효성 검사
		if (fd != -1) return 0;
		if (offset != 0) return 0;
		if (flags & MAP_POPULATE) { // anonymous 이면서 populate
			// 물리 페이지랑 연결 & 0으로 채우기 
			// 페이지 개수에 따라 반복
			for (int i = 0; i < page_num; i++){
				uint64 pa = kalloc();
				memset(pa, 0, PGSIZE);
				mappages(p->pagetable, va + i*PGSIZE, PGSIZE, pa, prot) // 여기 함수 안에 보면 pte도 같이 함
			}
			mmap_areas[idx].f = NULL;
			mmap_areas[idx].addr = addr;
			mmap_areas[idx].length = length;
			mmap_areas[idx].offset = offset;
			mmap_areas[idx].prot = prot;
			mmap_areas[idx].flags = flags;
			mmap_areas[idx].p = p;
		}
		else{ // anonymous인데 populate 없음(지연 할당)
			if (pte && (*pte & PTE_U)){ // entry가 존재하고 접근 권한 있음 -> 정상 동작
				for (int i = 0; i < page_num; i++){
					pte_t *pte = walk(p->pagetable, va + i*PGSIZE, 1);
					*pte = *pte & MASK; // valid bit을 0으로 설정
				}
				mmap_areas[idx].f = NULL;
				mmap_areas[idx].addr = addr;
				mmap_areas[idx].legnth = length;
				mmap_areas[idx].offset = offset;
				mmap_areas[idx].prot = prot;
				mmap_areas[idx].flags = flags;
				mmap_areas[idx].p = p;
			}
			else {
				// page fault
			}
		}
	}
	
	// file mapping일 때
	else{
		if (fd == -1) return 0;
		struct file *fp = p->ofile[fd];
		fp->off = offset;
		// 해당 file의 권한과 prot가 일치하는가
		if ((prot & PROT_READ) && !fp->readable) return 0;
		if ((port & PROT_WRITE) && !fp->writable) return 0;
		if (flags & MAP_POPULATE){ // file mapping 이면서 populate
			for (int i = 0; i < page_num; i++){
				uint64 pa = kalloc();
				mappages(p->pagetable, va + i * PGSIZE, PGSIZE, pa, prot); // 물리 페이지 할당
				
				release(&map->lock); // 파일 읽어오기 전에 lock 해제
				release(&p_lock);
				
				fileread(fp, va + i * PGSIZE, PGSIZE); // 파일 크기만큼 데이터를 읽어오기
				
				acquire(&p->lock); // 처리 후 다시 lock 잡기
				acquire(&map->lock);
			}
			mmap_areas[idx].f = p->ofile[fd];
			mmap_areas[idx].addr = addr;
			mmap_areas[idx].length = length;
			mmap_areas[idx].offset = offset;
			mmap_areas[idx].prot = prot;
			mmap_areas[idx].flags = flags;
			mmap_areas[idx].p = p;
		}
		else{ // file mapping인데 populate 없음
			if (pte && (*pte & PTE_U)) {
				for (int i = 0; i < page_num; i++){
					pte_t *pte = walk(p->pagetable, va + i*PGSIZE, 1);
					*pte = *pte & MASK;
				}
				mmap_areas[idx].f = p->ofile[fd];
				mmap_areas[idx].addr = addr;
				mmap_areas[idx].legnth = length;
				mmap_areas[idx].offset = offset;
				mmap_areas[idx].prot = prot;
				mmap_areas[idx].flags = flags;
				mmap_areas[idx].p = p;
			}
			else {
				// page fault
			}
		}
	}
	// lock 풀기
	release(&map_lock);
	return va; 
}

// page fault handler 함수를 두어서 trap을 보조
int
pgfault_handler()
{
	uint64 fa = r_stval(); // fault address 파악
}

//munmap 시스템콜 정의
int
munmap(uint64 addr)
{
	// 현재 프로세스
	struct proc *p = myporc();
	struct mmap_area *area = 0;
	int idx = 0;
	// mmap_area 찾기 -> 일치하는 거 찾으면 시작 주소, 길이 알 수 있음
	for (int i = 0; i < NAREA; i++){
		if (mmap_areas[i].p && mmap_areas[i].p == p && mmap_area[i].addr == addr){
			area = &mmap_areas[i];
			idx = i;
			break;
		}
	}
	// area 찾기 실패
	if (area == 0) return -1;
	uint64 end_addr = area->addr + area->length;
	
	// 알게 된 가상 주소랑 길이 가지고
	// PTE 존재하면 kfree 하고 PTE 삭제  아니면 그대로 두기
	acquire(&map_lock);
	for (uint64 a = area->addr; a < end_addr; a += PGSIZE){
		pte_t *pte = walk(p->pagetable, a, 0);
		// 없으면 계속 찾기
		if (pte == 0) continue;
		// 물리 페이지가 할당된 경우
		if (*pte & PTE_V){ // 물리 페이지 free하고 PTE 삭제
			uint64 pa = PTE2PA(*pte);
			memset((void*)pa, 1, PGSIZE);
			kfree((void*)pa);
		}
	}
	*pte = 0;
	mmap_areas[idx].p = 0;
	release(&map_lock);
	return 1;
}

// freemem 시스템콜
// 비어 있는 page 개수 반환
int
freemem()
{
	return freememinfo()
}

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&p->lock);
}

// Shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint64 sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
// 새로운 프로세스 생성할 때 default nice value는 20
int
kfork(void)
{
  int i, pid;
  struct proc *np; // 자식 프로세스
  struct proc *p = myproc(); // 부모 프로세스

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  // 부모의 값 상속
  np->priority = p->priority;
  np->weight = p->weight;
  np->vruntime = p->vruntime;
  // 값 초기 상태로 할당
  np->runtime = 0;
  np->remain_time = 5; 
  // vdeadline은 다시 계산
  // eligibility는 scheduler에서 계산
  np->vdeadline = np->vruntime + (5*1000*1024)/np->weight;

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
kexit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  // 여기도 sched() 존재
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
kwait(uint64 addr)
{
  struct proc *pp;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(pp = proc; pp < &proc[NPROC]; pp++){
      if(pp->parent == p){
        // make sure the child isn't still in exit() or swtch().
	// 자식 프로세스 lock
        acquire(&pp->lock);

        havekids = 1;
        if(pp->state == ZOMBIE){
          // Found one.
          pid = pp->pid;
	  // 원래 wait 함수는 ..
	  // uint64 addr(유저 모드에 있는 부모 프로세스의 메모리 주소)를 인자로 받음
	  // 부모의 주소가 존재해야 하고
	  // 커널에 있는 자식 종료 상태를 부모 프로세스 메모리 공간으로 복사해야함 
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
                                  sizeof(pp->xstate)) < 0) {
            release(&pp->lock);
            release(&wait_lock);
            return -1; // 에러
          }
          freeproc(pp);
          release(&pp->lock);
          release(&wait_lock);
          return pid; // 종료된 자식 프로세스 pid를 반환
        }
        release(&pp->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || killed(p)){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    // sleep 호출되는 지점 
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control via swtch back to the scheduler.
// 현재 존재하는 scheduler에서 안에 구조를 바꾸기(eevdf로)
void
scheduler(void)
{
  struct proc *p;
  struct proc *targetp = 0; // 실행할 프로세스
  struct cpu *c = mycpu();

  c->proc = 0;

  // 스케줄러 실행
  for ( ; ; ){
    intr_on();
    intr_off();

    targetp = 0;
    // 프로세스 테이블 전체 lock
    acquire(&proct_lock);
    // 전체 프로세스 순회하면서 runnable 상태의 프로세스들의 min_vruntime 구하기
    struct proc *firstp = 0;
    uint64 min_vruntime = 0;
    uint64 total_weight = 0;
    uint64 calculated = 0;

    // 첫 번째 프로세스를 기준으로 비교해나가기
    for (p = proc; p < &proc[NPROC]; p++){
	    if (p->state == RUNNABLE){
		    firstp = p;
		    min_vruntime = p->vruntime;
		    break;
	    }
    }
    // first process가 존재하면 실행 (포인터 변수)
    if (firstp)
    {
	// min_vruntime 찾기
	for (p=proc; p<&proc[NPROC]; p++){
		if (p->state == RUNNABLE && p->vruntime < min_vruntime){
			min_vruntime = p->vruntime;
		}
	}

   	 // min_vruntime 구하고 나서 eligibility 계산에 필요한 값 구하기
    	for (p=proc; p<&proc[NPROC]; p++){
	    if (p->state == RUNNABLE){
		    total_weight += p->weight;
		    calculated += (p->vruntime - min_vruntime) * p->weight;
	    }
    	}


    	// eligibility 확인 & vdeadline 제일 빠른 프로세스
    	for(p = proc; p < &proc[NPROC]; p++) {
      		if(p->state == RUNNABLE) {
			if (calculated >= (p->vruntime - min_vruntime)*total_weight){
				p->is_eligible = 1;
		} else {
			p->is_eligible = 0;
		}

		if (p->is_eligible){
			if (targetp == 0){
				targetp = p;
			} else if (p->vdeadline < targetp->vdeadline){
				targetp = p;
			}		
		}	
	}
      }

    	// 실행할 프로세스를 찾은 경우
    	if (targetp) {
		//printf("targetp: %d\n", targetp->pid);
	    targetp->state = RUNNING;
	    c->proc = targetp;

	    swtch(&c->context, &targetp->context);
	    c->proc = 0;
    	}
    }

    release(&proct_lock); 
    if (targetp==0){
	    asm volatile("wfi");
    }
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
// proc.c 안에서 스케줄러 양보하는 함수 ->  scheduler 로직에 맞게 바꿔줘야 함
// intena: 인터럽트 상태 저장 변수 -> 필요한가..?
void
sched(void)
{
  //int intena;
  // 다른 함수에서 lock 걸고 있으니까 sched는 걸지 말 것
  struct proc *p = myproc();
  struct cpu *c = mycpu();

  // sched 호출 전에 프로세스 락 걸려 있어야 함 -> 필수
  if(!holding(&p->lock))
    panic("sched p->lock");
  //if(mycpu()->noff != 1)
  //  panic("sched locks");
  if(p->state == RUNNING)
	  p->state = RUNNABLE;
    //panic("sched RUNNING");
  //if(intr_get())
  //  panic("sched interruptible");

  //intena = mycpu()->intena;
  // 풀었다가
  release(&p->lock);
  // 스케줄러로 switch 
  swtch(&p->context, &c->context);
  // 잡아서 넘겨주기 
  acquire(&p->lock);
  //mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
// clockintr가 부르는 함수
void
yield(void)
{
  struct proc *p = myproc();
  struct cpu *c = mycpu();

  // 자물쇠 잡기 1
  acquire(&p->lock);
  // 프로세스 상태를 running -> runnable로 변경
  if (p->state == RUNNING)
  	p->state = RUNNABLE;
  // 풀었다가
  release(&p->lock);
  //sched();
  // sched 함수 쓰지 않고 scheduler 함수가 스케줄링을 전적으로 담당
  // scheduler 함수를 부르게 되면 중복해서 여러 번 부르게 되므로 안 됨
  // 현재 상태 저장하고(첫 번째 인자), scheduler의 context를 로드 (두 번째 인자)
  swtch(&p->context, &c->context);
  // 다시 잡기
  acquire(&p->lock);

  // 1에사 잡은 자물쇠 풀기
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();

  // Still holding p->lock from scheduler.
  // panic:release : scheduler 수정했기 때문에 acquire이 없어짐 -> release 하면 오류-> 주석 처리
  //  release(&p->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);

    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    if (p->trapframe->a0 == -1) {
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
  uint64 satp = MAKE_SATP(p->pagetable);
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64))trampoline_userret)(satp);
}

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;
  // 스케줄러 수정했는데 sched 함수 호출 -> sched 수정 필요
  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
// 깨어날 때도 eevdf 스케줄러 적용
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
	// nv, runtime, vruntime은 그대로
	p->remain_time = 5; // 5로 초기화
	p->vdeadline = p->vruntime + (5*1000*1024)/p->weight; // vdeadline 다시 계산
        // eligibility는 scheduler 안에서 계산하니까 그때 수정
	p->state = RUNNABLE;
	///release(&p->lock);
	//printf("wake up process id: %d\n", p->pid);
      }//else{
      release(&p->lock);//}
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

void
setkilled(struct proc *p)
{
  acquire(&p->lock);
  p->killed = 1;
  release(&p->lock);
}

int
killed(struct proc *p)
{
  int k;
  
  acquire(&p->lock);
  k = p->killed;
  release(&p->lock);
  return k;
}

// 우선순위 정보 가져오는 함수 (nice value를 return)
int 
getnice(int pid)
{
	struct proc *p;
	int check = 0;
	int nicevalue;

	for (p = proc; p < &proc[NPROC]; p++)
	{
		if (p->pid == pid)
		{
			acquire(&p->lock);
			if (p->priority < 0 || p->priority > 39)
			{
				return -1;
			}
			else
			{
				check = 1;
				nicevalue = p->priority;
			}
			release(&p->lock);
			break;
		}
	}

	if (check == 0)
	{
		return -1;
	}
	else
	{
		return nicevalue;
	}

}

// 성공하면 0, 실패하면 -1 return
int 
setnice(int pid, int value)
{
	struct proc *p;
	int check = 0;

	if (value < 0 || value > 39 )
	{
		return -1;
	}

	for (p = proc; p < &proc[NPROC]; p++)
	{
		if (p->pid == pid)
		{
			acquire(&p->lock);
			check = 1;
			p->priority = value;
			// 우선순위 값 바뀌면 가중치도 수정
			p->weight = weight[value];
			// vdeadline도 다시 계산
			p->vdeadline = p->vruntime + (5*1000*1024)/p->weight;
			release(&p->lock);
			break;
		}
	}
	// 일치하는 프로세스가 없는 경우
	if (check == 0)
	{
		return -1;
	}

	return 0;
}

// 문자열로 출력하기 위한 로직
const char* state_string(enum procstate state)
{
	switch (state)
	{
		case UNUSED:
			return "UNUSED";
		case USED:
			return "USED";
		case SLEEPING:
			return "SLEEPING";
		case RUNNABLE:
			return "RUNNABLE";
		case RUNNING:
			return "RUNNING";
		case ZOMBIE:
			return "ZOMBIE";
		default:
			return "Unknown";
	}
}

// 프로세스 정보 출력
void
ps(int pid)
{
	struct proc *p;
	uint total_ticks;

	// ps가 출력되는 시점에 얻은 total_ticks 값 출력
	// lock 걸고 -> 값 구하고 -> lock 풀기
	acquire(&tickslock);
	total_ticks = ticks;
	release(&tickslock);

	printf("name\tpid\tstate\t\tpriority\truntime/weight\truntime\tvruntime\tvdeadline\tis_eligible\ttick %d\t\n", total_ticks*1000);

	if (pid == 0)
	{
		for (p = proc; p < &proc[NPROC]; p++)
		{
			acquire(&p->lock);
			if (p->state != UNUSED)
			{
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
						(p->runtime*1000/p->weight), p->runtime*1000, p->vruntime, p->vdeadline, p->is_eligible ? "true" : "false" );
			}
			release(&p->lock);
		}
	}

	else 
	{
		for (p = proc; p < &proc[NPROC]; p++)
		{
			acquire(&p->lock);
			if (p->pid == pid && p->state != UNUSED)
			{
				printf("%s\t%d\t%s\t%d\t%d\t%d\t%ld\t%ld\t%s\n", p->name, p->pid, state_string(p->state), p->priority,
						(p->runtime*1000/p->weight), p->runtime*1000, p->vruntime, p->vdeadline, p->is_eligible ? "true" : "false" );

			}
			release(&p->lock);
		}
	}

}

// 사용 가능한 메모리 공간 bytes 출력
uint64
meminfo(void)
{
	uint64 memsize = 0;
	memsize = freememinfo()*4096;

	return memsize;
}

// 성공하면 0, 실패하면 -1 return
int 
waitpid(int pid)
{
	// wait()와 동일한데, 특정 프로세스를 대상으로 함
	struct proc *pp; // 자식 프로세스
	struct proc *p = myproc(); // 부모 프로세스
	int havekids;
	
	acquire(&wait_lock);

	for (; ;)
	{
		havekids = 0;
		for (pp = proc; pp < &proc[NPROC]; pp++)
		{
			if (pp->pid == pid && pp->parent == p)
			{
				// 자식 찾음
				acquire(&pp->lock);

				havekids = 1;
				if (pp->state == ZOMBIE)
				{
					freeproc(pp); // 할당되어 있던 자식 프로세스 공간 free
					release(&pp->lock);
					release(&wait_lock);
					return 0;
				}
				// 자식 찾았는데 상태가 zombie가 아님
				// 일단 lock 걸어 놓은 거 풀기
				release(&pp->lock);
			}
		}
		
		// 자식 프로세스를 찾으려 했으나 찾지 못함
		// 혹은 부모 프로세스가 죽음
		if (havekids == 0 || killed(p))
		{
			release(&wait_lock);
			return -1;
		}

		// 자식 프로세스 있었다는 소리
		// 상태가 zombie가 아니었기 때문에 부모를 sleep 상태로
		sleep(p, &wait_lock);
	}
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [USED]      "used",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}
#include "types.h"
