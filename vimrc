" https://github.com/thoughtbot/dotfiles/blob/master/vimrc
" DOC:{{{1
" Versions: {{{2
" V1.1
"   -- Deux fonctions pour compiler pandoc (vim internal make et tpope " Dispatch)
"   -- [ ] Bug: change pas de répertoire courant quand on change de buffer
"
" V1.0: 2020_01_09:
"   -- compile pandoc (internal make et Dispatch)
"   -- wiki work et wiki perso :  <leader>ww et <leader>wp
" }}}
" References: {{{2
" Greg Hurrel: http s://github.com/wincent/wincent/tree/master/roles/dotfiles/files/.vim
" Steve Losh:  http ://learnvimscriptthehardway.stevelosh.com
" Drew_Neil:   http ://vimcasts.org
" Cheatsheet:  http s://devhints.io/vimscript
"   c_<C-r> : command mode tricks
"   i_<C-x> : normal  mode tricks
"   :w !sudo tee %
" }}} "}}}
" BASICS: {{{1
" Affichage: {{{2
set nocompatible
syntax on
filetype plugin on                               " chargement de plugin de filetype

set number                                       " nombres a gauche
set relativenumber                               " nombres relatifs
set showcmd                                      " en bas a droite
set laststatus=1                                 " status bar {0: never, 1: split needed, 2:always}
set wildmenu                                     " command-line completion
set wildmode=longest:list,full                   " https://www.reddit.com/r/vim/comments/19izuz/whats_your_wildmode/

set termguicolors                                " ?
set background=dark                              " colorscheme light ou dark
colorscheme base16-tomorrow-night                " voir autocommand
set lazyredraw                                   " affichage plus rapide
set noerrorbells
set novisualbell

set fillchars=vert:\│                            " ?
set list                                         " display invisible characters
set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮
set showmatch                                    " {} () []
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"             " ?
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"             " ?

set fdm=marker                                   " methode de repli
set foldtext=MonFoldText()                       " texte
"set foldlevel=0                                 " niveau
"set colorcolumn=80                              " cc
set nowrap                                       "
set showbreak=↪
"highlight ColorColumn ctermbg=0                 "
"call matchadd('ColorColumn', '\%81v', 100)      "

"}}}
" Fonctionalites: {{{2
set undofile
set mouse=a                                      " pour que la souris marche
set clipboard=unnamed                            " Vim yank to the clipboard, to be pasted anywhere. (OS register is "* by defaut, now default register "") 
if has("mouse_sgr")                              " redimensionne split dans tmux
    set ttymouse=sgr                             "
else                                             "
    set ttymouse=xterm2                          "
end                                              "

set autochdir                                    " set working directory = fichier ouvert
"autocmd BufEnter * silent! lcd %:p:h            " Unfortunately, when this option is set some plugins may not work correctly if they make assumptions about the current directory. Sometimes, as an alternative to setting autochdir, the following command gives better results:

set path+=**                                     " :find cherchera dans les sous repertoires
"
set ignorecase                                   " cherche les majuscules aussi
set smartcase                                    " matche les majuscule du regex
set hlsearch                                     " surligne regex
set incsearch                                    " surligne pendant la tape
"
" dico local  $HOME/.vim/spell/fr.utf-8.add
" dico global $HOME/.vim/spell/fr.utf-8.spl
set spelllang=fr                                 " langue pour l orthographe
set complete+=kspell                             " word completion CTRL-N CTRL-P
if ( index(['txt','md','tex'],&ft) >= 0) | set spell | else | set nospell | endif
" language tool pour l'orthographe
let g:languagetool_jar='$HOME/.vim/julien/LanguageTool/languagetool.jar'
" ouvre help vsplit à droite
cnoreabbrev h botright vert h
set rtp+=/opt/local/share/fzf/vim                "fuzzy file finder Doc: /opt/local/share/doc/fzf
set modelineexpr                                 " to allow expression in modeline
"}}}
" Edition: {{{2
set encoding=utf8                                " A garder ?
set expandtab                                    " indentation avec spaces plutot que tab
set smarttab                                     "
set shiftwidth=4                                 " largeur d'espace à ajouter en normal mode
set tabstop=4                                    " largueur d'une tabulation en espaces
set t_BE=                                        " hack : evite caractères bizarres lors de copier-coller
set textwidth=0                                  " insère un retour à la ligne
set virtualedit=""                               " cursor can be positioned where there is no actual character  (default "") {"", block, insert, all, onemore} 
" Lorem {{{
iabbr lorem Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
"}}}
"}}} "}}}
" FUNCTIONS: {{{1
" AlignDroite() {{{2
function! AlignDroite() 
  " Fonction: alignement à droite à 80 caracteres
  " Julien Borghetti  v1.0  (2020-01-13)
  set cmdheight=4                                                               " évite le 'Hit ENTER to continue'
  echohl WarningMsg | echom 'DEBUG : AlignDroite() commence' |                  " ecriture en rouge
  echon '                   [:mess {clear} pour historique]' |                  " sur la même ligne
  " 1. xyz...... devient ......xyz
  set virtualedit=all                                                           " peut aller où il n'y a pas de lettres
  :execute "normal! 079lvbelr." |                                               " avance de 79 pour arriver à 80
  " 2. xyz...... devient ......xyz
  :execute "normal! d$0P"
  " 3. ......xyz devient       xyz
  :s/\./ /g
  echom 'DEBUG : AlignDroite() fini' | echohl None                              " retour au blanc
  return
