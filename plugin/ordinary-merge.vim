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


let g:loaded_omerge = 1
" Window IDs
" ----------------------------------------------------------------------------
let s:win_id_commits_list = 0
let s:win_id_commit_details = 0
let s:win_id_commit_files = 0
let s:win_id_commit_diff = 0
" Script States
" ----------------------------------------------------------------------------
let s:om_selected_commit_hash = ''
" Config & Misc
" ----------------------------------------------------------------------------
let g:om_commits_window_size = 10

" Git Wrapper Functions
" ----------------------------------------------------------------------------

function! s:GitGetCurrentBranchName()
    let l:cmd = 'git branch --show-current'
    return trim(system(l:cmd))
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

    " 1st - Commits List
    let s:win_id_commits_list = win_getid()
    call setline('.', s:win_id_commits_list)

    " 2nd - Commit Meta Data
    wincmd n  " Creating new Window with new Buffer
    let s:win_id_commit_details = win_getid()
    call setline('.', s:win_id_commit_details)

    " 3rd - Files from selected Commit
    wincmd n
    let s:win_id_commit_files = win_getid()
    call setline('.', s:win_id_commit_files)

    map <buffer> <enter> :OrdinaryMergeRenderFileDiff<CR>

    " 4th - Diff from a single Commit's File
    wincmd n
    let s:win_id_commit_diff = win_getid()
    call setline('.', s:win_id_commit_diff)
    set syntax=diff

    " Going back to the 1st Window (Commits list) and adjust some Event/Maps
    " for this Window (Buffer) only
    call win_gotoid(s:win_id_commits_list)
    let l:commits = s:GitGetCommitsFromCurrentBranch()
    call setline('.', l:commits)
    "resize g:om_commits_window_size  " TODO why is this resizing to 1 line?
    " Mapping Enter key to trigger showing details about the selected commit
    map <buffer> <enter> :OrdinaryMergeRenderCommitDetails<CR>
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
        call setline('.', l:diff)
    endif
endfunction

" Exposes the plugin's functions for use as commands in Vim.
command! -nargs=0 OrdinaryMerge call s:OrdinaryMergeDashboard()
command! -nargs=0 OrdinaryMergeRenderCommitDetails call s:OrdinaryMergeRenderCommitDetails()
command! -nargs=0 OrdinaryMergeRenderFileDiff call s:OrdinaryMergeRenderFileDiff()
"command! -nargs=0 AspellCheck call omerge#AspellCheck()

