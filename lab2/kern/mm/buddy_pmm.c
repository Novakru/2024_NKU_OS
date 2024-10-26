#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_pmm.h>

/*
 * Buddy system memory allocator implementation.
 * The buddy allocator manages memory in powers of two, maintaining free memory blocks
 * that are split or merged as needed to satisfy memory allocation and deallocation.
 * 
 * The memory is divided into blocks whose sizes are always powers of two.
 * To allocate memory, the system searches for the smallest block that can satisfy the request,
 * possibly splitting larger blocks into smaller ones. When freeing, the allocator attempts to merge
 * "buddy" blocks back into larger blocks.
 */


#define MAX_ORDER 15  // Example: Supports up to 2^14 (16384) pages

struct buddy_free_area_t {
    list_entry_t free_list[MAX_ORDER];  // Separate list for each block size
    unsigned int nr_free[MAX_ORDER];    // Number of free blocks of each size
};

static struct buddy_free_area_t free_area;

#define free_list(order) (free_area.free_list[(order)])
#define nr_free(order) (free_area.nr_free[(order)])

static int
ilog2(size_t n) {
    int log = 0;
    while (n > 1) {
        n >>= 1;
        log++;
    }
    return log;
}


static void
show_buddy_info(void) {
    cprintf("Buddy System Status:\n");

    // 打印每个 order 的信息标题
    for (int order = 0; order < MAX_ORDER; order++) {
        cprintf("2^%d\t", order);
    }
    cprintf("\n");

    // 打印每个 order 的块数
    for (int order = 0; order < MAX_ORDER; order++) {
        cprintf("%u\t", nr_free(order));
    }
    cprintf("\n");
}

static void 
show_order_info(size_t order) {
	list_entry_t* le = &free_list(order);
	cprintf("after merge(order = %d): ", order);
	while ((le = list_next(le)) != &free_list(order)) {
		struct Page* curr_page = le2page(le, page_link);
		cprintf("[%p, %d]; ", page2pa(curr_page), curr_page->property);
	}
	cprintf("\n");
}

static void
buddy_init(void) {
    for (int i = 0; i < MAX_ORDER; i++) {
        list_init(&free_list(i));
        nr_free(i) = 0;
    }
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
	cprintf("init size want to: %d \n", n);
    size_t nearest_power_of_2 = 1;
    while (nearest_power_of_2 < n) {
        nearest_power_of_2 <<= 1;
    }
	nearest_power_of_2 >>= 1;
	cprintf("init size actually: %d \n", nearest_power_of_2);
    n = nearest_power_of_2 ;  // Adjust n to the nearest power of 2

    struct Page *p = base;
    for (; p != base + n; p++) {
		// uintptr_t phys_addr = page2pa(p);
        // cprintf("Mapping physical address: %p", phys_addr);
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
	cprintf("add free list[%d]\n", ilog2(n));
    list_add(&free_list(ilog2(n)), &(base->page_link));
    nr_free(ilog2(n))++;
	
}

static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    size_t order = 0;
    size_t size = 1;

    while (size < n) {
        size <<= 1;
        order++;
    }
    if (order >= MAX_ORDER) {
        return NULL;
    }

    for (size_t current_order = order; current_order < MAX_ORDER; current_order++) {
        if (!list_empty(&free_list(current_order))) {
            list_entry_t *le = list_next(&free_list(current_order));
            struct Page *page = le2page(le, page_link);
            list_del(le);
            nr_free(current_order)--;

            size_t split_size = 1 << current_order;

            while (current_order > order) {
                current_order--;
                split_size >>= 1;
                struct Page *buddy = page + split_size;
                buddy->property = split_size;
                SetPageProperty(buddy);

				// 确保有序排列，方便后续合并
				if (list_empty(&free_list(current_order))) {
					list_add(&free_list(current_order), &(buddy->page_link));
				} else {
					list_entry_t* le = &free_list(current_order);
					while ((le = list_next(le)) != &free_list(current_order)) {
						struct Page* curr_page = le2page(le, page_link);
						if (buddy < curr_page) {
							list_add_before(le, &(buddy->page_link));
							break;
						} else if (list_next(le) == &free_list(current_order)) {
							list_add(le, &(buddy->page_link));
						}
					}
				}

                nr_free(current_order)++;
            }

            ClearPageProperty(page);
            return page;
        }
    }
    return NULL;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0 && (n & (n - 1)) == 0);
    size_t order = (size_t)ilog2(n);
    struct Page *p = base;

    // 重置属性
    for (; p != base + n; p++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);

    // 将块添加到适当的 order 链表中
    list_entry_t *le = &free_list(order);
	if (list_empty(&free_list(order))) {
		list_add(&free_list(order), &(base->page_link));
	} else {
		list_entry_t* le = (&free_list(order));
		while ((le = list_next(le)) != (&free_list(order))) {
			struct Page* page = le2page(le, page_link);
			if (base < page) {
				list_add_before(le, &(base->page_link));
				break;
			} else if (list_next(le) == (&free_list(order))) {
				list_add(le, &(base->page_link));
			}
		}
	}
	nr_free(order)++;

    // 继续检查并尝试合并
    while (order < MAX_ORDER - 1) {
        int merged = 0;

        le = list_prev(&(base->page_link));
        if (le != &free_list(order)) {
            struct Page *prev_page = le2page(le, page_link);
			if (order == 1) prev_page = base - 2;
			// cprintf("---------------%p-------------", page2pa(prev_page));
			// le = list_next(&(base->page_link));
			// struct Page *next_page = le2page(le, page_link);
			// cprintf("---------------%p-------------", page2pa(next_page));
			// cprintf("---------------%p-------------", page2pa(le2page(&free_list(order), page_link)));
            if (prev_page + prev_page->property == base) {
                cprintf("------------------------before merge---------------------------\n");
                show_order_info(order);
                show_order_info(order + 1);

                // 合并前一个块
                prev_page->property += base->property;
                ClearPageProperty(base);
                list_del(&(base->page_link));
                list_del(&(prev_page->page_link));

                // 更新 base 为新的合并块的起始页
                base = prev_page;

                nr_free(order) -= 2;

                // 将合并后的块加入到更高的 order 链表中，按地址顺序插入
				if (list_empty(&free_list(order + 1))) {
					list_add(&free_list(order + 1), &(base->page_link));
				} else {
					list_entry_t* le = (&free_list(order + 1));
					while ((le = list_next(le)) != (&free_list(order + 1))) {
						struct Page* page = le2page(le, page_link);
						if (base < page) {
							list_add_before(le, &(base->page_link));
							break;
						} else if (list_next(le) == (&free_list(order + 1))) {
							list_add(le, &(base->page_link));
						}
					}
				}

                cprintf("------------------------------after merge------------------------\n");
                show_order_info(order);
                show_order_info(order + 1);
                nr_free(order + 1) += 1;
                order++;
                cprintf("curr_merge_order: %d\n", order);
                merged = 1;
            }
        }

        // (3.2) 与后面的块合并
        if (!merged) {
            le = list_next(&(base->page_link));
            if (le != &free_list(order)) {
                struct Page *next_page = le2page(le, page_link);
				if (order == 1) next_page = base + 2;
                if (base + base->property == next_page) {
					cprintf("------------------------before merge---------------------------\n");
                    show_order_info(order);
                    show_order_info(order + 1);

                    // 合并后一个块
                    base->property += next_page->property;
                    ClearPageProperty(next_page);
                    list_del(&(next_page->page_link));
                    list_del(&(base->page_link));

                    nr_free(order) -= 2;

                    // 将合并后的块加入到更高的 order 链表中，按地址顺序插入
					if (list_empty(&free_list(order + 1))) {
						list_add(&free_list(order + 1), &(base->page_link));
					} else {
						list_entry_t* le = (&free_list(order + 1));
						while ((le = list_next(le)) != (&free_list(order + 1))) {
							struct Page* page = le2page(le, page_link);
							if (base < page) {
								list_add_before(le, &(base->page_link));
								break;
							} else if (list_next(le) == (&free_list(order + 1))) {
								list_add(le, &(base->page_link));
							}
						}
					}

					cprintf("------------------------after merge---------------------------\n");
                    show_order_info(order);
                    show_order_info(order + 1);
                    nr_free(order + 1) += 1;
                    order++;
                    cprintf("curr_merge_order: %d\n", order);
                    continue;
                }
            }
        }

        // 如果没有合并成功，退出循环
        if (!merged) break;
    }
}