endfunction
nnoremap <Leader>ad  :call AlignDroite()<CR>
" }}}
" CompilePandoc(format) {{{2
function! CompilePandoc(format) 
    let l:debug = "no"
    if exists("g:loaded_dispatch")
        if l:debug == "yes"
"           DEBUG {{{3
            echom 'DEBUG CompilePandoc() : Dispatch -- START'
            echom "DEBUG CompilePandoc() -- fichier d'entrée : "              . expand('%')
"           echom "DEBUG CompilePandoc() -- chemin du fichier d'entrée : "    . expand('%:p')
"           echom "DEBUG CompilePandoc() -- racine du fichier d'entrée : "    . expand('%:r')
"           echom "DEBUG CompilePandoc() -- extension du fichier d'entrée : " . expand('%:e')
"           echom 'DEBUG CompilePandoc() -- nom du fichier de sortie : '      . expand('%') . ".html"
"           Dispatch! pandoc % > output.html
"           Dispatch! pandoc % -o output.html -s
"           Dispatch! pandoc % -o %.html --toc --standalone --mathjax --template blue-toc.html5           --css $HOME/.pandoc/templates/stylesheets/blue-toc.css
"
"           BUG : soit --mathjax soit --toc
"
"           ERROR
"           Dispatch! pandoc % -o %.html -s --mathjax -toc --toc-depth 3 --template github.html5             --css $HOME/.pandoc/templates/stylesheets/github.css
"           ERROR
"           Dispatch! pandoc % -o %.html -s --latexmathml
"           SUCCESS : soit --mathjax soit --toc
"           Dispatch! pandoc % -o %.html -s --mathjax
"           Dispatch! pandoc % -o %.html -s --mathjax           --template github.html5    --css $HOME/.pandoc/templates/stylesheets/github.css
"           Dispatch! pandoc % -o %.html -s --mathjax           --template blue-toc.html5  --css $HOME/.pandoc/templates/stylesheets/blue-toc.css
"           Dispatch! pandoc % -o %.html -s --mathjax                                      --css $HOME/.pandoc/templates/stylesheets/typora/night.css
"           TOC top
"             blog
"             notes
"             wiki / Fiches
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3 --template github.html5             --css $HOME/.pandoc/templates/stylesheets/github.css
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3 --template github.html5             --css $HOME/.pandoc/templates/stylesheets/bootstrap.css
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3                                     --css $HOME/.pandoc/templates/stylesheets/marked.css
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3                                     --css $HOME/.pandoc/templates/stylesheets/typora/night.css
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3                                     --css $HOME/.pandoc/templates/stylesheets/typora/gothic.css    
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3                                     --css $HOME/.pandoc/templates/stylesheets/typora/newsprint.css 
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3                                     --css $HOME/.pandoc/templates/stylesheets/typora/whitey.css    
"           TOC side (mieux en haut)
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3 --template blue-toc.html5           --css $HOME/.pandoc/templates/stylesheets/blue-toc.css
"           Dispatch! pandoc % -o %.html -s                                                         --css $HOME/.pandoc/templates/stylesheets/blue-toc.css
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3 --template bootstrap-adaptive.html5 --css $HOME/.pandoc/templates/stylesheets/bootstrap-adaptive.css
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3 --template bootstrap.html5          --css $HOME/.pandoc/templates/stylesheets/bootstrap.css
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3 --template uikit.html5              --css $HOME/.pandoc/templates/stylesheets/uikit.css
"           Dispatch! pandoc % -o %.html -s --toc --toc-depth 3                                     --css $HOME/.pandoc/templates/stylesheets/bootstrap.css
            Dispatch! open %:r.html
"           Dispatch! open %.html
"           return
"           }}} 
        else
            if a:format == "html"
"               pandoc -o %:r.html {{{3 
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --template github.html5             --css $HOME/.pandoc/templates/stylesheets/github.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 2 --template blue-toc.html5           --css $HOME/.pandoc/templates/stylesheets/blue-toc.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --template uikit.html5              --css $HOME/.pandoc/templates/stylesheets/uikit.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --template bootstrap-adaptive.html5 --css $HOME/.pandoc/templates/stylesheets/bootstrap-adaptive.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --template bootstrap.html5          --css $HOME/.pandoc/templates/stylesheets/bootstrap.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --template github.html5             --css $HOME/.pandoc/templates/stylesheets/github-v1.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --template github.html5             --css $HOME/.pandoc/templates/stylesheets/github.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --template github.html5             --css $HOME/.pandoc/templates/stylesheets/typora/github.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --css $HOME/.pandoc/templates/stylesheets/marked.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --css $HOME/.pandoc/templates/stylesheets/typora/night.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --css $HOME/.pandoc/templates/stylesheets/typora/gothic.css
                Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --css $HOME/.pandoc/templates/stylesheets/typora/newsprint.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --css $HOME/.pandoc/templates/stylesheets/typora/pixyll.css
"               Dispatch! pandoc % -o %:r.html -t html5 -f markdown -s --latexmathml -toc --toc-depth 3 --css $HOME/.pandoc/templates/stylesheets/typora/whitey.css
                Dispatch! open %.html
"               }}} 
            elseif a:format == "pdf"
"               pandoc -o %:r.pdf {{{3 
                Dispatch! pandoc % -o %:r.pdf --from markdown --template eisvogel --listings
                Dispatch! open %:r.pdf
