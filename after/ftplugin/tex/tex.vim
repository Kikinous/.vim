" Auteur: Julien Borghetti
" Sujet: Edition de LaTeX
" Doc: $texdoc article
" Todo:
"   1. par (port install par) pour formater avec gq formatprg (vimcast #18)
"   2. hard and soft wrapping vimcast #16 et #17
"   3. formatiing text : move to phrase par lignes, par, par justifie, pas de par. (vimcast 16,17,18)
"   5. focus function de greg hurrel
"   4. - lacheck ? (chktex vs lacheck)
"
augroup ParametresLaTeX

  " Hacks {{{1
  let @r="lyiwmaf{%0i\endjka{jkpjk'aabegin{jkf{r}0jk"                          " refactor julien03 en julien04 (commandes ->environment pour theoreme definition...)

"}}}

  " Divers: {{{1
  " ========
  "
  execute "packadd tabular"
  setlocal spell               " zg, zw, z=
  let g:tex_comment_nospell=1  " no spell check in comments
" par options {{{
" w - specify line length
" r - repeat characters in bodiless lines
" j - justifies text
" e - remove ‘superflous’ lines
" q - handle nested quotations in plaintext email }}}
  " fmt et par formattent des paragraphes. par gere le C
  set formatprg=par\ -w72\ -h " default=72
" Script pour les tabular : https://vim.fandom.com/wiki/Create_LaTeX_Tables

" nnoremap <Localleader>y :echom "coucou de .vim/after/ftplugin/tex/tex.vim suite a un FileType"<CR>
" set foldmarker={{{,}}},\\section,\\exo,\\exoPoints,\\exoComp,\\exoCompPoints
  "
"}}}
  "
  " Plugins_pour_LaTeX: {{{1
  " ==================
  " "
  execute "packadd tabular"
  "   -> https://github.com/rhysd/vim-grammarous
  execute "packadd vim-grammarous"
  nnoremap <LocalLeader>g   :GrammarousCheck --lang=fr<CR>
  nmap     <Space>w         <Plug>(grammarous-move-to-info-window)
  nmap     <Space>o         <Plug>(grammarous-open-info-window)
  nmap     <Space>r         <Plug>(grammarous-disable-rule)
  nmap     <Space>n         <Plug>(grammarous-move-to-next-error)
  nmap     <Space>p         <Plug>(grammarous-move-to-previous-error)
  nmap     <Space>eu        :edit $HOME/.vim/julien/UltiSnips/tex.snippets
" let g:grammarous#disabled_categories = {                                                    {{{
"           \ '*' : ['PUNCTUATION', 'TYPOGRAPHY'],
"           \ 'tex' : ['PUNCTUATION', 'TYPOGRAPHY','FR_SPELLING_RULE'],
"           \ 'help' : ['PUNCTUATION', 'TYPOGRAPHY'],
"           \ }
"                                                                                                                  }}}
  "   doc: ALE     {{{
  "   :ALEInfo
  "   :ALEFix
  "   :ALELint
  "   %chktex 10 , %chktex 6 : Disable some errors
  "   -> $HOME/.vim/pack/lesplugins/opt/ale/ale_linters/tex hack pour le faire marcher }}}
  execute "packadd ale"
  let b:ale_fixers = ['remove_trailing_lines',  'trim_whitespace']
  let b:ale_linters = ['chktex']
  let g:ale_lint_on_enter = 0                   "
  let g:ale_lint_on_text_changed = 'always'     " 'always' | 'normal' | 'insert' | 'never' (default=always) -> batterie
  let g:ale_lint_delay = 200                    " (default 200 ms)

  execute "packadd ultisnips"
  " :UltiSnipsEdit
  " Snippets are separated from the engine. Plugin 'honza/vim-snippets'
  " ultisnips will search all folders named UltiSnips (by default) under path $VIM
  " Trigger configuration.
  " Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
  let g:UltiSnipsExpandTrigger       = "<tab>"
" let g:UltiSnipsJumpForwardTrigger  = "<tab>"
" let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
  let g:UltiSnipsEditSplit           = "vertical"
" set runtimepath+=~/.vim/julien
  " repetoire de ma collection de snippets privées (pour :UltiSnipsEdit)
  let g:UltiSnipsSnippetsDir = '~/.vim/UltiSnips/'
  " nom des repertoires contenant des fichiers de snippets (tex.snippets, python.snippets, ...)
  " default = ["UltiSnips"]
" let g:UltiSnipsSnippetDirectories  = ['mesUltiSnips']
  nnoremap <Space>u   :UltiSnipsEdit<CR>

  " <Localleaderd>lt
  execute "packadd vim-latex"
" let g:latex_toc_split_side='rightbelow'
  let g:latex_toc_width=50
" charge vim help des packages
  silent! helptags ALL
