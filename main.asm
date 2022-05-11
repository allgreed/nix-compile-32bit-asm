section .text
global main
extern malloc
extern realloc
extern printf
main:
    call initialize_arr
    
    get_number:
        ; check if max_len == actual
        mov dword ebx, [max_arr_len]
        cmp [actual_arr_len], ebx
        ; if not -> can simply save number
        jne read_and_save
        ; if yes -> realloc
        ; max_arr_len+=10
        mov ebx, [max_arr_len]
        add ebx, 10
        mov [max_arr_len], ebx
        ; realloc
        mov eax, [max_arr_len]
        shl eax, 2 ; eax *= 4

        push eax ;size
        push dword [arr] ;previous mem block
        call realloc
        mov ebx, eax ;move allocated address to ebx
        mov dword [arr], ebx ; save new address in arr
        add esp, 8

        ; read number
        read_and_save:
            call read_number
            ; 0 = end input
            cmp eax, 0
            je end_input ;br
            ; save number to array
            ; calculate address (arr + 4*[actual_arr_len])
            push eax ;save number
            mov eax, [actual_arr_len]
            shl eax, 2 ; eax *= 4
            mov ebx, [arr]
            add ebx, eax
            ;mov [arr + 4*[actual_arr_len]], eax
            pop eax ;retreive number
            mov dword [ebx], eax 
            ; numbers++
            mov ebx, [actual_arr_len]
            add ebx, 1
            mov [actual_arr_len], ebx

            jmp get_number

    end_input:

    call print_arr_func
    
    ;sorting

    mov ebx, [arr]
    ; offset
    ; (n - 1) * 4 == n * 4 - 4
    ; TODO: can this be done smarter?
    mov eax, [actual_arr_len]
    dec eax
    shl eax, 2
    add ebx, eax

        enter_inner_loop:
        mov eax, [arr]
        xor ecx, ecx ; ecx calculates swaps

        inner_loop:
            cmp eax, ebx ; pointer == border_pointer
            je outer_loop

            mov edx, [eax] ; edx = 1st element of array
            add eax, 4 ; move to 2nd 

            cmp edx, [eax] ; cmp A[i] to A[i + 1]
            jle inner_loop
        swap:
            inc ecx ; swaps++
            xchg edx, [eax] 
            mov [eax - 4], edx ; eax -> *second element

            jmp inner_loop
    
    outer_loop:
        cmp ecx, 0
        jne enter_inner_loop



    call print_arr_func
    
    jmp exit
    


exit:
    mov eax,1 ; exit
    mov ebx,0 ; return code
    int 0x80

initialize_arr:
    ; malloc array with initial size of 10
    mov eax, 0 ; clear eax
    mov dword [max_arr_len], 10 ; save max arr length = 10 ints
    mov dword [actual_arr_len], 0 ;initial size is 0

    push dword 40 ; pass 40 bytes = 4 * 10 ints
    call malloc ; call malloc
    mov ebx, eax ;move allocated address to ebx
    mov dword [arr], ebx ; *arr = ebx (return value of malloc)
    add esp, 4 ; clear numer 40 from stack. It has 4 bytes. It can be done by pop or changing stack position.

    ret

print_arr_func:
    mov dword ecx, 0 ; counter - how many numbers were printed
    
    print:
        mov eax, ecx ; move index of current number to eax
        shl eax, 2 ; eax*= 4
        mov ebx, [arr]
        add ebx, eax ; ebx = address of ecx-th element

        push ecx ;save counter
        push dword [ebx] ; print number from address pointed by bex
        push num_msg
        call printf
        add esp, 8
        pop ecx

        add dword ecx, 1 ; move to next element
        cmp ecx, [actual_arr_len]
        jge end_print
        jne print

    end_print:

    push end_msg
    call printf
    add esp, 4

ret


read_char:
    ; returns value in buf
    mov eax, 3 ; sys_read
    mov ecx, buf ; where output
    mov ebx, 0 ; stdin
    mov edx, 1 ; size of buffer
    int 0x80
    ret
read_number:
    ; returns value in eax
    ; modifies ebx
    mov eax, 0
    read_next_char:
        push eax ; Save eax (because read_char is using it) and read a character
        call read_char
        pop eax ; Restore eax
        mov ebx, [buf] ; Read number is in memory, we need to retrieve it by an address.
        cmp ebx, 0xa ; compare read char to enter's code
        je read_number_end ; enter finishes reading number
        cmp ebx, 48 ; 48ASCII = 0 Check if is between 0 and 9
        jl skip_to_end_of_line
        cmp ebx, 57 ;57ASCII = 9
        jg skip_to_end_of_line
        mov ecx, 10 ; Because we have next number, multiply current number by 10
        mul ecx
        sub ebx, 48 ; Calculate the number from char, '0' has 48 value in ascii
        add eax, ebx ; Add it to the current number

    jmp read_next_char
; Handle wrong character
skip_to_end_of_line:
    mov eax, 0 ; clear eax, we dont want to return wrong number
    mov ebx, [buf] ; retrieve character from memory (it can be done better, because read_next_char did it once)
    cmp ebx, 0xa ; Enter which means new line, we can end it
    je read_number_end
    call read_char ; If not an enter, user put more than one value which need to be skipped
    jmp skip_to_end_of_line
read_number_end:
ret

section .data
max_arr_len dw 0,0 ;max available size
actual_arr_len dw 0,0 ; current array length
num_msg db '%d  ', 0x0
end_msg db '', 0xa, 0x0
arr dd 0,0,0,0 ; pointer to the beginning of the array
tmp dd 0,0,0,0 ; temp val for swaps

section .bss
buf resb 1 ; 1-byte buffer for reading char
