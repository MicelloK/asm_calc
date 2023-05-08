dane1 segment
    nline db 13,10,'$'
    in_msg db "Wprowadz slowny opis dzialania: $"
    out_msg db "Wynikiem jest: $"
    exception_msg db "Niepoprawne dane wejsciowe! $"

    input db 63, ?, 64 dup('$') ; bufor na dane wejściowe
    arg1 db 15, ?, 16 dup('$') ; bufor na argument 1
    arg2 db 15, ?, 16 dup('$') ; bufor na argument 2
    op db 15, ?, 16 dup('$') ; bufor na operator

    arg1_int db 0, '$' ; argument 1 jako liczba
    arg2_int db 0, '$' ; argument 2 jako liczba
    result_int db 0, "$" ; wynik jako liczba

    zero db "zero "
    one db "jeden "
    two db "dwa "
    three db "trzy "
    four db "cztery "
    five db "piec "
    six db "szesc "
    seven db "siedem "
    eight db "osiem "
    nine db "dziewiec "

    ten db "dziesiec$",10
    eleven db "jedenascie$",11
    twelve db "dwanascie$",12
    thirteen db "trzynascie$",13
    fourteen db "czternascie$",14
    fifteen db "pietnascie$",15
    sixteen db "szesnascie$",16
    seventeen db "siedemnascie$",17
    eighteen db "osiemnascie$",18
    nineteen db "dziewietnascie$",19

    twenty db "dwadziescia $",20
    thirty db "trzydziesci $",30
    forty db "czterdziesci $",40
    fifty db "piecdziesiat $",50
    sixty db "szescdziesiat $",60
    seventy db "siedemdziesiat $",70
    eighty db "osiemdziesiat $",80

    plus db "plus$"
    minus db "minus$"
    mlt db "razy$"

dane1 ends

;------------------------------------------------

code1 segment
start1:
    ; inicjalizacja stosu
    mov ax, seg stos1
    mov ss, ax
    mov sp, offset wstos1

    ; początek programu
    mov dx, offset in_msg
    call puts

    ; wczytanie danych
    call getl
    call endl

    ; analiza danych
    call split

    ; konwersja argumentów na liczby
    mov dx, offset arg1+2
    call arg_to_int

    mov dx, offset arg2+2
    call arg_to_int

    ; działanie
    call operation

    mov dx, offset out_msg
    call puts


exit:
    mov al,0 ; zwroc 0 do systemu
    mov ah,4ch
    int 21h

exception:
    mov dx, offset exception_msg
    call puts
    jmp exit


;------------------------;
;-- FUNKCJE POMOCNICZE --;
;------------------------;

puts: ; wypisuje ciąg znaków, którego offset jest w dx
    mov ax, seg dane1
    mov ds, ax
    mov ah, 09h
    int 21h
    ret

getl: ; wczytuje ciąg znaków z klawiatury i zapisuje do bufora
    mov ax, seg dane1
    mov ds, ax
    mov dx, offset input
    mov ah, 0ah ; wczytaj ciąg znaków
    int 21h
    ret

; si - wskaźnik na początek pierwszego ciągu znaków
; di - wskaźnik na początek drugiego ciągu znaków
cmp_str:
    xor al, al ; 1 - równe, 0 - różne

    cmploop:
        mov bl, byte ptr ds:[si] ; bl - aktualny znak z si
        mov cl, byte ptr ds:[di] ; cl - aktualny znak z di

        cmp bl, '$' ; jeśli koniec ciągu znaków to koniec
        je cmploop_equal

        cmp cl, '$' ; jeśli koniec ciągu znaków to koniec
        je cmploop_not_equal

        cmp bl, cl ; jeśli znaki są różne to koniec
        jne cmploop_not_equal

        inc si
        inc di
        jmp cmploop

    cmploop_not_equal:
        mov al, 0
        ret

    cmploop_equal:
        mov al, 1
        ret

endl:
    mov dx, offset nline
    call puts
    ret

;------------------------;
;-- PARSOWANIE WEJSCIA --;
;------------------------;

