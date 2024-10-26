/* slub.c - SLUB memory allocator implementation */
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <slub_pmm.h>
#include <stdio.h>
#include <assert.h>
#include "spinlock.h" // 添加自旋锁头文件

#define SLAB_MIN_SIZE  32
#define SLAB_MAX_SIZE  4096
#define SLAB_LIST_SIZE (SLAB_MAX_SIZE / SLAB_MIN_SIZE)

static list_entry_t slab_list[SLAB_LIST_SIZE];
static size_t slab_free_counts[SLAB_LIST_SIZE];
static spinlock_t slub_lock = SPINLOCK_INITIALIZER; // 初始化自旋锁

static void
slub_init(void) {
    for (int i = 0; i < SLAB_LIST_SIZE; i++) {
        list_init(&slab_list[i]);
        slab_free_counts[i] = 0;
    }
}

static void
slub_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    for (size_t i = 0; i < n; i++) {
        struct Page *p = base + i;
        p->flags = 0;
        set_page_ref(p, 0);
        
        // 假设 p->property 表示页面大小，且为 SLAB_MIN_SIZE 的倍数
        assert(p->property % SLAB_MIN_SIZE == 0);
        int index = (p->property / SLAB_MIN_SIZE) - 1;
        if (index >= 0 && index < SLAB_LIST_SIZE) {
            spin_lock(&slub_lock); // 获取锁
            list_add(&slab_list[index], &(p->page_link));
            slab_free_counts[index]++;
            spin_unlock(&slub_lock); // 释放锁
        } else {
           // printf("Invalid page property: %d for page %p\n", p->property, (void*)p);
        }
    }
}

static struct Page *
slub_alloc_pages(size_t n) {
    assert(n > 0 && n * PGSIZE <= SLAB_MAX_SIZE);
    
    int index = (n * PGSIZE / SLAB_MIN_SIZE) - 1;
    if (index < 0 || index >= SLAB_LIST_SIZE) {
        //printf("Invalid allocation size: %zu pages\n", n);
        return NULL;
    }
    
    spin_lock(&slub_lock); // 获取锁
    struct Page *p = NULL;
    if (slab_free_counts[index] > 0) {
        list_entry_t *le = list_next(&slab_list[index]);
        if (le != &slab_list[index]) { // 确保存在可用页面
            p = le2page(le, page_link);
            list_del(&(p->page_link));
            slab_free_counts[index]--;
        }
    }
    spin_unlock(&slub_lock); // 释放锁
    
    return p;
}

static void
slub_free_pages(struct Page *base, size_t n) {
    assert(n > 0 && n * PGSIZE <= SLAB_MAX_SIZE);
    
    int index = (n * PGSIZE / SLAB_MIN_SIZE) - 1;
    if (index < 0 || index >= SLAB_LIST_SIZE) {
        //printf("Invalid free size: %zu pages\n", n);
        return;
    }
    
    spin_lock(&slub_lock); // 获取锁
    list_add(&slab_list[index], &(base->page_link));
    slab_free_counts[index]++;
    set_page_ref(base, 0);
    base->flags = 0;
    spin_unlock(&slub_lock); // 释放锁
}

static size_t
slub_nr_free_pages(void) {
    size_t free_pages = 0;
    spin_lock(&slub_lock); // 获取锁
    for (int i = 0; i < SLAB_LIST_SIZE; i++) {
        free_pages += slab_free_counts[i];
    }
    spin_unlock(&slub_lock); // 释放锁
    return free_pages;
}

const struct pmm_manager slub_pmm_manager = {
    .name = "slub_pmm_manager",
    .init = slub_init,
    .init_memmap = slub_init_memmap,
    .alloc_pages = slub_alloc_pages,
    .free_pages = slub_free_pages,
    .nr_free_pages = slub_nr_free_pages,
    .check = NULL,  // 可以根据需要实现检查函数
};
