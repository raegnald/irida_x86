" Irida syntax highlighting

" Usage Instructions
" Put this file in .vim/syntax/irida.vim
" and add in your .vimrc file the next line:
" autocmd BufRead,BufNewFile *.iri set filetype=irida

if exists("b:current_syntax")
  finish
endif

syntax keyword iriTodos TODO FIXME NOTE
syntax keyword iriKeywords
  " begin
  \ end
  \ alloc proc
  \ assert
  \ printi prints
  \ add sub mul div
  \ eq
  \ drop dupl
  \ ret nothing

syntax keyword iriConditionals if then else
syntax keyword iriRepeats loop while
syntax keyword iriInclude include

syntax region iriCommentLine start="//" end="$" contains=iriTodos
syntax region iriStr start=/\v"/ skip=/\v\\./ end=/\v"/
syntax region iriChar start=/\v'/ skip=/\v\\./ end=/\v'/
"syntax region iriInt start='\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+'

syntax match iriInt "\v<\d+>"

" Set highlights
highlight default link iriTodos Todo
highlight default link iriKeywords Keyword
highlight default link iriConditionals Conditional
highlight default link iriRepeats Repeat
highlight default link iriInclude Include

highlight default link iriCommentLine Comment
highlight default link iriStr String
highlight default link iriChar Character
highlight default link iriInt Number


setlocal indentexpr=IriIdent()
function! IriIdent()
  let line = getline(v:lnum)
  let previousNum = prevnonblank(v:lnum - 1)
  let previous = getline(previousNum)

  if previous =~ "begin" && previous !~ "end" && line !~ "end" && line !~ "end"
    return indent(previousNum) + &tabstop
  endif
endfunction

let b:current_syntax = "irida"