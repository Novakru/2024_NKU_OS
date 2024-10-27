#include "slub_pmm.h"
#include <buddy_pmm.h>
#include <string.h>     // 包含 memset
#include <assert.h>     // 包含 assert
#include <stdio.h>      // 包含 cprintf

#define MAX_KMEM_CACHE 16  // 最大缓存种类数量
extern void buddy_init_memmap(struct Page *base, size_t n);
static struct kmem_cache kmem_caches[MAX_KMEM_CACHE];
static int kmem_cache_count = 0;

// 常用的对象大小
static size_t kmem_size_caches[] = {
    8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096
};

// 前向声明
static void slub_init(void);
static void slub_init_memmap(struct Page *base, size_t n);
static struct Page *slub_alloc_pages(size_t n);
static void slub_free_pages(struct Page *base, size_t n);
static size_t slub_nr_free_pages(void);
static void slub_check(void);

const struct pmm_manager slub_pmm_manager = {
    .name = "slub_pmm_manager",
    .init = slub_init,
    .init_memmap = slub_init_memmap,
    .alloc_pages = slub_alloc_pages,
    .free_pages = slub_free_pages,
    .nr_free_pages = slub_nr_free_pages,
    .check = slub_check,
};

static void slub_init(void) {
    int i;
    kmem_cache_count = sizeof(kmem_size_caches) / sizeof(size_t);
    for (i = 0; i < kmem_cache_count; i++) {
        kmem_caches[i].object_size = kmem_size_caches[i];
        kmem_caches[i].align = sizeof(void *);  // 指针大小对齐
        kmem_caches[i].size = kmem_caches[i].object_size;
        list_init(&(kmem_caches[i].slab_list));
        kmem_caches[i].name = "kmem_cache";
    }
}
// 全局空闲页面链表
static list_entry_t free_page_list;

// 全局变量：空闲页面计数
static size_t free_pages_count = 0;

// 初始化页面内存映射，将所有页面放入空闲链表
void slub_init_memmap(struct Page *base, size_t n) {
    list_init(&free_page_list);  // 初始化链表
    free_pages_count = n;  // 初始化空闲页面计数
    //free_pages_count = 0;  // 初始化空闲页面计数
    // 将每个页面加入链表
    for (size_t i = 0; i < n; i++) {
        list_add(&free_page_list, &(base[i].page_link));
    }
    //buddy_init_memmap(base, n); 
}

// 分配单个页面
// static struct Page *slub_alloc_pages(size_t n) {
//     assert(n == 1);  // 只处理单页分配

//     // 检查是否有空闲页面
//     if (list_empty(&free_page_list)) {
//         return NULL;  // 没有可用页面，返回 NULL
//     }

//     // 获取链表中的第一个页面
//     list_entry_t *le = list_next(&free_page_list);
//     struct Page *page = le2page(le, page_link);

//     // 从链表中移除该页面，并减少空闲页面计数
//     list_del(le);
//     free_pages_count--;

//     // 标记页面为 SLUB 使用
//     SetPageSlab(page);

//     return page;
// }
// 释放单个页面
// static void slub_free_pages(struct Page *base, size_t n) {
//     assert(n == 1);  // 只处理单页释放
//     assert(PageSlab(base));  // 确保该页面由 SLUB 分配

//     // 清除 SLUB 标记
//     ClearPageSlab(base);

//     // 将页面放回空闲链表，并增加空闲页面计数
//     list_add(&free_page_list, &(base->page_link));
//     free_pages_count++;
// }

// 返回当前空闲页面数量（
// static size_t slub_nr_free_pages(void) {
//     return free_pages_count;  // 返回空闲页面计数
// }
// 使用 Buddy 系统的页面分配接口
// static struct Page *slub_alloc_pages(size_t n) {
//     struct Page *page = buddy_alloc_pages(n);  // 通过 Buddy 系统分配页面
//     if (page != NULL) {
//         if (n==1){
//         SetPageSlab(page);  // 标记页面为 SLUB 使用
//         }
//         else
//         { 
//         SetPageBigObj(page);  // 设置页面为大对象标志
//         }
//     }
//     return page;
// }
static struct Page *slub_alloc_pages(size_t n) {
    struct Page *page = NULL;

    // 如果只需要一个页面，尝试从空闲链表中获取
    if (n == 1) {
        if (!list_empty(&free_page_list)) {
           
             cprintf("no ask buddy");
    list_entry_t *le = list_next(&free_page_list);
    struct Page *page = le2page(le, page_link);

    // 从链表中移除该页面，并减少空闲页面计数
    list_del(le);
    free_pages_count--;

    // 标记页面为 SLUB 使用
    SetPageSlab(page);

    return page;
        }
    }
    cprintf("ask buddy");