split: ; dzieli ciąg znaków na argumenty i operator
    mov si, offset input+2 ; si - wskaźnik na początek ciągu znaków

    mov di, offset arg1+2
    arg1loop:
        mov al, byte ptr ds:[si] ; al - aktualny znak
        cmp al, ' '
        je arg1loop_done ; jeśli spacja to koniec
        mov byte ptr ds:[di], al ; zapisanie znaku do bufora
        inc si
        inc di
        jmp arg1loop

    arg1loop_done:
        mov byte ptr ds:[di], '$' ; zakończenie bufora

    ; pomijanie spacji
    spcloop1:
        mov al, byte ptr ds:[si] ; al - aktualny znak
        cmp al, ' '
        jne operator ; jeśli nie ma spacji to znaczy że operator
        inc si
        jmp spcloop1

    operator:
        mov di, offset op+2

    oploop:
        mov al, byte ptr ds:[si] ; al - aktualny znak
        cmp al, ' '
        je oploop_done ; jeśli spacja to koniec
        mov byte ptr ds:[di], al ; zapisanie znaku do bufora
        inc si
        inc di
        jmp oploop

    oploop_done:
        mov byte ptr ds:[di], '$' ; zakończenie bufora
    
    spcloop2:
        mov al, byte ptr ds:[si]
        cmp al, ' '
        jne arg2start
        inc si
        jmp spcloop2

    arg2start:
        mov di, offset arg2+2

    arg2loop:
        mov al, byte ptr ds:[si]
        cmp al, ' '
        je arg2loop_done
        cmp al , 13
        je arg2loop_done
        mov byte ptr ds:[di], al
        inc si
        inc di
        jmp arg2loop

    arg2loop_done:
        mov byte ptr ds:[di], '$' ; zakończenie bufora

    ret

; dx - offset na argument+2
arg_to_int:
    mov si, offset zero
    xor ch, ch ; ch - ilosc spacji = 0
    
    fit:
        mov di, dx

        number_loop:
            mov al, byte ptr ds:[si] ; al - aktualny znak z si
            mov bl, byte ptr ds:[di] ; bl - aktualny znak z arg1

            cmp ch, 10 ; jeśli mniej niż 10 spacji to ok
            je exception ; jeśli więcej niż 10 spacji to błąd

            cmp bl, '$' ; jeśli koniec ciągu znaków to koniec
            je fit_done

            cmp al, ' '
            jne not_next
            inc ch ; jeśli spacja to zwiększ licznik spacji
            not_next:

            inc si
            cmp al, bl ; jeśli znaki są różne to koniec
            jne next_loop

            inc di
            jmp number_loop

    next_loop:
        mov al, byte ptr ds:[si] ; al - aktualny znak z si
        cmp al, ' '
        je next_loop_done
        inc si
        jmp next_loop

    next_loop_done:
        inc si
        jmp fit

    fit_done:
        cmp al, ' '
        jne exception ; jeśli arg sie skonczyl ale drugi wyraz nie to błąd

        mov di, offset arg1_int
        mov byte ptr ds:[di], ch ; zapisz ilość spacji
        ret

; operation - wykonuje działanie na arg1 i arg2
operation:
    mov di, offset op+2 ; di - wskaźnik na początek ciągu znaków

    mov si, offset plus ; si - wskaźnik na początek ciągu znaków
    call cmp_str
    cmp al, 1
    je plus_found

    mov si, offset minus
    call cmp_str
    cmp al, 1
    je minus_found

    mov si, offset mlt
    call cmp_str
    cmp al, 1
    je mlt_found

    jmp exception

    plus_found:
        mov al, byte ptr ds:[arg1_int]
        add al, byte ptr ds:[arg2_int]
        mov byte ptr ds:[result_int], al
        ret

    minus_found:
        mov al, byte ptr ds:[arg1_int]
        sub al, byte ptr ds:[arg2_int]
        mov byte ptr ds:[result_int], al
        ret

    mlt_found:
        xor ax, ax
        mov al, byte ptr ds:[arg1_int]
        mul byte ptr ds:[arg2_int]
        mov byte ptr ds:[result_int], al
        ret

; print_int:








;------------------------;



    


code1 ends

;------------------------------------------------

stos1 segment stack
    dw 300 dup (?) ; 600 bajtów
    wstos1 dw ? ; wierzchołek stosu
stos1 ends

;------------------------------------------------

end start1