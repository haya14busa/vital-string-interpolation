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
    let ps = s:_parser._parse_first_idx_range(str)
    while !empty(ps)
        let [s, e] = ps
        let expr = str[(s + len(s:_parser._ps)):(e - len(s:_parser._pend))]
        let v = s:_context_eval(expr, context)
        let str = (s > 0 ? str[0:(s-1)] : '') . v . str[(e+1):]
        let ps = s:_parser._parse_first_idx_range(str, s + len(v))
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


" Pair Parser:
let s:_parser = {}
let s:_parser._ppr = '$' " pattern prefix
let s:_parser._psb = '{' " pattern start bracket
let s:_parser._ps = s:_parser._ppr . s:_parser._psb " pattern start
let s:_parser._peb = '}' " pattern end bracket
let s:_parser._psu = '' " pattern suffix
let s:_parser._pend = s:_parser._peb . s:_parser._psu " pattern end

" return [start_index, end_index] or [] if not found
function! s:_parser._parse_first_idx_range(str, ...) abort
    let i = get(a:, 1, 0)
    let level = 0
    let str_state = ''
    let str_DOUBLE = '"'
    let str_SINGLE = "'"
    while i < len(a:str)
        if a:str[(i):(i + len(self._ps)-1)] is# self._ps
            let j = i + len(self._ps)
            while j < len(a:str)
                if a:str[j] is# str_DOUBLE && str_state is# str_DOUBLE
                    let str_state = ''
                elseif a:str[j] is# str_DOUBLE && str_state isnot# str_SINGLE
                    let str_state = str_DOUBLE
                elseif a:str[j] is# str_SINGLE && str_state is# str_SINGLE
                    let str_state = ''
                elseif a:str[j] is# str_SINGLE && str_state isnot# str_DOUBLE
                    let str_state = str_SINGLE
                elseif str_state isnot# ''
                    " pass
                elseif a:str[(j):(j + len(self._psb)-1)] is# self._psb
                    let level += 1
                elseif a:str[(j):(j + len(self._pend)-1)] is# self._pend
                    let level -= 1
                    if level < 0
                        return [i, j]
                    endif
                elseif a:str[(j):(j + len(self._psb)-1)] is# self._psb
                    let level -= 1
                endif
                let j += 1
            endwhile
        endif
        let i += 1
    endwhile
    return [] " not found
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