"               }}} 
            endif
        endif
    else
"       pandoc par makeprg {{{3
        echom 'DEBUG CompilePandoc() : makeprg -- START'
        set makeprg=pandoc\ %:r.md\ --from\ markdown\ --to\ html5\ -s\ -o\ %:r.html
        set makeprg+=\ --toc\ --toc-depth\ 3\ --latexmathml
"       set makeprg+=\ --template\ blue-toc.html5\ --css\ $HOME/.pandoc/templates/stylesheets/blue-toc.css
"       set makeprg+=\ --template\ uikit.html5\ --css\ $HOME/.pandoc/templates/stylesheets/uikit.css
"       set makeprg+=\ --template\ bootstrap-adaptive.html5\ --css\ $HOME/.pandoc/templates/stylesheets/bootstrap-adaptive.css
"       set makeprg+=\ --template\ bootstrap.html5\ --css\ $HOME/.pandoc/templates/stylesheets/bootstrap.css
"       set makeprg+=\ --template\ github.html5\ --css\ $HOME/.pandoc/templates/stylesheets/github.css
"       set makeprg+=\ --template\ github.html5\ --css\ $HOME/.pandoc/templates/stylesheets/github-v1.css
        set makeprg+=\ --template\ github.html5\ --css\ $HOME/.pandoc/templates/stylesheets/typora/github.css
"       set makeprg+=\ --css\ $HOME/.pandoc/templates/stylesheets/marked.css
"       set makeprg+=\ --css\ $HOME/.pandoc/templates/stylesheets/typora/night.css
"       set makeprg+=\ --css\ $HOME/.pandoc/templates/stylesheets/typora/gothic.css
"       set makeprg+=\ --css\ $HOME/.pandoc/templates/stylesheets/typora/newsprint.css
"       set makeprg+=\ --css\ $HOME/.pandoc/templates/stylesheets/typora/pixyll.css
"       set makeprg+=\ --css\ $HOME/.pandoc/templates/stylesheets/typora/whitey.css
        make!
        !open %:r.html
        echom "SUCESS : fonction CompilePandoc() par make interne à VIM terminé"
        echom "       : utilisation de copen"
        copen
"       }}}
    endif
endfunction
nnoremap  <Leader>md     :execute CompilePandoc("pdf")<CR>
"}}}
" MonFoldText() {{{2
function! MonFoldText() 
  let line = getline(v:foldstart)
  let sub = substitute(line, '/\*\|\*/\|{{{\d\=', '', 'g')
  return v:folddashes . sub
endfunction
" }}}
"}}}
" EffaceMapping() {{{2
function! EffaceMapping() 
" MARCHE PAS ENCORE --> essai de la fonction :mapclear
" Avec les sorties de nmap
  silent! unmap <C-P>                  "   <Plug>(ctrlp)
  silent! unmap <C-T>p                 " * <C-T>
  silent! unmap <C-T>n                 " * <C-]>
  silent! unmap '?                     " & :<C-U>echo ":Start" get(b:,"start",&shell)<CR>
  silent! unmap '!                     " & <SNR>45_:.Start!
  silent! unmap '<Space>               " & <SNR>45_:.Start<Space>
  silent! unmap '<CR>                  " & <SNR>45_:.Start<CR>
" silent! unmap ,cd                    " * :cd %:p:h<Esc>
" silent! unmap ,bo                    " * :browse oldfile<Esc>
" silent! unmap ,bb                    " * :b#<Esc>
" silent! unmap ,n                     " * :NERDTreeToggle<Esc>
" silent! unmap ,es                    " * :e ~/.vim/spell/fr.utf-8.add<Esc>
" silent! unmap ,et                    " * :e ~/.tmux.conf<Esc>
" silent! unmap ,ez                    " * :e ~/.zshrc<Esc>
" silent! unmap ,ev                    " * :e ~/.vimrc<Esc>
" silent! unmap ,<Space>               " * :nohlsearch<CR>
  silent! unmap `?                     " & <SNR>45_:.FocusDispatch<CR>
  silent! unmap `!                     " & <SNR>45_:.Dispatch!
  silent! unmap `<Space>               " & <SNR>45_:.Dispatch<Space>
  silent! unmap `<CR>                  " & <SNR>45_:.Dispatch<CR>
  silent! unmap cS                     "   <Plug>CSurround
  silent! unmap cs                     "   <Plug>Csurround
  silent! unmap ds                     "   <Plug>Dsurround
  silent! unmap g`?                    " & :<C-U>echo ":Spawn" &shell<CR>
  silent! unmap g`!                    " & <SNR>45_:.Spawn!
  silent! unmap g`<Space>              " & <SNR>45_:.Spawn<Space>
  silent! unmap g`<CR>                 " & <SNR>45_:.Spawn<CR>
  silent! unmap g'?                    " & :<C-U>echo ":Spawn" &shell<CR>
  silent! unmap g'!                    " & <SNR>45_:.Spawn!
  silent! unmap g'<Space>              " & <SNR>45_:.Spawn<Space>
  silent! unmap g'<CR>                 " & <SNR>45_:.Spawn<CR>
  silent! unmap m?                     " & :<C-U>echo ":Dispatch" dispatch#make_focus(v:count > 1 ? 0 : v:count ? line(".") : -1)<CR>
  silent! unmap m!                     " & <SNR>45_:.Make!
  silent! unmap m<Space>               " & <SNR>45_:.Make<Space>
  silent! unmap m<CR>                  " & <SNR>45_:.Make<CR>
