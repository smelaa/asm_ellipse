dane1 segment
X     db 0 ;oś pozioma elipsy
Y     db 0 ;oś pionowa elipsy

err1 db 'Blad danych wejsciowych! X i Y powinny zawierac sie w przedziale (0,200).$'

dane1 ends

;===============================================================================

code1 segment
start1:
	mov	ax, seg stos1                               ;ustawienie segmentu stosu
	mov	ss, ax 
	mov	sp, offset wstos1 

    mov ax, seg dane1
    mov es, ax
    mov si, 082h                                    ;wrzucam offset, gdzie znajduje się wywołanie z linii komend
    mov di, offset X                                ;do di wrzucam offset zmiennej do której chce sparsować pierwszy argument z linii komend
    call atoi                                       ;parsuje pierwszy argument
    mov di, offset Y                                ;do di wrzucam offset zmiennej do której chce sparsować drugi argument z linii komend
    call atoi                                       ;parsuje drugi argument


    koniec:
        mov al,0                                    ;przerwanie, koniec programu
        mov ah,4ch
        int 21h

;====================================
blad_danych:
    mov 	ax, seg err1                            ;wypisanie komunikatu bledu
	mov 	ds,ax 
	mov 	dx,offset err1 
	mov 	ah,9
	int	21h

    jmp koniec                                      ;zakończenie programu

;====================================
;funkcja konwertująca string na liczbę
;es:[di] - adres zmiennej w której należy przechować string zparsowany do inta [result]
;ds:[si] - adres pierwszego znaku liczby w formacie string 
atoi:                                               ;funkcja konwertuje string spod adresu ds:[si] do es:[di]
    mov byte ptr es:[di], 0                         ;zerowanie result
    
    xor cx, cx                                      ;zerowanie licznika cx (licznik cx liczy liczbę przeczytanych cyfr)

    mov bh, byte ptr ds:[si]                        ;do bh wrzucam kod ascii pierwszego znaku
    
    trim_spaces:                                    ;petla przesuwa offset stringa na pierwszy znak który nie jest spacją
        cmp bh, 32                                  ;jesli wczytany znak nie jest spacją to zaczynam wczytywać cyfry
        jne p1_atoi

        inc si                                      ;przesuwam offset na kolejny znak stringa

        mov bh, byte ptr ds:[si]                    ;do bh wrzucam kod ascii kolejnego znaku
        jmp trim_spaces

    p1_atoi:                                        ;petla przestaje się wykonywać jeśli skończą się cyfry
        cmp cx, 3                                   ;dane wejsciowe moga zawierac maksymalnie 3 cyfry
        jg blad_danych                     
        
        cmp bh, 48                                  ;jesli wczytany znak nie jest cyfrą to wracam
        jb powrot_atoi
        cmp bh, 57
        jg powrot_atoi

        inc cx                                      ;inkrementacja licznika wczytanych cyfr

        sub bh, 48                                  ;konwersja z char na int

        mov al, 10                                  ;mnozenie result przez 10
        mul byte ptr es:[di]

        add byte ptr es:[di], bh                    ;dodanie kolejnej cyfry

        inc si                                      ;przesuwam offset na kolejny znak stringa

        mov bh, byte ptr ds:[si]                    ;do ah wrzucam kod ascii kolejnego znaku

        jmp p1_atoi

    powrot_atoi: 
        cmp cx, 0
        je blad_danych                              ;jesli wczytane dane maja 0 cyfr - blad danych wejsciowych

        cmp byte ptr es:[di], 0                     ;jesli wczytana liczba nie miesci sie w przedziale - blad danych wejsciowych
        jng blad_danych  
        cmp byte ptr es:[di], 200
        jnb blad_danych  

        ret

;====================================


code1 ends

;===============================================================================

stos1 segment stack
	dw	300 dup(?) 
wstos1	dw	?
stos1 ends

;===============================================================================

end start1