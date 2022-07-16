" Title:        Example Plugin
" Description:  A plugin to provide an example for creating Vim plugins.
" Last Change:  8 November 2021
" Maintainer:   Example User <https://github.com/example-user>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_omerge")
    finish
endif

let s:columns_break_point = 140  " get max with &columns
" The Event Hook for Resizing - autocmd VimResized * exe "normal \<c-w>="
let g:loaded_omerge = 1
" Window IDs
" ----------------------------------------------------------------------------
let s:win_id_branches_list = 0
let s:win_id_commits_list = 0
let s:win_id_commit_details = 0
let s:win_id_commit_files = 0
let s:win_id_commit_diff = 0
" Script States
" ----------------------------------------------------------------------------
let s:om_selected_commit_hash = ''
" Config & Misc
" ----------------------------------------------------------------------------
let g:om_commits_window_size = 80

" Helpers
" ----------------------------------------------------------------------------
function! s:IsCurrBufferEmpty()
    return line('$') == 1 && getline(1) == ''
endfunction

" Git Wrapper Functions
" ----------------------------------------------------------------------------

function! s:GitGetCurrentBranchName()
    let l:cmd = 'git branch --show-current'
    return trim(system(l:cmd))
endfunction

function! s:GitGetBranchesList()
    let l:cmd = 'git --no-pager branch'
    return systemlist(l:cmd)
endfunction
    
function! s:GitGetCommitsFromBranch(branch_name)
    let l:cmd = 'git --no-pager log --pretty=oneline --abbrev-commit ' . a:branch_name
    return systemlist(l:cmd)
endfunction

function! s:GitGetCommitsFromCurrentBranch()
    let l:cmd = 'git --no-pager log --pretty=oneline --abbrev-commit'
    return systemlist(l:cmd)
endfunction

function! s:GitGetCommitDetails(commit_hash)
    let l:cmd = 'git --no-pager show --pretty=fuller -q ' . a:commit_hash
    return systemlist(l:cmd)
endfunction

function! s:GitGetCommitFilePaths(commit_hash)
    let l:cmd = 'git show --name-only --format=""  ' . a:commit_hash
    return systemlist(l:cmd)
endfunction

function! s:GitGetParentHash(git_commit_hash)
    let l:cmd = 'git rev-parse ' . a:git_commit_hash . '^1'
    return trim(system(l:cmd))
endfunction

function! s:GitGetFileDiff(git_commit_hash, file_path)
    let l:git_commit_parent_hash = s:GitGetParentHash(a:git_commit_hash)
    let l:cmd = "git --no-pager diff " . a:git_commit_hash . " " . l:git_commit_parent_hash . " " . a:file_path
    return systemlist(l:cmd)
endfunction

" UI Functions
" ----------------------------------------------------------------------------

function! s:OrdinaryMergeDashboard() abort
    " So far we planned 4 windows
    " 1 - Shows the list of commits
    " 2 - Shows the meta data related to a single commit
    " 3 - Shows the files modified by a single commit
    " 4 - Shows the DIFF from a single file

    "set splitbelow  " This works but lets experiment

    " 0 - Branches List
    let s:win_id_branches_list = win_getid()
    call setline('.', s:win_id_branches_list)

    map <buffer> <enter> :OrdinaryMergeRenderBranch<CR>

    " 1st - Commits List
    bot new
    let s:win_id_commits_list = win_getid()
    call setline('.', s:win_id_commits_list)

    map <buffer> <enter> :OrdinaryMergeRenderCommitDetails<CR>
    map <buffer> b :OrdinaryMergeChangeWindowFocus "branches_list"<CR>

    " 2nd - Commit Meta Data
    "wincmd n  " Creating new Window (at top) with new Buffer = :split and :enew
    bot new
    let s:win_id_commit_details = win_getid()
    call setline('.', s:win_id_commit_details)

    map <buffer> b :OrdinaryMergeChangeWindowFocus "branches_list"<CR>
    map <buffer> c :OrdinaryMergeChangeWindowFocus "commits_list"<CR>

    " 3rd - Files from selected Commit
    "wincmd n
    bot new
    let s:win_id_commit_files = win_getid()
    call setline('.', s:win_id_commit_files)

    map <buffer> <enter> :OrdinaryMergeRenderFileDiff<CR>

    " 4th - Diff from a single Commit's File
    "wincmd n
    botright vnew
    let s:win_id_commit_diff = win_getid()
    call setline('.', s:win_id_commit_diff)
    set syntax=diff

    map <buffer> b :OrdinaryMergeChangeWindowFocus "branches_list"<CR>
    map <buffer> c :OrdinaryMergeChangeWindowFocus "commits_list"<CR>
    map <buffer> f :OrdinaryMergeChangeWindowFocus "commit_files"<CR>

    call s:OrdinaryMergeRenderBranchesList()

    " Going back to the 1st Window (Commits list) and adjust some Event/Maps
    " for this Window (Buffer) only
    call s:OrdinaryMergeRenderCommitsList()

    " Resizing the left side of the split
    " vertical resize 80 " TODO using g:om_commits_window_size results in width == 1
    let l:width_size = g:om_commits_window_size
    execute ':vertical resize ' . l:width_size

    call s:OrdinaryMergeRenderCommitDetails()
