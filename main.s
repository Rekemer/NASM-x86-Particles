	.file	"main.c"
	.intel_syntax noprefix
	.text
	.globl	_sum
	.def	_sum;	.scl	2;	.type	32;	.endef
_sum:
LFB10:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	mov	edx, DWORD PTR [ebp+8]
	mov	eax, DWORD PTR [ebp+12]
	add	eax, edx
	pop	ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE10:
	.globl	_a
	.data
	.align 4
_a:
	.long	2
	.globl	_b
	.align 4
_b:
	.long	4
	.globl	_k
	.align 4
_k:
	.long	1065353216
	.def	___main;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
LC0:
	.ascii "%f\0"
	.text
	.globl	_main
	.def	_main;	.scl	2;	.type	32;	.endef
_main:
LFB11:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	and	esp, -16
	sub	esp, 32
	call	___main
	mov	DWORD PTR _a, 4
	mov	eax, DWORD PTR _a
	mov	DWORD PTR [esp+28], eax
	fild	DWORD PTR [esp+28]
	fstp	DWORD PTR _k
	fld	DWORD PTR _k
	fstp	QWORD PTR [esp+4]
	mov	DWORD PTR [esp], OFFSET FLAT:LC0
	call	_printf
	mov	eax, 0
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE11:
	.ident	"GCC: (MinGW.org GCC-6.3.0-1) 6.3.0"
	.def	_printf;	.scl	2;	.type	32;	.endef
