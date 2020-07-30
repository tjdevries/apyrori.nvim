
nnoremap <plug>ApyroriInsert <cmd>
      \ lua require('apyrori').find_and_insert_match(vim.api.nvim_call_function('expand', {'<cword>'}), nil, false)<CR>

" Suggested mapping
nmap <M-i> <plug>ApyroriInsert
