;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq abbrev-file-name "~/sync/emacs/abbrev_defs")
(setq save-abbrevs 'silently)

(defvar my/1080p-font-size 12
  "Font size for 1080p displays.")

(defvar my/4k-font-size 20
  "Font size for 4K / high-resolution displays.")

(defvar my/monitor-font--timer nil)
(defvar my/monitor-font--last-size nil)

(defun my/set-font-for-monitor (&optional frame)
  "Set doom font size based on the current monitor (poll-friendly)."
  (when (display-graphic-p)
    (let* ((frame (or frame (selected-frame)))
           (geometry (frame-monitor-attribute 'geometry frame))
           (scale (or (frame-monitor-attribute 'scale-factor frame) 1))
           (width (and geometry (nth 2 geometry)))
           (size (when width
                   (let ((effective-width (* width scale)))
                     (if (> effective-width 3000)
                         my/4k-font-size
                       my/1080p-font-size)))))

      (when (and size (not (equal size my/monitor-font--last-size)))
        (setq my/monitor-font--last-size size)
        (setq doom-font (font-spec :family "Hack Nerd Font" :size size))
        (when (fboundp 'doom/reload-font)
          (doom/reload-font))
        ;; Show in the echo area (bottom/statusline area)
        (message "Font changed: %s" size)))))

(let ((hn (string-trim (system-name))))
  (when (and hn (string-match-p "\\`ax-bee\\'" hn))
    ;; Apply once right now
    (when (display-graphic-p)
      (my/set-font-for-monitor (selected-frame)))

    ;; Poll to detect monitor changes even when focus doesn't change (Hyprland)
    (when my/monitor-font--timer
      (cancel-timer my/monitor-font--timer))
    (setq my/monitor-font--timer
          (run-with-timer 0 1.0 (lambda () (my/set-font-for-monitor (selected-frame)))))))

(setq bookmark-default-file
      (expand-file-name "~/sync/emacs/bookmark-default-file"))

(setq bookmark-save-flag 1)

(setq calendar-week-start-day 1)

(defun ax/open-calendar ()
  "Open a read-only view of the calendar on radicale."
  (interactive)
  (require 'calfw)
  (require 'calfw-ical)
  (calfw-ical-data-cache-clear-all)
  (calfw-open-calendar-buffer
   :contents-sources
   (list (calfw-ical-create-source
          "http://192.168.178.8:5232/ax/calendar/"
          "calendar"
          "IndianRed"))))

(use-package! org-caldav
  :defer t
  :config
  (setq org-caldav-url "http://192.168.178.8:5232/ax"
        org-caldav-calendar-id "calendar"
        org-caldav-inbox "~/org/caldav-inbox.org"
        org-caldav-files '("~/org/todo.org")
        org-caldav-sync-direction 'twoway
        org-caldav-save-directory "~/org/.org-caldav/"
        org-caldav-backup-file "~/org/.org-caldav/backup.org"))

(set-popup-rule! "^\\*org caldav sync result" :size 0.3 :quit t :select nil)

(setq org-icalendar-timezone "Europe/Berlin")
(setq org-icalendar-use-scheduled
      '(event-if-not-todo event-if-todo-not-done))
(setq org-icalendar-use-deadline
      '(event-if-not-todo event-if-todo-not-done))

(set-popup-rule! "^\\*eww" :size 0.8 :quit t)

;; doom doctor suggestions
(setq shell-file-name (executable-find "bash"))
(setq-default vterm-shell "/usr/bin/fish")
(setq-default explicit-shell-file-name "/usr/bin/fish")

;; Prevent Doom from forcing vterm into a bottom popup window.
;; This lets vterm open in the current or split window like any normal buffer.
;; (after! vterm
;;   (set-popup-rule! "^\\*vterm\\*" :ignore t))

(after! org
  (require 'ox-twbs))

;; get rid of the delay after executing delete-pair
(setq delete-pair-blink-delay 0.1)

(use-package! denote
  :hook (dired-mode . denote-dired-mode)
  :config
  (setq denote-directory (expand-file-name "~/org/notes/"))
  (denote-rename-buffer-mode 1))

(setq image-dired-thumb-size 128)

(setq image-dired-external-viewer "nsxiv")

;; https://protesilaos.com/emacs/dired-preview
(setq dired-preview-delay 0.1) ;; default 0.7
(setq dired-preview-max-size (expt 2 20))
(setq dired-preview-ignored-extensions-regexp
        (concat "\\."
                "\\(gz\\|"
                "zst\\|"
                "tar\\|"
                "xz\\|"
                "rar\\|"
                "zip\\|"
                "iso\\|"
                "epub"
                "\\)"))

(after! eat
  (setq shell-file-name "/run/current-system/sw/bin/fish"
        explicit-shell-file-name "/run/current-system/sw/bin/fish"
        eat-shell "/run/current-system/sw/bin/fish"
        eat-term-name "xterm-256color")
  (set-face-foreground 'eat-term-color-0   "#0c1014")
  (set-face-foreground 'eat-term-color-1   "#c23127")
  (set-face-foreground 'eat-term-color-2   "#2aa889")
  (set-face-foreground 'eat-term-color-3   "#edb443")
  (set-face-foreground 'eat-term-color-4   "#195466")
  (set-face-foreground 'eat-term-color-5   "#4e5166")
  (set-face-foreground 'eat-term-color-6   "#33859e")
  (set-face-foreground 'eat-term-color-7   "#99d1ce")
  (set-face-foreground 'eat-term-color-8   "#11151c")
  (set-face-foreground 'eat-term-color-9   "#d26937")
  (set-face-foreground 'eat-term-color-10  "#091f2e")
  (set-face-foreground 'eat-term-color-11  "#245361")
  (set-face-foreground 'eat-term-color-12  "#0a3749")
  (set-face-foreground 'eat-term-color-13  "#888ca6")
  (set-face-foreground 'eat-term-color-14  "#599cab")
  (set-face-foreground 'eat-term-color-15  "#d3ebe9"))

(setenv "FZF_DEFAULT_COMMAND" "fd -u")
(use-package! fzf
  :bind
    ;; Don't forget to set keybinds!
  :config
  (setq fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
        fzf/executable "fzf"
        fzf/git-grep-args "-i --line-number %s"
        ;; command used for `fzf-grep-*` functions
        ;; example usage for ripgrep:
        ;; fzf/grep-command "rg --no-heading -nH"
        fzf/grep-command "grep -nrH"
        ;; If nil, the fzf buffer will appear at the top of the window
        fzf/position-bottom t
        fzf/window-height 35))

(defun ax-tmr-notify-send (timer)
  "Announce finished TIMER via notify-send.
Fall back to `tmr-notification-notify' if notify-send is unavailable."
  (if (executable-find "notify-send")
      (call-process "notify-send" nil 0 nil
                    "-a" "Emacs TMR"
                    "-u" (symbol-name tmr-notification-urgency)
                    "TMR May Ring"
                    (or (tmr--timer-description timer) "Time is up!"))
    (tmr-notification-notify timer)))

(use-package! tmr
  :defer t
  :init
  (define-key global-map (kbd "C-c t") #'tmr-prefix-map)
  :config
  (setq tmr-sound-file (expand-file-name "sounds/alarm.ogg" doom-user-dir)
        tmr-notification-urgency 'normal)
  (remove-hook 'tmr-timer-finished-functions #'tmr-notification-notify)
  (add-hook 'tmr-timer-finished-functions #'ax-tmr-notify-send))

(after! lsp-mode
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-show-with-cursor t
        lsp-ui-doc-position 'top))  ; Position pop-up at top of window

(after! cider
  (add-hook 'cider-mode-hook #'lsp)
  (setq cider-doc-view-function #'cider-docview-inline-symbol)  ; Inline docs with examples
  (set-popup-rule! "^\\*cider-repl" :side 'right :size 0.4 :quit nil :ttl nil)
  (map! :map cider-mode-map
        :localleader
        (:prefix ("e" . "eval")
         :desc "Eval defun up to point" "p" #'cider-eval-defun-up-to-point)))

;; (add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)

(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '(janet-mode . "janet"))
  (lsp-register-client
    (make-lsp-client
      :new-connection (lsp-stdio-connection "janet-lsp")
      :activation-fn (lsp-activate-on "janet")
      :server-id 'janet-lsp)))

(use-package! janet-mode
  :mode "\\.janet\\'"
  :config
  (add-hook 'janet-mode-hook (lambda () (setq indent-tabs-mode nil)))
  (add-hook 'janet-mode-hook #'lsp))

(use-package! ajrepl
  :after janet-mode
  :config
  (add-hook 'janet-mode-hook #'ajrepl-interaction-mode))

(defvar ax/joker-executable "joker"
  "Name or path of the joker binary.")

(defvar ax/joker--namespace-cache nil
  "Cached list of namespace names known to joker.")

(defun ax/joker--ns-form ()
  "Return the buffer's leading (ns ...) form as a string, or nil."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "^(ns\\_>" nil t)
      (goto-char (match-beginning 0))
      (let ((beg (point)))
        (when (ignore-errors (forward-sexp) t)
          (buffer-substring-no-properties beg (point)))))))

(defun ax/joker--with-ns (expr)
  "Prefix EXPR with the buffer's ns form, so namespace aliases resolve."
  (let ((ns (ax/joker--ns-form)))
    (if ns (concat ns " " expr) expr)))

(defun ax/joker--symbol-at-point ()
  "Return the joker symbol at point as a string, or nil.
Numbers, keywords and reader macros are rejected, and so is a half-typed
name like \"os/\": joker reads a dangling slash as an error rather than a
symbol, and while you are still typing that is the common case."
  (let ((sym (thing-at-point 'symbol t)))
    (and sym
         (string-match-p "\\`[^0-9:#/][^/]*\\(/[^/]+\\)?\\'" sym)
         sym)))

(defun ax/joker--run (expr)
  "Evaluate EXPR with joker, from the current file's directory.
Return a cons cell of (EXIT-CODE . TRIMMED-OUTPUT)."
  (let ((dir (or (and buffer-file-name (file-name-directory buffer-file-name))
                 default-directory)))
    (with-temp-buffer
      (setq default-directory dir)
      (let ((exit (call-process ax/joker-executable nil t nil "--eval" expr)))
        (cons exit (string-trim (buffer-string)))))))

(defun ax/joker--lines (expr)
  "Return the lines EXPR prints, as a list, or nil if joker errored."
  (let ((res (ax/joker--run expr)))
    (and (zerop (car res)) (split-string (cdr res) "\n" t))))

(defun ax/joker--run-async (expr callback)
  "Evaluate EXPR with joker without blocking, then CALLBACK with its output."
  (when (executable-find ax/joker-executable)
    (let* ((default-directory
            (or (and buffer-file-name (file-name-directory buffer-file-name))
                default-directory))
           (out (generate-new-buffer " *joker-async*")))
      (make-process
       :name "joker" :buffer out :noquery t :connection-type 'pipe
       :command (list ax/joker-executable "--eval" expr)
       :sentinel
       ;; The process buffer catches stderr too, so a joker error would
       ;; otherwise be handed to the caller as if it were documentation.
       ;; Gate on the exit status and stay silent on failure.
       (lambda (proc _event)
         (unless (process-live-p proc)
           (let ((text (with-current-buffer out (string-trim (buffer-string))))
                 (ok (zerop (process-exit-status proc))))
             (kill-buffer out)
             (when ok (funcall callback text)))))))))

(defun ax/joker--popup (name text)
  "Show TEXT in a popup buffer called NAME."
  (let ((buf (get-buffer-create name)))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert text)
        (goto-char (point-min)))
      (unless (derived-mode-p 'special-mode) (special-mode)))
    (display-buffer buf)
    buf))

(set-popup-rule! "^\\*joker-doc\\*" :size 0.3 :quit t :select t)

(defun ax/joker-doc (&optional symbol)
  "Show joker's documentation for SYMBOL, or for the symbol at point."
  (interactive)
  (let ((sym (or symbol (ax/joker--symbol-at-point))))
    (unless sym (user-error "No joker symbol at point"))
    (let* ((expr (format "(joker.repl/doc %s)" sym))
           (res (ax/joker--run (ax/joker--with-ns expr))))
      ;; An unreachable :require aborts the whole expression, prelude included;
      ;; retry bare so fully-qualified lookups still work.
      (unless (zerop (car res))
        (setq res (ax/joker--run expr)))
      (if (or (not (zerop (car res))) (string-empty-p (cdr res)))
          (ignore (message "No joker docs for %s" sym))
        (ax/joker--popup "*joker-doc*" (cdr res))
        'deferred))))

(defun ax/joker-apropos (pattern)
  "Pick one of the joker vars matching PATTERN and document it."
  (interactive "sJoker apropos: ")
  (if-let* ((matches (ax/joker--lines
                      (format "(doseq [s (joker.repl/apropos %S)] (println s))"
                              pattern))))
      (ax/joker-doc (completing-read "Joker symbol: " matches nil t))
    (message "Nothing in joker matches %s" pattern)))

(defun ax/joker--namespaces ()
  "Return every namespace joker knows about. Cached; joker's set is fixed."
  (or ax/joker--namespace-cache
      (setq ax/joker--namespace-cache
            (ax/joker--lines
             "(doseq [n (sort (map str (all-ns)))] (println n))"))))

(defun ax/joker-dir (ns)
  "Pick one of the public vars of joker namespace NS and document it.
`joker.repl/dir' prints bare names, so NS goes back on before the lookup."
  (interactive (list (completing-read "Joker namespace: "
                                      (ax/joker--namespaces) nil t)))
  (if-let* ((vars (ax/joker--lines (format "(joker.repl/dir %s)" ns))))
      (ax/joker-doc (concat ns "/" (completing-read (format "%s/" ns) vars nil t)))
    (message "No public vars in %s" ns)))

(defun ax/joker-eldoc-function (callback &rest _)
  "Eldoc backend for the joker symbol at point.
Returns the signature followed by the docstring."
  (when-let* ((sym (ax/joker--symbol-at-point)))
    (ax/joker--run-async
     (ax/joker--with-ns
      (format (concat "(let [m (meta (resolve '%s))]"
                      " (when m"
                      "   (println (str (:ns m) \"/\" (:name m)"
                      "                 \" \" (:arglists m)))"
                      "   (when (:doc m) (println (:doc m)))))")
              sym))
     (lambda (out)
       (unless (string-empty-p out)
         (funcall callback out))))
    t))

(add-hook! 'joker-mode-hook
  (defun ax/joker-init-eldoc-h ()
    (add-hook 'eldoc-documentation-functions #'ax/joker-eldoc-function nil t)
    (eldoc-mode +1)))

(defvar-local ax/joker--completions nil)
(defvar-local ax/joker--completions-key nil)

(defconst ax/joker--completions-expr
  (concat "(doseq [n (all-ns)]"
          "  (println (str n))"
          "  (doseq [[k _] (ns-publics n)] (println (str n \"/\" k))))"
          " (doseq [[k _] (ns-publics 'joker.core)] (println (str k)))")
  "Candidates that need no namespace context: namespaces, every var fully
qualified, and the bare `joker.core' names.")

(defconst ax/joker--aliases-expr
  (concat " (doseq [[a n] (ns-aliases *ns*)]"
          "   (doseq [[k _] (ns-publics n)] (println (str a \"/\" k))))")
  "Alias-qualified candidates. Needs the buffer's ns form to have run.")

(defun ax/joker--completions ()
  "Return joker completion candidates for this buffer, cached per ns form.
Falls back to the context-free candidates when the ns form does not
evaluate — a `:require' of a sibling file that joker cannot reach would
otherwise leave the buffer with no completion at all, and silently."
  (let ((key (ax/joker--ns-form)))
    (unless (and ax/joker--completions
                 (equal key ax/joker--completions-key))
      (setq ax/joker--completions-key key
            ax/joker--completions
            (or (ax/joker--lines
                 (ax/joker--with-ns (concat ax/joker--completions-expr
                                            ax/joker--aliases-expr)))
                (ax/joker--lines ax/joker--completions-expr))))
    ax/joker--completions))

(defun ax/joker-complete-at-point ()
  "Complete the joker symbol at point.
`:exclusive' stays no, so dabbrev and friends still get a turn."
  (when-let* ((bounds (bounds-of-thing-at-point 'symbol)))
    (list (car bounds) (cdr bounds)
          (ax/joker--completions)
          :exclusive 'no)))

(add-hook! 'joker-mode-hook
  (defun ax/joker-init-capf-h ()
    (add-hook 'completion-at-point-functions #'ax/joker-complete-at-point nil t)))

(after! flycheck
  (flycheck-define-checker joker
    "A Joker syntax and lint checker, using `joker --lint'."
    :command ("joker" "--dialect" "joker" "--lint" "-")
    :standard-input t
    :error-patterns
    ((error   line-start "<stdin>:" line ":" column ": "
              (0+ not-newline) (or "error: " "Exception: ") (message) line-end)
     (warning line-start "<stdin>:" line ":" column ": "
              (0+ not-newline) "warning: " (message) line-end))
    :modes (joker-mode))
  (add-to-list 'flycheck-checkers 'joker))

(defun ax/joker-eval-region (beg end)
  "Evaluate the region between BEG and END with joker."
  (let ((res (ax/joker--run
              (ax/joker--with-ns (buffer-substring-no-properties beg end)))))
    (+eval-display-results (if (string-empty-p (cdr res)) "nil" (cdr res))
                           (current-buffer))
    t))

(defun ax/joker--sexp-end ()
  "Return the position just past the form before point.
Evil's normal state leaves point ON the closing paren rather than after
it. Taking `point' as-is there makes `backward-sexp' walk back over the
last inner form instead, so (reduce + [1 2 3]) evaluates to [1 2 3]."
  (if (and (bound-and-true-p evil-local-mode)
           (not (memq (bound-and-true-p evil-state) '(insert emacs)))
           (not (eobp)))
      (1+ (point))
    (point)))

(defun ax/joker-eval-last-sexp ()
  "Evaluate the form before point with joker."
  (interactive)
  (let* ((end (ax/joker--sexp-end))
         (beg (save-excursion (goto-char end) (backward-sexp) (point))))
    (ax/joker-eval-region beg end)))

(defun ax/joker-eval-defun ()
  "Evaluate the top-level form around point with joker.
The bounds are taken first so the result overlay lands at point, rather
than at the start of the defun."
  (interactive)
  (let ((bounds (save-excursion
                  (end-of-defun)
                  (let ((end (point)))
                    (beginning-of-defun)
                    (cons (point) end)))))
    (ax/joker-eval-region (car bounds) (cdr bounds))))

(defun ax/joker-repl ()
  "Open a joker REPL in a comint buffer."
  (interactive)
  (let ((buf (get-buffer-create "*joker-repl*")))
    (unless (comint-check-proc buf)
      (make-comint-in-buffer "joker" buf ax/joker-executable nil "--no-readline")
      (with-current-buffer buf
        (setq-local comint-prompt-regexp "^[^>\n]*=> *")
        (setq-local comint-prompt-read-only t)))
    buf))

(defun ax/joker-format-buffer ()
  "Reformat the current buffer with `joker --format'."
  (interactive)
  (let ((tmp (generate-new-buffer " *joker-format*")))
    (unwind-protect
        (let ((exit (call-process-region (point-min) (point-max)
                                         ax/joker-executable nil tmp nil
                                         "--format" "-")))
          (if (and (integerp exit) (zerop exit) (> (buffer-size tmp) 0))
              (replace-buffer-contents tmp)
            (message "joker --format failed: %s"
                     (with-current-buffer tmp (string-trim (buffer-string))))))
      (kill-buffer tmp))))

(after! clojure-mode
  (set-lookup-handlers! 'joker-mode
    :documentation #'ax/joker-doc)
  (set-eval-handler! 'joker-mode #'ax/joker-eval-region)
  (set-repl-handler! 'joker-mode #'ax/joker-repl :persist t)

  ;; Without this `C-x C-e' stays `eval-last-sexp', which would quietly read the
  ;; form as Emacs Lisp instead of joker.
  (map! :map joker-mode-map
        "C-x C-e" #'ax/joker-eval-last-sexp)

  (map! :map joker-mode-map
        :localleader
        :desc "Format buffer" "=" #'ax/joker-format-buffer
        (:prefix ("e" . "eval")
         :desc "Eval buffer"    "b" #'+eval/buffer
         :desc "Eval defun"     "d" #'ax/joker-eval-defun
         :desc "Eval last sexp" "e" #'ax/joker-eval-last-sexp
         :desc "Eval region"    "r" #'+eval/region)
        (:prefix ("h" . "help")
         :desc "Doc for symbol"   "d" #'ax/joker-doc
         :desc "Apropos"          "a" #'ax/joker-apropos
         :desc "Browse namespace" "n" #'ax/joker-dir)
        (:prefix ("r" . "repl")
         :desc "Open repl"      "r" #'+eval/open-repl-other-window
         :desc "Send to repl"   "b" #'+eval/buffer-or-region-in-repl)))

(after!
 consult
 (consult-customize
  consult-theme :preview-key '(:debounce 0.2 any)
  consult-ripgrep
  consult-git-grep
  consult-grep
  consult-man
  consult-bookmark
  consult-recent-file
  consult-xref
  ;; :preview-key "M-."
  :preview-key '(:debounce 0.4 any)))

(setq doom-font (font-spec :family "Hack Nerd Font" :size 16 :weight 'semi-light))

(defvar ax/doom-active-theme-file (expand-file-name "~/.config/doom/active-theme.el"))

;; Load active theme from symlink if present, else fall back to gotham
(if (file-exists-p ax/doom-active-theme-file)
    (load-file ax/doom-active-theme-file)
  (setq doom-theme 'gotham))

;; Watch doom config dir so symlink swaps are picked up at runtime
(require 'filenotify)
(file-notify-add-watch (file-truename (expand-file-name "~/.config/doom/")) '(change)
  (lambda (event)
    (when (and (memq (nth 1 event) '(created changed))
               (string-suffix-p "active-theme.el" (nth 2 event)))
      (load-file ax/doom-active-theme-file))))

(custom-theme-set-faces!
 'the-matrix
 '(mode-line          :background "#000000" :foreground "#00733d" :box (:color "#00b25f"))
 '(mode-line-inactive :background "#000000" :foreground "#00733d" :box (:color "#004022"))
 '(powerline-active0   :inherit mode-line :background "#000000")
 '(powerline-active1   :inherit mode-line :background "#01120a")
 '(powerline-active2   :inherit mode-line :background "#011f11")
 '(powerline-inactive0 :inherit mode-line-inactive :background "#000000")
 '(powerline-inactive1 :inherit mode-line-inactive :background "#000000")
 '(powerline-inactive2 :inherit mode-line-inactive :background "#000000"))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; (setq elfeed-db-directory (expand-file-name "~/sync/emacs/elfeed"))

(after! elfeed
  (setq-default elfeed-search-filter "@3-days-ago +unread"))

(use-package emms
  :config
  (require 'emms-setup)
  (require 'emms-mpris)
  (emms-all)
  (emms-default-players)
  (emms-mpris-enable)
  :custom
  (emms-browser-covers #'emms-browser-cache-thumbnail-async) ; without this, no covers in browser
  :bind ; TODO use evil binds and move to keybindings
  (("C-c w m b" . emms-browser)
   ("C-c w m e" . emms)
   ("C-c w m p" . emms-play-playlist )
   ("<XF86AudioPrev>" . emms-previous)
   ("<XF86AudioNext>" . emms-next)
   ("<XF86AudioPlay>" . emms-pause)))

(setq emms-browser-playlist-info-title-format "%T. %t")

(defun ax/open-emms-layout ()
  "Open the EMMS browser on the left and a playlist on the right."
  (interactive)
  (delete-other-windows)
  (split-window-right)
  (other-window 0)
  (emms-browser)
  (other-window 1)
  (emms-playlist-mode-go))

(defun ax/trigger-scrobble (status)
  "Run when a song starts or finishes. STATUS should be either 'started or 'finished."
  (let* ((track (emms-playlist-current-selected-track))
         (title (emms-track-get track 'info-title))
         (artist (emms-track-get track 'info-artist))
         (album (emms-track-get track 'info-album))
         (message-text (format "%s — %s" (or artist "Unknown artist") (or title "Unknown title")))
         (status-text (if (eq status 'started) "Now playing" "Finished playing")))
    (message "%s: %s" status-text message-text)
    ;; (shell-command (format "notify-send '%s' '%s'" status-text message-text))
    
    (shell-command
     (format "nix develop ~/my/scripts/lastfm --command python ~/my/scripts/lastfm/scrobble.py %s %s %s"
         ;; shell-quote-argument helps when eg title is multiple words, so we only pass exactly 3 args to python
         (shell-quote-argument (or artist "Unknown artist"))
         (shell-quote-argument (or album "Unknown album"))
         (shell-quote-argument (or title "Unknown title"))))))

(add-hook 'emms-player-started-hook
          (lambda () (ax/trigger-scrobble 'started)))

(defun thanos/wtype-text (text)
  "Process TEXT for wtype, handling newlines properly."
  (let* ((has-final-newline (string-match-p "\n$" text))
         (lines (split-string text "\n"))
         (last-idx (1- (length lines))))
    (string-join
     (cl-loop for line in lines
              for i from 0
              collect (cond
                       ;; Last line without final newline
                       ((and (= i last-idx) (not has-final-newline))
                        (format "wtype -s 350 \"%s\"" 
                                (replace-regexp-in-string "\"" "\\\\\"" line)))
                       ;; Any other line
                       (t
                        (format "wtype -s 350 \"%s\" && wtype -k Return" 
                                (replace-regexp-in-string "\"" "\\\\\"" line)))))
     " && ")))

(defun thanos/type ()
  "Launch a temporary frame with a clean buffer for typing."
  (interactive)
  (let ((frame (make-frame '((name . "emacs-float")
                             (fullscreen . 0)
                             (undecorated . t)
                             (width . 70)
                             (height . 20))))
        (buf (get-buffer-create "emacs-float")))
    (select-frame frame)
    (switch-to-buffer buf)
    (erase-buffer)
    (org-mode)
    (setq-local header-line-format
                (format " %s to insert text or %s to cancel."
                        (propertize "C-c C-c" 'face 'help-key-binding)
			(propertize "C-c C-k" 'face 'help-key-binding)))
    (local-set-key (kbd "C-c C-k")
		   (lambda () (interactive)
		     (kill-new (buffer-string))
		     (delete-frame)))
    (local-set-key (kbd "C-c C-c")
		   (lambda () (interactive)
		     (start-process-shell-command
		      "wtype" nil
		      (thanos/wtype-text (buffer-string)))
		     (delete-frame)))))

(defun ax/git-count-commits ()
  "Count the number of commits in the current Git repository
   using \='git log --oneline | wc -l\='."
  (interactive)
  (message "Number of commits: %s"
           (string-trim (shell-command-to-string "git log --oneline | wc -l"))))

(defun ax/org-fold-all-list-items ()
  "Fold every plain-list item in the current Org buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward (org-item-beginning-re) nil t)
      (forward-line 0)
      (if (org-at-item-p)
          (let* ((struct (org-list-struct))
                 (end (org-list-get-bottom-point struct)))
            (dolist (item (org-list-get-all-items
                           (point) struct (org-list-prevs-alist struct)))
              (org-list-set-item-visibility item struct 'folded))
            (goto-char end))
        (forward-line 1)))))

(defun ax/toggle-dashboard ()
  (interactive)
  (if (string= (buffer-name) "*doom*")
      (switch-to-buffer (other-buffer (current-buffer) t))
    (switch-to-buffer "*doom*")))

(map! :leader
      :desc "Toggle line comment" "-" #'comment-line)

(map! :leader
      :prefix "w"
      :desc "Horizontal split" "z" #'evil-window-split)

(map! :leader
      (:prefix-map ("j" . "ax custom binds")
       ;; non-nested
       (:desc "org-capture" "j" #'org-capture)
       (:desc "toggle the calm doom buffer" "k" #'ax/toggle-dashboard)
       (:desc "Toggle Dired Preview (global)" "p" #'dired-preview-global-mode)
       (:desc "winner-undo" "u" #'winner-undo)
       (:desc "winner-redo" "U" #'winner-redo)
       (:desc "org-publish to vps" "v" #'ax/publish-site)
       (:desc "visually select a window" "w" #'ace-window)
       (:desc "open terminal (eat)" "RET" #'eat)
       ;; nested
       (:prefix ("c" . "calendar")
        :desc "org-caldav sync" "s" #'org-caldav-sync
        :desc "open calendar view" "c" #'ax/open-calendar)
       (:prefix ("d" . "dirvish / delete")
        :desc "dirvish-fd" "f" #'dirvish-fd
        :desc "dired-do-kill-lines" "k" #'dired-do-kill-lines
        :desc "dirvish-move" "m" #'dirvish-move
        :desc "dirvish-narrow" "n" #'dirvish-narrow
        :desc "delete-pair" "p" #'delete-pair)
       (:prefix ("e" . "elfeed")
        :desc "elfeed" "e" #'elfeed
        :desc "elfeed update" "u" #'elfeed-update)
       (:prefix ("f" . "fzf")
        :desc "Starts fzf session in dir" "f" #'fzf-directory
        :desc "consult-git-grep" "g" #'consult-git-grep
        :desc "consult-ripgrep" "r" #'consult-ripgrep)
       (:prefix ("t" . "t bindings")
        :desc "org-babel-tangle" "t" #'org-babel-tangle)))

(map! :leader
      (:prefix ("t" . "toggle")
       :desc "Toggle line highlight in frame" "h" #'hl-line-mode
       :desc "Toggle line highlight globally" "H" #'global-hl-line-mode
       :desc "Toggle markdown-view-mode"      "M" #'ax/toggle-markdown-mode
       :desc "Toggle truncate lines"          "T" #'toggle-truncate-lines
       :desc "Toggle zen"                     "z" #'+zen/toggle
       :desc "Toggle zen"                     "Z" #'+zen/toggle-fullscreen
       :desc "Toggle treemacs"                "t" #'+treemacs/toggle))

(after! magit
  (setq magit-section-initial-visibility-alist
        '((unpulled . show)
          (unpushed . show))))

(custom-set-faces
 '(markdown-header-face ((t (:inherit font-lock-function-name-face :weight bold :family "variable-pitch"))))
 '(markdown-header-face-1 ((t (:inherit markdown-header-face :height 1.6))))
 '(markdown-header-face-2 ((t (:inherit markdown-header-face :height 1.5))))
 '(markdown-header-face-3 ((t (:inherit markdown-header-face :height 1.4))))
 '(markdown-header-face-4 ((t (:inherit markdown-header-face :height 1.3))))
 '(markdown-header-face-5 ((t (:inherit markdown-header-face :height 1.2))))
 '(markdown-header-face-6 ((t (:inherit markdown-header-face :height 1.1)))))

(defun ax/toggle-markdown-mode ()
  "Toggle between `markdown-mode` and `markdown-view-mode`."
  (interactive)
  (if (eq major-mode 'markdown-view-mode)
      (markdown-mode)
    (markdown-view-mode)))

(when-let* ((gdiff (executable-find "gdiff")))
  (setq diff-command gdiff))

(when-let* ((gls (executable-find "gls")))
  (setq insert-directory-program gls))

(setq org-directory "~/org/")

(custom-set-faces!
  '(org-level-1 :height 1.5)
  '(org-level-2 :height 1.4)
  '(org-level-3 :height 1.3)
  '(org-level-4 :height 1.2)
  '(org-level-5 :height 1.1)
  '(org-document-title :height 1.7))

(defun ax/org-collapse-except-dashed ()
  "Collapse all; show child headings of level-1 headings starting with \"-- \"."
  (interactive)
  (if (fboundp 'org-cycle-overview) (org-cycle-overview) (org-overview))
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^\\* -- " nil t)
      (when (org-at-heading-p)
        (if (fboundp 'org-fold-show-children)
            (org-fold-show-children)
          (org-show-children))))))

(defun ax/org-maybe-collapse-except-dashed ()
  "Apply `ax/org-collapse-except-dashed' when visiting ~/org/todo.org."
  (when (and buffer-file-name
             (file-equal-p buffer-file-name (expand-file-name "~/org/todo.org")))
    (ax/org-collapse-except-dashed)))

(add-hook 'find-file-hook #'ax/org-maybe-collapse-except-dashed)

(defvar ax/vps0-src-dir "/ssh:vps:/usr/local/www/mysite-src/")

(defvar ax/vps0-nav-cache nil
  "Cached contents of nav.html, reset at the start of each publish run.")

(defun ax/vps0-nav-preamble (_info)
  "Return the site nav HTML, read from nav.html in `ax/vps0-src-dir'."
  (or ax/vps0-nav-cache
      (setq ax/vps0-nav-cache
            (let ((f (expand-file-name "nav.html" ax/vps0-src-dir)))
              (unless (file-readable-p f)
                (user-error "ax: nav.html not readable at %s" f))
              (with-temp-buffer
                (insert-file-contents f)
                (buffer-string))))))

(setq org-publish-project-alist
      `(("ax-vps0"
         :base-directory ,ax/vps0-src-dir
         :base-extension "org"
         :publishing-directory "/ssh:vps:/usr/local/www/mysite/"
         :publishing-function org-html-publish-to-html
         :recursive t
         :section-numbers nil
         :html-preamble ax/vps0-nav-preamble)
        ("ax-images"
         :base-directory ,(concat ax/vps0-src-dir "assets/")
         :base-extension "png\\|jpg\\|jpeg\\|gif\\|svg\\|webp"
         :publishing-directory "/ssh:vps:/usr/local/www/mysite/assets/"
         :recursive t
         :publishing-function org-publish-attachment)
        ("ax-website"
         :components ("ax-vps0" "ax-images"))))

(defun ax/publish-site ()
  "Publish the whole ax-website project (HTML + images), forcing a full rebuild.
Also drops the cached nav so nav.html edits are picked up."
  (interactive)
  (setq ax/vps0-nav-cache nil)
  (org-publish "ax-website" t))

(setq ispell-program-name "hunspell")

;; ax-x1c = OpenBSD (special case), everything else = NixOS
(if (string-match-p "ax-x1c" (system-name))
    ;; === OpenBSD settings ===
    (progn
      (setq ispell-dictionary "en-GB,de-DE")
      (setq ispell-local-dictionary "en-GB,de-DE")
      (setq ispell-hunspell-dictionary-alist
            '(("en-GB,de-DE" "[[:alpha:]]" "[^[:alpha:]]" "'" nil ("-d" "en-GB,de-DE") nil utf-8))))

  ;; === NixOS settings (default) ===
  (progn
    (setq ispell-dictionary "en_US,de_DE")
    (setq ispell-local-dictionary "en_US,de_DE")
    (setq ispell-hunspell-dictionary-alist
          '(("en_US,de_DE" "[[:alpha:]]" "[^[:alpha:]]" "'" nil ("-d" "en_US,de_DE") nil utf-8)))
    ;; Plain word list for ispell word completion (ispell-completion-at-point,
    ;; the source of dictionary suggestions in corfu). NixOS has no
    ;; /usr/share/dict/words, so this file is provisioned by home-manager
    ;; (pkgs-extra.nix -> ~/.local/share/dict/words). Without it the ispell capf
    ;; errors and Doom silently disables it, leaving only dabbrev.
    (setq ispell-alternate-dictionary (expand-file-name "~/.local/share/dict/words"))
    ;; Use grep instead of `look' so word order / UTF-8 umlauts in the German
    ;; entries don't break look's binary search. The file is small; speed is fine.
    (setq ispell-look-p nil)))

(load-file "/home/ax/x/ax.el")

(load-file "/home/ax/x/cljbang/axc.el")
