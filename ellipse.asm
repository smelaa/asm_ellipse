.387 ;dyrektywa informujaca o zmiennym przecinku 
dane1 segment
X_start     db 0 ;oś pozioma elipsy
Y_start     db 0 ;oś pionowa elipsy

k1          db 0 ;kod ostatniego klawisza
err1        db 'Blad danych wejsciowych! X i Y powinny zawierac sie w przedziale (0,200).$'

dane1 ends

;===============================================================================

code1 segment
start1:
	mov	ax, seg stos1                               ;ustawienie segmentu stosu
	mov	ss, ax 
	mov	sp, offset wstos1 

    ;PARSOAWANIE ARGUMENTÓW
    mov ax, seg dane1
    mov es, ax
    mov si, 082h                                    ;wrzucam offset, gdzie znajduje się wywołanie z linii komend
    mov di, offset X_start                          ;do di wrzucam offset zmiennej do której chce sparsować pierwszy argument z linii komend
    call atoi                                       ;parsuje pierwszy argument
    mov di, offset Y_start                          ;do di wrzucam offset zmiennej do której chce sparsować drugi argument z linii komend
    call atoi                                       ;parsuje drugi argument

    mov ax, seg dane1                               ;do ds wrzuć segment danych
    mov ds, ax 

    mov al, byte ptr ds:[X_start]                   ;do osX wrzuć polowe sparsowanego X_start
    xor ah, ah
    mov bl, 2
    div bl
    xor ah, ah
    mov word ptr cs:[osX], ax

    mov al, byte ptr ds:[Y_start]                   ;do osY wrzuć polowe sparsowanego Y_start
    xor ah, ah
    mov bl, 2
    div bl
    xor ah, ah
    mov word ptr cs:[osY], ax

    ;TRYB GRAFICZNY
    mov al, 13h ;320x200 256 kolorów
	mov ah, 0 
	int 10h 

    mov byte ptr cs:[ke], 13                         ;do ke przypisany losowy kolor początkowy elipsy
    mov byte ptr cs:[kb], 0                          ;do kb przypisany losowy kolor początkowy tła
    call narysuj_elipse

    ;OBSŁUGA PRZYCISKÓW
    inf_p: 
        in al, 60h                                  ;60h to kod klawiatury - wrzucam kod klawisza do al  
        cmp al, 1                                   ;1 - ESC -> zakońćz program
        je chg_txt

        cmp al, byte ptr ds:[k1]                    ;jesli klawisz był już obsłużony to nie obsługuj znowu
        je inf_p
        mov byte ptr ds:[k1], al                    ;zapisz ze byl juz obslugiwany
        
        p1:
            cmp al, 75                              ;75 - LEFT -> zmniejsz X
            jne p2

            dec byte ptr cs:[osX]
            jmp p_dr
        p2: 
            cmp al, 77                              ;77 - RIGHT -> zwiększ X
            jne p3

            inc byte ptr cs:[osX]
            jmp p_dr
        p3: 
            cmp al, 72                              ;72 - UP -> zwiększ Y
            jne p4

            inc byte ptr cs:[osY]
            jmp p_dr
        p4: 
            cmp al, 80                              ;80 - DOWN -> zmniejsz Y
            jne pk

            dec byte ptr cs:[osY]
            jmp p_dr
        pk:                                         ;37 - ALT+K -> zmień kolor
            cmp al, 37                             
            jne pb

            inc byte ptr cs:[ke]
            jmp p_dr
        pb:                                         ;48 - ALT+B -> zmień kolor tla
            cmp al, 48                             
            jne inf_p

            inc byte ptr cs:[kb]
        p_dr:
            call set_bnd
            call narysuj_elipse
            jmp inf_p

	;TRYB TEKSTOWY
    chg_txt:
        mov al, 3h
        mov ah, 0 
        int 10h 

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
        jg blad_danych                     
        
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
        jg blad_danych

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
kb   db ? ;kolor tła
clean_screen:                                       ;funkcja czyści ekran
    mov ax, 0a000h                                  ;adres pamięci obrazu
    mov es, ax  

    mov di, 0                                       ;do di pierwszy adres komorki pamieci obrazu
    mov cx, 64000                                   ;cx - ile razy ma powtorzyc zeby wyczyscic ekran
    mov al, byte ptr cs:[kb]                        ;al - wkolor tla
    cld
    rep stosb

    ret