endfunction

function! s:OrdinaryMergeRenderBranch(...)
    call win_gotoid(s:win_id_branches_list)
    " Recoveing name of selected branch
    let s:om_selected_branch = getline('.')
    " Cleaning up possible * chareacter
    let s:om_selected_branch = substitute(s:om_selected_branch, '\(\*\s\)\?\(.*\)', '\2', 'g')
    " echom "Selected branch " . s:om_selected_branch
    call s:OrdinaryMergeRenderCommitsList()
endfunction

function! s:OrdinaryMergeRenderBranchesList(...)
    call win_gotoid(s:win_id_branches_list)
    let l:branches = s:GitGetBranchesList()
    call setline('.', l:branches)
endfunction

function! s:OrdinaryMergeRenderCommitsList(...)
    call win_gotoid(s:win_id_commits_list)
    let l:commits = s:GitGetCommitsFromCurrentBranch()
    if s:IsCurrBufferEmpty() == 0
        %delete  " wipe buffer content
    endif
    call setline('.', l:commits)
endfunction

function! s:OrdinaryMergeRenderCommitDetails(...)
    " Going back to 1st Window (commits)
    call win_gotoid(s:win_id_commits_list)

    " Recovering selected commit
    let s:om_selected_commit_hash = split(getline('.'))[0]

    let l:commit_hash = s:om_selected_commit_hash

    echom 'Rendering Details for commit ' . l:commit_hash

    " Going back to the 2nd Window (commit details)
    call win_gotoid(s:win_id_commit_details)

    " Rendering Commit details
    call setline('.', s:GitGetCommitDetails(l:commit_hash))

    " Going back to the 3rd Window (commit's files)
    call win_gotoid(s:win_id_commit_files)

    " Rendering File paths
    call setline('.', s:GitGetCommitFilePaths(l:commit_hash))

    call s:OrdinaryMergeRenderFileDiff()
    return 0

    " Recover the first file path from the list of commit's files (if any)
    let s:file_path = trim(getline('.'))

    if len(s:file_path) >= 1
        " Going back to the 4th Window (DIFF)
        call win_gotoid(s:win_id_commit_diff)
        
        " Rendering DIFF
        let l:diff = s:GitGetFileDiff(l:commit_hash, s:file_path)
        call setline('.', l:diff)
    endif
endfunction

function! s:OrdinaryMergeRenderFileDiff(...)
    let l:commit_hash = s:om_selected_commit_hash

    " Going back to the 3rd Window (commit's files)
    call win_gotoid(s:win_id_commit_files)

    " Recover the first file path from the list of commit's files (if any)
    let s:file_path = trim(getline('.'))

    if len(s:file_path) >= 1
        " Going back to the 4th Window (DIFF)
        call win_gotoid(s:win_id_commit_diff)
        
        " Rendering DIFF
        let l:diff = s:GitGetFileDiff(l:commit_hash, s:file_path)
        if s:IsCurrBufferEmpty() == 0
            %delete  " wipe buffer content
        endif
        call setline('.', l:diff)
    endif
endfunction

function! s:OrdinaryMergeChangeWindowFocus(...)
    if a:0 == 0
        return
    endif
    let l:win_name = trim(a:1)
    if l:win_name == "commits_list"
        call win_gotoid(s:win_id_commits_list)
    endif
    if l:win_name == "commit_files"
        call win_gotoid(s:win_id_commit_files)
    endif
    if l:win_name == "branches_list"
        call win_gotoid(s:win_id_branches_list)
    endif
endfunction

" Exposes the plugin's functions for use as commands in Vim.
command! -nargs=0 OrdinaryMerge call s:OrdinaryMergeDashboard()
command! -nargs=0 OrdinaryMergeRenderBranch call s:OrdinaryMergeRenderBranch()
command! -nargs=0 OrdinaryMergeRenderCommitDetails call s:OrdinaryMergeRenderCommitDetails()
command! -nargs=0 OrdinaryMergeRenderFileDiff call s:OrdinaryMergeRenderFileDiff()
command! -nargs=1 OrdinaryMergeChangeWindowFocus call s:OrdinaryMergeChangeWindowFocus(<args>)
"command! -nargs=0 AspellCheck call omerge#AspellCheck()

