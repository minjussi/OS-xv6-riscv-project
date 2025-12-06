#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "file.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];

// mmap_areas 최대 64 -> param.h에 정의
struct mmap_area mmap_areas[NAREA];

// map 할 때 동기화를 위해 새로운 lock 정의
struct spinlock map_lock;

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

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

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
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
	//printf("freeproc 시작: pid=%d\n", p->pid);
	acquire(&map_lock);
	for (int i = 0; i < NAREA; i++){
		if (mmap_areas[i].p == p){
			uint64 start_addr = mmap_areas[i].addr;
			uint64 end_addr = start_addr + mmap_areas[i].length;
			struct file *fp = mmap_areas[i].f;

			for (uint64 a = start_addr; a < end_addr; a += PGSIZE){
				pte_t *pte = walk(p->pagetable, a, 0);
				if (pte!=0){
					if (*pte & PTE_V){
						uint64 pa = PTE2PA(*pte);
						kfree((void*)pa);
					}
					*pte = 0;
				}
			}
			mmap_areas[i].p = 0;
			if (fp){
				fileclose(fp);
			}
		}
	}
	release(&map_lock);

	//printf("mmap area를 munmap하고 pagetable도 freeproc\n");
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
// mmap을 프로세스가 호출하면 mmap_area에 정보 저장, mmap 공간 할당
uint64
mmap(uint64 addr, int length, int prot, int flags, int fd, int offset)
{
	uint64 va = MMAPBASE + addr; // 가상 페이지 주소
	uint64 pa;
	struct proc *p = myproc();
	int idx = -1;
	int page_num = 0;
	// 유효성 검사
	if (length <= 0) return 0;
	if (offset < 0) return 0;
	if ((addr % PGSIZE) != 0) return 0;
	page_num = PGROUNDUP(length) / PGSIZE; // 할당해야하는 페이지 개수 구하기
					       // page-aligned 하게 맞추기 위해 round up
	acquire(&map_lock); // lock 잡고 시작
	// mmap_areas 순회하면서 빈 슬롯 찾기
	for (int i = 0; i < NAREA; i++){
		if (mmap_areas[i].p == 0){
			idx = i;
			break;
		}
	}

	if (idx == -1) { // 실패 로직 처리
		release(&map_lock);
		return 0;
	}

	// MAP_ANONYMOUS가 주어진 경우
	if (flags & MAP_ANONYMOUS){
		if (flags & MAP_POPULATE){ // anonymous 이면서 populate
			for (int i = 0; i < page_num; i++){
				pa = (uint64)kalloc();
				if (pa == 0) {
					release(&map_lock);
					return 0;
				}
				int perm = PTE_U;
				if (prot & PROT_READ) perm |= PTE_R;
				if (prot & PROT_WRITE) perm |= PTE_W;
				memset((void*)pa, 0, PGSIZE);
				if (mappages(p->pagetable, va+(i*PGSIZE), PGSIZE, pa, perm) != 0){
					release(&map_lock);
					kfree((void*)pa);
					return 0;
				}
			}
			mmap_areas[idx].f = 0;
			mmap_areas[idx].addr = va; // munmap 할 때의 편의를 위해 MMAPBASE 더한 값 저장
			mmap_areas[idx].length = length;
			mmap_areas[idx].offset = offset;
			mmap_areas[idx].prot = prot;
			mmap_areas[idx].flags = flags;
			mmap_areas[idx].p = p;
		}
		else{ // anonymous인데 populate 없음
			mmap_areas[idx].f = 0;
			mmap_areas[idx].addr = va;
			mmap_areas[idx].length = length;
			mmap_areas[idx].offset = offset;
			mmap_areas[idx].prot = prot;
			mmap_areas[idx].flags = flags;
			mmap_areas[idx].p = p;
		}
	}
	// file mapping일 때
	else {
		if (fd < 0 || fd >= NOFILE || p->ofile[fd] == 0){ // fd 유효성 검사
			release(&map_lock);
			return 0;
		}
		
		struct file *fp = p->ofile[fd];
		if (((prot & PROT_READ) && !fp->readable) || ((prot & PROT_WRITE) && !fp->writable)){ // 권한이 일치하는지 확인
			release(&map_lock);
			return 0;
		}

		if (flags & MAP_POPULATE) { // file mapping 이면서 populate
			for (int i = 0; i < page_num; i++){
				pa = (uint64)kalloc();
				if (pa == 0){
					release(&map_lock);
					return 0;
				}
				//release(&p->lock);
				fp->off = offset + (i*PGSIZE);
				release(&map_lock);
				printf("mmap에서 fileread 하는 경우?\n");
				if (fileread(fp, pa, PGSIZE) < 0){
					acquire(&map_lock);
					kfree((void*)pa);
					release(&map_lock);
					return 0;
				}
				//acquire(&p->lock);
				acquire(&map_lock);
				int perm = PTE_U;
				if (prot & PROT_READ) perm |= PTE_R;
				if (prot & PROT_WRITE) perm |= PTE_W;
				if (mappages(p->pagetable, va+(i*PGSIZE), PGSIZE, pa, perm) != 0){
					release(&map_lock);
					return 0;
				}
			}
			if ((mmap_areas[idx].f = filedup(fp)) == 0){
				release(&map_lock);
				return 0;
			}
			mmap_areas[idx].addr = va;
			mmap_areas[idx].length = length;
			mmap_areas[idx].offset = offset;
			mmap_areas[idx].prot = prot;
			mmap_areas[idx].flags = flags;
			mmap_areas[idx].p = p;
		}
		else { // file mapping인데 populate 없음
		       // page fault handler 실행되거나 그냥 mmap_area만 적거나
			if ((mmap_areas[idx].f = filedup(fp)) == 0){
				release(&map_lock);
				return 0;
			}
			mmap_areas[idx].addr = va;
			mmap_areas[idx].length = length;
			mmap_areas[idx].offset = offset;
			mmap_areas[idx].prot = prot;
			mmap_areas[idx].flags = flags;
			mmap_areas[idx].p = p;
		}
	}
	// lock 풀기
	release(&map_lock);
	return va;
}

