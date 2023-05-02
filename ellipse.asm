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
    xor bh, bh                                      ;zerowanie rejestru w ktorym bedzie result
    
    xor cx, cx                                      ;zerowanie licznika cx (licznik cx liczy liczbę przeczytanych cyfr)

    mov bl, byte ptr ds:[si]                        ;do bh wrzucam kod ascii pierwszego znaku
    
    trim_spaces:                                    ;petla przesuwa offset stringa na pierwszy znak który nie jest spacją
        cmp bl, 32                                  ;jesli wczytany znak nie jest spacją to zaczynam wczytywać cyfry
        jne p1_atoi

        inc si                                      ;przesuwam offset na kolejny znak stringa
        mov bl, byte ptr ds:[si]                    ;do bh wrzucam kod ascii kolejnego znaku
        jmp trim_spaces

    p1_atoi:                                        ;petla przestaje się wykonywać jeśli skończą się cyfry
        cmp cx, 3                                   ;dane wejsciowe moga zawierac maksymalnie 3 cyfry
        ;jg blad_danych                     
        
        cmp bl, 48                                  ;jesli wczytany znak nie jest cyfrą to wracam
        jl powrot_atoi
        cmp bl, 57
        jg powrot_atoi

        inc cx                                      ;inkrementacja licznika wczytanych cyfr

        sub bl, 48                                  ;konwersja z char na int

        mov al, 10                                  ;mnozenie result przez 10
        mul bh

        xor bh, bh                                  ;w ax - wynik mnozenia, do ktorego dodaje aktualna cyfre z bl
        add ax, bx

        cmp ax, 200                                 ;jesli wykraczmy poza przedzial - wypisuje blad
        jge blad_danych

        mov bh, al                                  ;do bh przypisuje aktualnie zparsowany wynik

        inc si                                      ;przesuwam offset na kolejny znak stringa
        mov bl, byte ptr ds:[si]                    ;do ah wrzucam kod ascii kolejnego znaku
        jmp p1_atoi

    powrot_atoi: 
        cmp cx, 0
        je blad_danych                              ;jesli wczytane dane maja 0 cyfr - blad danych wejsciowych

        cmp bh, 0                                   ;jesli dane wychodza poza przedzial - blad danych (>=200 sprawdzone w kodzie wyżej)
        je blad_danych 

        mov byte ptr es:[di] , bh                   ;do miejsca z pamięcią wrzucam obliczony wynik

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