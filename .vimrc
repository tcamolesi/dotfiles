set nocompatible

" Tab expansion
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2

" Search options
set incsearch
set smartcase
" set hlsearch

" Indenting
set ai
filetype indent on
set smartindent

" Display options
set sc
set ruler
set number
set wildmenu

" Misc
set pastetoggle=\<F2>
set history=1000

" Wait just 200ms to disambiguate commands
set timeoutlen=200

" Allow cursor to go past the end of the line in visual block mode
set virtualedit=block

" Allow buffer to be hidden without writing to disk
set hidden 

" Colorscheme
set t_Co=256
syntax enable
set background=dark

colorscheme jellybeans 

" Use jk to switch to normal mode
inoremap jk <esc>
cnoremap jk <c-c>
" Using jk to exit visual mode makes cursor movement too slow
" vnoremap jk <esc>

" Useful readline bindings
set <m-f>=f
set <m-b>=b
cnoremap <c-e> <end>
cnoremap <c-a> <home>
cnoremap <c-f> <Right>
cnoremap <c-b> <Left>
cnoremap <m-f> <S-Right>
cnoremap <m-b> <S-Left>

inoremap <c-e> <end>
inoremap <c-a> <home>
inoremap <c-f> <Right>
inoremap <c-b> <Left>
inoremap <m-f> <S-Right>
inoremap <m-b> <S-Left>

" Don't expand tabs when editing Makefiles
autocmd FileType make setlocal noexpandtab

" JSON plugin
autocmd BufRead *.json set filetype=json
au! Syntax json source ~/.vim/json.vim

inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
\ "\<lt>C-n>" :
\ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
\ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
\ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
imap <C-@> <C-Space>

" Load pathogen plugins
call pathogen#infect()
