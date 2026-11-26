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
       (corfu +dabbrev +icons +orderless)
       (vertico +icons)

       :ui
       doom
       dashboard
       hl-todo
       minimap
       modeline
       ophints
       (popup +defaults)
       treemacs
       (vc-gutter +pretty)
       vi-tilde-fringe
       window-select
       workspaces
       zen

       :editor
       (evil +everywhere)
       file-templates
       fold
       ;;(format +onsave) ; automated prettiness
       ;;lispy            ; vim for lisp, for people who don't like vim
       ;;multiple-cursors ; editing in many places at once
       ;;parinfer         ; turn lisp into python, sort of
       ;;rotate-text      ; cycle region at point between text candidates
       snippets
       ;;word-wrap        ; soft wrapping with language-aware indent

       :emacs
       (dired +dirvish +icons)
       electric
       (ibuffer +icons)
       undo
       vc

       :term
       (ghostel +everywhere)

       :checkers
       syntax
       (spell +flyspell)

       :tools
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
       rgb                 ; creating color strings
       ;;taskrunner        ; taskrunner for all your projects
       ;;tmux              ; an API for interacting with tmux
       tree-sitter
       ;;upload            ; map local to remote projects via ssh/ftp

       :os
       (:if (featurep :system 'macos) macos) ; improve compatibility with macOS
       ;; tty

       :lang
       (clojure +lsp +tree-sitter)
       data
       emacs-lisp
       (go +lsp +tree-sitter)
       (markdown +tree-sitter)
       (nix +lsp +tree-sitter)
       (org +pretty)
       (rust +lsp +tree-sitter)
       (sh +fish)
       (yaml +tree-sitter)

       :email
       (:when (string= (system-name) "ax-bee")
        (mu4e +mbsync +org))

       :app
       calendar
       emms
       ;; everywhere
       (rss +org)

       :config
       literate
       (default +bindings +smartparens))