    // 如果链表为空或请求多个页面，则使用 Buddy 系统分配
    page = buddy_alloc_pages(n);
    if (page != NULL) {
        if (n == 1) {
            SetPageSlab(page);  // 标记页面为 SLUB 使用
        } else {
            SetPageBigObj(page);  // 设置为大对象标志
        }
    }

    return page;
}
// // 使用 Buddy 系统的页面释放接口
// static void slub_free_pages(struct Page *base, size_t n) {
//     assert(PageSlab(base));  // 确保页面由 SLUB 分配
//     ClearPageSlab(base);  // 清除 SLUB 标记
//     buddy_free_pages(base, n);  // 通过 Buddy 系统释放页面
// }
// // 查询剩余页面数量
// static size_t slub_nr_free_pages(void) {
//     return buddy_nr_free_pages();  // 使用 Buddy 系统查询剩余页面
// }
// 使用 Buddy 系统的页面释放接口
static void slub_free_pages(struct Page *base, size_t n) {
    if (n == 1 && PageSlab(base)) {
        // 单页面且为 SLUB 页面时，将页面归还到空闲链表
        ClearPageSlab(base);  // 清除 SLUB 标记
        list_add(&(base->page_link), &free_page_list);  // 加入空闲链表
        free_pages_count++;  // 增加空闲页面计数
    } else {
        // 多页面或非 SLUB 页面时，通过 Buddy 系统释放
        if (n > 1) {
            ClearPageBigObj(base);  // 清除大对象标记
        }
        buddy_free_pages(base, n);
    }
}

// 查询剩余页面数量
static size_t slub_nr_free_pages(void) {
    // 返回空闲链表页面数和 Buddy 系统页面数之和
    return free_pages_count + buddy_nr_free_pages();
}




// void *kmalloc(size_t size) {
//     int i;
//     struct kmem_cache *cache = NULL;
//     for (i = 0; i < kmem_cache_count; i++) {
//         if (kmem_caches[i].object_size >= size) {
//             cache = &kmem_caches[i];
//             break;
//         }
//     }
//     if (cache == NULL) {
//         // 对象大小过大，直接分配页面
//         struct Page *page = slub_alloc_pages(1);
//         if (page == NULL) return NULL;
//         return page2kva(page);
//     }

//     // 在 kmem_cache 中查找有可用空间的 slab
//     struct slab *slab = NULL;
//     list_entry_t *le = &cache->slab_list;
//     while ((le = list_next(le)) != &cache->slab_list) {
//         slab = le2slab(le, slab_list);
//         if (slab->inuse < (PGSIZE - sizeof(struct slab)) / cache->size) {
//             break;
//         }
//     }

//     if (le == &cache->slab_list) {
//         // 没有可用的 slab，创建新的
//         struct Page *page = slub_alloc_pages(1);
//         if (page == NULL) return NULL;
//         slab = (struct slab *)page2kva(page);
//         memset(slab, 0, sizeof(struct slab));
//         slab->s_mem = (void *)((char *)slab + sizeof(struct slab));
//         slab->inuse = 0;
//         slab->free = 0;
//         list_add(&cache->slab_list, &(slab->slab_list));
//     }

//     // 分配对象
//     void *obj = (void *)((char *)slab->s_mem + slab->free * cache->size);
//     slab->inuse++;
//     slab->free++;
//     return obj;
// }




// void *kmalloc(size_t size) {
//     int i;
//     struct kmem_cache *cache = NULL;
//     for (i = 0; i < kmem_cache_count; i++) {
//         if (kmem_caches[i].object_size >= size) {
//             cache = &kmem_caches[i];
//             break;
//         }
//     }
   
// //     if (cache == NULL) {
// //     // 对象大小过大，直接分配页面
// //     struct Page *page = slub_alloc_pages(1);
// //     if (page == NULL) return NULL;
// //     SetPageBigObj(page);  // 设置页面为大对象标志
// //     return page2kva(page);
// // }
//      if (cache == NULL) {
//         // 对象大小过大，直接分配页面
//         size_t n = (size + PGSIZE - 1) / PGSIZE;  // 计算需要的页数
//         struct Page *page = slub_alloc_pages(n);
//         if (page == NULL) return NULL;
//         page->property = n;  // 记录分配的页数
       
//         return page2kva(page);
//     }

//     // 在 kmem_cache 中查找有可用空间的 slab
//     struct slab *slab = NULL;
//     list_entry_t *le = &cache->slab_list;

// find_slab:
//     while ((le = list_next(le)) != &cache->slab_list) {
//         slab = le2slab(le, slab_list);
//         // 如果 slab 有空闲对象，或者还未分配满
//         if (slab->free_list != NULL || 
//             slab->inuse < ((PGSIZE - ((char *)slab->s_mem - (char *)slab)) / cache->size)) {
//             break;
//         }
//     }

