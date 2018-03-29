.section .text
.global valuepack
// TODO: disappear when out of bound
valuepack:
    push    {r4-r10, lr}
    
    @ load pre value pack location (x, y)
    @ r10 ------- global_address
    
    @ r4 - width            constant no need to name it
    @ r5 - length           constant no need to name it
    @ r6 - image address
    @ r7 - x_offset
    @ r8 - y_offset
    @ valuepack1:    .int x, y, type, ability    
    @ valuepack2:    .int x, y, type, ability 
    @ valuepack3:    .int x, y, type, ability       

    valuePackAdr        .req    r6
    valuePackX          .req    r7
    valuePackY          .req    r8
    valuePackType       .req    r9
    //valuePackAbility    .req    r10

    ldr     r10, =valuepack1         @ value1/2/3
    
checkValue1:
    
    ldr     valuePackType, [r10, #8]

    cmp     valuePackType, #0
    ldreq   r10, =valuepack2
    beq     checkValue2
   
    cmp     valuePackType, #1
    ldreq   valuePackAdr, =valuepack1
    ldreq   valuePackX, [r10]
    ldreq   valuePackY, [r10, #4]
    beq     movement

    //cmp     valuePackType, #2
    
checkValue2:

    ldr     valuePackType, [r10, #8]

    cmp     valuePackType, #0
    ldreq   r10, =valuepack3
    beq     checkValue3

    cmp     valuePackType, #1
    ldreq   valuePackAdr, =valuepack2
    ldreq   valuePackX, [r10]
    ldreq   valuePackY, [r10, #4]
    beq     movement

    //cmp    valuePackType, #2

checkValue3:

    ldr     valuePackType, [r10, #8]

    cmp     valuePackType, #0
    beq     done
    //beq     checkValue3
    
    cmp     valuePackType, #1
    ldreq   valuePackAdr, =valuepack3
    ldreq   valuePackX, [r10]
    ldreq   valuePackY, [r10, #4]

movement:
    @ valuePack x, y, adr
    
    
    mov     r4, #32	

    mov	    r1, valuePackX
    mov     r2, valuePackY
    sub	    r1, #600
    sub     r2, #80

    udiv    r1, r1, r4
    udiv    r2, r2, r4
    
    mul     r1, r4
    mul     r2, r4

    add	    r1, #600
    add     r2, #80

    ldr     r4, =floor
    mov     r5, r1
    mov     r6, r2
    push    {r4-r6}
    bl      drawCell
    pop     {r4-r6}
@-------------------------------
    mov     r4, #32	
	
    mov	    r1, valuePackX
    mov     r2, valuePackY
    add	    r1, #32
    sub	    r1, #600
    sub     r2, #80

    udiv    r1, r1, r4
    udiv    r2, r2, r4
    
    mul     r1, r4
    mul     r2, r4

    add	    r1, #600
    add     r2, #80

    ldr     r4, =floor
    mov     r5, r1
    mov     r6, r2
    push    {r4-r6}
    bl      drawCell
    pop     {r4-r6}
    

    add     valuePackY, #1
    str     valuePackY, [r10, #4]
    
    udiv    r1, valuePackX, r4
    udiv    r2, valuePackY, r4
    
    mul     r1, r4
    mul     r2, r4
    
    mov     r4, #64
    mov     r5, #32
    ldr	    valuePackAdr, =value1
	
    push    {r4-r10}
    bl      drawPicture
    pop     {r4-r10}

    
    
    ldr	    r0, =valuepack1
    cmp     r10, r0
    beq	    checkValue2

    ldr	    r0, =valuepack2
    cmp	    r10, r0
    beq	    checkValue3

done:
    pop     {r4-r10, pc}