;====================================
;obiekt: elipsa
osX   dw ? ;polos pozioma
osY   dw ? ;polos pionowa
;............
narysuj_elipse:
    call clean_screen
    mov cx, word ptr cs:[osY]
    ;cmp word ptr cs:[osX], cx 
    ;jl od_Y
    od_X:
        mov cx, word ptr cs:[osX]
        p_odX: push cx 
            mov word ptr cs:[X], cx 
            mov word ptr cs:[setX], cx 
            mov ax, word ptr cs:[osX]
            mov word ptr cs:[a], ax 
            mov ax, word ptr cs:[osY]
            mov word ptr cs:[b], ax 
            call ustal_pkt
            mov ax, word ptr cs:[setY]
            mov word ptr cs:[Y], ax 
            call odbij_zapal_pkt
            pop cx
            loop p_odX 
    od_Y:
        mov cx, word ptr cs:[osY]
        p_odY: push cx 
            mov word ptr cs:[Y], cx 
            mov word ptr cs:[setX], cx 
            mov ax, word ptr cs:[osY]
            mov word ptr cs:[a], ax 
            mov ax, word ptr cs:[osX]
            mov word ptr cs:[b], ax 
            call ustal_pkt
            mov ax, word ptr cs:[setY]
            mov word ptr cs:[X], ax 
            call odbij_zapal_pkt
            pop cx
            loop p_odY
        ret

;..........................
setX   dw ? ;wyliczana zmienna
setY   dw ? ;zmienna służącą do wyliczenia
a      dw ? ;półoś zgodna z wsp wyliczaną
b      dw ? ;druga półoś
;............
ustal_pkt:                                          ;ustala punkt (x,y)=(x, sqrt((1-x^2/a^2)b^2))
    finit
    fild word ptr cs:[setX]                         ;x
    fimul word ptr cs:[setX]                        ;x^2
    fidiv word ptr cs:[a]                           ;x^2/a
    fidiv word ptr cs:[a]                           ;x^2/a^2
    fld1     
    fsub                                            ;x^2/a^2-1
    fchs                                            ;1-x^2/a^2
    fimul word ptr cs:[b]                           ;(1-x^2/a^2)b
    fimul word ptr cs:[b]                           ;(1-x^2/a^2)b^2
    fsqrt

    fist word ptr cs:[setY]                         ;zapisz wynik do setY
    ret
;..........................
;parametry: X, Y
odbij_zapal_pkt:                                    ;narysuj punkt w 4 ćwiartkach symetrycznie
    call przenies_zapal_pkt                         ;(X, Y)

    xor ax, ax
    sub ax, word ptr cs:[X] 
    mov word ptr cs:[X], ax
    call przenies_zapal_pkt                         ;(-X, Y)

    xor ax, ax
    sub ax, word ptr cs:[Y] 
    mov word ptr cs:[Y], ax
    call przenies_zapal_pkt                         ;(-X, -Y)

    xor ax, ax
    sub ax, word ptr cs:[X] 
    mov word ptr cs:[X], ax
    call przenies_zapal_pkt                         ;(X, -Y)

    ret
;..........................
;parametry: X, Y
przenies_zapal_pkt:                                 ;przenies na srodek ekranu
    push word ptr cs:[X] 
    push word ptr cs:[Y] 
    
    mov ax, word ptr cs:[X]     
    add ax, 160
    mov word ptr cs:[X], ax

    mov ax, word ptr cs:[Y]
    add ax, 100
    mov word ptr cs:[Y], ax

    call zapal_punkt

    pop word ptr cs:[Y] 
    pop word ptr cs:[X] 

    ret
;====================================
set_bnd:                                            ;funkcja dbająca o to by wartości osi nie wykraczyły poza to co mieści się na ekranie
    cmp word ptr cs:[osX], 160                      ;X overflow
    jl sb_2
    mov word ptr cs:[osX], 159
    sb_2:                                           ;Y overflow
        cmp word ptr cs:[osY], 100
        jl sb_3
        mov word ptr cs:[osY], 99
    sb_3:                                           ;X underflow
        cmp word ptr cs:[osX], 0
        jg sb_4
        mov word ptr cs:[osX], 1
    sb_4:                                           ;Y underflow
        cmp word ptr cs:[osY], 0
        jg sb_cmb
        mov word ptr cs:[osY], 1
    sb_cmb: ret
;====================================
;obiekt: punkt
X   dw ?
Y   dw ?
ke   db ?
;..........................
zapal_punkt:                                        ;funkcja zapala punkt o danych wsp x i y
    mov ax, 0a000h                                  ;adres pamięci obrazu
    mov es, ax                                      

    mov ax, word ptr cs:[Y]                         ;ax=320*Y
    mov bx, 320
    mul bx 

    mov bx, word ptr cs:[X]                         ;bx=ax+X=320*Y+X
    add bx, ax 

    mov al, byte ptr cs:[ke]                         ;al=numer koloru k
    mov byte ptr es:[bx], al                        ;do komórki o adresie bx przypisz kolor k
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