# apyrori.nvim

Auto imports for Python based on your current project. The name is a pun on _a priori_. It's not a great pun, but it's a pun nonetheless.


## Installation

```vim
" Used for running jobs in lua
Plug 'TravonteD/luajob'
" Actual plugin
Plug 'tjdevries/apyrori.nvim'
```

## Usage

```vim
" You may want to put this within a python only part of your config.
nmap <A-I> <plug>(ApyroriInsert)
```
