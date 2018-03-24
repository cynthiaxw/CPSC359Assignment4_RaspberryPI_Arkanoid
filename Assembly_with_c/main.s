@ Code section
.section .text

.global main
main:
	@ ask for frame buffer information
	ldr 		r0, =frameBufferInfo 	@ frame buffer information structure
	bl		initFbInfo

	@mov	r0, #600
	@mov	r1, #80
	@ldr	r2, = floor
	@bl	drawPicture
	bl	ballMove
	


haltLoop$:
	b	haltLoop$




@ Data section
.section .data

.align
.globl frameBufferInfo
frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen height