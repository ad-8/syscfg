;;; init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find a link to Doom's Module Index where all
;;      of our modules are listed, including what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'K' (or
;;      'C-c c k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;      directory (for easy access to its source code).

(doom! :input

       :completion
       (corfu +dabbrev +icons +orderless) ; complete with cap(f), cape and a flying feather!
       (vertico +icons)                   ; the search engine of the future

       :ui
       doom                ; what makes DOOM look the way it does
       dashboard           ; a nifty splash screen for Emacs
       hl-todo             ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       ;;ligatures         ; ligatures and symbols to make your code pretty again
       minimap             ; show a map of the code on the side
       modeline            ; snazzy, Atom-inspired modeline, plus API
       ophints             ; highlight the region an operation acts on
       (popup +defaults)   ; tame sudden yet inevitable temporary windows
       ;; tabs             ; a tab bar for Emacs
       treemacs            ; a project drawer, like neotree but cooler
       ;;unicode           ; extended unicode support for various languages
       (vc-gutter +pretty) ; vcs diff in the fringe
       vi-tilde-fringe     ; fringe tildes to mark beyond EOB
       window-select       ; visually switch windows
       workspaces          ; tab emulation, persistence & separate workspaces
       zen                 ; distraction-free coding or writing

       :editor
       (evil +everywhere) ; come to the dark side, we have cookies
       file-templates     ; auto-snippets for empty files
       fold               ; (nigh) universal code folding
       ;;(format +onsave) ; automated prettiness
       ;;god              ; run Emacs commands without modifier keys
       ;;lispy            ; vim for lisp, for people who don't like vim
       ;;multiple-cursors ; editing in many places at once
       ;;objed            ; text object editing for the innocent
       ;;parinfer         ; turn lisp into python, sort of
       ;;rotate-text      ; cycle region at point between text candidates
       snippets           ; my elves. They type so I don't have to
       ;;word-wrap        ; soft wrapping with language-aware indent

       :emacs
       (dired +dirvish +icons) ; making dired pretty [functional]
       electric                ; smarter, keyword-based electric-indent
       (ibuffer +icons)        ; interactive buffer management
       undo                    ; persistent, smarter undo for your inevitable mistakes
       vc                      ; version-control and Emacs, sitting in a tree

       :term
       ;;eshell            ; the elisp shell that works everywhere
       ;;shell             ; simple shell REPL for Emacs
       ;;term              ; basic terminal emulator for Emacs
       ;;vterm             ; the best terminal emulation in Emacs

       :checkers
       syntax              ; tasing you for every semicolon you forget
       (spell +flyspell)   ; tasing you for misspelling mispelling
       ;;grammar           ; tasing grammar mistake every you make

       :tools
       ;;debugger          ; FIXME stepping through code, to help you add bugs
       direnv
       ;;docker
       ;;editorconfig      ; let someone else argue about tabs vs spaces
       (eval +overlay)     ; run code, run (also, repls)
       lookup              ; navigate your code and its documentation
       lsp                 ; M-x vscode
       magit               ; a git porcelain for Emacs
       ;;make              ; run make tasks from Emacs
       ;;pass              ; password manager for nerds
       ;;pdf               ; pdf enhancements
       ;;prodigy           ; FIXME managing external services & code builders
       rgb                 ; creating color strings
       ;;taskrunner        ; taskrunner for all your projects
       ;;tmux              ; an API for interacting with tmux
       ;;tree-sitter       ; syntax and parsing, sitting in a tree...
       ;;upload            ; map local to remote projects via ssh/ftp

       :os
       (:if (featurep :system 'macos) macos)  ; improve compatibility with macOS
       ;;tty               ; improve the terminal Emacs experience

       :lang
       (clojure +lsp)      ; java with a lisp
       ;;common-lisp       ; if you've seen one lisp, you've seen them all
       data                ; config/data formats
       emacs-lisp          ; drown in parentheses
       ;;json              ; At least it ain't XML
       ;;(java +lsp)       ; the poster child for carpal tunnel syndrome
       ;;latex             ; writing papers in Emacs has never been so fun
       lua               ; one-based indices? one-based indices
       markdown            ; writing docs for people to ignore

       ;; TODO
       ;; (nix +lsp +tree-sitter) ; I hereby declare "nix geht mehr!"
       (nix +lsp)          ; I hereby declare "nix geht mehr!"

       (org +pretty)       ; organize your plain life in plain text

       ; run `gem install ruby-lsp` in project dir after `rbenv` is properly configured
       (ruby +lsp +rails)  ; 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}

       (rust +lsp)         ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       ;;(scheme +guile)   ; a fully conniving family of lisps
       (sh +fish)          ; she sells {ba,z,fi}sh shells on the C xor
       ;;web               ; the tubes
       yaml                ; JSON, but readable
       ;;zig               ; C, but simpler

       :email
       ;;(mu4e +org +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       calendar
       emms                ; Emacs Multimedia System
       ;;everywhere        ; *leave* Emacs!? You must be joking
       ;;irc               ; how neckbeards socialize
       (rss +org)        ; emacs as an RSS reader

       :config
       literate
       (default +bindings +smartparens))
