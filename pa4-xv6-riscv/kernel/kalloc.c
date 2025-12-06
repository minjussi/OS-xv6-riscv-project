// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

// pa4: struct for page control
struct page pages[PHYSTOP/PGSIZE]; // LRU 리스트
struct page *page_lru_head;        // LRU 헤드
char *bitmap;
struct spinlock swap_lock;

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  freerange(end, (void*)PHYSTOP);
  // 1개의 물리 페이지는 swap space 추적하는 bitmap으로 
  bitmap = (char*)kalloc();
  memset(bitmap, 0, PGSIZE); 
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&kmem.lock);
  // lru list에서 빼기
  klrultrmv(ptr2page((uint64)pa));
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
// pa4: kalloc function
void *
kalloc(void)
{
  struct run *r;
  struct page *victim_page = 0;
  pte_t *pte;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;

  else { // 페이지 놓을 공간이 없어서 kalloc 안 될 때
	for (struct page *i = page_lru_head; ; i = i->next){ // lru list 순회하면서 evict할 페이지 고르기
		if (i == 0){ // 페이지가 없음
			printf("Error: Out Of Memory\n");
			release(&kmem.lock);
			return 0;
		}
		pte = walk(i->pagetable, (uint64)i->vaddr, 0);	
		if (pte == 0 || (*pte & PTE_V) == 0){ // PTE 없거나 swap out 된 거 건너뛰기
			i = i->next;
			klrultrmv(i);
			if (page_lru_head == 0) { // 페이지가 없음
				printf("Error: Out Of Memory\n");
				release(&kmem.lock);
				return 0;
			}
			continue;
		}
		if (!(*pte & PTE_A)){ // PTE_A가 0 -> victim
			victim_page = i;
			break;
		} else if (*pte & PTE_A) { // PTE_A가 1 -> 0으로 바꾸기
			*pte = *pte & ~PTE_A;
		}	
	}
	
	if (victim_page){
		// ptr(물리 주소) 구하기
		uint64 ptr = PTE2PA(*pte);
		// blkno 찾기
		int blkno = setbitmap();
		if (blkno < 0) { // swapspace 다 참
			printf("Error: Out Of Memory\n");
			release(&kmem.lock);
			return 0;
		}
		release(&kmem.lock);
		swapwrite(ptr, blkno);
		acquire(&kmem.lock);
		// PTE_V를 0으로 설정
		uint64 flags = PTE_FLAGS(*pte);
		flags = flags & ~PTE_V;
		// PPN을 swap space offset으로 채우기(offset 값이랑 flags 더해서 -> pte 새로 만들기)
		*pte = (blkno << 10) | flags;
		// swapout 했으니까 lru list에서도 빼기
		klrultrmv(victim_page);
		memset((char*)ptr, 5, PGSIZE);
		release(&kmem.lock);
		return (void*) ptr;
	} else { // swap -out할 페이지가 없음
		printf("Error: Out Of Memory\n");
		release(&kmem.lock);
		return 0;
	}
		
  }
  release(&kmem.lock);

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}

// pa4: 비트맵 관리하기
// 비트맵에 1로 표기
int
setbitmap()
{
	acquire(&swap_lock);
	for (int i = 0; i < PGSIZE; i++){
		int byte = bitmap[i];
		// 비어 있는 비트가 있을 때
		if (byte != 0xFF){
			// 바이트 내에 비트 하나씩 검사
			for (int j = 0; j < 8; j++){
				if ((byte & (1 << j)) == 0){ // 해당 위치에 1 넣어서 & 연산 -> 빈 슬롯 찾음
					bitmap[i] |= 1 << j;
					release(&swap_lock);
					return (i*8)+j;
				}
			}
		}
	}
	release(&swap_lock);
	return -1;
}

// 비트맵에 0으로 표기
void
clearbitmap(int blkno)
{
	acquire(&swap_lock);
	int byte = blkno / 8;
	int bit = blkno % 8;
	bitmap[byte] = bitmap[byte] & (~(1 << bit));
	release(&swap_lock);
}

// 비트맵 확인하는 함수
int
checkbitmap(int blkno)
{
	acquire(&swap_lock);
	int byte = blkno / 8;
	int bit = blkno % 8;
	if (bitmap[byte] & (1 << bit)){ // bit가 1인 경우
		release(&swap_lock);
		return 1;
	} else { // 0인 경우
		release(&swap_lock);
		return 0;
	}
}

// pa4: lru list 관리하기
// lru list에 추가
void
lrultadd(struct page *p, pagetable_t pagetable, uint64 vaddr)
{
	acquire(&kmem.lock);
	p->pagetable = pagetable;
	p->vaddr = (char*) vaddr;
	if (page_lru_head == 0){ // 비어 있음
		page_lru_head = p;
		p->next = p;
		p->prev = p;
	} else {
		p->next = page_lru_head;
		p->prev = page_lru_head->prev;
		page_lru_head->prev->next = p;
		page_lru_head->prev = p;
	}
	release(&kmem.lock);
}

// lru list에서 제거
void
klrultrmv(struct page *p)
{
	// 내부에서 부를 때 -> lock 없이
	if (p->next == 0 || p->prev == 0){ // 연결이 없음
		return;
	}
	if (page_lru_head == 0) { // 비어 있음
		return;
	}
	if (p->next == p){ // 자기 자신 가리키면 head -> head만 남아 있음
		page_lru_head = 0;
	} else {
		if (page_lru_head == p){
			page_lru_head = p->next;
		}
		p->prev->next = p->next;
		p->next->prev = p->prev;
	}
	
	p->prev = 0;
	p->next = 0;
}

void
lrultrmv(struct page *p)
{
	// 외부에서 부를 때는 lock 필요
	acquire(&kmem.lock);
	klrultrmv(p);
	release(&kmem.lock);
}

// page로 바꿔주는 함수 따로 정의
struct page*
ptr2page(uint64 ptr)
{
	uint64 idx = ptr / PGSIZE;
	return &pages[idx];
}
