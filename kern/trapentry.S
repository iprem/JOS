/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>
#include <kern/macro.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushq $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushq $0;							\
	pushq $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
   Find the PUSHA,POPA macros in kern/macro.h. Since amd64 doesn't support
   pusha,popa so you will find these macros handy.
 */

/* Trap numbers 0 - 9, 9 is reserved */
TRAPHANDLER_NOEC(XTRPX_divzero, T_DIVIDE)
TRAPHANDLER_NOEC(XTRPX_debug, T_DEBUG)
TRAPHANDLER_NOEC(XTRPX_nmi, T_NMI)
TRAPHANDLER_NOEC(XTRPX_brkpt, T_BRKPT)
TRAPHANDLER_NOEC(XTRPX_oflow, T_OFLOW)
TRAPHANDLER_NOEC(XTRPX_bound, T_BOUND)
TRAPHANDLER_NOEC(XTRPX_illop, T_ILLOP)
TRAPHANDLER_NOEC(XTRPX_device, T_DEVICE)
TRAPHANDLER_NOEC(XTRPX_dblflt, T_DBLFLT)
TRAPHANDLER_NOEC(XTRPX_9, 9)

/* Trap numbers 10 - 15 */
TRAPHANDLER(XTRPX_tss, T_TSS)
TRAPHANDLER(XTRPX_segnp, T_SEGNP)
TRAPHANDLER(XTRPX_stack, T_STACK)
TRAPHANDLER(XTRPX_gpflt, T_GPFLT)
TRAPHANDLER(XTRPX_pgflt, T_PGFLT)
TRAPHANDLER(XTRPX_15, 15)

/* Trap numbers 16 - 19 */
TRAPHANDLER_NOEC(XTRPX_fperr, T_FPERR)
TRAPHANDLER_NOEC(XTRPX_align, T_ALIGN)
TRAPHANDLER_NOEC(XTRPX_mchk, T_MCHK)
TRAPHANDLER_NOEC(XTRPX_simderr, T_SIMDERR)

/* Trap numbers 20 - 31 */
TRAPHANDLER_NOEC(XTRPX_20, 20)
TRAPHANDLER_NOEC(XTRPX_21, 21)
TRAPHANDLER_NOEC(XTRPX_22, 22)
TRAPHANDLER_NOEC(XTRPX_23, 23)
TRAPHANDLER_NOEC(XTRPX_24, 24)
TRAPHANDLER_NOEC(XTRPX_25, 25)
TRAPHANDLER_NOEC(XTRPX_26, 26)
TRAPHANDLER_NOEC(XTRPX_27, 27)
TRAPHANDLER_NOEC(XTRPX_28, 28)
TRAPHANDLER_NOEC(XTRPX_29, 29)
TRAPHANDLER_NOEC(XTRPX_30, 30)
TRAPHANDLER_NOEC(XTRPX_31, 31)

/* Trap numbers 32 - 47 */
TRAPHANDLER_NOEC(XTRPX_32, 32)
TRAPHANDLER_NOEC(XTRPX_33, 33)
TRAPHANDLER_NOEC(XTRPX_34, 34)
TRAPHANDLER_NOEC(XTRPX_35, 35)
TRAPHANDLER_NOEC(XTRPX_36, 36)
TRAPHANDLER_NOEC(XTRPX_37, 37)
TRAPHANDLER_NOEC(XTRPX_38, 38)
TRAPHANDLER_NOEC(XTRPX_39, 39)
TRAPHANDLER_NOEC(XTRPX_40, 40)
TRAPHANDLER_NOEC(XTRPX_41, 41)
TRAPHANDLER_NOEC(XTRPX_42, 42)
TRAPHANDLER_NOEC(XTRPX_43, 43)
TRAPHANDLER_NOEC(XTRPX_44, 44)
TRAPHANDLER_NOEC(XTRPX_45, 45)
TRAPHANDLER_NOEC(XTRPX_46, 46)
TRAPHANDLER_NOEC(XTRPX_47, 47)

TRAPHANDLER_NOEC(XTRPX_syscall, T_SYSCALL)

TRAPHANDLER_NOEC(XTRPX_default, T_DEFAULT)

/*
 * Lab 3: Your code here for _alltraps
 *
 * Hint: Be sure to review the x64 calling convention from lab1
 *       for how to pass a pointer to the trapframe.
 */
_alltraps:
	// The processor already pushed (on this new stack)
	// SS, RSP, EFLAGS, CS, RIP, and an optional error code.
	// To make the new stack look like TrapFrame,
	// All we need to push are ds, es, and all 15 registers
	subq	$16, %rsp
	movw	%ds,8(%rsp)
	movw	%es,0(%rsp)
	// Push all 15 registers
	PUSHA

	// load GD_KD into %ds and %es
	movq	$GD_KD, %rax
	movw	%ax, %ds
	movw	%ax, %es

	// Pass a pointer to the Trapframe as an argument to trap()
	movq	%rsp, %rdi

	// call trap
	call trap

	// restores the old CPU state saved in the Trapframe
	// and then uses the iret instruction to return from the exception
	POPA_
	movw	0(%rsp), %es
	movw	8(%rsp), %ds
	addq	$16, %rsp

	iret
