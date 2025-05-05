// apple thinks that they are special and diverge 
// from the ARM64 standard ABI in many areas, you will
// see a lot of stack manipulation just to get _printf
// to work, because of how apple handles variadic functions
// see: https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms#Update-code-that-passes-arguments-to-variadic-functions

// author: Dusti Johnson
// date: 2025-MAY-4

.data
_fmt:	.asciz	"%d\n"

.text
.globl	_main
.extern	_printf
.extern	_exit
.align 4

_main:
	sub	sp, sp, #32		// allocate 32 bytes on stack

	// w = 0
	mov	x1, #0
	str	x1, [sp, #0]

	//  printf("%d\n", w) 
	sub	sp, sp, #48		// temp 16-bytes outside of previous 32
	str	x1, [sp, #0]		// spill vararg into slot
	adrp	x0, _fmt@PAGE		// prepare format string
	add	x0, x0, _fmt@PAGEOFF	
	bl	_printf			// printf(fmt, w)
	add	sp, sp, #48		// restore sp

	// x = 0
	mov	x1, #0
	str	x1, [sp, #8]

	//  printf("%d\n", x) 
	sub	sp, sp, #48
	str	x1, [sp, #0]
	adrp	x0, _fmt@PAGE
	add	x0, x0, _fmt@PAGEOFF	
	bl	_printf
	add	sp, sp, #48

	// y = 1
	mov	x1, #1
	str	x1, [sp, #16] 

	//  printf("%d\n", y) 
	sub	sp, sp, #48
	str	x1, [sp, #0]
	adrp	x0, _fmt@PAGE
	add	x0, x0, _fmt@PAGEOFF	
	bl	_printf
	add	sp, sp, #48

	mov	x19, #8			// initalize count to 8 in callee-saved register
_top:
	cbz	x19, _done		// if x19 is 0, branch to _done

	// load w, x, y
	ldr	x20, [sp, #0]
	ldr	x21, [sp, #8]
	ldr	x22, [sp, #16]

	// z = w + x + y
	mov	x1, #0
	add	x1, x20, x21
	add	x1, x1, x22

	// store new values
	str	x21, [sp, #0]		// w = x
	str	x22, [sp, #8]		// x = y
	str	x1,  [sp, #16]		// y = z

	//  printf("%d\n", z)
	sub	sp, sp, #48
	str	x1, [sp, #0] 
	adrp	x0, _fmt@PAGE
	add	x0, x0, _fmt@PAGEOFF
	bl	_printf
	add	sp, sp, #48

	sub	x19, x19, #1		// decrement count by 1
	b	_top
_done:
	mov	x0, #0			// exit code 0
	bl	_exit