"}}}
  "
  " Compilation: {{{1
  " ============
  " 'shell-escape' pour autoriser LaTeX à executer des commandes shell. Besoin avec python, minted et usetikzlibrary{external}.
  set makeprg=latexmk\ -pv\ -pdf
" nnoremap <localleader>l      :<C-u>call SaveAndExecutePdfLaTeX()<CR>
" nnoremap <LocalLeader>t      :w<cr> :Dispatch  latexmk -pdfxe -pv -latexoption="-shell-escape -halt-on-error" %<CR>
  nnoremap <LocalLeader>m      :w<CR> :term      latexmk -pdf   -pv -latexoption="-shell-escape" %<CR>
" nnoremap <LocalLeader>l      :w<CR> :Dispatch  latexmk -pdf   -pv -latexoption="-shell-escape -halt-on-error -f" %<CR>
  nnoremap <LocalLeader>l      :w<CR> :Dispatch  latexmk -pdf   -pv -latexoption="-shell-escape -halt-on-error -f " %<CR>
" pour avoir la quickfix window qui marche
" https://github.com/lervag/vimtex/blob/master/autoload/vimtex/compiler/latexmk.vim
"
" https://github.com/tpope/vim-dispatch/issues/41
" :Dispatch ignores the current 'efm' and tries to find an appropriate one by
" digging through compiler/*.vim. If you want to set 'efm' yourself, you need
" to use :Make.
"
  nnoremap <LocalLeader>L      :w<CR> :Dispatch! latexmk -pdf   -pv -latexoption="-shell-escape -halt-on-error" -file-line-error  %<CR>
  "}}}
  "
  " Templates: {{{1
  " ============
   nnoremap <LocalLeader>ej    :e $HOME/Library/texmf/tex/latex/julien04.sty<Esc>
   nnoremap <LocalLeader>ep    :e $HOME/Library/texmf/tex/latex/<Esc>
   nnoremap <LocalLeader>eg    :e $HOME/Documents/EN/cours/LaTeX/gallerie/gallerie.tex<Esc>
   nnoremap <LocalLeader>et    :e $HOME/.vim/julien/template/latex/template.tex<Esc>
   nnoremap <LocalLeader>rt    :-1r $HOME/.vim/julien/template/latex/template.tex<Esc>
  "}}}
  "
  " Abbrev:{{{1
  " =========
   iabbrev includegraphics \includegraphics[width=\linewidth]{.png}
   iabbrev graph           \includegraphics[width=\linewidth]{.png}
   iabbrev minipage        \begin{minipage}[t]{0.5\linewidth} \vspace{0mm}<CR>\end{minipage}
   iabbrev definition      \begin{definition}[]<CR><CR>\end{definition}
   iabbrev exemple         \begin{exemple}[]<CR><CR>\end{exemple}
   iabbrev propriete       \begin{propriete}[]<CR><CR>\end{propriete}
"  problèmes lors de la frappe
"   iabbrev remarque        \begin{remarque}[]<CR><CR>\end{remarque}
  "}}}
  " Snippets:{{{1
  " =========
  " NORMAL MODE
   nnoremap <LocalLeader>es           :e     $HOME/.vim/julien/snippets/latex<CR>
   nnoremap <LocalLeader>sapp         :-1read $HOME/.vim/julien/snippets/latex/appendix.snip<CR>f{
   nnoremap <LocalLeader>sacti        :-1read $HOME/.vim/julien/snippets/latex/activite.snip<CR>f:
   nnoremap <LocalLeader>sitemize     :-1read $HOME/.vim/julien/snippets/latex/itemize.snip<CR>f{
   nnoremap <LocalLeader>sgraphics    :-1read $HOME/.vim/julien/snippets/latex/graphics.snip<CR>$h
   nnoremap <LocalLeader>scenter      :-1read $HOME/.vim/julien/snippets/latex/center.snip<CR>jdd}P
   nnoremap <LocalLeader>smini        :-1read $HOME/.vim/julien/snippets/latex/minipage.snip<CR>j
   nnoremap <LocalLeader>subsec       :-1read $HOME/.vim/julien/snippets/latex/subsec.snip<CR>f{
   nnoremap <LocalLeader>sec          :-1read $HOME/.vim/julien/snippets/latex/section.snip<CR>f{
   nnoremap <LocalLeader>stable       :-1read $HOME/.vim/julien/snippets/latex/table.snip<CR>
   nnoremap <LocalLeader>stemplate    :-1read $HOME/.vim/julien/template/latex/template.tex<CR>

   " INSERT MODE
   " <++> inspired by https://www.youtube.com/watch?v=Q4I_Ft-VLAg
   inoremap <Space><Space> <Esc>/<++><CR>"_c4l
   autocmd FileType tex inoremap  <LocalLeader>sec      \section{}<CR><++><Esc>kf{a

"  autocmd FileType tex inoremap  <LocalLeader>sec      \section{}<Esc>hi



  "}}}
augroup END

" vim: nospell
