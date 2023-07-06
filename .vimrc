" BB .vimrc

" Vim not Vi
set nocompatible

" Enable and plugins
filetype plugin on
syntax on

" Plug-in installation calls for vim-plug
call plug#begin('~/.vim/plugged')
" TPope Commentary
Plug 'https://github.com/tpope/vim-commentary.git'
" TPope Endwise (add end intelligently with Ruby)
Plug 'https://github.com/tpope/vim-endwise.git'
" TPope Vinegar (netrw improvements)
Plug 'https://github.com/tpope/vim-vinegar.git'
" TPope Dispatch
Plug 'https://github.com/tpope/vim-dispatch.git'
" ALE (language linting)
Plug 'https://github.com/dense-analysis/ale.git'
" VOoM Outliner
Plug 'https://github.com/vim-voom/VOoM.git'
" Vlime for Common Lisp
Plug 'https://github.com/vlime/vlime.git'
" Rainbow parentheses as a visual aid for S-expressions
Plug 'https://github.com/junegunn/rainbow_parentheses.vim.git'
" Parinfer for editing S-expressions
Plug 'https://github.com/bhurlow/vim-parinfer.git'
" Match-up for displaying matching beginning/end tags
Plug 'https://github.com/andymass/vim-matchup.git'
call plug#end()

" Open Netrw splits in the right hand side
let g:netrw_altv=1

" Theme
set termguicolors
colorscheme paper

" Vlime config
let g:vlime_leader=","

" Highlight the current line
set cursorline

" Display title of file/folder
set title

" VOOm width
let g:voom_tree_width=38

" Display line numbers
set number
set relativenumber

" Only look at tags and current file for autocomplete
set complete=.,t

" Ale linter settings
let g:ale_linters = {
\   'ruby': ['rubocop', 'reek'],
\   'eruby': ['erblint'],
\   'javascript': ['eslint'],
\   'tcl': ['nagelfar']
\}
let g:ale_sign_error = '!!'
let g:ale_sign_warning = '??'
let g:ale_sign_info = 'oo'
let g:ale_linters_explicit = 1
let g:ale_list_window_size = 5
let g:ale_virtualtext_cursor = 'disabled'
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" Use the line number column for ALE signs
set signcolumn=number

" Background color fix for Kitty
let &t_ut=''

" Use an undo file
set undofile

" Storing the undo, swap files in a nice place.
setglobal undodir=$HOME/.vim/tmp//
setglobal backupdir=$HOME/.vim/tmp//
setglobal directory=$HOME/.vim/tmp//
if !isdirectory(&undodir)
  call mkdir(&undodir)
end

" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**

" Display all matching files when we tab complete
set wildmenu

" Ignore node module directory. Lots of noise.
" Helps massively with Command+T performance.
set wildignore+=*/node_modules
set wildignore+=*/tmp
set wildignore+=*/storage
set wildignore+=*/app/assets/fonts

" Tab and indent settings
set autoindent     " Autoindent when making new line
set tabstop=2      " Set tabs to 2 spaces when reading file
set softtabstop=2  " Set tabs to 2 space when editing
set shiftwidth=2
set expandtab      " Make tabs spaces, not <TAB>

" Only redraw when required
set lazyredraw

" Show the status line at the bottom
set ls=2
set showmatch

" Search settings
set incsearch
set hlsearch
set ignorecase
set smartcase

" Adding spacebar as an additional leader
let mapleader="\<Space>"
" Clear out highlighted search terms
nnoremap <leader>, :nohlsearch<CR>
" Return to previous buffer with leader+backspace
nnoremap <leader><BS> <C-^>
" Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>

" Allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Show one line above/below cursor at edge of buffer
" Pulled from TPope's Sensible repo
if !&scrolloff
  set scrolloff=3
endif
if !&sidescrolloff
  set sidescrolloff=5
endif
set display+=lastline

" Make set :list display better (showing whitespace chars)
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

function! FzyCommand(choice_command, fzy_args, vim_command)
  try
    let selection = system(a:choice_command . " | fzy " . a:fzy_args)
  catch /Vim:Interrupt/
    " Swallow the ^C so that the redraw below happens; otherwise
    " there will be leftovers from fzy on the screen.
    redraw!
    return
  endtry
  redraw!
  exec a:vim_command . " " . selection
endfunction

nnoremap <leader>t :call FzyCommand("fd -t f -H", "", ":e")<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SMART FILE DEFAULTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup vimrcEx
  " Clear all autocmds in the group
  autocmd!

  " Zettelkasten.
  autocmd! FileType zet set autoread
  " Set template
  autocmd! BufNewFile [0-9]\\\{14\}.md :silent 0r ~/.vim/templates/zettelkasten.md

  " Jump to last cursor position unless it's invalid or in an event handler
  autocmd! BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " For Ruby et. al., autoindent with two spaces, always expand tabs
  autocmd! FileType ruby,haml,eruby,yaml,html,sass,cucumber set ai sw=2 sts=2 et

  " Python settings
  autocmd! FileType python set sw=4 sts=4 et

  " Sass
  autocmd! BufRead,BufNewFile *.sass setfiletype sass

  " Markdown settings
  autocmd! BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
  autocmd! BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;
  autocmd! FileType markdown set sw=4 sts=4 et 

  " JS
  autocmd! FileType javascript set sw=2 sts=2 expandtab

  " Two-space indents in json
  autocmd! FileType json set sw=2 sts=2 expandtab

  " Hitting K in a Ruby file opens rdoc, which completely breaks the terminal
  " to the point of having to kill vim and do `reset`. Unmap it entirely.
  nnoremap K <Nop>
augroup END