//     if (le == &cache->slab_list) {
//         // 没有可用的 slab，创建新的
//         struct Page *page = slub_alloc_pages(1);
//         if (page == NULL) return NULL;
//         slab = (struct slab *)page2kva(page);
//         memset(slab, 0, sizeof(struct slab));
//         slab->s_mem = (void *)(((uintptr_t)(slab + 1) + cache->align - 1) & ~(cache->align -1));
//         slab->inuse = 0;
//         slab->free_list = NULL;
//         list_add(&cache->slab_list, &(slab->slab_list));
//     }

//     void *obj = NULL;
//     if (slab->free_list != NULL) {
//         // 从空闲链表中取出一个对象
//         obj = slab->free_list;
//         slab->free_list = *(void **)obj;
//     } else {
//         // 检查是否超过容量
//         size_t max_objects = ((PGSIZE - ((char *)slab->s_mem - (char *)slab)) / cache->size);
//         if (slab->inuse >= max_objects) {
//             // 当前 slab 已满，需要寻找下一个 slab
//             goto find_slab;
//         }
//         // 从未使用的区域分配
//         obj = (void *)((char *)slab->s_mem + slab->inuse * cache->size);
//     }
//     slab->inuse++;
//     return obj;
// }
void *kmalloc(size_t size) {
    int i;
    struct kmem_cache *cache = NULL;

    // 1. 查找适合的 kmem_cache
    for (i = 0; i < kmem_cache_count; i++) {
        if (kmem_caches[i].object_size >= size) {
            cache = &kmem_caches[i];
            break;
        }
    }

    // 2. 如果没有找到合适的缓存，直接分配页面
    if (cache == NULL) {
        size_t n = (size + PGSIZE - 1) / PGSIZE;  // 计算所需页数
        struct Page *page = slub_alloc_pages(n);
        if (page == NULL) return NULL;

        if (n == 1) {
            SetPageSlab(page);  // 标记单页为 SLUB 使用
        } else {
            SetPageBigObj(page);  // 标记多页为大对象
        }

        page->property = n;  // 记录分配的页数
        return page2kva(page);
    }

    // 3. 在 kmem_cache 中查找合适的 slab
    struct slab *slab = NULL;
    list_entry_t *le = &cache->slab_list;

find_slab:
    while ((le = list_next(le)) != &cache->slab_list) {
        slab = le2slab(le, slab_list);

        // 如果 slab 有空闲对象或还未使用完
        size_t max_objects = (PGSIZE - ((char *)slab->s_mem - (char *)slab)) / cache->size;
        if (slab->free_list != NULL || slab->inuse < max_objects) {
            break;
        }
    }

    // 4. 如果没有可用的 slab，创建新的 slab
    if (le == &cache->slab_list) {
        struct Page *page = slub_alloc_pages(1);
        if (page == NULL) return NULL;

        slab = (struct slab *)page2kva(page);
        memset(slab, 0, sizeof(struct slab));

        slab->s_mem = (void *)(((uintptr_t)(slab + 1) + cache->align - 1) & ~(cache->align - 1));
        slab->inuse = 0;
        slab->free_list = NULL;
        list_add(&cache->slab_list, &(slab->slab_list));
    }

    // 5. 从 slab 中分配对象
    void *obj = NULL;
    if (slab->free_list != NULL) {
        // 从空闲链表中取出一个对象
        obj = slab->free_list;
        slab->free_list = *(void **)obj;
    } else {
        // 检查是否超出容量
        size_t max_objects = (PGSIZE - ((char *)slab->s_mem - (char *)slab)) / cache->size;
        if (slab->inuse >= max_objects) {
            // 当前 slab 已满，寻找下一个 slab
            goto find_slab;
        }
        // 从未使用的区域分配对象
        obj = (void *)((char *)slab->s_mem + slab->inuse * cache->size);
    }

    slab->inuse++;
    return obj;
}
static inline struct Page *kva2page(void *kva) {
    return pa2page((uintptr_t)kva - PHYSICAL_MEMORY_OFFSET);  // 将虚拟地址转换为物理地址并映射到页面
}

// void kfree(void *obj) {
//     assert(obj != NULL);  // 确保传入的对象不为空
//        // // 首先，检查对象是否属于直接分配的大对象
//     // struct Page *page = kva2page((void *)((uintptr_t)obj & ~(PGSIZE - 1)));
//     // if (PageBigObj(page)) {
//     //     // 对象是直接分配的页面，需要释放页面
//     //     ClearPageBigObj(page);
//     //     slub_free_pages(page, 1);
//     //     return;
//     // }