" silent! unmap ySS                    "   <Plug>YSsurround
" silent! unmap ySs                    "   <Plug>YSsurround
" silent! unmap yss                    "   <Plug>Yssurround
" silent! unmap yS                     "   <Plug>YSurround
" silent! unmap ys                     "   <Plug>Ysurround
" silent! unmap zS                     " * [s
" silent! unmap zs                     " * ]s
" silent! unmap <Plug>YSurround        "  * <SNR>46_opfunc2('setup')
" silent! unmap <Plug>Ysurround        "  * <SNR>46_opfunc('setup')
" silent! unmap <Plug>YSsurround       "  * <SNR>46_opfunc2('setup').'_'
" silent! unmap <Plug>Yssurround       "  * '^'.v:count1.<SNR>46_opfunc('setup').'g_'
" silent! unmap <Plug>CSurround        "  * :<C-U>call <SNR>46_changesurround(1)<CR>
" silent! unmap <Plug>Csurround        "  * :<C-U>call <SNR>46_changesurround()<CR>
" silent! unmap <Plug>Dsurround        "  * :<C-U>call <SNR>46_dosurround(<SNR>46_inputtarget())<CR>
" silent! unmap <Plug>SurroundRepeat   "  * .
" silent! unmap <SNR>45_:.             "  & :<C-R>=getcmdline() =~ ',' ? "\0250" : ""<CR>
" silent! unmap <Plug>(ctrlp)          "  * :<C-U>CtrlP<CR>
" silent! unmap <Plug>NetrwBrowseX     "  * :call netrw#BrowseX(expand((exists("g:netrw_gx")? g:netrw_gx : '<cfile>')),netrw#CheckIfRemote())<CR>
" silent! unmap <D-v>
endfunction
" }}}
" s:align() {{{2
function! s:align() 
  " par tpope : aligne les barres d'une table
  " utilisé par le mapping inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction "}}}
" Modele() "{{{2
function! Modele()
  " Fonction: snippet d'une fonction vimscript
  " Julien Borghetti  v1.0  (2020-01-13)
  set cmdheight=4                                                               " évite le 'Hit ENTER to continue'
  echohl WarningMsg | echom 'DEBUG : Modele() commence' |                       " ecriture en rouge
  echon '                        [:mess {clear} pour historique]' |             " sur la même ligne
  "
  " Code
  "
  echom 'DEBUG : Modele() fini' | echohl None                                   " retour au blanc
  return
endfunction
nnoremap <Leader>tt  :call Modele()<CR>
"}}}
" SaveAndExecutePython() {{{2
let s:buf_nr = -1
function! SaveAndExecutePython()
    " SOURCE [reusable window]: https://github.com/fatih/vim-go/blob/master/autoload/go/ui.vim
    " save and reload the current file
    silent execute "update | edit"
    " get file path of current file
    let s:current_buffer_file_path = expand("%")
    let s:output_buffer_name = "Python"
    let s:output_buffer_filetype = "output"
    " reuse existing buffer window if it exists otherwise create a new one
    if !exists("s:buf_nr") || !bufexists(s:buf_nr)
        silent execute 'botright new ' . s:output_buffer_name
        let s:buf_nr = bufnr('%')
    elseif bufwinnr(s:buf_nr) == -1
        silent execute 'botright new'
        silent execute s:buf_nr . 'buffer'
    elseif bufwinnr(s:buf_nr) != bufwinnr('%')
        silent execute bufwinnr(s:buf_nr) . 'wincmd w'
    endif
    silent execute "setlocal filetype=" . s:output_buffer_filetype
    setlocal bufhidden=delete
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nobuflisted
    setlocal winfixheight
    setlocal cursorline " make it easy to distinguish
    setlocal nonumber
    setlocal norelativenumber
    setlocal showbreak=""
    " clear the buffer
    setlocal noreadonly
    setlocal modifiable
    setlocal nospell
    %delete _
    " add the console output
    silent execute ".!python " . shellescape(s:current_buffer_file_path, 1)
    " resize window to content length
    " Note: This is annoying because if you print a lot of lines then your code buffer is forced to a height of one line every time you run this function.
    "       However without this line the buffer starts off as a default size and if you resize the buffer then it keeps that custom size after repeated runs of this function.
    "       But if you close the output buffer then it returns to using the default size when its recreated
    "execute 'resize' . line('$')
    " make the buffer non modifiable
    setlocal readonly
    setlocal nomodifiable
endfunction

"}}}
" SaveAndExecutePdfLaTeX() {{{2
let s:buf_nr = -1
function! SaveAndExecutePdfLaTeX()
    " SOURCE [reusable window]: https://github.com/fatih/vim-go/blob/master/autoload/go/ui.vim
    " save and reload the current file
    silent execute "update | edit"
    " get file path of current file
    let s:current_buffer_file_path = expand("%")
    let s:output_buffer_name = "pdfLaTeX"
    let s:output_buffer_filetype = "output"
    " reuse existing buffer window if it exists otherwise create a new one
    if !exists("s:buf_nr") || !bufexists(s:buf_nr)
        silent execute 'botright new ' . s:output_buffer_name
        let s:buf_nr = bufnr('%')
    elseif bufwinnr(s:buf_nr) == -1
        silent execute 'botright new'
        silent execute s:buf_nr . 'buffer'
    elseif bufwinnr(s:buf_nr) != bufwinnr('%')
        silent execute bufwinnr(s:buf_nr) . 'wincmd w'
    endif
    silent execute "setlocal filetype=" . s:output_buffer_filetype
    setlocal bufhidden=delete
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nobuflisted
    setlocal winfixheight
    setlocal cursorline
    setlocal nonumber
    setlocal norelativenumber
    setlocal showbreak=""
    setlocal nospell
"
    setlocal noreadonly
    setlocal modifiable
    %delete _
    " add the console output
    " [http://vim.wikia.com/wiki/Append_output_of_an_external_command]
    silent execute ".!latexmk -pdf -pv -latexoption=-shell-escape " . shellescape(s:current_buffer_file_path, 1)
    setlocal nomodifiable
endfunction

"}}}
" WipeReg {{{2
command! WipeReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor "}}}
" Async jobs {{{2
" This callback will be executed when the entire command is completed
function! SaveAndExecutePdfLaTeX2()
    echom "coucou"
    " save and reload the current file
"    silent execute "update | edit"
    " get file path of current file
"    let s:current_buffer_file_path = expand("%")
    " execute la commande shell qui compile
"    execute ".!latexmk -pdf -pv -latexoption=-shell-escape " . shellescape(s:current_buffer_file_path, 1)
endfunction

function! BackgroundCommandClose(channel)
  " Read the output from the command into the quickfix window
  execute "cfile! " . g:backgroundCommandOutput
  " Open the quickfix window
  copen
  unlet g:backgroundCommandOutput
endfunction

function! RunBackgroundCommand(command)
  " Make sure we're running VIM version 8 or higher.
  if v:version < 800
    echoerr 'RunBackgroundCommand requires VIM version 8 or higher'
    return
  endif

  if exists('g:backgroundCommandOutput')
    echo 'Already running task in background'
  else
    echo 'Running task in background'
    " Launch the job.
    " Notice that we're only capturing out, and not err here. This is because, for some reason, the callback
    " will not actually get hit if we write err out to the same file. Not sure if I'm doing this wrong or?
    let g:backgroundCommandOutput = tempname()
    call job_start(a:command, {'close_cb': 'BackgroundCommandClose', 'out_io': 'file', 'out_name': g:backgroundCommandOutput})
  endif
endfunction

"}}}
" tests {{{2
" Pourquoi cette lignes ? 2020-01-09
"command! -nargs=+ -complete=shellcmd RunBackgroundCommand call RunBackgroundCommand(<q-args>)
"}}} "}}}
" MAPPINGS: {{{1
" Parametres:{{{2
" :map
" :verbose map ,
let mapleader = ","
let maplocalleader = "\<Space>"
set timeoutlen=1000                               "  mapping timeout en [ms]
set ttimeoutlen=10                                "  timeout after <Esc> [ms]
mapclear
nnoremap ;               .
inoremap jk              <esc>
vnoremap jk              <esc>
"}}}
" Debuging: {{{2
" source script under cursor
nnoremap <Leader>so      Y:@"<CR>
vnoremap <Leader>so      y:@"<CR>
nnoremap <Leader>wso    :w<CR>:so % <CR>

