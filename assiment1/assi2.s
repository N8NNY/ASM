    .text
    .global main
    .global printf

main:
    ldr r1,=return
    str lr,[r1]
    ldr r1,=testval 
    bl loopvalue
    bl exit

loopvalue:
    push {lr}
    ldr r0,[r1],#4
    cmp r0,#0
    popeq {pc}
    push {r1}
    // bl to print float
    bl part
    pop {r1}
    bl loopvalue
    pop {pc}

part:
    push {lr}
    // sign
    and r1,r0,#0x80000000
    // exponent
    lsl r0,r0,#1
    lsr r2,r0,#24
    sub r2,r2,#126 
    // fraction
    mov r3,#0x80000000
    lsl r0,r0,#8 
    lsr r0,r0,#1
    orr r3,r0,r3
    // print interger
    push {r2,r3}
    bl head
    pop {r2,r3}
    // compare exponent 
    cmp r2,#0
    lslgt r3,r3,r2
    cmp r2,#0
    neglt r2,r2
    lsrlt r3,r3,r2
    // print fraction
    bl tail
    // print newline
    bl newline
    pop {pc}

head:
    push {lr}
    mov r4,#32
    sub r4,r4,r2
    lsr r5,r3,r4
    cmp r1,#0
    negne r5,r5
    ldr r0,=dot
    mov r1,r5
    bl printf
    pop {pc}

tail:
    push {lr}
    mov r5,#10
    mov r6,r3
    umull r3,r7,r6,r5
    push {r3}
    ldr r0,=print
    mov r1,r7
    bl printf
    pop {r3}
    cmp r3,#0
    popeq {pc}
    bl tail
    pop {pc}

newline:
    push {lr}
    push {r0}
    ldr r0,=nl
    bl printf
    pop {r0}
    pop {pc}
    
exit:
    ldr r1,=return 
    ldr lr,[r1]
    bx lr 

    .data
    .balign 4
return: .word 0

    .balign 4
print: .asciz "%d"
    .balign 4
dot: .asciz "%d."
    .balign 4
nl: .asciz "\n"

    .balign
testval:
    .float 0.5
    .float 0.25
    .float -1.0
    .float 100.0
    .float 1234.567
    .float -9876.543
    .float 7070.7070
    .float 3.3333
    .float 694.3e-9
    .float 6.0221e2
    .float 6.0221e23
    .word 0
