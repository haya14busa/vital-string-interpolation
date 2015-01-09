"=============================================================================
" FILE: autoload/vital/__latest__/Data/String/Interpolation.vim
" AUTHOR: haya14busa
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
scriptencoding utf-8
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

"" String interpolation in Vim script
" DOC:
" interpolate({string} [, {context}])
"       String interpolation[1] allows you to build string with evaluating
"       expressions inside `${}` in the {string}. You can pass a {context}
"       dictionary to evaluate `${expr}`.
"       alias: format(), s() taken from Scala's s"${expr}"
"       [1]: http://en.wikipedia.org/wiki/String_interpolation
" USAGE:
" :let s:I = vital#of('vital').import('Data.String.Interpolation')
" :echo s:I.interpolate('Hi, ${name}!', {'name': 'haya14busa'})
" " => Hi, haya14busa!
" :let s:name = 'haya14busa'
" :echo s:I.s('Hi, ${name}!', s:)
" " => Hi, haya14busa!
" :function! s:IIFE() abort
" :    let name = 'haya14busa'
" :    return s:I.s('Hi, ${name}!', l:)
" :endfunction
" :echo s:IIFE()
" " => Hi, haya14busa!
function! s:_interpolate(string, ...) abort
    let context = get(a:, 1, {})
    let str = a:string
    let ms = s:_ms(str)
    let mstart = 0 " match start
    while !empty(ms)
        let value = s:_context_eval(ms[1], context)
        let _mstart = match(str, s:_format, mstart) + len(value)
        let str = substitute(str, printf('\%%>%dc%s', mstart, ms[0]), value, '')
        let mstart = _mstart
        let ms = s:_ms(str, mstart)
    endwhile
    return str
endfunction
function! s:interpolate(...) abort
    return call(function('s:_interpolate'), a:000)
endfunction
function! s:format(...) abort
    return call(function('s:_interpolate'), a:000)
endfunction
function! s:s(...) abort
    return call(function('s:_interpolate'), a:000)
endfunction

"" format: ${expr} / ${string({})} / ${}
let s:_format = '\v\$\{(%(\{.{-}\}|.){-})\}'

"" Return ['${expr}', 'expr', '', ''] or [] when there are no matches
function! s:_ms(string, ...) abort
    let start = get(a:, 1, 0)
    return matchlist(a:string, s:_format, start)
endfunction

"" Contextual eval()
function! s:_context_eval(expr, context) abort
    call extend(l:, a:context)
    sandbox return eval(a:expr)
endfunction

" " NOTE: \= doesn't support recursive call. :h sub-replace-expression
" function! s:interpolate(string, ...) abort
"     call extend(l:, get(a:, 1, {}))
"     return substitute(a:string, '\m\${\(.\{-}\)}', '\=eval(submatch(1))', 'g')
" endfunction
" echo s:interpolate('Recursive call: ${Test()}', {'Test': function('s:test')})
" " => Recursive call: Happy new year, =eval(submatch(1))! <= invalid!


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" __END__  {{{
" vim: expandtab softtabstop=4 shiftwidth=4
" vim: foldmethod=marker
" }}}
