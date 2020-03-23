
nnoremap <plug>(ApyroriInsert) <cmd> lua require('apyrori').insert_match(vim.api.nvim_call_function('expand', {'<cword>'}))

" Suggested mapping
" nmap <A-I> <plug>ApyroriInsert
