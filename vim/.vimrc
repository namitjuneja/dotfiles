set number


"" map to all modes including insert mode (! stands for insert mode)
map! kj <Esc>`^
map ;lkj <Esc>:wq<CR>

filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

set textwidth=72 
set colorcolumn=72
"" set number of window columns
set columns=72

"" swp files in temp directory
set backupdir=/tmp//
set directory=/tmp//
set undodir=/tmp//
