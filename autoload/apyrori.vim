""
" Lame callback to re-route to lua :P
function! apyrori#prompt_callback(text) abort
  call luaeval("require('apyrori').prompt_callback(_A)", a:text)
endfunction

""
" sets the callback
function! apyrori#set_prompt_callback(bufnr) abort
  call prompt_setcallback(a:bufnr, function('apyrori#prompt_callback'))
endfunction
