
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
void trigger_ebreak();
void trigger_illegal_instruction();

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00e50513          	addi	a0,a0,14 # 80204018 <buf>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	42660613          	addi	a2,a2,1062 # 80204438 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	071000ef          	jal	ra,80200892 <memset>

    cons_init();  // init the console
    80200026:	3c6000ef          	jal	ra,802003ec <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	d8658593          	addi	a1,a1,-634 # 80200db0 <etext>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	d9e50513          	addi	a0,a0,-610 # 80200dd0 <etext+0x20>
    8020003a:	05a000ef          	jal	ra,80200094 <cprintf>

    print_kerninfo();
    8020003e:	0fa000ef          	jal	ra,80200138 <print_kerninfo>
print_stackframe();
    80200042:	184000ef          	jal	ra,802001c6 <print_stackframe>
    //grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200046:	3c0000ef          	jal	ra,80200406 <idt_init>

    intr_enable();  // enable irq interrupt
    8020004a:	3b0000ef          	jal	ra,802003fa <intr_enable>
    static int round = 0;
    round++;
}

void trigger_ebreak() {
    __asm__ __volatile__ (
    8020004e:	9002                	ebreak
    );
}

// 触发非法指令异常的函数
void trigger_illegal_instruction() {
    __asm__ __volatile__ (
    80200050:	30200073          	mret
    clock_init();  // init clock interrupt
    80200054:	356000ef          	jal	ra,802003aa <clock_init>
    while (1)
    80200058:	a001                	j	80200058 <kern_init+0x4e>

000000008020005a <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    8020005a:	1141                	addi	sp,sp,-16
    8020005c:	e022                	sd	s0,0(sp)
    8020005e:	e406                	sd	ra,8(sp)
    80200060:	842e                	mv	s0,a1
    cons_putc(c);
    80200062:	38c000ef          	jal	ra,802003ee <cons_putc>
    (*cnt)++;
    80200066:	401c                	lw	a5,0(s0)
}
    80200068:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    8020006a:	2785                	addiw	a5,a5,1
    8020006c:	c01c                	sw	a5,0(s0)
}
    8020006e:	6402                	ld	s0,0(sp)
    80200070:	0141                	addi	sp,sp,16
    80200072:	8082                	ret

0000000080200074 <vcprintf>:
 * written to stdout.
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap) {
    80200074:	1101                	addi	sp,sp,-32
    80200076:	862a                	mv	a2,a0
    80200078:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007a:	00000517          	auipc	a0,0x0
    8020007e:	fe050513          	addi	a0,a0,-32 # 8020005a <cputch>
    80200082:	006c                	addi	a1,sp,12
int vcprintf(const char *fmt, va_list ap) {
    80200084:	ec06                	sd	ra,24(sp)
    int cnt = 0;
    80200086:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200088:	089000ef          	jal	ra,80200910 <vprintfmt>
    return cnt;
}
    8020008c:	60e2                	ld	ra,24(sp)
    8020008e:	4532                	lw	a0,12(sp)
    80200090:	6105                	addi	sp,sp,32
    80200092:	8082                	ret

0000000080200094 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200094:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200096:	02810313          	addi	t1,sp,40 # 80204028 <buf+0x10>
int cprintf(const char *fmt, ...) {
    8020009a:	8e2a                	mv	t3,a0
    8020009c:	f42e                	sd	a1,40(sp)
    8020009e:	f832                	sd	a2,48(sp)
    802000a0:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    802000a2:	00000517          	auipc	a0,0x0
    802000a6:	fb850513          	addi	a0,a0,-72 # 8020005a <cputch>
    802000aa:	004c                	addi	a1,sp,4
    802000ac:	869a                	mv	a3,t1
    802000ae:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    802000b0:	ec06                	sd	ra,24(sp)
    802000b2:	e0ba                	sd	a4,64(sp)
    802000b4:	e4be                	sd	a5,72(sp)
    802000b6:	e8c2                	sd	a6,80(sp)
    802000b8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    802000ba:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    802000bc:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    802000be:	053000ef          	jal	ra,80200910 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    802000c2:	60e2                	ld	ra,24(sp)
    802000c4:	4512                	lw	a0,4(sp)
    802000c6:	6125                	addi	sp,sp,96
    802000c8:	8082                	ret

00000000802000ca <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c) { cons_putc(c); }
    802000ca:	a615                	j	802003ee <cons_putc>

00000000802000cc <getchar>:
    cputch('\n', &cnt);
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int getchar(void) {
    802000cc:	1141                	addi	sp,sp,-16
    802000ce:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0) /* do nothing */;
    802000d0:	326000ef          	jal	ra,802003f6 <cons_getc>
    802000d4:	dd75                	beqz	a0,802000d0 <getchar+0x4>
    return c;
}
    802000d6:	60a2                	ld	ra,8(sp)
    802000d8:	0141                	addi	sp,sp,16
    802000da:	8082                	ret

00000000802000dc <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void __panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
    802000dc:	00004317          	auipc	t1,0x4
    802000e0:	33c30313          	addi	t1,t1,828 # 80204418 <is_panic>
    802000e4:	00032e03          	lw	t3,0(t1)
void __panic(const char *file, int line, const char *fmt, ...) {
    802000e8:	715d                	addi	sp,sp,-80
    802000ea:	ec06                	sd	ra,24(sp)
    802000ec:	e822                	sd	s0,16(sp)
    802000ee:	f436                	sd	a3,40(sp)
    802000f0:	f83a                	sd	a4,48(sp)
    802000f2:	fc3e                	sd	a5,56(sp)
    802000f4:	e0c2                	sd	a6,64(sp)
    802000f6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
    802000f8:	020e1a63          	bnez	t3,8020012c <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
    802000fc:	4785                	li	a5,1
    802000fe:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    80200102:	8432                	mv	s0,a2
    80200104:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
    80200106:	862e                	mv	a2,a1
    80200108:	85aa                	mv	a1,a0
    8020010a:	00001517          	auipc	a0,0x1
    8020010e:	cce50513          	addi	a0,a0,-818 # 80200dd8 <etext+0x28>
    va_start(ap, fmt);
    80200112:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
    80200114:	f81ff0ef          	jal	ra,80200094 <cprintf>
    vcprintf(fmt, ap);
    80200118:	65a2                	ld	a1,8(sp)
    8020011a:	8522                	mv	a0,s0
    8020011c:	f59ff0ef          	jal	ra,80200074 <vcprintf>
    cprintf("\n");
    80200120:	00001517          	auipc	a0,0x1
    80200124:	da050513          	addi	a0,a0,-608 # 80200ec0 <etext+0x110>
    80200128:	f6dff0ef          	jal	ra,80200094 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
    8020012c:	2d4000ef          	jal	ra,80200400 <intr_disable>
    while (1) {
        kmonitor(NULL);
    80200130:	4501                	li	a0,0
    80200132:	130000ef          	jal	ra,80200262 <kmonitor>
    while (1) {
    80200136:	bfed                	j	80200130 <__panic+0x54>

0000000080200138 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    80200138:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    8020013a:	00001517          	auipc	a0,0x1
    8020013e:	cbe50513          	addi	a0,a0,-834 # 80200df8 <etext+0x48>
void print_kerninfo(void) {
    80200142:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    80200144:	f51ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    80200148:	00000597          	auipc	a1,0x0
    8020014c:	ec258593          	addi	a1,a1,-318 # 8020000a <kern_init>
    80200150:	00001517          	auipc	a0,0x1
    80200154:	cc850513          	addi	a0,a0,-824 # 80200e18 <etext+0x68>
    80200158:	f3dff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    8020015c:	00001597          	auipc	a1,0x1
    80200160:	c5458593          	addi	a1,a1,-940 # 80200db0 <etext>
    80200164:	00001517          	auipc	a0,0x1
    80200168:	cd450513          	addi	a0,a0,-812 # 80200e38 <etext+0x88>
    8020016c:	f29ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    80200170:	00004597          	auipc	a1,0x4
    80200174:	ea858593          	addi	a1,a1,-344 # 80204018 <buf>
    80200178:	00001517          	auipc	a0,0x1
    8020017c:	ce050513          	addi	a0,a0,-800 # 80200e58 <etext+0xa8>
    80200180:	f15ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    80200184:	00004597          	auipc	a1,0x4
    80200188:	2b458593          	addi	a1,a1,692 # 80204438 <end>
    8020018c:	00001517          	auipc	a0,0x1
    80200190:	cec50513          	addi	a0,a0,-788 # 80200e78 <etext+0xc8>
    80200194:	f01ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200198:	00004597          	auipc	a1,0x4
    8020019c:	69f58593          	addi	a1,a1,1695 # 80204837 <end+0x3ff>
    802001a0:	00000797          	auipc	a5,0x0
    802001a4:	e6a78793          	addi	a5,a5,-406 # 8020000a <kern_init>
    802001a8:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    802001ac:	43f7d593          	srai	a1,a5,0x3f
}
    802001b0:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    802001b2:	3ff5f593          	andi	a1,a1,1023
    802001b6:	95be                	add	a1,a1,a5
    802001b8:	85a9                	srai	a1,a1,0xa
    802001ba:	00001517          	auipc	a0,0x1
    802001be:	cde50513          	addi	a0,a0,-802 # 80200e98 <etext+0xe8>
}
    802001c2:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    802001c4:	bdc1                	j	80200094 <cprintf>

00000000802001c6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
    802001c6:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
    802001c8:	00001617          	auipc	a2,0x1
    802001cc:	d0060613          	addi	a2,a2,-768 # 80200ec8 <etext+0x118>
    802001d0:	04e00593          	li	a1,78
    802001d4:	00001517          	auipc	a0,0x1
    802001d8:	d0c50513          	addi	a0,a0,-756 # 80200ee0 <etext+0x130>
void print_stackframe(void) {
    802001dc:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
    802001de:	effff0ef          	jal	ra,802000dc <__panic>

00000000802001e2 <mon_help>:
        }
    }
}

