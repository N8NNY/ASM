    .text
    .global _start
_start:
    ldr r4,[sp,#8] @ first parameter address 
    cmp r4,#0
    bleq _exit
    mov r1,r4
    bl strlen
    mov r2,r0
    bl _write

checkArgument:
    add r4,r4,r0
    add r4,r4,#1
    ldrb r5,[r4]
    cmp r5,#76
    bleq _exit
    mov r1,r4
    bl strlen
    mov r2,r0
    bl _write
    bl checkArgument

_exit:
    mov r7,#1
    swi 0

_write:
    push {r0-r7}
    mov r7,#4
    mov r0,#1
    mov r1,r4
    swi 0
    pop {r0-r7}
    mov pc,lr

strlen:
@ ======================================================
@ find string length 
@ input : r1 point to string
@=======================================================
mov r0, #0 @ length to return

l2:
    ldrb r2, [r1], #1 @ get current char and advance
    cmp r2, #0 @ are we at the end of the string?
    addne r0, #1
    bne l2
    mov pc, lr
