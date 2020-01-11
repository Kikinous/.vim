autocmd BufNewFile,BufRead *.tex  set ft=tex
autocmd BufNewFile,BufRead *.snip set ft=tex
autocmd BufWritePre        *.tex :%s/\s\+$//e                                                      " supprime les Trailing Whitespaces