" cmdheight (default=1)
nnoremap <Leader>1      :set cmdheight=1<CR>
nnoremap <Leader>2      :set cmdheight=2<CR>
nnoremap <Leader>3      :set cmdheight=3<CR>
nnoremap <Leader>4      :set cmdheight=4<CR>
nnoremap <Leader>5      :set cmdheight=5<CR>

" test de colorscheme
nnoremap <Leader>sc     :packadd ScrollColor<CR>:SCROLLCOLOR<CR>

" rebuild all tags
nnoremap <Leader>ht     :helptags ALL<CR> " faire un diff on every window nnoremap <Leader>diff   :windo difft<CR> " fugitive " [MANUEL](https://git-scm.com/book/en/v2) "nnoremap <Leader>gr    :!git reset --hard HEAD                             " reset repertoire de travail to last commit "}}}
" Navigating:{{{2


" stop surlignage
nnoremap <Leader><space> :nohlsearch<CR>

"scroll
noremap <C-j> 10jzz
noremap <C-k> 10kzz

" Browsing
"    map  CTRL-P         fzf pluging
"nnoremap <Leader>n       :NERDTreeToggle<Esc>
nnoremap <Leader>n       :30vs .<CR>              " use internal netrw plugin [BLOG](https://shapeshed.com/vim-netrw/)
"nnoremap <Leader>bb ":b#<Esc>                    " obsolète :  CTRL-^ switch to the alternate file
nnoremap <Leader>bo      :browse oldfile<CR>     " :bro oldfiles
"
" aliad to ~/.vim
cabbrev cdv             cd ~/.vim

" [working directory](https://vim.fandom.com/wiki/Set_working_directory_to_the_current_file)
" - un global current directory
" - un local  current directory par windown
" :echo expand("%:p")                             " fichier
" :echo expand("%:p:h")                           " chemin
nnoremap <Leader>cd      :cd %:p:h<Esc>           " set working directory de toutes les windows
nnoremap <Leader>lcd     :lcd %:p:h<Esc>          " set working directory de la window active

" Tags
"mapping obsolètes : en fait <c-]> = <c-$> sur AZERTY
"nnoremap <c-t>n          <c-]>                 " <c-]> = <c-$> sur AZERTY
"nnoremap <c-t>p          <c-t>                 " ^ sur AZERTY

