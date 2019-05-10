    .text
    .global _start

_start:
    ldr r0,=file
    mov r1,#0
    mov r2,#384
    mov r7,#5
    svc 0
    /*handle err*/
    cmp r0,#-1
    bleq err
    
    mov r4,r0 @ save file descriptor
    mov r3,#0 @ set r3 = 0 for counter byte

openFile:
    /*move cursor */
    mov r0,r4
    mov r1,#0
    mov r2,#0
    mov r7,#19
    svc 0

    /*read file*/
    mov r0,r4
    ldr r1,=file_buffer
    mov r2,#10000
    mov r7,#3
    svc 0
    
    ldr r8,=file_buffer @ index file_buffer
    mov r2,#0 @ set r5 = 0 for couuter space
    mov r1,#0 @ set r9 = 0 for couuter /n
    mov r12,#1

Word:
    push {r0-r7}
    bl checkWord
    pop {r0-r7}

counter:
    cmp r12,#0
    bleq Word
    mov r6,r8
    mov r7,#0
    mov r9,#0
    /*check eof*/
    ldrb r5,[r6]
    cmp r5,#0
    bleq print_out

    /*counter byte*/
    add r8,r8,#1 @ push index
    add r3,r3,#1 @ add couter byte+=1

    /*counter word*/
    cmp r5,#32 @ check with space
    subeq r9,r6,#1
    ldreqb r7,[r9]
    cmp r7,#32
    addgt r1,r1,#1 @ add couter /n+=1
    mov r7,#0 
    cmp r5,#10 @ check with newline
    subeq r9,r6,#1
    ldreqb r7,[r9]
    cmp r7,#32
    addgt r1,r1,#1 @ add couter /n+=1

    /*counter newline*/
    cmp r5,#10 
    addeq r2,r2,#1 @ add couter space+=1
    bleq Word
    mov r10,#1
    bl counter

checkWord:
    /*set up*/
    push {lr}
    ldrb r12,[r8]
    cmp r12,#10
    addeq r8,r8,#1
    mov r0,r8
    ldr r1,=word
    mov r2,#0 @ length of word
    mov r7,#0
    mov r6,#0
    mov r10,#0
    mov r3,r1
    push {r0,r1,r3,r4}
    bl len
    pop {r0,r1,r3,r4}
    
C:
    ldrb r4,[r0,r10]
    ldrb r5,[r3],#1
    cmp r4,r5
    addeq r6,r6,#1
    add r7,r7,#1
    add r10,r10,#1
    cmp r7,r2
    bllt C
R:
    /*word in line*/
    cmp r6,r2
    moveq r12,#1 @ return true
    popeq {lr}
    bxeq lr
    /*not found word in line*/
    ldrb r9,[r0]
    cmp r9,#10
    moveq r12,#0 @ return false
    addeq r8,r0,#1 @ return index -> newline + 1
    popeq {lr}
    bxeq lr
    /*loop check until /n*/
    add r0,r0,#1
    mov r7,#0
    mov r6,#0
    mov r10,#0
    mov r3,r1
    bl C

len:
    mov r2,#0 @return length
l1:
    ldrb r4,[r1],#1
    cmp r4,#0
    addne r2,r2,#1
    bne l1
    bx lr

print_out:
    ldr r5,=temp
    /* write newline*/
    mov r6,r2
    bl int2ascii
    mov r10,r5
    mov r2,r12
    bl revers
    bl write 
    /* write word*/
    mov r6,r1
    bl int2ascii
    mov r10,r5
    mov r2,r12
    bl revers
    bl write 
    /* write byte*/
    mov r6,r3
    bl int2ascii
    mov r10,r5
    mov r2,r12
    bl revers
    bl write 
    
    b _exit

write:
    push {r1-r4,lr}
    mov r0,#1
    mov r1,r10
    mov r7,#4
    svc 0
    pop {r1-r4,lr}
    mov pc,lr

revers:
    push {r1-r7,lr}
    mov r0,r5 @ index temp
    ldr r3,=output
    sub r2,r2,#2
loopR:
    add r0,r5,r2
    ldrb r1,[r0]
    strb r1,[r3],#1
    cmp r2,#0
    moveq r1,#32
    streqb r1,[r3]
    popeq {r1-r7,lr}
    ldreq r10,=output
    bxeq lr
    sub r2,r2,#1
    bl loopR

int2ascii:
    push {r1-r7,lr}
    mov r0,r6
    mov r1,#0
    ldr r2,=temp
    mov r12,#0
    cmp r0,#10
    movlt r1,r6
    blt str_final
mod:
    sub r0,r0,#10
    add r1,r1,#1
    cmp r0,#10
    blgt mod
str_result:
    add r12,r12,#1
    add r11,r0,#48
    strb r11,[r2],#1 
    cmp r1,#10
    movgt r0,r1
    movgt r1,#0
    blgt mod
str_final:
    add r12,r12,#2
    add r11,r1,#48
    strb r11,[r2],#1
    mov r11,#32
    strb r11,[r2]
    pop {r1-r7,lr}
    mov pc,lr
    
_exit:
    mov r7,#1
    svc 0

err:
    mov r4,r0
    mov r0,#1
    ldr r1,=errmsg
    mov r2,#(errmsgend-errmsg)
    mov r7,#4
    svc 0
    mov r0,r4
    b _exit

    .data
errmsg: .asciz "Can't Open file!"
errmsgend:
file: .asciz "/home/pi/Workspace/assiment2/test"
file_buffer: .space 10000
output: .space 1000
temp: .space 1000
word: .asciz "n8n"
