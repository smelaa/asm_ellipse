# Elipsa - Asembler 8086
## Opis zadania
Proszę napisać program uruchamiany z parametrami będącymi dwiema liczbami całkowitymi z przedziału (0, 200), reprezentującymi dwie osie (średnice) elipsy: wielką i małą. Program powinien stabilnie wyświetlić na ekranie w trybie graficznym "VGA: 320x200 256-kolorów" odpowiednią elipsę. Klawisze ze strzałkami powinny umożliwiać dynamiczną zmianę długości osi, a program na bieżąco powinien wówczas aktualizować wygląd elipsy na ekranie. Klawisze: "gór-dół" powinny zmieniać oś pionową, a klawisze: "lewo-prawo" oś poziomą. Wciśnięcie klawisza "Esc", powinno poprawnie zakańczać program.\
\
Przykłady wywołania programu:\
program2 150 40\
program2 200 120\

## Pliki projektu i sposób uruchomienia
Pliki: DOSXNT.386, DOSXNT.EXT, LINK.EXE, ML.ERR, ML.EXE to pliki kompilatora.\
Plik TD.EXE to plik debuggera.\
Plik ellipse.asm to napisany program (in progress).\
\
Aby go uruchomić należy pobrać i uruchomić DOSBoxa, wejść do odpowiedniego katalogu i wywołać następujące polecenia:\
ml ellipse.asm\
ellipse x y\
gdzie x i y to parametry wywołania programu.