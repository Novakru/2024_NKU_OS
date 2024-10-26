#ifndef __KERN_MM_SLUB_PMM_H__
#define __KERN_MM_SLUB_PMM_H__

#include <pmm.h>
#include <list.h>
#include <defs.h>        // 包含 size_t 等类型定义
#include <memlayout.h>   // 包含页面大小和相关宏

// 定义 SLUB 专用的页面标志位
#define PG_slab         2   // 表示该页被 SLUB 使用

// 操作 PG_slab 标志位的宏
#define SetPageSlab(page)       ((page)->flags |= (1 << PG_slab))
#define ClearPageSlab(page)     ((page)->flags &= ~(1 << PG_slab))
#define PageSlab(page)          ((page)->flags & (1 << PG_slab))

// 将页面转换为内核虚拟地址的函数
static inline void *page2kva(struct Page *page) {
    return (void *)(page2pa(page) + PHYSICAL_MEMORY_OFFSET);
}

// 定义数据结构和函数声明

struct kmem_cache {
    size_t object_size;         // 对象大小
    size_t align;               // 对齐
    size_t size;                // 实际分配大小，考虑对齐
    struct list_entry slab_list;  // slab 链表
    const char *name;           // 缓存名称
};

struct slab {
    struct list_entry slab_list; // 链入 kmem_cache 的 slab_list
    void *s_mem;                 // 第一个对象的起始地址
    unsigned int inuse;          // 已分配的对象数
    unsigned int free;           // 下一个可用对象的索引
    void *free_list;             // 空闲对象链表
};

#define le2slab(le, member) \
    ((struct slab *)((char *)(le) - offsetof(struct slab, member)))

extern const struct pmm_manager slub_pmm_manager;

void *kmalloc(size_t size);
void kfree(void *obj);

#endif /* !__KERN_MM_SLUB_PMM_H__ */