// munmap 시스템콜 정의
int
munmap(uint64 addr)
{
	struct proc *p = myproc();
	struct mmap_area *area = 0;
	int idx = 0;

	//printf("munmap시작: pid=%d, pagetable=%p\n", p->pid, p->pagetable);
	
	acquire(&map_lock);
	for (int i = 0; i < NAREA; i++){
		if (mmap_areas[i].p && mmap_areas[i].p == p && mmap_areas[i].addr == addr){
			area = &mmap_areas[i];
			idx = i;
			break;
		}
	}
	// area 찾기 실패
	if (area == 0){
		release(&map_lock);
		return -1;
	}
	uint64 end_addr = area->addr + area->length;
	struct file *fp = 0;
	fp = area->f;

	//acquire(&map_lock);
	for (uint64 a = area->addr; a < end_addr; a += PGSIZE){
		pte_t *pte = walk(p->pagetable, a, 0);
		if (pte != 0){
			if (*pte & PTE_V){ // 물리 페이지 할당된 경우 free하고 PTE 삭제
				uint64 pa = PTE2PA(*pte);
				kfree((void*)pa);
			}
			*pte = 0;
		}
	}
	// mmap_areas 해제
	mmap_areas[idx].p = 0;
	release(&map_lock);

	if (fp){
		fileclose(fp);
	}
	return 1; // 성공적으로 munmap함
}

// freemem 시스템콜
// 비어 있는 page 개수 반환
int
freemem()
{
	return freememinfo();
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

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint64 sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if(sz + n > TRAPFRAME) {
      return -1;
    }
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
// 자식 프로세스는 별도의 물리 페이지를 할당하는데, 부모의 물리 페이지 내용 복사
int
kfork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

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

  acquire(&map_lock);
  // mmsp area 순회하면서 자식 프로세스에 부모 정보 그대로 복사
  for (i = 0; i < NAREA; i++){
  	 if (mmap_areas[i].p == p){
		 int idx = -1;
		 for (int j = 0; j < NAREA; j++){
			 if (mmap_areas[j].p == 0){
				 idx = j;
				 break;
			 }
		 }
		 if (idx==-1){
			 freeproc(np);
			 release(&map_lock);
			 return -1;
		 }
		 if (mmap_areas[idx].f){ // file mapping인 경우 
		 	mmap_areas[idx].f = filedup(mmap_areas[i].f); //file.c에 정의된 함수 활용
		 }
		 mmap_areas[idx].addr = mmap_areas[i].addr;
		 mmap_areas[idx].length = mmap_areas[i].length;
		 mmap_areas[idx].offset = mmap_areas[i].offset;
		 mmap_areas[idx].prot = mmap_areas[i].prot;
		 mmap_areas[idx].flags = mmap_areas[i].flags;
		 mmap_areas[idx].p = np;
	 }
  }
  release(&map_lock);

  safestrcpy(np->name, p->name, sizeof(p->name));

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
        acquire(&pp->lock);

        havekids = 1;
        if(pp->state == ZOMBIE){
          // Found one.
          pid = pp->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
                                  sizeof(pp->xstate)) < 0) {
            release(&pp->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(pp);
          release(&pp->lock);
          release(&wait_lock);
          return pid;
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
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();

  c->proc = 0;
  for(;;){
    // The most recent process to run may have had interrupts
    // turned off; enable them to avoid a deadlock if all
    // processes are waiting. Then turn them back off
    // to avoid a possible race between an interrupt
    // and wfi.
    intr_on();
    intr_off();

    int found = 0;
    for(p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if(p->state == RUNNABLE) {
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
        found = 1;
      }
      release(&p->lock);
    }
    if(found == 0) {
      // nothing to run; stop running on this core until an interrupt.
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
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched RUNNING");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
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
  release(&p->lock);

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

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        p->state = RUNNABLE;
      }
      release(&p->lock);
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
