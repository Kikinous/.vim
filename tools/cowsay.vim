" Generate all cowfiles output install on the system
" list au cowfiles
:!cowsay -l  > ~/tmp/cowsay.txt
:e ~/tmp/cowsay.txt
" erase informative first lien
:normal dd
" put all cowfiles on a new line
:%s/\ /\r/g      | nohlsearch
" generate shell command line for all cowfiles, read the sdtout and put it under line 0
:%s/\(.*\)/:0r!cowsay -f \1 Coucou, ceci est un test./g    | nohlsearch | w
" source the script (left at file bottom, undo otherwise)
:silent! so%    | w
"
" Selected cowfiles
:0r!echo "*******************************************************************"
:w
:0r!cowsay -f surgery    Pardon, depuis le 31 dec, j ai un nerf pince dans les cervicalles. Deux fois aux urgences.
:0r!cowsay -f head-in    je crois que j ai ete clair cette fois
:0r!cowsay -f telebears  pas trop reactif.
:0r!cowsay mon cher matthieu, bonne annee a toi aussi, et vous aussi

:w

