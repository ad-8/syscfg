;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq abbrev-file-name "~/sync/emacs/abbrev_defs")
(setq save-abbrevs 'silently)

(defvar ax/1080p-font-size 12
  "Font size for 1080p displays.")

(defvar ax/4k-font-size 18
  "Font size for 4K / high-resolution displays.")

(defvar ax/monitor-font--timer nil)
(defvar ax/monitor-font--last-size nil)

(defun ax/set-font-for-monitor (&optional frame)
  "Set doom font size based on the current monitor (poll-friendly)."
  (when (display-graphic-p)
    (let* ((frame (or frame (selected-frame)))
           (geometry (frame-monitor-attribute 'geometry frame))
           (scale (or (frame-monitor-attribute 'scale-factor frame) 1))
           (width (and geometry (nth 2 geometry)))
           (size (when width
                   (let ((effective-width (* width scale)))
                     (if (> effective-width 3000)
                         ax/4k-font-size
                       ax/1080p-font-size)))))

      (when (and size (not (equal size ax/monitor-font--last-size)))
        (setq ax/monitor-font--last-size size)
        (setq doom-font (font-spec :family "Hack Nerd Font" :size size))
        (when (fboundp 'doom/reload-font)
          (doom/reload-font))
        ;; Show in the echo area (bottom/statusline area)
        (message "Font changed: %s" size)))))

(let ((hn (string-trim (system-name))))
  (when (and hn (string-match-p "\\`ax-bee\\'" hn))
    ;; Apply once right now
    (when (display-graphic-p)
      (ax/set-font-for-monitor (selected-frame)))

    ;; Poll to detect monitor changes even when focus doesn't change (Hyprland)
    (when ax/monitor-font--timer
      (cancel-timer ax/monitor-font--timer))
    (setq ax/monitor-font--timer
          (run-with-timer 0 1.0 (lambda () (ax/set-font-for-monitor (selected-frame)))))))

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
(setq-default explicit-shell-file-name (executable-find "fish"))

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

(defface ax/dirvish-modeline '((t))
  "Laid over dirvish's modeline segments; empty unless a theme sets it.")

(defun ax/dirvish-ml-face (str)
  (when (stringp str) (add-face-text-property 0 (length str) 'ax/dirvish-modeline nil str))
  str)

(after! dirvish
  (dolist (seg (append (plist-get dirvish-mode-line-format :left)
                       (plist-get dirvish-mode-line-format :right)))
    (advice-add (intern (format "dirvish-%s-ml" seg)) :filter-return #'ax/dirvish-ml-face)))

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
  (setq tmr-sound-file (expand-file-name "~/sync/emacs/alarm.ogg")
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
 '(mode-line-inactive :background "#000000" :foreground "#00733d" :box (:color "#004022")))

(custom-theme-set-faces!
 'the-matrix
 '(org-agenda-done                  :foreground "#00733d")
 '(elfeed-search-title-face         :foreground "#00733d")
 '(org-agenda-structure             :foreground "#00cd6d")
 '(org-agenda-date-weekend          :foreground "#00733d" :weight bold)
 '(org-agenda-date-today            :foreground "#00ff88" :weight bold :slant italic))

(custom-theme-set-faces!
 'the-matrix
 '(org-scheduled                 :foreground "#00b25f")
 '(org-scheduled-today           :foreground "#00b25f")
 '(org-scheduled-previously      :foreground "#0081c7")
 '(org-upcoming-deadline         :foreground "#0081c7")
 '(org-time-grid                 :foreground "#00733d")
 '(org-agenda-current-time       :foreground "#00e57a")
 '(org-agenda-dimmed-todo-face   :foreground "#00733d" :slant italic)
 '(org-habit-clear-face          :background "#0081c7" :foreground "#000000")
 '(org-habit-clear-future-face   :background "#001e2e")
 '(org-habit-ready-face          :background "#00b25f" :foreground "#000000")
 '(org-habit-ready-future-face   :background "#004022")
 '(org-habit-overdue-face        :background "#cc0037" :foreground "#000000")
 '(org-habit-overdue-future-face :background "#30000c")
 '(org-ellipsis                  :foreground "#00733d")
 '(org-footnote                  :foreground "#00cd6d" :underline t)
 '(org-formula                   :foreground "#00cd6d")
 '(org-sexp-date                 :foreground "#00cd6d")
 '(org-clock-overlay             :background "#004022" :foreground "#00e57a")
 '(org-column                    :background "#011f11" :weight normal :slant normal :strike-through nil :underline nil)
 '(org-column-title              :background "#011f11" :underline t :weight bold)
 '(org-agenda-restriction-lock   :background "#011f11")
 '(org-dispatcher-highlight      :background "#004022" :foreground "#00ff88" :weight bold)
 '(org-mode-line-clock-overrun   :inherit mode-line :background "#cc0037" :foreground "#000000"))

(custom-theme-set-faces!
 'the-matrix
 '(org-modern-date-active         :inherit org-modern-label :background "#011f11" :foreground "#00b25f")
 '(org-modern-date-inactive       :inherit org-modern-label :background "#011f11" :foreground "#00733d")
 '(org-modern-time-active         :inherit org-modern-label :weight semibold :background "#004022" :foreground "#00e57a")
 '(org-modern-time-inactive       :inherit org-modern-label :background "#011f11" :foreground "#00733d")
 '(org-modern-done                :inherit org-modern-label :background "#011f11" :foreground "#00733d")
 '(org-modern-tag                 :inherit (secondary-selection org-modern-label) :foreground "#00cd6d")
 '(org-modern-progress-complete   :background "#00b25f" :foreground "#000000")
 '(org-modern-progress-incomplete :background "#011f11" :foreground "#00b25f")
 '(org-modern-horizontal-rule     :underline "#004022" :extend t))

(custom-theme-set-faces!
 'the-matrix
 '(window-divider             :foreground "#00733d")
 '(window-divider-first-pixel :foreground "#00733d")
 '(window-divider-last-pixel  :foreground "#00733d")
 '(eros-result-overlay-face   :background "#011f11" :box (:line-width -1 :color "#00733d"))
 '(tooltip                    :background "#011f11" :foreground "#00b25f" :inherit variable-pitch)
 '(minibuffer-nonselected     :background "#004022" :foreground "#00ff88" :weight bold)
 '(tab-bar-tab-highlight      :box (:line-width 1 :style released-button) :background "#004022" :foreground "#00e57a")
 '(pulse-highlight-start-face :background "#004022")
 '(pulse-highlight-face       :background "#004022")
 '(bookmark-face              :foreground "#00cd6d")
 '(isearch-group-1            :background "#004022" :foreground "#00ff88")
 '(isearch-group-2            :background "#011f11" :foreground "#00e57a")
 '(homoglyph                  :foreground "#0081c7")
 '(nobreak-hyphen             :foreground "#0081c7")
 '(diary                      :foreground "#00e57a")
 '(holiday                    :background "#004022")
 '(ansi-color-bright-black    :foreground "#00733d" :background "#00733d")
 '(ansi-color-bright-red      :foreground "#cc0037" :background "#cc0037")
 '(ansi-color-bright-green    :foreground "#00ff88" :background "#00ff88")
 '(ansi-color-bright-yellow   :foreground "#00ff88" :background "#00ff88")
 '(ansi-color-bright-blue     :foreground "#0081c7" :background "#0081c7")
 '(ansi-color-bright-magenta  :foreground "#00e57a" :background "#00e57a")
 '(ansi-color-bright-cyan     :foreground "#00e57a" :background "#00e57a")
 '(ansi-color-bright-white    :foreground "#00ff88" :background "#00ff88")
 '(flyspell-incorrect         :underline (:style wave :color "#cc0037"))
 '(flyspell-duplicate         :underline (:style wave :color "#0081c7"))
 '(ibuffer-locked-buffer      :foreground "#0081c7"))

(custom-theme-set-faces!
 'the-matrix
 '(diredfl-dir-heading          :foreground "#00e57a")
 '(diredfl-dir-name             :foreground "#00cd6d" :weight bold)
 '(diredfl-dir-priv             :foreground "#00cd6d" :weight bold)
 '(diredfl-file-name            :foreground "#00b25f")
 '(diredfl-file-suffix          :foreground "#00733d")
 '(diredfl-compressed-file-name   :foreground "#0081c7")
 '(diredfl-compressed-file-suffix :foreground "#0081c7")
 '(diredfl-date-time            :foreground "#00733d")
 '(diredfl-number               :foreground "#00b25f")
 '(diredfl-ignored-file-name    :foreground "#00733d")
 '(diredfl-symlink              :foreground "#0081c7")
 '(diredfl-link-priv            :foreground "#0081c7")
 '(diredfl-executable-tag       :foreground "#0081c7")
 '(diredfl-exec-priv            :foreground "#0081c7")
 '(diredfl-read-priv            :foreground "#00b25f")
 '(diredfl-write-priv           :foreground "#00cd6d")
 '(diredfl-no-priv              :foreground "#00733d")
 '(diredfl-other-priv           :foreground "#00b25f")
 '(diredfl-rare-priv            :foreground "#00cd6d")
 '(diredfl-flag-mark            :foreground "#00ff88" :background "#004022")
 '(diredfl-flag-mark-line       :background "#004022")
 '(diredfl-deletion             :foreground "#cc0037" :background "#30000c")
 '(diredfl-deletion-file-name   :foreground "#cc0037")
 '(diredfl-autofile-name        :background "#011f11")
 '(diredfl-tagged-autofile-name :background "#011f11")
 '(dirvish-file-modes           :foreground "#00733d")
 '(dirvish-file-time            :foreground "#00733d")
 '(dirvish-narrow-match-face-0  :weight bold :foreground "#00e57a")
 '(dirvish-narrow-match-face-1  :weight bold :foreground "#00cd6d")
 '(dirvish-narrow-match-face-2  :weight bold :foreground "#00b25f")
 '(dirvish-narrow-match-face-3  :weight bold :foreground "#00ff88")
 '(dirvish-vc-needs-merge-face  :background "#30000c"))

(custom-theme-set-faces!
 'the-matrix
 '(magit-blame-highlight        :extend t :background "#011f11" :foreground "#00b25f")
 '(magit-dimmed                 :foreground "#00733d")
 '(magit-log-date               :foreground "#00733d" :slant normal :weight normal)
 '(magit-log-graph              :foreground "#00733d")
 '(magit-refname                :foreground "#00733d")
 '(magit-diff-added-indicator   :foreground "#0081c7")
 '(magit-diff-removed-indicator :foreground "#cc0037")
 '(magit-diff-our-heading       :extend t :background "#30000c" :foreground "#cc0037")
 '(magit-diff-their-heading     :extend t :background "#001e2e" :foreground "#0081c7")
 '(magit-diff-base              :extend t :background "#011f11" :foreground "#00b25f")
 '(magit-diff-base-heading      :extend t :background "#004022" :foreground "#00e57a")
 '(magit-diff-base-highlight    :extend t :background "#004022" :foreground "#00b25f")
 '(magit-diff-base-indicator    :foreground "#00b25f")
 '(magit-diff-file-heading-selection :extend t :inherit magit-diff-file-heading-highlight :background "#004022" :foreground "#00ff88")
 '(magit-diff-hunk-heading-selection :extend t :inherit magit-diff-hunk-heading-highlight :background "#004022" :foreground "#00ff88")
 '(magit-diff-lines-heading     :extend t :inherit magit-diff-hunk-heading-highlight :background "#004022" :foreground "#00ff88")
 '(magit-section-heading-selection :extend t :background "#004022" :foreground "#00ff88")
 '(magit-bisect-good            :foreground "#00cd6d")
 '(magit-bisect-bad             :foreground "#cc0037")
 '(magit-bisect-skip            :foreground "#00733d")
 '(magit-cherry-equivalent      :foreground "#00733d")
 '(magit-cherry-unmatched       :foreground "#00cd6d")
 '(magit-process-ng             :inherit magit-section-heading :foreground "#cc0037")
 '(magit-reflog-commit          :foreground "#00cd6d")
 '(magit-reflog-merge           :foreground "#00cd6d")
 '(magit-reflog-cherry-pick     :foreground "#00cd6d")
 '(magit-reflog-amend           :foreground "#00e57a")
 '(magit-reflog-rebase          :foreground "#00e57a")
 '(magit-reflog-checkout        :foreground "#0081c7")
 '(magit-reflog-remote          :foreground "#0081c7")
 '(magit-reflog-other           :foreground "#0081c7")
 '(magit-reflog-reset           :foreground "#cc0037")
 '(magit-sequence-head          :foreground "#0081c7")
 '(magit-sequence-part          :foreground "#00e57a")
 '(magit-sequence-stop          :foreground "#00cd6d")
 '(magit-sequence-drop          :foreground "#cc0037")
 '(magit-signature-good         :foreground "#00cd6d")
 '(magit-signature-bad          :foreground "#cc0037" :weight bold)
 '(magit-signature-untrusted    :foreground "#0081c7")
 '(magit-signature-expired      :foreground "#0081c7")
 '(magit-signature-revoked      :foreground "#cc0037")
 '(magit-signature-error        :foreground "#0081c7")
 '(transient-key-exit           :inherit transient-key :foreground "#00b25f")
 '(transient-key-return         :inherit transient-key :foreground "#00e57a")
 '(transient-key-recurse        :inherit transient-key :foreground "#00ff88")
 '(transient-key-stack          :inherit transient-key :foreground "#00cd6d")
 '(transient-key-noop           :inherit transient-key :foreground "#00733d")
 '(transient-enabled-suffix     :background "#00cd6d" :foreground "#000000" :weight bold)
 '(transient-disabled-suffix    :background "#cc0037" :foreground "#000000" :weight bold)
 '(transient-higher-level       :box (:line-width (-1 . -1) :color "#00733d"))
 '(transient-mismatched-key     :box (:line-width (-1 . -1) :color "#cc0037"))
 '(transient-nonstandard-key    :box (:line-width (-1 . -1) :color "#0081c7"))
 '(diff-indicator-added         :inherit diff-added :foreground "#0081c7")
 '(diff-indicator-changed       :inherit diff-changed :foreground "#00cd6d")
 '(diff-indicator-removed       :inherit diff-removed :foreground "#cc0037")
 '(diff-refine-changed          :background "#004022")
 '(diff-refine-added            :inherit diff-refine-changed :background "#0081c7" :foreground "#000000")
 '(diff-refine-removed          :inherit diff-refine-changed :background "#cc0037" :foreground "#000000")
 '(diff-changed-unspecified     :inherit diff-changed :background "#011f11" :extend t)
 '(diff-error                   :foreground "#cc0037" :background "#000000" :weight bold)
 '(smerge-upper                 :background "#30000c" :extend t)
 '(smerge-lower                 :background "#001e2e" :extend t)
 '(smerge-base                  :background "#011f11" :extend t)
 '(smerge-markers               :background "#004022" :extend t)
 '(smerge-refined-added         :inherit smerge-refined-change :background "#0081c7" :foreground "#000000")
 '(smerge-refined-removed       :inherit smerge-refined-change :background "#cc0037" :foreground "#000000"))

(custom-theme-set-faces!
 'the-matrix
 '(calfw-title-face              :foreground "#00e57a" :weight bold :height 2.0 :inherit variable-pitch)
 '(calfw-header-face             :foreground "#00cd6d" :weight bold)
 '(calfw-sunday-face             :foreground "#00733d" :weight bold)
 '(calfw-saturday-face           :foreground "#00733d" :weight bold)
 '(calfw-holiday-face            :background "#01120a" :foreground "#0081c7" :weight bold)
 '(calfw-grid-face               :foreground "#004022")
 '(calfw-day-title-face          :background "#01120a")
 '(calfw-default-day-face        :weight bold :inherit calfw-day-title-face)
 '(calfw-annotation-face         :foreground "#00733d" :inherit calfw-day-title-face)
 '(calfw-disable-face            :foreground "#00733d" :inherit calfw-day-title-face)
 '(calfw-today-title-face        :background "#004022" :foreground "#00ff88" :weight bold)
 '(calfw-today-face              :foreground "#00ff88" :weight bold)
 '(calfw-default-content-face    :foreground "#00b25f")
 '(calfw-periods-face            :foreground "#0081c7")
 '(calfw-calendar-hidden-face    :foreground "#00733d" :strike-through t)
 '(calfw-toolbar-face            :foreground "#01120a" :background "#01120a")
 '(calfw-toolbar-button-off-face :foreground "#00733d" :weight bold :background "#01120a")
 '(calfw-toolbar-button-on-face  :foreground "#00e57a" :weight bold :background "#01120a"))

(custom-theme-set-faces!
 'the-matrix
 '(emms-playlist-track-face            :foreground "#00b25f")
 '(emms-playlist-selected-face         :foreground "#00ff88")
 '(emms-metaplaylist-mode-face         :foreground "#00b25f")
 '(emms-metaplaylist-mode-current-face :foreground "#00ff88")
 '(emms-browser-year/genre-face        :foreground "#00e57a" :height 1.5)
 '(emms-browser-artist-face            :foreground "#00cd6d" :height 1.3)
 '(emms-browser-albumartist-face       :foreground "#00cd6d" :height 1.3)
 '(emms-browser-composer-face          :foreground "#00cd6d" :height 1.3)
 '(emms-browser-performer-face         :foreground "#00cd6d" :height 1.3)
 '(emms-browser-album-face             :foreground "#00b25f" :height 1.1)
 '(emms-browser-track-face             :foreground "#00b25f" :height 1.0))

(custom-theme-set-faces!
 'the-matrix
 '(lsp-ui-doc-background          :background "#011f11")
 '(lsp-ui-doc-header              :foreground "#000000" :background "#00b25f")
 '(lsp-ui-peek-peek               :background "#01120a")
 '(lsp-ui-peek-list               :background "#01120a")
 '(lsp-ui-peek-header             :background "#004022" :foreground "#00e57a")
 '(lsp-ui-peek-footer             :inherit lsp-ui-peek-header)
 '(lsp-ui-peek-selection          :background "#004022" :foreground "#00ff88")
 '(lsp-ui-peek-highlight          :background "#004022" :foreground "#00ff88" :distant-foreground "#00ff88" :box (:line-width -1 :color "#00ff88"))
 '(lsp-ui-peek-filename           :foreground "#00cd6d")
 '(lsp-ui-peek-line-number        :foreground "#00733d")
 '(lsp-ui-sideline-code-action    :foreground "#0081c7")
 '(lsp-ui-sideline-current-symbol :foreground "#00ff88" :weight ultra-bold :box (:line-width -1 :color "#00ff88") :height 0.99)
 '(lsp-ui-sideline-symbol         :foreground "#00733d" :box (:line-width -1 :color "#00733d") :height 0.99)
 '(lsp-modeline-code-actions-preferred-face :foreground "#0081c7")
 '(lsp-installation-buffer-face          :foreground "#00cd6d")
 '(lsp-installation-finished-buffer-face :foreground "#0081c7")
 '(lsp-dired-path-error-face   :underline (:style wave :color "#cc0037"))
 '(lsp-dired-path-warning-face :underline (:style wave :color "#0081c7"))
 '(lsp-dired-path-info-face    :underline (:style wave :color "#00cd6d"))
 '(lsp-dired-path-hint-face    :underline (:style wave :color "#00cd6d"))
 '(lsp-headerline-breadcrumb-path-warning-face    :underline (:style wave :color "#0081c7") :inherit lsp-headerline-breadcrumb-path-face)
 '(lsp-headerline-breadcrumb-path-info-face       :underline (:style wave :color "#00cd6d") :inherit lsp-headerline-breadcrumb-path-face)
 '(lsp-headerline-breadcrumb-path-hint-face       :underline (:style wave :color "#00cd6d") :inherit lsp-headerline-breadcrumb-path-face)
 '(lsp-headerline-breadcrumb-symbols-error-face   :inherit lsp-headerline-breadcrumb-symbols-face :underline (:style wave :color "#cc0037"))
 '(lsp-headerline-breadcrumb-symbols-warning-face :inherit lsp-headerline-breadcrumb-symbols-face :underline (:style wave :color "#0081c7"))
 '(lsp-headerline-breadcrumb-symbols-info-face    :inherit lsp-headerline-breadcrumb-symbols-face :underline (:style wave :color "#00cd6d"))
 '(lsp-headerline-breadcrumb-symbols-hint-face    :inherit lsp-headerline-breadcrumb-symbols-face :underline (:style wave :color "#00cd6d")))

(custom-theme-set-faces!
 'the-matrix
 '(nrepl-message-1-face :foreground "#0081c7")
 '(nrepl-message-2-face :foreground "#00cd6d")
 '(nrepl-message-3-face :foreground "#00e57a")
 '(nrepl-message-4-face :foreground "#00ff88")
 '(nrepl-message-5-face :foreground "#00b25f")
 '(nrepl-message-6-face :foreground "#0081c7")
 '(nrepl-message-7-face :foreground "#00cd6d")
 '(nrepl-message-8-face :foreground "#00e57a")
 '(cider-macrostep-gensym-1-face :foreground "#0081c7")
 '(cider-macrostep-gensym-2-face :foreground "#00cd6d")
 '(cider-macrostep-gensym-3-face :foreground "#00e57a")
 '(cider-macrostep-gensym-4-face :foreground "#00ff88")
 '(cider-macrostep-gensym-5-face :foreground "#00b25f")
 '(cider-macrostep-gensym-6-face :foreground "#0081c7")
 '(cider-macrostep-gensym-7-face :foreground "#00cd6d")
 '(cider-macrostep-expansion-face :background "#01120a" :extend t)
 '(cider-error-overlay-face      :background "#30000c" :extend t)
 '(cider-debug-code-overlay-face :background "#004022")
 '(cider-deprecated-face         :background "#001e2e")
 '(cider-enlightened-face        :inherit cider-result-overlay-face :box (:color "#00e57a" :line-width -1))
 '(cider-enlightened-local-face  :weight bold :foreground "#00e57a")
 '(cider-fringe-bad-face         :foreground "#cc0037")
 '(cider-fringe-stale-face       :foreground "#0081c7")
 '(cider-instrumented-face       :box (:color "#cc0037" :line-width -1))
 '(cider-traced-face             :box (:color "#0081c7" :line-width -1))
 '(macrostep-expansion-highlight-face :extend t :background "#01120a")
 '(macrostep-gensym-1 :foreground "#0081c7" :box t :bold t)
 '(macrostep-gensym-2 :foreground "#00cd6d" :box t :bold t)
 '(macrostep-gensym-3 :foreground "#00e57a" :box t :bold t)
 '(macrostep-gensym-4 :foreground "#00ff88" :box t :bold t)
 '(macrostep-gensym-5 :foreground "#00b25f" :box t :bold t))

(custom-theme-set-faces!
 'the-matrix
 '(avy-background-face  :foreground "#00733d")
 '(avy-lead-face        :foreground "#000000" :background "#00ff88")
 '(avy-lead-face-0      :foreground "#000000" :background "#0081c7")
 '(avy-lead-face-1      :foreground "#000000" :background "#00b25f")
 '(avy-lead-face-2      :foreground "#000000" :background "#00cd6d")
 '(aw-background-face   :foreground "#00733d")
 '(aw-leading-char-face :foreground "#00ff88")
 '(anzu-match-1         :background "#00cd6d" :foreground "#000000")
 '(anzu-match-2         :background "#00e57a" :foreground "#000000")
 '(anzu-match-3         :background "#0081c7" :foreground "#000000")
 '(anzu-mode-line       :foreground "#00e57a" :weight bold)
 '(anzu-replace-to      :foreground "#00ff88")
 '(corfu-quick1         :background "#0081c7" :foreground "#000000" :inherit bold)
 '(corfu-quick2         :background "#00cd6d" :foreground "#000000" :inherit bold)
 '(corfu-indexed        :height 0.75 :foreground "#00733d" :background "#011f11")
 '(vertico-quick1       :background "#0081c7" :foreground "#000000" :inherit bold)
 '(vertico-quick2       :background "#00cd6d" :foreground "#000000" :inherit bold)
 '(vundo-highlight      :inherit vundo-node :weight bold :foreground "#00ff88")
 '(vundo-saved          :inherit vundo-node :foreground "#00cd6d")
 '(vundo-diff-highlight :inherit vundo-highlight :foreground "#0081c7")
 '(tmr-tabulated-start-time     :foreground "#00733d")
 '(tmr-tabulated-end-time       :foreground "#00cd6d")
 '(tmr-tabulated-remaining-time :foreground "#00e57a")
 '(evil-ex-info                   :slant italic :foreground "#cc0037")
 '(evil-ex-substitute-replacement :underline t :foreground "#cc0037")
 '(sp-wrap-overlay-opening-pair :inherit sp-wrap-overlay-face :foreground "#00cd6d")
 '(sp-wrap-overlay-closing-pair :inherit sp-wrap-overlay-face :foreground "#cc0037")
 '(rainbow-delimiters-base-error-face :inherit rainbow-delimiters-base-face :foreground "#cc0037")
 '(flycheck-annotate-error-background   :background "#30000c" :extend t)
 '(flycheck-annotate-warning-background :background "#001e2e" :extend t)
 '(flycheck-annotate-info-background    :background "#01120a" :extend t)
 '(wgrep-delete-face    :background "#30000c" :foreground "#cc0037")
 '(wgrep-reject-face    :foreground "#cc0037" :weight bold)
 '(markdown-highlighting-face :background "#004022" :foreground "#00ff88")
 '(git-timemachine-minibuffer-author-face :foreground "#00cd6d")
 '(git-timemachine-minibuffer-detail-face :foreground "#00e57a")
 '(tldr-title           :foreground "#00e57a" :bold t :height 1.2)
 '(tldr-introduction    :foreground "#00733d" :italic t)
 '(tldr-description     :foreground "#00b25f")
 '(tldr-command-itself  :foreground "#000000" :background "#00cd6d" :bold t)
 '(tldr-command-argument :foreground "#00b25f" :background "#011f11" :underline t)
 '(tldr-code-block      :foreground "#00cd6d" :background "#011f11")
 '(rustic-cargo-outdated         :foreground "#cc0037")
 '(rustic-cargo-outdated-upgrade :foreground "#00cd6d")
 '(rustic-errno-face             :foreground "#cc0037")
 '(rustic-popup-key              :foreground "#00e57a")
 '(rustic-popup-section          :foreground "#00cd6d")
 '(persp-face-lighter-buffer-not-in-persp :background "#30000c" :foreground "#cc0037" :weight bold)
 '(yaml-tab-face        :background "#cc0037" :foreground "#cc0037" :bold t)
 '(denote-faces-delimiter :foreground "#00733d")
 '(nix-search-version   :foreground "#0081c7")
 '(lv-separator         :background "#004022")
 '(doom-modeline-debug-visual :foreground "#0081c7")
 '(doom-docs-symbol     :inherit font-lock-keyword-face :box (:line-width (-1 . -1) :color "#004022"))
 '(doom-docs-abbr       :underline (:line-width 1 :color "#004022"))
 '(doom-docs-header-link :foreground "#00e57a" :weight bold)
 '(treemacs-marked-file-face         :foreground "#00ff88" :background "#004022" :bold t)
 '(treemacs-peek-mode-indicator-face :background "#004022")
 '(treemacs-fringe-indicator-face    :foreground "#00e57a")
 '(treemacs-on-success-pulse-face    :foreground "#000000" :background "#00cd6d" :extend t)
 '(treemacs-on-failure-pulse-face    :foreground "#000000" :background "#cc0037" :extend t))

(custom-theme-set-faces!
 'the-matrix
 '(eww-form-text           :inherit widget-field :box (:line-width 1 :color "#00733d"))
 '(eww-form-textarea       :inherit widget-field :box (:line-width 1 :color "#00733d"))
 '(eww-form-submit         :inherit custom-button)
 '(eww-form-file           :inherit custom-button)
 '(eww-form-checkbox       :inherit custom-button)
 '(eww-form-select         :inherit custom-button)
 '(eww-valid-certificate   :foreground "#00b25f" :weight bold)
 '(eww-invalid-certificate :foreground "#cc0037" :weight bold))

(custom-theme-set-faces!
 'gotham
 '(org-agenda-done :foreground "#245361"))

(custom-theme-set-faces!
 'gotham
 '(org-habit-alert-face   :background "#edb443" :foreground "#0c1014")
 '(org-habit-ready-face   :background "#2aa889" :foreground "#0c1014")
 '(org-habit-overdue-face :background "#c23127" :foreground "#d3ebe9")
 '(org-habit-clear-face   :background "#195466" :foreground "#d3ebe9"))

(custom-theme-set-faces!
 'gotham
 '(org-headline-done :foreground "#245361"))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; (setq elfeed-db-directory (expand-file-name "~/sync/emacs/elfeed"))

(after! elfeed
  (setq-default elfeed-search-filter "@3-days-ago +unread"))

(after! elfeed-show
  (map! :map elfeed-show-mode-map
        :n "q" #'+rss/delete-pane))

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
    
    (make-process
     :name "ax-scrobble"
     :buffer " *ax-scrobble*"
     :noquery t
     :command (list "nix" "develop" (expand-file-name "~/x/lastfm")
                    "--command" "python" (expand-file-name "~/x/lastfm/scrobble.py")
                    ;; each list element is one argv entry, even when eg title is multiple words, so we only pass exactly 3 args to python
                    (or artist "Unknown artist")
                    (or album "Unknown album")
                    (or title "Unknown title")))))

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
       (:desc "show amount of git commits" "#" #'ax/git-count-commits)
       (:desc "org-publish to vps" "v" #'ax/publish-site)
       (:desc "visually select a window" "w" #'ace-window)
       (:desc "open terminal (ghostel)" "RET" #'ghostel)
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

(after! org
  (setq org-agenda-files
        (directory-files-recursively
         org-directory "\\.org\\'" nil
         (lambda (dir) (not (string-prefix-p "." (file-name-nondirectory dir)))))))

(dolist (spec '((org-level-1 :height 1.25) (org-level-2 :height 1.20)
                (org-level-3 :height 1.15) (org-level-4 :height 1.10)
                (org-level-5 :height 1.05) (org-document-title :height 1.5)
                (org-agenda-done :weight normal)))
  (face-spec-set (car spec) `((t ,@(cdr spec))) 'face-override-spec))

(after! org
  (add-to-list 'org-modules 'org-habit t)
  (setq org-habit-show-all-today t))

(setq org-log-into-drawer t)

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
    ;; (config-emacs.nix -> ~/.local/share/dict/words). Without it the ispell capf
    ;; errors and Doom silently disables it, leaving only dabbrev.
    (setq ispell-alternate-dictionary (expand-file-name "~/.local/share/dict/words"))
    ;; Use grep instead of `look' so word order / UTF-8 umlauts in the German
    ;; entries don't break look's binary search. The file is small; speed is fine.
    (setq ispell-look-p nil)))

(when (file-exists-p "/home/ax/x/ax.el") (load-file "/home/ax/x/ax.el"))

(when (file-exists-p "/home/ax/x/cljbang/axc.el") (load-file "/home/ax/x/cljbang/axc.el"))

(after! lsp-zig
  (setq lsp-zig-enable-argument-placeholders nil))