/* mon_help - print the information about mon_* functions */
int mon_help(int argc, char **argv, struct trapframe *tf) {
    802001e2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    802001e4:	00001617          	auipc	a2,0x1
    802001e8:	d1460613          	addi	a2,a2,-748 # 80200ef8 <etext+0x148>
    802001ec:	00001597          	auipc	a1,0x1
    802001f0:	d2c58593          	addi	a1,a1,-724 # 80200f18 <etext+0x168>
    802001f4:	00001517          	auipc	a0,0x1
    802001f8:	d2c50513          	addi	a0,a0,-724 # 80200f20 <etext+0x170>
int mon_help(int argc, char **argv, struct trapframe *tf) {
    802001fc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    802001fe:	e97ff0ef          	jal	ra,80200094 <cprintf>
    80200202:	00001617          	auipc	a2,0x1
    80200206:	d2e60613          	addi	a2,a2,-722 # 80200f30 <etext+0x180>
    8020020a:	00001597          	auipc	a1,0x1
    8020020e:	d4e58593          	addi	a1,a1,-690 # 80200f58 <etext+0x1a8>
    80200212:	00001517          	auipc	a0,0x1
    80200216:	d0e50513          	addi	a0,a0,-754 # 80200f20 <etext+0x170>
    8020021a:	e7bff0ef          	jal	ra,80200094 <cprintf>
    8020021e:	00001617          	auipc	a2,0x1
    80200222:	d4a60613          	addi	a2,a2,-694 # 80200f68 <etext+0x1b8>
    80200226:	00001597          	auipc	a1,0x1
    8020022a:	d6258593          	addi	a1,a1,-670 # 80200f88 <etext+0x1d8>
    8020022e:	00001517          	auipc	a0,0x1
    80200232:	cf250513          	addi	a0,a0,-782 # 80200f20 <etext+0x170>
    80200236:	e5fff0ef          	jal	ra,80200094 <cprintf>
    }
    return 0;
}
    8020023a:	60a2                	ld	ra,8(sp)
    8020023c:	4501                	li	a0,0
    8020023e:	0141                	addi	sp,sp,16
    80200240:	8082                	ret

0000000080200242 <mon_kerninfo>:

/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
    80200242:	1141                	addi	sp,sp,-16
    80200244:	e406                	sd	ra,8(sp)
    print_kerninfo();
    80200246:	ef3ff0ef          	jal	ra,80200138 <print_kerninfo>
    return 0;
}
    8020024a:	60a2                	ld	ra,8(sp)
    8020024c:	4501                	li	a0,0
    8020024e:	0141                	addi	sp,sp,16
    80200250:	8082                	ret

0000000080200252 <mon_backtrace>:

/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int mon_backtrace(int argc, char **argv, struct trapframe *tf) {
    80200252:	1141                	addi	sp,sp,-16
    80200254:	e406                	sd	ra,8(sp)
    print_stackframe();
    80200256:	f71ff0ef          	jal	ra,802001c6 <print_stackframe>
    return 0;
}
    8020025a:	60a2                	ld	ra,8(sp)
    8020025c:	4501                	li	a0,0
    8020025e:	0141                	addi	sp,sp,16
    80200260:	8082                	ret