" Marks                                         " :help mark-motions
nnoremap <Leader>ml      :marks<CR>
nnoremap <Leader>md      :delmarks a-z<CR>      " minuscule : single file
nnoremap <Leader>mD      :delmarks A-Z<CR>      " majuscule : global
"if exists(":SignatureToggleSigns")              " plugin: vim-signature
  nnoremap <Leader>st      :SignatureToggleSigns<Esc>
  nnoremap <Leader>sr      :SignatureRefresh<Esc>
  nnoremap <Leader>sl      :SignatureListBufferMarks<Esc>
  nnoremap <Leader>sL      :SignatureListGlobalMarks<Esc>
"endif
"}}}
" Editing:{{{2

" Invisible characters : on/off
nnoremap <Leader>l       :set list!<CR>                                         

" Spelling
nnoremap <Leader>z       :set spell<CR>
nnoremap <Leader>Z       :set nospell<CR>
nnoremap zs              ]s
nnoremap zS              [s

" Comments
" -- Methode 1 - normal mode
nnoremap  <Leader>cc     :s/^/"/<CR>:nohls<CR>
nnoremap  <Leader>cu     :s/^"//<CR>:nohls<CR>
" -- Methode 2 - visual mode
"autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
"autocmd FileType sh,ruby,python   let b:comment_leader = '# '
"autocmd FileType conf,fstab       let b:comment_leader = '# '
"autocmd FileType tex              let b:comment_leader = '% '
"autocmd FileType mail             let b:comment_leader = '> '
"autocmd FileType vim              let b:comment_leader = '" '
"noremap <silent> <Leader>cc     :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
"noremap <silent> <Leader>cu     :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

" Format paragraph
nnoremap <Leader>gw      gwap
nnoremap <Leader>gq      gqap

" Tabularize                                    " :help Tabular.txt
"if exists(":Tabularize")                        " plugin : tabular
  noremap <Leader>t,     :Tabularize /,<CR>
  noremap <Leader>t&     :Tabularize /&<CR>
  noremap <Leader>t=     :Tabularize /=<CR>
  noremap <Leader>t<Bar> :Tabularize /<Bar><CR>
  noremap <Leader>t:     :Tabularize /:<CR>              " (defaults on) :Tabularize /:/l1<CR> je crois
  " doc: CENTERING left/center/right {{{
  " 1 -- Chaine de test
  " abc,def,ghi
  " a,b
  " a,b,c
  " 
  " 2 -- alignements lcr
  " :Tabularize /,/l0<CR>
  " abc,def,ghi
  " a  ,b
  " a  ,b  ,c
  " :Tabularize /,/c0<CR>
  " abc,def,ghi
  "  a , b
  "  a , b , c
  " :Tabularize /,/r0<CR>
  " abc,def,ghi
  "   a,  b
  "   a,  b,  c
  "
  " 3 --  espaces et répétitions des lcr
  "   --  l/c/r s'affectent aux champs et au patterns
  " :Tabularize /,<CR>
  " :Tabularize /,/l1<CR>
  " :Tabularize /,/l1c1<CR>
  " :Tabularize /,/l1l1<CR>
  " abc , def , ghi
  " a   , b
  " a   , b   , c
  " 
  " :Tabularize /,/l0c1<CR>
  " abc, def, ghi
  " a  , b
  " a  , b  , c
  " :Tabularize /,/r0c1l0<CR>     (PROBLEME)
  " abc, def,ghi
  "   a, b
  "   a, b  , c
  " :Tabularize /,/r0c1l0c1l0<CR> (SOLUTION)
  " abc, def, ghi
  " a  , b
  " a  , b  , c

  " }}}
  " doc: FIRST MATCH ONLY {{{
  "    Here, we use a Vim regex that would only match the first colon on the line.
  "    It matches the beginning of the line, followed by all the non-colon characters
  "    up to the first colon, and then forgets about what it matched so far and
  "    pretends that the match starts exactly at the colon.
  "}}}
  " aligne les : des [Nom : titre](lien) en markdown
  noremap <Leader>tf:    :Tabularize /^[^:]*\zs/l1c0<CR> " align first :  / (left+1space)  ; (center+0space)
  " aligne les ]( des [Nom : titre](lien) en markdown
  noremap <Leader>t]     :Tabularize /^[^]]*\zs/l0c0<CR> " align first ]  / (left+0space)  ; (center+0space)
  " meme chose grace à une TabularPattern défini ci-après
  noremap <Leader>tml    :Tabularize markdown_liens<CR>  " AddTabularPattern défini ci dessous
 " Table
 " -- alignement des | automatique
 " -- tpope
  inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a
