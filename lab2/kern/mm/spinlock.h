/* spinlock.h - 简化版自旋锁实现 */

#ifndef SPINLOCK_H
#define SPINLOCK_H

#include "defs.h"  // 引入已有的类型定义

/* 自旋锁结构 */
typedef struct {
    volatile int locked;
} spinlock_t;

/* 初始化自旋锁 */
#define SPINLOCK_INITIALIZER { 0 }

/* 获取自旋锁 */
static inline void spin_lock(spinlock_t *lock) {
    while (__sync_lock_test_and_set(&lock->locked, 1)) {
        /* 自旋等待 */
        while (lock->locked) {
            /* 可选：添加 CPU 休眠指令以减少功耗 */
        }
    }
}

/* 释放自旋锁 */
static inline void spin_unlock(spinlock_t *lock) {
    __sync_lock_release(&lock->locked);
}

#endif /* SPINLOCK_H */