0000000080200262 <kmonitor>:
void kmonitor(struct trapframe *tf) {
    80200262:	7115                	addi	sp,sp,-224
    80200264:	ed5e                	sd	s7,152(sp)
    80200266:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
    80200268:	00001517          	auipc	a0,0x1
    8020026c:	d3050513          	addi	a0,a0,-720 # 80200f98 <etext+0x1e8>
void kmonitor(struct trapframe *tf) {
    80200270:	ed86                	sd	ra,216(sp)
    80200272:	e9a2                	sd	s0,208(sp)
    80200274:	e5a6                	sd	s1,200(sp)
    80200276:	e1ca                	sd	s2,192(sp)
    80200278:	fd4e                	sd	s3,184(sp)
    8020027a:	f952                	sd	s4,176(sp)
    8020027c:	f556                	sd	s5,168(sp)
    8020027e:	f15a                	sd	s6,160(sp)
    80200280:	e962                	sd	s8,144(sp)
    80200282:	e566                	sd	s9,136(sp)
    80200284:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
    80200286:	e0fff0ef          	jal	ra,80200094 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
    8020028a:	00001517          	auipc	a0,0x1
    8020028e:	d3650513          	addi	a0,a0,-714 # 80200fc0 <etext+0x210>
    80200292:	e03ff0ef          	jal	ra,80200094 <cprintf>
    if (tf != NULL) {
    80200296:	000b8563          	beqz	s7,802002a0 <kmonitor+0x3e>
        print_trapframe(tf);
    8020029a:	855e                	mv	a0,s7
    8020029c:	348000ef          	jal	ra,802005e4 <print_trapframe>
    802002a0:	00001c17          	auipc	s8,0x1
    802002a4:	d90c0c13          	addi	s8,s8,-624 # 80201030 <commands>
        if ((buf = readline("K> ")) != NULL) {
    802002a8:	00001917          	auipc	s2,0x1
    802002ac:	d4090913          	addi	s2,s2,-704 # 80200fe8 <etext+0x238>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
    802002b0:	00001497          	auipc	s1,0x1
    802002b4:	d4048493          	addi	s1,s1,-704 # 80200ff0 <etext+0x240>
        if (argc == MAXARGS - 1) {
    802002b8:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
    802002ba:	00001b17          	auipc	s6,0x1
    802002be:	d3eb0b13          	addi	s6,s6,-706 # 80200ff8 <etext+0x248>
        argv[argc++] = buf;
    802002c2:	00001a17          	auipc	s4,0x1
    802002c6:	c56a0a13          	addi	s4,s4,-938 # 80200f18 <etext+0x168>
    for (i = 0; i < NCOMMANDS; i++) {
    802002ca:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
    802002cc:	854a                	mv	a0,s2
    802002ce:	1c5000ef          	jal	ra,80200c92 <readline>
    802002d2:	842a                	mv	s0,a0
    802002d4:	dd65                	beqz	a0,802002cc <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
    802002d6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
    802002da:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
    802002dc:	e1bd                	bnez	a1,80200342 <kmonitor+0xe0>
    if (argc == 0) {
    802002de:	fe0c87e3          	beqz	s9,802002cc <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
    802002e2:	6582                	ld	a1,0(sp)
    802002e4:	00001d17          	auipc	s10,0x1
    802002e8:	d4cd0d13          	addi	s10,s10,-692 # 80201030 <commands>
        argv[argc++] = buf;
    802002ec:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++) {
    802002ee:	4401                	li	s0,0
    802002f0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
    802002f2:	56c000ef          	jal	ra,8020085e <strcmp>
    802002f6:	c919                	beqz	a0,8020030c <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i++) {
    802002f8:	2405                	addiw	s0,s0,1
    802002fa:	0b540063          	beq	s0,s5,8020039a <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
    802002fe:	000d3503          	ld	a0,0(s10)
    80200302:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i++) {
    80200304:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
    80200306:	558000ef          	jal	ra,8020085e <strcmp>
    8020030a:	f57d                	bnez	a0,802002f8 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
    8020030c:	00141793          	slli	a5,s0,0x1
    80200310:	97a2                	add	a5,a5,s0
    80200312:	078e                	slli	a5,a5,0x3
    80200314:	97e2                	add	a5,a5,s8
    80200316:	6b9c                	ld	a5,16(a5)
    80200318:	865e                	mv	a2,s7
    8020031a:	002c                	addi	a1,sp,8
    8020031c:	fffc851b          	addiw	a0,s9,-1
    80200320:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
    80200322:	fa0555e3          	bgez	a0,802002cc <kmonitor+0x6a>
}
    80200326:	60ee                	ld	ra,216(sp)
    80200328:	644e                	ld	s0,208(sp)
    8020032a:	64ae                	ld	s1,200(sp)
    8020032c:	690e                	ld	s2,192(sp)
    8020032e:	79ea                	ld	s3,184(sp)
    80200330:	7a4a                	ld	s4,176(sp)
    80200332:	7aaa                	ld	s5,168(sp)
    80200334:	7b0a                	ld	s6,160(sp)
    80200336:	6bea                	ld	s7,152(sp)
    80200338:	6c4a                	ld	s8,144(sp)
    8020033a:	6caa                	ld	s9,136(sp)
    8020033c:	6d0a                	ld	s10,128(sp)
    8020033e:	612d                	addi	sp,sp,224
    80200340:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
    80200342:	8526                	mv	a0,s1
    80200344:	538000ef          	jal	ra,8020087c <strchr>
    80200348:	c901                	beqz	a0,80200358 <kmonitor+0xf6>
    8020034a:	00144583          	lbu	a1,1(s0)
            *buf++ = '\0';
    8020034e:	00040023          	sb	zero,0(s0)
    80200352:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
    80200354:	d5c9                	beqz	a1,802002de <kmonitor+0x7c>
    80200356:	b7f5                	j	80200342 <kmonitor+0xe0>
        if (*buf == '\0') {
    80200358:	00044783          	lbu	a5,0(s0)
    8020035c:	d3c9                	beqz	a5,802002de <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
    8020035e:	033c8963          	beq	s9,s3,80200390 <kmonitor+0x12e>
        argv[argc++] = buf;
    80200362:	003c9793          	slli	a5,s9,0x3
    80200366:	0118                	addi	a4,sp,128
    80200368:	97ba                	add	a5,a5,a4
    8020036a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
    8020036e:	00044583          	lbu	a1,0(s0)
        argv[argc++] = buf;
    80200372:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
    80200374:	e591                	bnez	a1,80200380 <kmonitor+0x11e>
    80200376:	b7b5                	j	802002e2 <kmonitor+0x80>
    80200378:	00144583          	lbu	a1,1(s0)
            buf++;
    8020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
    8020037e:	d1a5                	beqz	a1,802002de <kmonitor+0x7c>
    80200380:	8526                	mv	a0,s1
    80200382:	4fa000ef          	jal	ra,8020087c <strchr>
    80200386:	d96d                	beqz	a0,80200378 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
    80200388:	00044583          	lbu	a1,0(s0)
    8020038c:	d9a9                	beqz	a1,802002de <kmonitor+0x7c>
    8020038e:	bf55                	j	80200342 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
    80200390:	45c1                	li	a1,16
    80200392:	855a                	mv	a0,s6
    80200394:	d01ff0ef          	jal	ra,80200094 <cprintf>
    80200398:	b7e9                	j	80200362 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
    8020039a:	6582                	ld	a1,0(sp)
    8020039c:	00001517          	auipc	a0,0x1
    802003a0:	c7c50513          	addi	a0,a0,-900 # 80201018 <etext+0x268>
    802003a4:	cf1ff0ef          	jal	ra,80200094 <cprintf>
    return 0;
    802003a8:	b715                	j	802002cc <kmonitor+0x6a>

00000000802003aa <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    802003aa:	1141                	addi	sp,sp,-16
    802003ac:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    802003ae:	02000793          	li	a5,32
    802003b2:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    802003b6:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    802003ba:	67e1                	lui	a5,0x18
    802003bc:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    802003c0:	953e                	add	a0,a0,a5
    802003c2:	1bb000ef          	jal	ra,80200d7c <sbi_set_timer>
}
    802003c6:	60a2                	ld	ra,8(sp)
    ticks = 0;
    802003c8:	00004797          	auipc	a5,0x4
    802003cc:	0407bc23          	sd	zero,88(a5) # 80204420 <ticks>
    cprintf("++ setup timer interrupts\n");
    802003d0:	00001517          	auipc	a0,0x1
    802003d4:	ca850513          	addi	a0,a0,-856 # 80201078 <commands+0x48>
}
    802003d8:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    802003da:	b96d                	j	80200094 <cprintf>

00000000802003dc <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    802003dc:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    802003e0:	67e1                	lui	a5,0x18
    802003e2:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    802003e6:	953e                	add	a0,a0,a5
    802003e8:	1950006f          	j	80200d7c <sbi_set_timer>

00000000802003ec <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    802003ec:	8082                	ret

00000000802003ee <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    802003ee:	0ff57513          	andi	a0,a0,255
    802003f2:	1710006f          	j	80200d62 <sbi_console_putchar>

00000000802003f6 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
    802003f6:	1510006f          	j	80200d46 <sbi_console_getchar>

00000000802003fa <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    802003fa:	100167f3          	csrrsi	a5,sstatus,2
    802003fe:	8082                	ret

0000000080200400 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
    80200400:	100177f3          	csrrci	a5,sstatus,2
    80200404:	8082                	ret

0000000080200406 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200406:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020040a:	00000797          	auipc	a5,0x0
    8020040e:	38278793          	addi	a5,a5,898 # 8020078c <__alltraps>
    80200412:	10579073          	csrw	stvec,a5
}
    80200416:	8082                	ret

0000000080200418 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200418:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020041a:	1141                	addi	sp,sp,-16
    8020041c:	e022                	sd	s0,0(sp)
    8020041e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200420:	00001517          	auipc	a0,0x1
    80200424:	c7850513          	addi	a0,a0,-904 # 80201098 <commands+0x68>
void print_regs(struct pushregs *gpr) {
    80200428:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020042a:	c6bff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    8020042e:	640c                	ld	a1,8(s0)
    80200430:	00001517          	auipc	a0,0x1
    80200434:	c8050513          	addi	a0,a0,-896 # 802010b0 <commands+0x80>
    80200438:	c5dff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    8020043c:	680c                	ld	a1,16(s0)
    8020043e:	00001517          	auipc	a0,0x1
    80200442:	c8a50513          	addi	a0,a0,-886 # 802010c8 <commands+0x98>
    80200446:	c4fff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    8020044a:	6c0c                	ld	a1,24(s0)
    8020044c:	00001517          	auipc	a0,0x1
    80200450:	c9450513          	addi	a0,a0,-876 # 802010e0 <commands+0xb0>
    80200454:	c41ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    80200458:	700c                	ld	a1,32(s0)
    8020045a:	00001517          	auipc	a0,0x1
    8020045e:	c9e50513          	addi	a0,a0,-866 # 802010f8 <commands+0xc8>
    80200462:	c33ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    80200466:	740c                	ld	a1,40(s0)
    80200468:	00001517          	auipc	a0,0x1
    8020046c:	ca850513          	addi	a0,a0,-856 # 80201110 <commands+0xe0>
    80200470:	c25ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    80200474:	780c                	ld	a1,48(s0)
    80200476:	00001517          	auipc	a0,0x1
    8020047a:	cb250513          	addi	a0,a0,-846 # 80201128 <commands+0xf8>
    8020047e:	c17ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200482:	7c0c                	ld	a1,56(s0)
    80200484:	00001517          	auipc	a0,0x1
    80200488:	cbc50513          	addi	a0,a0,-836 # 80201140 <commands+0x110>
    8020048c:	c09ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200490:	602c                	ld	a1,64(s0)
    80200492:	00001517          	auipc	a0,0x1
    80200496:	cc650513          	addi	a0,a0,-826 # 80201158 <commands+0x128>
    8020049a:	bfbff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020049e:	642c                	ld	a1,72(s0)
    802004a0:	00001517          	auipc	a0,0x1
    802004a4:	cd050513          	addi	a0,a0,-816 # 80201170 <commands+0x140>
    802004a8:	bedff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    802004ac:	682c                	ld	a1,80(s0)
    802004ae:	00001517          	auipc	a0,0x1
    802004b2:	cda50513          	addi	a0,a0,-806 # 80201188 <commands+0x158>
    802004b6:	bdfff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    802004ba:	6c2c                	ld	a1,88(s0)
    802004bc:	00001517          	auipc	a0,0x1
    802004c0:	ce450513          	addi	a0,a0,-796 # 802011a0 <commands+0x170>
    802004c4:	bd1ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    802004c8:	702c                	ld	a1,96(s0)
    802004ca:	00001517          	auipc	a0,0x1
    802004ce:	cee50513          	addi	a0,a0,-786 # 802011b8 <commands+0x188>
    802004d2:	bc3ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    802004d6:	742c                	ld	a1,104(s0)
    802004d8:	00001517          	auipc	a0,0x1
    802004dc:	cf850513          	addi	a0,a0,-776 # 802011d0 <commands+0x1a0>
    802004e0:	bb5ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    802004e4:	782c                	ld	a1,112(s0)
    802004e6:	00001517          	auipc	a0,0x1
    802004ea:	d0250513          	addi	a0,a0,-766 # 802011e8 <commands+0x1b8>
    802004ee:	ba7ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    802004f2:	7c2c                	ld	a1,120(s0)
    802004f4:	00001517          	auipc	a0,0x1
    802004f8:	d0c50513          	addi	a0,a0,-756 # 80201200 <commands+0x1d0>
    802004fc:	b99ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200500:	604c                	ld	a1,128(s0)
    80200502:	00001517          	auipc	a0,0x1
    80200506:	d1650513          	addi	a0,a0,-746 # 80201218 <commands+0x1e8>
    8020050a:	b8bff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020050e:	644c                	ld	a1,136(s0)
    80200510:	00001517          	auipc	a0,0x1
    80200514:	d2050513          	addi	a0,a0,-736 # 80201230 <commands+0x200>
    80200518:	b7dff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020051c:	684c                	ld	a1,144(s0)
    8020051e:	00001517          	auipc	a0,0x1
    80200522:	d2a50513          	addi	a0,a0,-726 # 80201248 <commands+0x218>
    80200526:	b6fff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    8020052a:	6c4c                	ld	a1,152(s0)
    8020052c:	00001517          	auipc	a0,0x1
    80200530:	d3450513          	addi	a0,a0,-716 # 80201260 <commands+0x230>
    80200534:	b61ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    80200538:	704c                	ld	a1,160(s0)
    8020053a:	00001517          	auipc	a0,0x1
    8020053e:	d3e50513          	addi	a0,a0,-706 # 80201278 <commands+0x248>
    80200542:	b53ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    80200546:	744c                	ld	a1,168(s0)
    80200548:	00001517          	auipc	a0,0x1
    8020054c:	d4850513          	addi	a0,a0,-696 # 80201290 <commands+0x260>
    80200550:	b45ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    80200554:	784c                	ld	a1,176(s0)
    80200556:	00001517          	auipc	a0,0x1
    8020055a:	d5250513          	addi	a0,a0,-686 # 802012a8 <commands+0x278>
    8020055e:	b37ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    80200562:	7c4c                	ld	a1,184(s0)
    80200564:	00001517          	auipc	a0,0x1
    80200568:	d5c50513          	addi	a0,a0,-676 # 802012c0 <commands+0x290>
    8020056c:	b29ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    80200570:	606c                	ld	a1,192(s0)
    80200572:	00001517          	auipc	a0,0x1
    80200576:	d6650513          	addi	a0,a0,-666 # 802012d8 <commands+0x2a8>
    8020057a:	b1bff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    8020057e:	646c                	ld	a1,200(s0)
    80200580:	00001517          	auipc	a0,0x1
    80200584:	d7050513          	addi	a0,a0,-656 # 802012f0 <commands+0x2c0>
    80200588:	b0dff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020058c:	686c                	ld	a1,208(s0)
    8020058e:	00001517          	auipc	a0,0x1
    80200592:	d7a50513          	addi	a0,a0,-646 # 80201308 <commands+0x2d8>
    80200596:	affff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020059a:	6c6c                	ld	a1,216(s0)
    8020059c:	00001517          	auipc	a0,0x1
    802005a0:	d8450513          	addi	a0,a0,-636 # 80201320 <commands+0x2f0>
    802005a4:	af1ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    802005a8:	706c                	ld	a1,224(s0)
    802005aa:	00001517          	auipc	a0,0x1
    802005ae:	d8e50513          	addi	a0,a0,-626 # 80201338 <commands+0x308>
    802005b2:	ae3ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    802005b6:	746c                	ld	a1,232(s0)
    802005b8:	00001517          	auipc	a0,0x1
    802005bc:	d9850513          	addi	a0,a0,-616 # 80201350 <commands+0x320>
    802005c0:	ad5ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    802005c4:	786c                	ld	a1,240(s0)
    802005c6:	00001517          	auipc	a0,0x1
    802005ca:	da250513          	addi	a0,a0,-606 # 80201368 <commands+0x338>
    802005ce:	ac7ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    802005d2:	7c6c                	ld	a1,248(s0)
}
    802005d4:	6402                	ld	s0,0(sp)
    802005d6:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    802005d8:	00001517          	auipc	a0,0x1
    802005dc:	da850513          	addi	a0,a0,-600 # 80201380 <commands+0x350>
}
    802005e0:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    802005e2:	bc4d                	j	80200094 <cprintf>

00000000802005e4 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    802005e4:	1141                	addi	sp,sp,-16
    802005e6:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    802005e8:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    802005ea:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    802005ec:	00001517          	auipc	a0,0x1
    802005f0:	dac50513          	addi	a0,a0,-596 # 80201398 <commands+0x368>
void print_trapframe(struct trapframe *tf) {
    802005f4:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    802005f6:	a9fff0ef          	jal	ra,80200094 <cprintf>
    print_regs(&tf->gpr);
    802005fa:	8522                	mv	a0,s0
    802005fc:	e1dff0ef          	jal	ra,80200418 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200600:	10043583          	ld	a1,256(s0)
    80200604:	00001517          	auipc	a0,0x1
    80200608:	dac50513          	addi	a0,a0,-596 # 802013b0 <commands+0x380>
    8020060c:	a89ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200610:	10843583          	ld	a1,264(s0)
    80200614:	00001517          	auipc	a0,0x1
    80200618:	db450513          	addi	a0,a0,-588 # 802013c8 <commands+0x398>
    8020061c:	a79ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200620:	11043583          	ld	a1,272(s0)
    80200624:	00001517          	auipc	a0,0x1
    80200628:	dbc50513          	addi	a0,a0,-580 # 802013e0 <commands+0x3b0>
    8020062c:	a69ff0ef          	jal	ra,80200094 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    80200630:	11843583          	ld	a1,280(s0)
}
    80200634:	6402                	ld	s0,0(sp)
    80200636:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    80200638:	00001517          	auipc	a0,0x1
    8020063c:	dc050513          	addi	a0,a0,-576 # 802013f8 <commands+0x3c8>
}
    80200640:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    80200642:	bc89                	j	80200094 <cprintf>

0000000080200644 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    80200644:	11853783          	ld	a5,280(a0)
    80200648:	472d                	li	a4,11
    8020064a:	0786                	slli	a5,a5,0x1
    8020064c:	8385                	srli	a5,a5,0x1
    8020064e:	08f76463          	bltu	a4,a5,802006d6 <interrupt_handler+0x92>
    80200652:	00001717          	auipc	a4,0x1
    80200656:	e6e70713          	addi	a4,a4,-402 # 802014c0 <commands+0x490>
    8020065a:	078a                	slli	a5,a5,0x2
    8020065c:	97ba                	add	a5,a5,a4
    8020065e:	439c                	lw	a5,0(a5)
    80200660:	97ba                	add	a5,a5,a4
    80200662:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    80200664:	00001517          	auipc	a0,0x1
    80200668:	e0c50513          	addi	a0,a0,-500 # 80201470 <commands+0x440>
    8020066c:	b425                	j	80200094 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    8020066e:	00001517          	auipc	a0,0x1
    80200672:	de250513          	addi	a0,a0,-542 # 80201450 <commands+0x420>
    80200676:	bc39                	j	80200094 <cprintf>
            cprintf("User software interrupt\n");
    80200678:	00001517          	auipc	a0,0x1
    8020067c:	d9850513          	addi	a0,a0,-616 # 80201410 <commands+0x3e0>
    80200680:	bc11                	j	80200094 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200682:	00001517          	auipc	a0,0x1
    80200686:	dae50513          	addi	a0,a0,-594 # 80201430 <commands+0x400>
    8020068a:	b429                	j	80200094 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020068c:	1101                	addi	sp,sp,-32
    8020068e:	e822                	sd	s0,16(sp)
    80200690:	e426                	sd	s1,8(sp)
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
			clock_set_next_event();
			ticks++;
    80200692:	00004417          	auipc	s0,0x4
    80200696:	d8e40413          	addi	s0,s0,-626 # 80204420 <ticks>
void interrupt_handler(struct trapframe *tf) {
    8020069a:	ec06                	sd	ra,24(sp)
			clock_set_next_event();
    8020069c:	d41ff0ef          	jal	ra,802003dc <clock_set_next_event>
			ticks++;
    802006a0:	601c                	ld	a5,0(s0)
			if(num == 10) sbi_shutdown();
    802006a2:	00004497          	auipc	s1,0x4
    802006a6:	d8648493          	addi	s1,s1,-634 # 80204428 <num>
    802006aa:	4729                	li	a4,10
			ticks++;
    802006ac:	0785                	addi	a5,a5,1
    802006ae:	e01c                	sd	a5,0(s0)
			if(num == 10) sbi_shutdown();
    802006b0:	609c                	ld	a5,0(s1)
    802006b2:	02e78f63          	beq	a5,a4,802006f0 <interrupt_handler+0xac>
			if (ticks % TICK_NUM == 0) {
    802006b6:	601c                	ld	a5,0(s0)
    802006b8:	06400713          	li	a4,100
    802006bc:	02e7f7b3          	remu	a5,a5,a4
    802006c0:	cf81                	beqz	a5,802006d8 <interrupt_handler+0x94>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802006c2:	60e2                	ld	ra,24(sp)
    802006c4:	6442                	ld	s0,16(sp)
    802006c6:	64a2                	ld	s1,8(sp)
    802006c8:	6105                	addi	sp,sp,32
    802006ca:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    802006cc:	00001517          	auipc	a0,0x1
    802006d0:	dd450513          	addi	a0,a0,-556 # 802014a0 <commands+0x470>
    802006d4:	b2c1                	j	80200094 <cprintf>
            print_trapframe(tf);
    802006d6:	b739                	j	802005e4 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    802006d8:	06400593          	li	a1,100
    802006dc:	00001517          	auipc	a0,0x1
    802006e0:	db450513          	addi	a0,a0,-588 # 80201490 <commands+0x460>
    802006e4:	9b1ff0ef          	jal	ra,80200094 <cprintf>
				num++;
    802006e8:	609c                	ld	a5,0(s1)
    802006ea:	0785                	addi	a5,a5,1
    802006ec:	e09c                	sd	a5,0(s1)
    802006ee:	bfd1                	j	802006c2 <interrupt_handler+0x7e>
			if(num == 10) sbi_shutdown();
    802006f0:	6a6000ef          	jal	ra,80200d96 <sbi_shutdown>
    802006f4:	b7c9                	j	802006b6 <interrupt_handler+0x72>

00000000802006f6 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    802006f6:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    802006fa:	1141                	addi	sp,sp,-16
    802006fc:	e022                	sd	s0,0(sp)
    802006fe:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    80200700:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    80200702:	842a                	mv	s0,a0
    switch (tf->cause) {
    80200704:	04e78663          	beq	a5,a4,80200750 <exception_handler+0x5a>
    80200708:	02f76c63          	bltu	a4,a5,80200740 <exception_handler+0x4a>
    8020070c:	4709                	li	a4,2
    8020070e:	02e79563          	bne	a5,a4,80200738 <exception_handler+0x42>
             /* LAB1 CHALLENGE3   YOUR CODE :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
			cprintf("Exception type:Illegal instruction \n");
    80200712:	00001517          	auipc	a0,0x1
    80200716:	dde50513          	addi	a0,a0,-546 # 802014f0 <commands+0x4c0>
    8020071a:	97bff0ef          	jal	ra,80200094 <cprintf>
			cprintf("Illegal instruction exception at 0x%016llx\n\n", tf->epc);
    8020071e:	10843583          	ld	a1,264(s0)
    80200722:	00001517          	auipc	a0,0x1
    80200726:	df650513          	addi	a0,a0,-522 # 80201518 <commands+0x4e8>
    8020072a:	96bff0ef          	jal	ra,80200094 <cprintf>
			tf->epc += 4;
    8020072e:	10843783          	ld	a5,264(s0)
    80200732:	0791                	addi	a5,a5,4
    80200734:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200738:	60a2                	ld	ra,8(sp)
    8020073a:	6402                	ld	s0,0(sp)
    8020073c:	0141                	addi	sp,sp,16
    8020073e:	8082                	ret
    switch (tf->cause) {
    80200740:	17f1                	addi	a5,a5,-4
    80200742:	471d                	li	a4,7
    80200744:	fef77ae3          	bgeu	a4,a5,80200738 <exception_handler+0x42>
}
    80200748:	6402                	ld	s0,0(sp)
    8020074a:	60a2                	ld	ra,8(sp)
    8020074c:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    8020074e:	bd59                	j	802005e4 <print_trapframe>
			cprintf("Exception type: breakpoint \n");
    80200750:	00001517          	auipc	a0,0x1
    80200754:	df850513          	addi	a0,a0,-520 # 80201548 <commands+0x518>
    80200758:	93dff0ef          	jal	ra,80200094 <cprintf>
			cprintf("ebreak caught at 0x%016llx\n\n", tf->epc);
    8020075c:	10843583          	ld	a1,264(s0)
    80200760:	00001517          	auipc	a0,0x1
    80200764:	e0850513          	addi	a0,a0,-504 # 80201568 <commands+0x538>
    80200768:	92dff0ef          	jal	ra,80200094 <cprintf>
			tf->epc += 2;
    8020076c:	10843783          	ld	a5,264(s0)
}
    80200770:	60a2                	ld	ra,8(sp)
			tf->epc += 2;
    80200772:	0789                	addi	a5,a5,2
    80200774:	10f43423          	sd	a5,264(s0)
}
    80200778:	6402                	ld	s0,0(sp)
    8020077a:	0141                	addi	sp,sp,16
    8020077c:	8082                	ret

000000008020077e <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    8020077e:	11853783          	ld	a5,280(a0)
    80200782:	0007c363          	bltz	a5,80200788 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200786:	bf85                	j	802006f6 <exception_handler>
        interrupt_handler(tf);
    80200788:	bd75                	j	80200644 <interrupt_handler>
	...

000000008020078c <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    8020078c:	14011073          	csrw	sscratch,sp
    80200790:	712d                	addi	sp,sp,-288
    80200792:	e002                	sd	zero,0(sp)
    80200794:	e406                	sd	ra,8(sp)
    80200796:	ec0e                	sd	gp,24(sp)
    80200798:	f012                	sd	tp,32(sp)
    8020079a:	f416                	sd	t0,40(sp)
    8020079c:	f81a                	sd	t1,48(sp)
    8020079e:	fc1e                	sd	t2,56(sp)
    802007a0:	e0a2                	sd	s0,64(sp)
    802007a2:	e4a6                	sd	s1,72(sp)
    802007a4:	e8aa                	sd	a0,80(sp)
    802007a6:	ecae                	sd	a1,88(sp)
    802007a8:	f0b2                	sd	a2,96(sp)
    802007aa:	f4b6                	sd	a3,104(sp)
    802007ac:	f8ba                	sd	a4,112(sp)
    802007ae:	fcbe                	sd	a5,120(sp)
    802007b0:	e142                	sd	a6,128(sp)
    802007b2:	e546                	sd	a7,136(sp)
    802007b4:	e94a                	sd	s2,144(sp)
    802007b6:	ed4e                	sd	s3,152(sp)
    802007b8:	f152                	sd	s4,160(sp)
    802007ba:	f556                	sd	s5,168(sp)
    802007bc:	f95a                	sd	s6,176(sp)
    802007be:	fd5e                	sd	s7,184(sp)
    802007c0:	e1e2                	sd	s8,192(sp)
    802007c2:	e5e6                	sd	s9,200(sp)
    802007c4:	e9ea                	sd	s10,208(sp)
    802007c6:	edee                	sd	s11,216(sp)
    802007c8:	f1f2                	sd	t3,224(sp)
    802007ca:	f5f6                	sd	t4,232(sp)
    802007cc:	f9fa                	sd	t5,240(sp)
    802007ce:	fdfe                	sd	t6,248(sp)
    802007d0:	14001473          	csrrw	s0,sscratch,zero
    802007d4:	100024f3          	csrr	s1,sstatus
    802007d8:	14102973          	csrr	s2,sepc
    802007dc:	143029f3          	csrr	s3,stval
    802007e0:	14202a73          	csrr	s4,scause
    802007e4:	e822                	sd	s0,16(sp)
    802007e6:	e226                	sd	s1,256(sp)
    802007e8:	e64a                	sd	s2,264(sp)
    802007ea:	ea4e                	sd	s3,272(sp)
    802007ec:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802007ee:	850a                	mv	a0,sp
    jal trap
    802007f0:	f8fff0ef          	jal	ra,8020077e <trap>

00000000802007f4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802007f4:	6492                	ld	s1,256(sp)
    802007f6:	6932                	ld	s2,264(sp)
    802007f8:	10049073          	csrw	sstatus,s1
    802007fc:	14191073          	csrw	sepc,s2
    80200800:	60a2                	ld	ra,8(sp)
    80200802:	61e2                	ld	gp,24(sp)
    80200804:	7202                	ld	tp,32(sp)
    80200806:	72a2                	ld	t0,40(sp)
    80200808:	7342                	ld	t1,48(sp)
    8020080a:	73e2                	ld	t2,56(sp)
    8020080c:	6406                	ld	s0,64(sp)
    8020080e:	64a6                	ld	s1,72(sp)
    80200810:	6546                	ld	a0,80(sp)
    80200812:	65e6                	ld	a1,88(sp)
    80200814:	7606                	ld	a2,96(sp)
    80200816:	76a6                	ld	a3,104(sp)
    80200818:	7746                	ld	a4,112(sp)
    8020081a:	77e6                	ld	a5,120(sp)
    8020081c:	680a                	ld	a6,128(sp)
    8020081e:	68aa                	ld	a7,136(sp)
    80200820:	694a                	ld	s2,144(sp)
    80200822:	69ea                	ld	s3,152(sp)
    80200824:	7a0a                	ld	s4,160(sp)
    80200826:	7aaa                	ld	s5,168(sp)
    80200828:	7b4a                	ld	s6,176(sp)
    8020082a:	7bea                	ld	s7,184(sp)
    8020082c:	6c0e                	ld	s8,192(sp)
    8020082e:	6cae                	ld	s9,200(sp)
    80200830:	6d4e                	ld	s10,208(sp)
    80200832:	6dee                	ld	s11,216(sp)
    80200834:	7e0e                	ld	t3,224(sp)
    80200836:	7eae                	ld	t4,232(sp)
    80200838:	7f4e                	ld	t5,240(sp)
    8020083a:	7fee                	ld	t6,248(sp)
    8020083c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    8020083e:	10200073          	sret

0000000080200842 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    80200842:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    80200844:	e589                	bnez	a1,8020084e <strnlen+0xc>
    80200846:	a811                	j	8020085a <strnlen+0x18>
        cnt ++;
    80200848:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    8020084a:	00f58863          	beq	a1,a5,8020085a <strnlen+0x18>
    8020084e:	00f50733          	add	a4,a0,a5
    80200852:	00074703          	lbu	a4,0(a4)
    80200856:	fb6d                	bnez	a4,80200848 <strnlen+0x6>
    80200858:	85be                	mv	a1,a5
    }
    return cnt;
}
    8020085a:	852e                	mv	a0,a1
    8020085c:	8082                	ret

000000008020085e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
    8020085e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
    80200862:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
    80200866:	cb89                	beqz	a5,80200878 <strcmp+0x1a>
        s1 ++, s2 ++;
    80200868:	0505                	addi	a0,a0,1
    8020086a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
    8020086c:	fee789e3          	beq	a5,a4,8020085e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
    80200870:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
    80200874:	9d19                	subw	a0,a0,a4
    80200876:	8082                	ret
    80200878:	4501                	li	a0,0
    8020087a:	bfed                	j	80200874 <strcmp+0x16>

000000008020087c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
    8020087c:	00054783          	lbu	a5,0(a0)
    80200880:	c799                	beqz	a5,8020088e <strchr+0x12>
        if (*s == c) {
    80200882:	00f58763          	beq	a1,a5,80200890 <strchr+0x14>
    while (*s != '\0') {
    80200886:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
    8020088a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
    8020088c:	fbfd                	bnez	a5,80200882 <strchr+0x6>
    }
    return NULL;
    8020088e:	4501                	li	a0,0
}
    80200890:	8082                	ret

0000000080200892 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200892:	ca01                	beqz	a2,802008a2 <memset+0x10>
    80200894:	962a                	add	a2,a2,a0
    char *p = s;
    80200896:	87aa                	mv	a5,a0
        *p ++ = c;
    80200898:	0785                	addi	a5,a5,1
    8020089a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    8020089e:	fec79de3          	bne	a5,a2,80200898 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802008a2:	8082                	ret

00000000802008a4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802008a4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802008a8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802008aa:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802008ae:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802008b0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802008b4:	f022                	sd	s0,32(sp)
    802008b6:	ec26                	sd	s1,24(sp)
    802008b8:	e84a                	sd	s2,16(sp)
    802008ba:	f406                	sd	ra,40(sp)
    802008bc:	e44e                	sd	s3,8(sp)
    802008be:	84aa                	mv	s1,a0
    802008c0:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802008c2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802008c6:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802008c8:	03067e63          	bgeu	a2,a6,80200904 <printnum+0x60>
    802008cc:	89be                	mv	s3,a5
        while (-- width > 0)
    802008ce:	00805763          	blez	s0,802008dc <printnum+0x38>
    802008d2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802008d4:	85ca                	mv	a1,s2
    802008d6:	854e                	mv	a0,s3
    802008d8:	9482                	jalr	s1
        while (-- width > 0)
    802008da:	fc65                	bnez	s0,802008d2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802008dc:	1a02                	slli	s4,s4,0x20
    802008de:	00001797          	auipc	a5,0x1
    802008e2:	caa78793          	addi	a5,a5,-854 # 80201588 <commands+0x558>
    802008e6:	020a5a13          	srli	s4,s4,0x20
    802008ea:	9a3e                	add	s4,s4,a5
}
    802008ec:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802008ee:	000a4503          	lbu	a0,0(s4)
}
    802008f2:	70a2                	ld	ra,40(sp)
    802008f4:	69a2                	ld	s3,8(sp)
    802008f6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802008f8:	85ca                	mv	a1,s2
    802008fa:	87a6                	mv	a5,s1
}
    802008fc:	6942                	ld	s2,16(sp)
    802008fe:	64e2                	ld	s1,24(sp)
    80200900:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200902:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    80200904:	03065633          	divu	a2,a2,a6
    80200908:	8722                	mv	a4,s0
    8020090a:	f9bff0ef          	jal	ra,802008a4 <printnum>
    8020090e:	b7f9                	j	802008dc <printnum+0x38>

0000000080200910 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200910:	7119                	addi	sp,sp,-128
    80200912:	f4a6                	sd	s1,104(sp)
    80200914:	f0ca                	sd	s2,96(sp)
    80200916:	ecce                	sd	s3,88(sp)
    80200918:	e8d2                	sd	s4,80(sp)
    8020091a:	e4d6                	sd	s5,72(sp)
    8020091c:	e0da                	sd	s6,64(sp)
    8020091e:	fc5e                	sd	s7,56(sp)
    80200920:	f06a                	sd	s10,32(sp)
    80200922:	fc86                	sd	ra,120(sp)
    80200924:	f8a2                	sd	s0,112(sp)
    80200926:	f862                	sd	s8,48(sp)
    80200928:	f466                	sd	s9,40(sp)
    8020092a:	ec6e                	sd	s11,24(sp)
    8020092c:	892a                	mv	s2,a0
    8020092e:	84ae                	mv	s1,a1
    80200930:	8d32                	mv	s10,a2
    80200932:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200934:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200938:	5b7d                	li	s6,-1
    8020093a:	00001a97          	auipc	s5,0x1
    8020093e:	c82a8a93          	addi	s5,s5,-894 # 802015bc <commands+0x58c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200942:	00001b97          	auipc	s7,0x1
    80200946:	e56b8b93          	addi	s7,s7,-426 # 80201798 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020094a:	000d4503          	lbu	a0,0(s10)
    8020094e:	001d0413          	addi	s0,s10,1
    80200952:	01350a63          	beq	a0,s3,80200966 <vprintfmt+0x56>
            if (ch == '\0') {
    80200956:	c121                	beqz	a0,80200996 <vprintfmt+0x86>
            putch(ch, putdat);
    80200958:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020095a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8020095c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020095e:	fff44503          	lbu	a0,-1(s0)
    80200962:	ff351ae3          	bne	a0,s3,80200956 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    80200966:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    8020096a:	02000793          	li	a5,32
        lflag = altflag = 0;
    8020096e:	4c81                	li	s9,0
    80200970:	4881                	li	a7,0
        width = precision = -1;
    80200972:	5c7d                	li	s8,-1
    80200974:	5dfd                	li	s11,-1
    80200976:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    8020097a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020097c:	fdd6059b          	addiw	a1,a2,-35
    80200980:	0ff5f593          	andi	a1,a1,255
    80200984:	00140d13          	addi	s10,s0,1
    80200988:	04b56263          	bltu	a0,a1,802009cc <vprintfmt+0xbc>
    8020098c:	058a                	slli	a1,a1,0x2
    8020098e:	95d6                	add	a1,a1,s5
    80200990:	4194                	lw	a3,0(a1)
    80200992:	96d6                	add	a3,a3,s5
    80200994:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200996:	70e6                	ld	ra,120(sp)
    80200998:	7446                	ld	s0,112(sp)
    8020099a:	74a6                	ld	s1,104(sp)
    8020099c:	7906                	ld	s2,96(sp)
    8020099e:	69e6                	ld	s3,88(sp)
    802009a0:	6a46                	ld	s4,80(sp)
    802009a2:	6aa6                	ld	s5,72(sp)
    802009a4:	6b06                	ld	s6,64(sp)
    802009a6:	7be2                	ld	s7,56(sp)
    802009a8:	7c42                	ld	s8,48(sp)
    802009aa:	7ca2                	ld	s9,40(sp)
    802009ac:	7d02                	ld	s10,32(sp)
    802009ae:	6de2                	ld	s11,24(sp)
    802009b0:	6109                	addi	sp,sp,128
    802009b2:	8082                	ret
            padc = '0';
    802009b4:	87b2                	mv	a5,a2
            goto reswitch;
    802009b6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802009ba:	846a                	mv	s0,s10
    802009bc:	00140d13          	addi	s10,s0,1
    802009c0:	fdd6059b          	addiw	a1,a2,-35
    802009c4:	0ff5f593          	andi	a1,a1,255
    802009c8:	fcb572e3          	bgeu	a0,a1,8020098c <vprintfmt+0x7c>
            putch('%', putdat);
    802009cc:	85a6                	mv	a1,s1
    802009ce:	02500513          	li	a0,37
    802009d2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802009d4:	fff44783          	lbu	a5,-1(s0)
    802009d8:	8d22                	mv	s10,s0
    802009da:	f73788e3          	beq	a5,s3,8020094a <vprintfmt+0x3a>
    802009de:	ffed4783          	lbu	a5,-2(s10)
    802009e2:	1d7d                	addi	s10,s10,-1
    802009e4:	ff379de3          	bne	a5,s3,802009de <vprintfmt+0xce>
    802009e8:	b78d                	j	8020094a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    802009ea:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    802009ee:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802009f2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802009f4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802009f8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    802009fc:	02d86463          	bltu	a6,a3,80200a24 <vprintfmt+0x114>
                ch = *fmt;
    80200a00:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    80200a04:	002c169b          	slliw	a3,s8,0x2
    80200a08:	0186873b          	addw	a4,a3,s8
    80200a0c:	0017171b          	slliw	a4,a4,0x1
    80200a10:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80200a12:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    80200a16:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200a18:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    80200a1c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200a20:	fed870e3          	bgeu	a6,a3,80200a00 <vprintfmt+0xf0>
            if (width < 0)
    80200a24:	f40ddce3          	bgez	s11,8020097c <vprintfmt+0x6c>
                width = precision, precision = -1;
    80200a28:	8de2                	mv	s11,s8
    80200a2a:	5c7d                	li	s8,-1
    80200a2c:	bf81                	j	8020097c <vprintfmt+0x6c>
            if (width < 0)
    80200a2e:	fffdc693          	not	a3,s11
    80200a32:	96fd                	srai	a3,a3,0x3f
    80200a34:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    80200a38:	00144603          	lbu	a2,1(s0)
    80200a3c:	2d81                	sext.w	s11,s11
    80200a3e:	846a                	mv	s0,s10
            goto reswitch;
    80200a40:	bf35                	j	8020097c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80200a42:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    80200a46:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200a4a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200a4c:	846a                	mv	s0,s10
            goto process_precision;
    80200a4e:	bfd9                	j	80200a24 <vprintfmt+0x114>
    if (lflag >= 2) {
    80200a50:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200a52:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200a56:	01174463          	blt	a4,a7,80200a5e <vprintfmt+0x14e>
    else if (lflag) {
    80200a5a:	1a088e63          	beqz	a7,80200c16 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    80200a5e:	000a3603          	ld	a2,0(s4)
    80200a62:	46c1                	li	a3,16
    80200a64:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    80200a66:	2781                	sext.w	a5,a5
    80200a68:	876e                	mv	a4,s11
    80200a6a:	85a6                	mv	a1,s1
    80200a6c:	854a                	mv	a0,s2
    80200a6e:	e37ff0ef          	jal	ra,802008a4 <printnum>
            break;
    80200a72:	bde1                	j	8020094a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    80200a74:	000a2503          	lw	a0,0(s4)
    80200a78:	85a6                	mv	a1,s1
    80200a7a:	0a21                	addi	s4,s4,8
    80200a7c:	9902                	jalr	s2
            break;
    80200a7e:	b5f1                	j	8020094a <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200a80:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200a82:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200a86:	01174463          	blt	a4,a7,80200a8e <vprintfmt+0x17e>
    else if (lflag) {
    80200a8a:	18088163          	beqz	a7,80200c0c <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    80200a8e:	000a3603          	ld	a2,0(s4)
    80200a92:	46a9                	li	a3,10
    80200a94:	8a2e                	mv	s4,a1
    80200a96:	bfc1                	j	80200a66 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    80200a98:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200a9c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200a9e:	846a                	mv	s0,s10
            goto reswitch;
    80200aa0:	bdf1                	j	8020097c <vprintfmt+0x6c>
            putch(ch, putdat);
    80200aa2:	85a6                	mv	a1,s1
    80200aa4:	02500513          	li	a0,37
    80200aa8:	9902                	jalr	s2
            break;
    80200aaa:	b545                	j	8020094a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    80200aac:	00144603          	lbu	a2,1(s0)
            lflag ++;
    80200ab0:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200ab2:	846a                	mv	s0,s10
            goto reswitch;
    80200ab4:	b5e1                	j	8020097c <vprintfmt+0x6c>
    if (lflag >= 2) {
    80200ab6:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200ab8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200abc:	01174463          	blt	a4,a7,80200ac4 <vprintfmt+0x1b4>
    else if (lflag) {
    80200ac0:	14088163          	beqz	a7,80200c02 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    80200ac4:	000a3603          	ld	a2,0(s4)
    80200ac8:	46a1                	li	a3,8
    80200aca:	8a2e                	mv	s4,a1
    80200acc:	bf69                	j	80200a66 <vprintfmt+0x156>
            putch('0', putdat);
    80200ace:	03000513          	li	a0,48
    80200ad2:	85a6                	mv	a1,s1
    80200ad4:	e03e                	sd	a5,0(sp)
    80200ad6:	9902                	jalr	s2
            putch('x', putdat);
    80200ad8:	85a6                	mv	a1,s1
    80200ada:	07800513          	li	a0,120
    80200ade:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200ae0:	0a21                	addi	s4,s4,8
            goto number;
    80200ae2:	6782                	ld	a5,0(sp)
    80200ae4:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    80200ae6:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    80200aea:	bfb5                	j	80200a66 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200aec:	000a3403          	ld	s0,0(s4)
    80200af0:	008a0713          	addi	a4,s4,8
    80200af4:	e03a                	sd	a4,0(sp)
    80200af6:	14040263          	beqz	s0,80200c3a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    80200afa:	0fb05763          	blez	s11,80200be8 <vprintfmt+0x2d8>
    80200afe:	02d00693          	li	a3,45
    80200b02:	0cd79163          	bne	a5,a3,80200bc4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200b06:	00044783          	lbu	a5,0(s0)
    80200b0a:	0007851b          	sext.w	a0,a5
    80200b0e:	cf85                	beqz	a5,80200b46 <vprintfmt+0x236>
    80200b10:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200b14:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200b18:	000c4563          	bltz	s8,80200b22 <vprintfmt+0x212>
    80200b1c:	3c7d                	addiw	s8,s8,-1
    80200b1e:	036c0263          	beq	s8,s6,80200b42 <vprintfmt+0x232>
                    putch('?', putdat);
    80200b22:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200b24:	0e0c8e63          	beqz	s9,80200c20 <vprintfmt+0x310>
    80200b28:	3781                	addiw	a5,a5,-32
    80200b2a:	0ef47b63          	bgeu	s0,a5,80200c20 <vprintfmt+0x310>
                    putch('?', putdat);
    80200b2e:	03f00513          	li	a0,63
    80200b32:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200b34:	000a4783          	lbu	a5,0(s4)
    80200b38:	3dfd                	addiw	s11,s11,-1
    80200b3a:	0a05                	addi	s4,s4,1
    80200b3c:	0007851b          	sext.w	a0,a5
    80200b40:	ffe1                	bnez	a5,80200b18 <vprintfmt+0x208>
            for (; width > 0; width --) {
    80200b42:	01b05963          	blez	s11,80200b54 <vprintfmt+0x244>
    80200b46:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200b48:	85a6                	mv	a1,s1
    80200b4a:	02000513          	li	a0,32
    80200b4e:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200b50:	fe0d9be3          	bnez	s11,80200b46 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200b54:	6a02                	ld	s4,0(sp)
    80200b56:	bbd5                	j	8020094a <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200b58:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200b5a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    80200b5e:	01174463          	blt	a4,a7,80200b66 <vprintfmt+0x256>
    else if (lflag) {
    80200b62:	08088d63          	beqz	a7,80200bfc <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    80200b66:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80200b6a:	0a044d63          	bltz	s0,80200c24 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    80200b6e:	8622                	mv	a2,s0
    80200b70:	8a66                	mv	s4,s9
    80200b72:	46a9                	li	a3,10
    80200b74:	bdcd                	j	80200a66 <vprintfmt+0x156>
            err = va_arg(ap, int);
    80200b76:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200b7a:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200b7c:	0a21                	addi	s4,s4,8
            if (err < 0) {
    80200b7e:	41f7d69b          	sraiw	a3,a5,0x1f
    80200b82:	8fb5                	xor	a5,a5,a3
    80200b84:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200b88:	02d74163          	blt	a4,a3,80200baa <vprintfmt+0x29a>
    80200b8c:	00369793          	slli	a5,a3,0x3
    80200b90:	97de                	add	a5,a5,s7
    80200b92:	639c                	ld	a5,0(a5)
    80200b94:	cb99                	beqz	a5,80200baa <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    80200b96:	86be                	mv	a3,a5
    80200b98:	00001617          	auipc	a2,0x1
    80200b9c:	a2060613          	addi	a2,a2,-1504 # 802015b8 <commands+0x588>
    80200ba0:	85a6                	mv	a1,s1
    80200ba2:	854a                	mv	a0,s2
    80200ba4:	0ce000ef          	jal	ra,80200c72 <printfmt>
    80200ba8:	b34d                	j	8020094a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200baa:	00001617          	auipc	a2,0x1
    80200bae:	9fe60613          	addi	a2,a2,-1538 # 802015a8 <commands+0x578>
    80200bb2:	85a6                	mv	a1,s1
    80200bb4:	854a                	mv	a0,s2
    80200bb6:	0bc000ef          	jal	ra,80200c72 <printfmt>
    80200bba:	bb41                	j	8020094a <vprintfmt+0x3a>
                p = "(null)";
    80200bbc:	00001417          	auipc	s0,0x1
    80200bc0:	9e440413          	addi	s0,s0,-1564 # 802015a0 <commands+0x570>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200bc4:	85e2                	mv	a1,s8
    80200bc6:	8522                	mv	a0,s0
    80200bc8:	e43e                	sd	a5,8(sp)
    80200bca:	c79ff0ef          	jal	ra,80200842 <strnlen>
    80200bce:	40ad8dbb          	subw	s11,s11,a0
    80200bd2:	01b05b63          	blez	s11,80200be8 <vprintfmt+0x2d8>
                    putch(padc, putdat);
    80200bd6:	67a2                	ld	a5,8(sp)
    80200bd8:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200bdc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200bde:	85a6                	mv	a1,s1
    80200be0:	8552                	mv	a0,s4
    80200be2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200be4:	fe0d9ce3          	bnez	s11,80200bdc <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200be8:	00044783          	lbu	a5,0(s0)
    80200bec:	00140a13          	addi	s4,s0,1
    80200bf0:	0007851b          	sext.w	a0,a5
    80200bf4:	d3a5                	beqz	a5,80200b54 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    80200bf6:	05e00413          	li	s0,94
    80200bfa:	bf39                	j	80200b18 <vprintfmt+0x208>
        return va_arg(*ap, int);
    80200bfc:	000a2403          	lw	s0,0(s4)
    80200c00:	b7ad                	j	80200b6a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    80200c02:	000a6603          	lwu	a2,0(s4)
    80200c06:	46a1                	li	a3,8
    80200c08:	8a2e                	mv	s4,a1
    80200c0a:	bdb1                	j	80200a66 <vprintfmt+0x156>
    80200c0c:	000a6603          	lwu	a2,0(s4)
    80200c10:	46a9                	li	a3,10
    80200c12:	8a2e                	mv	s4,a1
    80200c14:	bd89                	j	80200a66 <vprintfmt+0x156>
    80200c16:	000a6603          	lwu	a2,0(s4)
    80200c1a:	46c1                	li	a3,16
    80200c1c:	8a2e                	mv	s4,a1
    80200c1e:	b5a1                	j	80200a66 <vprintfmt+0x156>
                    putch(ch, putdat);
    80200c20:	9902                	jalr	s2
    80200c22:	bf09                	j	80200b34 <vprintfmt+0x224>
                putch('-', putdat);
    80200c24:	85a6                	mv	a1,s1
    80200c26:	02d00513          	li	a0,45
    80200c2a:	e03e                	sd	a5,0(sp)
    80200c2c:	9902                	jalr	s2
                num = -(long long)num;
    80200c2e:	6782                	ld	a5,0(sp)
    80200c30:	8a66                	mv	s4,s9
    80200c32:	40800633          	neg	a2,s0
    80200c36:	46a9                	li	a3,10
    80200c38:	b53d                	j	80200a66 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80200c3a:	03b05163          	blez	s11,80200c5c <vprintfmt+0x34c>
    80200c3e:	02d00693          	li	a3,45
    80200c42:	f6d79de3          	bne	a5,a3,80200bbc <vprintfmt+0x2ac>
                p = "(null)";
    80200c46:	00001417          	auipc	s0,0x1
    80200c4a:	95a40413          	addi	s0,s0,-1702 # 802015a0 <commands+0x570>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200c4e:	02800793          	li	a5,40
    80200c52:	02800513          	li	a0,40
    80200c56:	00140a13          	addi	s4,s0,1
    80200c5a:	bd6d                	j	80200b14 <vprintfmt+0x204>
    80200c5c:	00001a17          	auipc	s4,0x1
    80200c60:	945a0a13          	addi	s4,s4,-1723 # 802015a1 <commands+0x571>
    80200c64:	02800513          	li	a0,40
    80200c68:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    80200c6c:	05e00413          	li	s0,94
    80200c70:	b565                	j	80200b18 <vprintfmt+0x208>

0000000080200c72 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200c72:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200c74:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200c78:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200c7a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200c7c:	ec06                	sd	ra,24(sp)
    80200c7e:	f83a                	sd	a4,48(sp)
    80200c80:	fc3e                	sd	a5,56(sp)
    80200c82:	e0c2                	sd	a6,64(sp)
    80200c84:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200c86:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200c88:	c89ff0ef          	jal	ra,80200910 <vprintfmt>
}
    80200c8c:	60e2                	ld	ra,24(sp)
    80200c8e:	6161                	addi	sp,sp,80
    80200c90:	8082                	ret

0000000080200c92 <readline>:
 *
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *readline(const char *prompt) {
    80200c92:	715d                	addi	sp,sp,-80
    80200c94:	e486                	sd	ra,72(sp)
    80200c96:	e0a6                	sd	s1,64(sp)
    80200c98:	fc4a                	sd	s2,56(sp)
    80200c9a:	f84e                	sd	s3,48(sp)
    80200c9c:	f452                	sd	s4,40(sp)
    80200c9e:	f056                	sd	s5,32(sp)
    80200ca0:	ec5a                	sd	s6,24(sp)
    80200ca2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
    80200ca4:	c901                	beqz	a0,80200cb4 <readline+0x22>
    80200ca6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
    80200ca8:	00001517          	auipc	a0,0x1
    80200cac:	91050513          	addi	a0,a0,-1776 # 802015b8 <commands+0x588>
    80200cb0:	be4ff0ef          	jal	ra,80200094 <cprintf>
char *readline(const char *prompt) {
    80200cb4:	4481                	li	s1,0
    int i = 0, c;
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        } else if (c >= ' ' && i < BUFSIZE - 1) {
    80200cb6:	497d                	li	s2,31
            cputchar(c);
            buf[i++] = c;
        } else if (c == '\b' && i > 0) {
    80200cb8:	49a1                	li	s3,8
            cputchar(c);
            i--;
        } else if (c == '\n' || c == '\r') {
    80200cba:	4aa9                	li	s5,10
    80200cbc:	4b35                	li	s6,13
            buf[i++] = c;
    80200cbe:	00003b97          	auipc	s7,0x3
    80200cc2:	35ab8b93          	addi	s7,s7,858 # 80204018 <buf>
        } else if (c >= ' ' && i < BUFSIZE - 1) {
    80200cc6:	3fe00a13          	li	s4,1022
        c = getchar();
    80200cca:	c02ff0ef          	jal	ra,802000cc <getchar>
        if (c < 0) {
    80200cce:	00054a63          	bltz	a0,80200ce2 <readline+0x50>
        } else if (c >= ' ' && i < BUFSIZE - 1) {
    80200cd2:	00a95a63          	bge	s2,a0,80200ce6 <readline+0x54>
    80200cd6:	029a5263          	bge	s4,s1,80200cfa <readline+0x68>
        c = getchar();
    80200cda:	bf2ff0ef          	jal	ra,802000cc <getchar>
        if (c < 0) {
    80200cde:	fe055ae3          	bgez	a0,80200cd2 <readline+0x40>
            return NULL;
    80200ce2:	4501                	li	a0,0
    80200ce4:	a091                	j	80200d28 <readline+0x96>
        } else if (c == '\b' && i > 0) {
    80200ce6:	03351463          	bne	a0,s3,80200d0e <readline+0x7c>
    80200cea:	e8a9                	bnez	s1,80200d3c <readline+0xaa>
        c = getchar();
    80200cec:	be0ff0ef          	jal	ra,802000cc <getchar>
        if (c < 0) {
    80200cf0:	fe0549e3          	bltz	a0,80200ce2 <readline+0x50>
        } else if (c >= ' ' && i < BUFSIZE - 1) {
    80200cf4:	fea959e3          	bge	s2,a0,80200ce6 <readline+0x54>
    80200cf8:	4481                	li	s1,0
            cputchar(c);
    80200cfa:	e42a                	sd	a0,8(sp)
    80200cfc:	bceff0ef          	jal	ra,802000ca <cputchar>
            buf[i++] = c;
    80200d00:	6522                	ld	a0,8(sp)
    80200d02:	009b87b3          	add	a5,s7,s1
    80200d06:	2485                	addiw	s1,s1,1
    80200d08:	00a78023          	sb	a0,0(a5)
    80200d0c:	bf7d                	j	80200cca <readline+0x38>
        } else if (c == '\n' || c == '\r') {
    80200d0e:	01550463          	beq	a0,s5,80200d16 <readline+0x84>
    80200d12:	fb651ce3          	bne	a0,s6,80200cca <readline+0x38>
            cputchar(c);
    80200d16:	bb4ff0ef          	jal	ra,802000ca <cputchar>
            buf[i] = '\0';
    80200d1a:	00003517          	auipc	a0,0x3
    80200d1e:	2fe50513          	addi	a0,a0,766 # 80204018 <buf>
    80200d22:	94aa                	add	s1,s1,a0
    80200d24:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
    80200d28:	60a6                	ld	ra,72(sp)
    80200d2a:	6486                	ld	s1,64(sp)
    80200d2c:	7962                	ld	s2,56(sp)
    80200d2e:	79c2                	ld	s3,48(sp)
    80200d30:	7a22                	ld	s4,40(sp)
    80200d32:	7a82                	ld	s5,32(sp)
    80200d34:	6b62                	ld	s6,24(sp)
    80200d36:	6bc2                	ld	s7,16(sp)
    80200d38:	6161                	addi	sp,sp,80
    80200d3a:	8082                	ret
            cputchar(c);
    80200d3c:	4521                	li	a0,8
    80200d3e:	b8cff0ef          	jal	ra,802000ca <cputchar>
            i--;
    80200d42:	34fd                	addiw	s1,s1,-1
    80200d44:	b759                	j	80200cca <readline+0x38>

0000000080200d46 <sbi_console_getchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    80200d46:	4501                	li	a0,0
    80200d48:	00003797          	auipc	a5,0x3
    80200d4c:	2b87b783          	ld	a5,696(a5) # 80204000 <SBI_CONSOLE_GETCHAR>
    80200d50:	88be                	mv	a7,a5
    80200d52:	852a                	mv	a0,a0
    80200d54:	85aa                	mv	a1,a0
    80200d56:	862a                	mv	a2,a0
    80200d58:	00000073          	ecall
    80200d5c:	852a                	mv	a0,a0
    return ret_val;
}

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
    80200d5e:	2501                	sext.w	a0,a0
    80200d60:	8082                	ret

0000000080200d62 <sbi_console_putchar>:
    __asm__ volatile (
    80200d62:	4781                	li	a5,0
    80200d64:	00003717          	auipc	a4,0x3
    80200d68:	2a473703          	ld	a4,676(a4) # 80204008 <SBI_CONSOLE_PUTCHAR>
    80200d6c:	88ba                	mv	a7,a4
    80200d6e:	852a                	mv	a0,a0
    80200d70:	85be                	mv	a1,a5
    80200d72:	863e                	mv	a2,a5
    80200d74:	00000073          	ecall
    80200d78:	87aa                	mv	a5,a0
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    80200d7a:	8082                	ret

0000000080200d7c <sbi_set_timer>:
    __asm__ volatile (
    80200d7c:	4781                	li	a5,0
    80200d7e:	00003717          	auipc	a4,0x3
    80200d82:	6b273703          	ld	a4,1714(a4) # 80204430 <SBI_SET_TIMER>
    80200d86:	88ba                	mv	a7,a4
    80200d88:	852a                	mv	a0,a0
    80200d8a:	85be                	mv	a1,a5
    80200d8c:	863e                	mv	a2,a5
    80200d8e:	00000073          	ecall
    80200d92:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    80200d94:	8082                	ret

0000000080200d96 <sbi_shutdown>:
    __asm__ volatile (
    80200d96:	4781                	li	a5,0
    80200d98:	00003717          	auipc	a4,0x3
    80200d9c:	27873703          	ld	a4,632(a4) # 80204010 <SBI_SHUTDOWN>
    80200da0:	88ba                	mv	a7,a4
    80200da2:	853e                	mv	a0,a5
    80200da4:	85be                	mv	a1,a5
    80200da6:	863e                	mv	a2,a5
    80200da8:	00000073          	ecall
    80200dac:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200dae:	8082                	ret
