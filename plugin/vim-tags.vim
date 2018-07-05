
if (exists('g:loaded_tags') || &cp)
    finish
endif

let g:loaded_tags = 1

if (!exists('g:tags_debug'))
    let g:tags_debug = 0
endif

" define default "tags_event" {{{2
if (!exists("g:tags_event") || !(type(g:tags_event) == type([])))
  let s:tags_event = [ "VimEnter" ]
else
  let s:tags_event = g:tags_event
endif

if has("autocmd")
  augroup tags
    autocmd!

    for event in s:tags_event
      " call s:ConnectScope() when creating or reading any file
      exec "autocmd ".event." * call s:ConnectScope()"
    endfor
  augroup END
endif
" }}}

" Function: s:CheckProject() {{{2
"
" Quit if no porject defined
"
function! s:CheckProject()
    if !exists("g:tags_root")
        return 0
    else
        return 1
    endif
endfunction

" Function: s:BuildTags() {{{2
"
" Build cscope tags and connect it
"
function! s:BuildTags()
    if s:CheckProject()
        silent exec 'cs kill -1'
        if (!exists("g:tags_find_cmd"))
            let g:tags_find_cmd = "find . -name '*.[ch]' -o -name '*.[ch]pp'"
        endif
        exec "!cd ".g:tags_root." && echo 'create source_list.txt ...' && ".g:tags_find_cmd." > source_list.txt && echo 'create cscope.out ...' && sed -ie '/ /d' source_list.txt && cscope -qbR -i source_list.txt && cd - > /dev/null"
        call s:ConnectScope()
    else
        call s:DebugPrint(0, "No Source Root defined!")
    endif
endfunction
" }}}

" Function: s:ConnectScope() {{{2
"
" Connect cscope.out
"
function! s:ConnectScope()
    if s:CheckProject()
        silent exec 'cs kill -1'
        let s:cscope_fn = g:tags_root . '/cscope.out'
        if filereadable(s:cscope_fn)
            " Add cscope with -C (case insensitive)
            silent exec 'cs add ' . s:cscope_fn . ' ' . g:tags_root . ' ' . '-C'
            call s:DebugPrint(0, 'cscope.out connected.')
        else
            call s:DebugPrint(0, 'cscope.out not found.')
        endif
    endif
endfunction
" }}}

" Function: s:DebugPrint(level, text) {{{2
"
" output debug message, if this message has high enough importance
"
function! s:DebugPrint(level, text)
  if (g:tags_debug > a:level)
    echom "tags: " . a:text
  endif
endfunction

command! BuildTags call s:BuildTags()
command! ConnectScope call s:ConnectScope()