"endif
"}}}
" Particular_Files:{{{2
" ConfigFiles
nnoremap <Leader>ev      :e ~/.vim/vimrc<CR>
nnoremap <Leader>ez      :e ~/.zshrc<Esc>
nnoremap <Leader>el      :e ~/.vim/after/ftplugin/tex/tex.vim<Esc>
nnoremap <Leader>es      :e ~/.vim/spell/fr.utf-8.add<Esc>
nnoremap <Leader>ej      :e $HOME/Library/texmf/tex/latex/julien04.sty<Esc>
"
" Wiki
nnoremap <Leader>wp      :e ~/Documents/wiki/Index.md<CR>
nnoremap <Leader>ww      :e ~/Documents/EN/cours/admin/wiki/Index.md<CR>
nnoremap <Leader>wf      :put =expand('%:p')<CR>
"
" LaTeX
" voir $HOME/.vim/ftdetect/tex.vim
" voir $HOME/.vim/after/ftplugin/tex/tex.vim
nnoremap <Leader>rt      :-1r $HOME/.vim/julien/template/latex/template.tex<CR>
"
" Markdown
" nnoremap <Leader>mdf     :%!~/.vim/tools/Markdown.pl --html4tags<CR> | set ro 
" nnoremap <Leader>md      :execute "!~/.vim/tools/Markdown.pl --html4tags % > %.html && open %.html " <CR>

"}}} "}}}
" AUTOCMD: Tmux, Focus, Vimrc, Python, Markdown, LaTeX {{{1
" Tmux: {{{2
augroup Tmux
  autocmd!
  if exists('$TMUX')
    autocmd BufNewFile,BufEnter * call system("tmux rename-window 'vim| " . expand("%:t") . "'")    " renomme la 'tmux window'
    autocmd VimLeave            * call system("tmux setw automatic-rename on")
  endif
augroup END
"}}}
" Focus: {{{2
augroup Focus
    autocmd!
    autocmd FocusLost,WinLeave *                          let &l:colorcolumn=join(range(1, 255), ',')                  " surligne les colonnes 1 à 255
    autocmd BufEnter,FocusGained,VimEnter,WinEnter *      let &l:colorcolumn=+0                                        " surligne la colonne 0 qui n'est pas affichée (pour desactiver en fait)
augroup END
"}}}
" Vimrc: {{{2
augroup VimRC
  autocmd!
" debug:
" autocmd BufRead *.vimrc             nnoremap <buffer> <leader>p       :echo "coucou leader"<CR>
" autocmd BufRead *.vimrc             nnoremap <buffer> <localleader>p  :echo "coucou local-leader"<CR>
  autocmd FileType vim                :packadd tabular<CR>
  autocmd BufNewFile,BufRead  *.vim   :%s/\s\+$//e            " supprime les Trailing Whitespaces       
  autocmd BufWritePre         *.vim   :%s/\s\+$//e            " supprime les Trailing Whitespaces
" autocmd BufNewFile,BufRead  *.vim   vnoremap <Leader>c  :'<,'>s/^/"/<CR>
augroup END 
"}}}
" Python: {{{2
augroup Python
   autocmd!
   autocmd BufNewFile,BufRead *.py  nnoremap <buffer> <localleader>P  : <C-u>call SaveAndExecutePython()<CR>
   autocmd BufNewFile,BufRead *.py  nnoremap <buffer> <localleader>p  : <C-u>call SaveAndExecutePython()<CR>
   autocmd BufWritePre        *.py    :%s/\s\+$//e              " supprime les Trailing Whitespaces
augroup END
"}}}
" LaTeX: {{{2
" <leader> el
" voir $HOME/.vim/ftdetect/tex.vim
" voir $HOME/.vim/after/ftplugin/tex/tex.vim
" Pas sûr que tout ça marche bien !
augroup Latex
"  commandes mises dans .vim/ftdetext/tex.vim ; ca marche ?
"  autocmd!
"  autocmd BufNewFile,BufRead *.tex  set ft=tex
"  autocmd BufNewFile,BufRead *.snip set ft=tex
"  autocmd BufWritePre        *.tex :%s/\s\+$//e
augroup END
"}}} "}}}
" PLUGINS: {{{1
" DOC: {{{2
" :scriptnames
" :helptags ALL
" vim --startuptime file.log
" set rtp?                                       " runtimepath
" }}}
" STARTING_PLUGINS: {{{2
" $HOME/.vim/pack/lesplugins/start
" Plugin: base16-vim
" Plugin: ctrlp
" Plugin: lightline {{{3
" set noshowmode                                    " pas écrire -- INSERT --
let g:lightline = {
    \ 'colorscheme': 'Tomorrow_Night_Bright',
    \ }
let g:lightline.tabline = {
    \ 'left': [ [ 'tabs' ] ],
    \ 'right': [ [ '' ] ] ,
    \ }                                             " efface la croix à droite
let g:lightline.tab = {
    \ 'active': [ 'tabnum', 'filename', 'modified' ],
    \ 'inactive': [ 'tabnum', 'filename', 'modified' ] }
"
" }}}
" Plugin: netrw {{{3
" -- [TUTO](http://vimcasts.org/episodes/the-file-explorer/)
" -- :help pi_netrw.txt

let g:netrw_banner = 1               " 0:remove 1:keep                      " I toggle banner
let g:netrw_liststyle = 3            " 1:thin 2:long 3:wide 4:tree          " i cycle view types
" how are openned files
let g:netrw_browse_split = 4         " 1:hs 2:vs 3:tab 4:previous window    " p preview <c-W>z close
let g:netrw_altv = 1                 " change left to right splitting
let g:netrw_winsize = 25             " 25% de la page
"augroup ProjectDrawer
"  autocmd!
"  autocmd VimEnter * :Vexplore
"augroup END
" 
""}}}
" Plugin: nnn {{{3
"
" 1. CUSTOM MAPPINGS
" Disable default mappings
let g:nnn#set_default_mappings = 0
" Then set your own
nnoremap <silent> <leader>nn :NnnPicker<CR>
" Or override
" Start nnn in the current file's directory
nnoremap <leader>n :NnnPicker '%:p:h'<CR>