//     struct Page *page = kva2page((void *)((uintptr_t)obj & ~(PGSIZE - 1)));
//     if (PageBigObj(page)) {
//         // 对象是直接分配的页面，需要释放页面
//         size_t n = page->property;  // 获取分配的页数
//         ClearPageBigObj(page);
//         slub_free_pages(page, n);  // 释放正确数量的页面
//         return;
//     }
   

 

//     struct slab *slab = NULL;
//     struct kmem_cache *cache = NULL;
//     int found = 0;

//     // 遍历所有缓存池，找到包含该对象的 slab
//     for (int i = 0; i < kmem_cache_count; i++) {
//         cache = &kmem_caches[i];
//         list_entry_t *le = &cache->slab_list;

//         // 遍历当前缓存池中的所有 slab
//         while ((le = list_next(le)) != &cache->slab_list) {
//             slab = le2slab(le, slab_list);

//             // 检查对象是否在这个 slab 中
//             //size_t slab_size = PGSIZE;
//             size_t slab_size = PGSIZE - ((char *)slab->s_mem - (char *)slab);
//             if ((char *)obj >= (char *)slab->s_mem &&
//             (char *)obj < (char *)slab->s_mem + slab_size) {
//              found = 1;
//              break;  // 找到所属的 slab，跳出循环
//             }

            
//             // if ((char *)obj >= (char *)slab->s_mem &&
//             //     (char *)obj < (char *)slab + slab_size) {
//             //     found = 1;
//             //     break;  // 找到所属的 slab，跳出循环
//             // }
//         }
//         if (found) break;
//     }

//     // 如果没有找到所属的 slab，则报错
//     if (!found) {
//         panic("kfree: invalid object pointer!\n");
//     }

//     // 将对象加入到 slab 的 free_list 中
//     *(void **)obj = slab->free_list;
//     slab->free_list = obj;

//     // 减少已使用对象计数
//     slab->inuse--;

//     // 如果 slab 中没有对象在使用，释放该 slab 的页面
//     if (slab->inuse == 0) {
//         // 从缓存池链表中移除 slab
//         list_del(&(slab->slab_list));

//         // 将虚拟地址转换为页面结构，并释放该页面
//         struct Page *page = kva2page(slab);
//         slub_free_pages(page, 1);  // 释放页面
//     }
// }


// 修改后的 kfree 函数
void kfree(void *obj) {
    assert(obj != NULL);  // 确保对象不为空

    // 1. 检查对象是否属于大对象
    struct Page *page = kva2page((void *)((uintptr_t)obj & ~(PGSIZE - 1)));
    if (PageBigObj(page)) {
        size_t n = page->property;  // 获取分配的页数
        
        slub_free_pages(page, n);   // 释放正确数量的页面
        return;
    }

    struct slab *slab = NULL;
    struct kmem_cache *cache = NULL;
    int found = 0;

    // 2. 遍历所有缓存池，找到包含该对象的 slab
    for (int i = 0; i < kmem_cache_count; i++) {
        cache = &kmem_caches[i];
        list_entry_t *le = &cache->slab_list;

        // 遍历当前缓存池中的所有 slab
        while ((le = list_next(le)) != &cache->slab_list) {
            slab = le2slab(le, slab_list);

            // 计算 slab 的有效区域大小
            size_t slab_size = PGSIZE - ((char *)slab->s_mem - (char *)slab);
            if ((char *)obj >= (char *)slab->s_mem &&
                (char *)obj < (char *)slab->s_mem + slab_size) {
                found = 1;  // 找到对象所属的 slab
                break;
            }
        }
        if (found) break;
    }

    // 3. 如果没有找到所属的 slab，则报错
    if (!found) {
        panic("kfree: invalid object pointer!\n");
    }

    // 4. 将对象加入到 slab 的 free_list 中
    *(void **)obj = slab->free_list;
    slab->free_list = obj;

    // 减少已使用对象计数
    slab->inuse--;

    // 5. 如果 slab 中没有对象在使用，释放该 slab 的页面
    if (slab->inuse == 0) {
        // 从缓存池链表中移除 slab
        list_del(&(slab->slab_list));

        // 将 slab 的虚拟地址转换为页面，并释放该页面
        struct Page *page = kva2page(slab);
        slub_free_pages(page, 1);  // 释放页面
    }
}


static void slub_check(void) {
    cprintf("SLUB allocator check start...\n");

    void *obj1 = kmalloc(33);
    assert(obj1 != NULL);
    
    void *obj2 = kmalloc(69);
    assert(obj2 != NULL);
    //struct Page * p0 = buddy_alloc_pages(2);
    //void *obj3 = kmalloc(100000);
    //assert(obj3 != NULL);
  

    kfree(obj1);
    kfree(obj2);
    //kfree(obj3);

    
    

    cprintf("SLUB allocator check passed!\n");
}