static size_t
buddy_nr_free_pages(void) {
    size_t total = 0;
    for (int i = 0; i < MAX_ORDER; i++) {
        total += nr_free(i) * (1 << i);
    }
    return total;
}


static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
	show_buddy_info();
    assert((p0 = buddy_alloc_pages(1)) != NULL);
	show_buddy_info();
    assert((p1 = buddy_alloc_pages(1)) != NULL);
	show_buddy_info();
    assert((p2 = buddy_alloc_pages(1)) != NULL);
	show_buddy_info();
	// // 输出 p0, p1, p2 的物理地址
    // uintptr_t addr_p0 = page2pa(p0);
    // uintptr_t addr_p1 = page2pa(p1);
    // uintptr_t addr_p2 = page2pa(p2);

    // cprintf("Allocated Page Addresses:\n");
    // cprintf("p0: %p\n", addr_p0);
    // cprintf("p1: %p\n", addr_p1);
    // cprintf("p2: %p\n", addr_p2);

	cprintf("~~~~~~~~~~~~~~~~~~~~~~buddy_alloc_pages done!~~~~~~~~~~~~~~~~~~~~~~\n");

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
	// cprintf("addr & ref check done!\n");

	cprintf("\n\n\n\n");
	cprintf("******************buddy_nr_free_pages(p0, 1)**********************   freeSz:%d\n", buddy_nr_free_pages());
    buddy_free_pages(p0, 1);
	show_buddy_info();
	cprintf("\n\n\n\n");
	cprintf("******************buddy_nr_free_pages(p1, 1)**********************   freeSz:%d\n", buddy_nr_free_pages());
    buddy_free_pages(p1, 1);
	show_buddy_info();
	cprintf("\n\n\n\n");
	cprintf("******************buddy_nr_free_pages(p2, 1)**********************   freeSz:%d\n", buddy_nr_free_pages());
    buddy_free_pages(p2, 1);
	show_buddy_info();
	cprintf("\n\n\n\n");
	cprintf("~~~~~~~~~~~~~~~~~~~~~buddy_free_pages done!~~~~~~~~~~~~~~~~~~~~~~~\n\n\n");

    // assert((p0 = buddy_alloc_pages(2)) != NULL);
	// cprintf("buddy_alloc_pages(2):%d\n", buddy_nr_free_pages());
	// show_buddy_info();
    // assert((p1 = buddy_alloc_pages(1)) != NULL);
	// show_buddy_info();
	// cprintf("buddy_alloc_pages(1):%d\n", buddy_nr_free_pages());
    // assert(p0 != p1);
	// // show_buddy_info();
    // buddy_free_pages(p0, 2);
    // buddy_free_pages(p1, 1);
}


static void
buddy_check(void) {
    basic_check();
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
