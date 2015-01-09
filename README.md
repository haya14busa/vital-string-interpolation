String interpolation in Vim
===========================
[![Build Status](https://travis-ci.org/haya14busa/vital-string-interpolation.svg?branch=master)](https://travis-ci.org/haya14busa/vital-string-interpolation)

Vital.Data.String.Interpolation is String interpolation[1] library.

[1]: http://en.wikipedia.org/wiki/String_interpolation

Installation
------------

### 1. Install vital.vim and vital-string-interpolation.vim with your favorite plugin manager.

```vim
NeoBundle 'vim-jp/vital.vim'
NeoBundle 'haya14busa/vital-string-interpolation.vim'

Plugin 'vim-jp/vital.vim'
Plugin 'haya14busa/vital-string-interpolation.vim'

Plug 'vim-jp/vital.vim'
Plug 'haya14busa/vital-string-interpolation.vim'
```

### 2. Embed vital-string-interpolation.vim into your plugin with :Vitalize (assume current directory is the root of your plugin repository).
See `:Vitalize` for more information.

```vim
:Vitalize . --name={plugin_name} vital-string-interpolation
```

### 3. You can update vital-string-interpolation.vim with :Vitalize.
```vim
:Vitalize .
```

Usage
-----

```vim
let s:V = vital#of("vital")
let s:I = s:V.import("Data.String.Interpolation")

echo s:I.interpolate('Hi, ${name}!', {'name': 'haya14busa'})
" => Hi, haya14busa!

let scores = [
\   {'name': 'haya14busa', 'score': 14},
\   {'name': 'tom', 'score': 32}
\ ]
for score in scores
    echo s:I.format('Hi, ${name}. Your SCORE is ${score}!', score)
endfor
" => Hi, haya14busa. Your SCORE is 14!
" => Hi, tom. Your SCORE is 32!

" You can just pass :h internal-variables as a context.
function! s:IIFE() abort
    let name = 'haya14busa'
    return s:I.s('Hi, ${name}!', l:)
endfunction
echo s:IIFE()
" => Hi, haya14busa!
```
