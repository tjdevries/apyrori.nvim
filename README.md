# apyrori.nvim

Auto imports for Python based on your current project. The name is a pun on _a priori_. It's not a great pun, but it's a pun nonetheless.


## How it works

It's pretty simple and it's pretty dumb, and that's why it works so great.

When you're working on a large project, you've probably imported the thing you want to import somewhere before.
This plugin simply looks at all the places you've imported the word under your cursor, picks the most likely (A.K.A. most frequent) import
and adds that to the top of your file.


For example:

```python
# FILE: my_package/foo.py

from my_package.services import MagicRequests

...
```

Now you're editing a new file, and you haven't imported `MagicRequests` yet. If you type out what you want to import and invoke `<plug>ApyroriInsert`,
the file will go from:

```python
# FILE: my_package/bar.py

class MySweetSummerChild(MagicRequests):
    pass
```

to

```python
# FILE: my_package/bar.py

from my_package.services import MagicRequests

class MySweetSummerChild(MagicRequests):
    pass
```

Another benefit is that when you're doing type annotations for Python, it is SO annoying to always pick `from typing import List` from all the other places that define `List`. This way you just standardize it across your project.

## Installation

```vim
" Used for running jobs in lua
Plug 'tjdevries/luvjob.nvim'
" Actual plugin
Plug 'tjdevries/apyrori.nvim'
```

## Usage

```vim
" You may want to put this within a python only part of your config.
nmap <M-i> <plug>ApyroriInsert
```

You can see it in action here:

https://asciinema.org/a/4gKqKLPnSSQWQzWEcjveoIY0v


### To Do

- [ ] Make a pop up for "contested" imports, so you can choose one easily
    - This is sort of done
- [ ] Make a pop up for "unknown" imports, so you can just type something and it will drop it at the top of your file
- [ ] Make a way to add "default" imports, so even if your project doesn't have them, we can add them anyways
- [ ] Make a "fuzzy" importer, and you can choose from  a similar popup as the contested one