" 2. LAYOUT
" Opens the nnn window in a split
"let g:nnn#layout = 'new' " or vnew, tabnew etc.
" Or pass a dictionary with window size
"let g:nnn#layout = { 'left': '~20%' } " or right, up, down
let g:nnn#layout = { 'left': '20%' } " or right, up, down
" Floating window (neovim latest and vim with patch 8.2.191)
"let g:nnn#layout = { 'window': { 'width': 0.9, 'height': 0.6, 'highlight': 'Debug' } }

" 3. ACTION
"let g:nnn#action = {
"      \ '<c-t>': 'tab split',
"      \ '<c-x>': 'split',
"      \ '<c-v>': 'vsplit' }

"}}}
" Plugin: tabular {{{3
if exists(":Tabularize")
"   But, now that this command does exactly what we want it to, it's become pretty
"   unwieldy.  It would be unpleasant to need to type that more than once or
"   twice.  The solution is to assign a name to it.
    AddTabularPattern! first_comma_left  /^[^,]*\zs,/l1c0
    AddTabularPattern! first_comma_right /^[^,]*\zs,/r1c0
    AddTabularPattern! markdown_liens /^[^]]*\zs/l0c0
endif "}}}
" Plugin: vim-dispatch {{{3
" commandes externes dans tmux
" QuickFix par :Copen
let g:dispatch_no_maps = 1                       " no new maps
"}}}
" Plugin: vim-fugitive {{{3
" File lifecycle :       Unmodified | Modified | Staged
" -- [SOURCE](https://github.com/tpope/vim-fugitive)
" -- [BOOK](https://git-scm.com/book/en/v2)
" -----------------------------
" 0. Unmodified -->  Modified -->  Staged  (v.s. parent commit)
" :G                           git status
"      -                       toggle modified / stagged
"      g?                      show fugitive-maps
"      gq                      close status buffer
"      gq                      close status buffer
" -----------------------------
" 1. Modified                  1 buffer
"                              [TUTO](http://vimcasts.org/episodes/fugitive-vim---a-complement-to-command-line-git/)
" :Gedit                       view staged
" :Gread                       view last commit
" :Gwrite                      add modification to stage (git add %)
" -----------------------------
" 2. Modified <--> Staged      
" 2.1 Split diff               [TUTO](http://vimcasts.org/episodes/fugitive-vim-working-with-the-git-index/)
" :Gdiff                       diff entre Modified et staged
"      :Gwrite :Gread          global reconciliation
"      :diffget :diffput       local reconciliation
" 2.2 In line diff             [TUTO](https://www.youtube.com/watch?v=2KqNqk6oV6Q)
" =                            les diff apparaissent
" -----------------------------
" 3. Unmodified v.s. Staged    
" :G                           git status
"      D                       git diff --cached [stackoverflow](https://stackoverflow.com/questions/15407652/how-can-i-run-git-diff-staged-with-fugitive)
" :Gcommit                     commit
"
" }}}
" Plugin: vim-signature {{{3
" markers dans la marge
" :SignatureToggleSigns       voir MAPPINGS
" :SignatureListBufferMarks   voir MAPPINGS
let g:SignatureMap = {
    \ 'Leader'             :  "m",
    \ 'PlaceNextMark'      :  "",
    \ 'ToggleMarkAtLine'   :  "m.",
    \ 'PurgeMarksAtLine'   :  "m-",
    \ 'DeleteMark'         :  "dm",
    \ 'PurgeMarks'         :  "m<Space>",
    \ 'PurgeMarkers'       :  "m<BS>",
    \ 'GotoNextLineAlpha'  :  "",
    \ 'GotoPrevLineAlpha'  :  "",
    \ 'GotoNextSpotAlpha'  :  "",
    \ 'GotoPrevSpotAlpha'  :  "",
    \ 'GotoNextLineByPos'  :  "",
    \ 'GotoPrevLineByPos'  :  "",
    \ 'GotoNextSpotByPos'  :  "",
    \ 'GotoPrevSpotByPos'  :  "",
    \ 'GotoNextMarker'     :  "",
    \ 'GotoPrevMarker'     :  "",
    \ 'GotoNextMarkerAny'  :  "",
    \ 'GotoPrevMarkerAny'  :  "",
    \ 'ListBufferMarks'    :  "m/",
    \ 'ListBufferMarkers'  :  "m?"
    \ }
" }}} 
" Plugin: startscreen  {{{3
function! T()
    set ft=help
    " Read on our TODO file
    " read ~/TODO
    read !fortune | cowsay

    " Some margin for readability
    :silent %>>

    read ~/.vim/doc/intro.txt 

    " Go to line 1
    :1
    
    " open ntrw file browser
    ":Vexplore
"   :normal <C-w> l
endfun
let g:Startscreen_function = function('T')
"}}}   "}}}
" OPTIONAL_PLUGINS: {{{2
" $HOME/.vim/pack/lesplugins/opt
" [TUTO submodules](http://vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/)
" gruvbox
" grammarous-vim
" vim-surround
" ScrollColor                                    " tester les colorscheme installés
" }}} " }}}

command! -nargs=+ -complete=shellcmd RunBackgroundCommand call RunBackgroundCommand(<q-args>)


" vim: foldmethod=marker : foldlevel=1 : modifiable : virtualedit=all : noma
