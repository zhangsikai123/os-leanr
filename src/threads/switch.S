#include "threads/switch.h"

#### struct thread *switch_threads (struct thread *cur, struct thread *next);
####
#### Switches from CUR, which must be the running thread, to NEXT,
#### which must also be running switch_threads(), returning CUR in
#### NEXT's context.
####
#### This function works by assuming that the thread we're switching
#### into is also running switch_threads().  Thus, all it has to do is
#### preserve a few registers on the stack, then switch stacks and
#### restore the registers.  As part of switching stacks we record the
#### current stack pointer in CUR's thread structure.

.globl switch_threads
.func switch_threads
switch_threads:
	# Save caller's register state.
	#
	# Note that the SVR4 ABI allows us to destroy %eax, %ecx, %edx,
	# but requires us to preserve %ebx, %ebp, %esi, %edi.  See
	# [SysV-ABI-386] pages 3-11 and 3-12 for details.
	#
	# This stack frame must match the one set up by thread_create()
	# in size.
        # ebx: callee-saved register; also used to hold the GOT pointer when making function calls via the PLT. GOT:global Offset Table pinter: It maps symbols in programming code to their corresponding absolute memory addresses to facilitate Position Independent Code (PIC) and Position Independent Executables (PIE)
        # ebp: callee-saved register; optionally used as frame pointer
        # esi: callee-saved register
        # edi: callee-saved register
	pushl %ebx
	pushl %ebp
	pushl %esi
	pushl %edi

        # stack now:
        #       | old thread stack |
        #       |   ret
        #       |   ebx |
        #       |   ebp |
        #       |   esi |
        #       |   edi |
        # esp--> ----------
        #
	# Get offsetof (struct thread, stack).
.globl thread_stack_ofs
	mov thread_stack_ofs, %edx

        # eax: scratch register; also used to return integer and pointer values from functions; also stores the address of a returned struct or union
	# Save current stack pointer to old thread's stack, if any.
        # SWITCH_CUR(reg): reg + 20
	movl SWITCH_CUR(%esp), %eax # 这是干什么？？？
	movl %esp, (%eax,%edx,1) # 保存esp

        # edx = thread_stack_ofs
        # eax = [esp + 20]
        # [eax + edx ] = esp

	# Restore stack pointer from new thread's stack.
        # ecx = [esp + 24]
        movl SWITCH_NEXT(%esp), %ecx
	movl (%ecx,%edx,1), %esp

	# Restore caller's register state.
	popl %edi
	popl %esi
	popl %ebp
	popl %ebx
        ret
.endfunc

.globl switch_entry
.func switch_entry
switch_entry:
	# Discard switch_threads() arguments.
	addl $8, %esp

	# Call thread_schedule_tail(prev).
	pushl %eax
.globl thread_schedule_tail
	call thread_schedule_tail
	addl $4, %esp

	# Start thread proper.
	ret
.endfunc
