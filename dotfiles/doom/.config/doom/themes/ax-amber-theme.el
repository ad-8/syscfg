;;; ax-amber-theme.el --- retrofuturistic amber CRT (P3 phosphor, DEC VT220 lineage)
;;; Anchored on foxbunny/vim-amber dark mode (https://github.com/foxbunny/vim-amber).
(require 'doom-themes)

(defgroup ax-amber-theme nil
  "Options for ax-amber"
  :group 'doom-themes)

(defcustom ax-amber-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'ax-amber-theme
  :type 'boolean)

(defcustom ax-amber-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'ax-amber-theme
  :type 'boolean)

(defcustom ax-amber-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'ax-amber-theme
  :type '(choice integer boolean))

;; Strict 5-color palette from foxbunny/vim-amber dark mode:
;;   bg          = #140b05   (s:bg)
;;   bg-overlay  = #1c1008   (s:special)
;;   fg-dim      = #c56306   (s:subbg)
;;   fg          = #fc9505   (s:fg, the iconic CRT amber)
;;   danger      = #ff0000   (Error/SpellBad, the only off-amber upstream uses)
;;
;; Vim-amber's design intent: "pretty much no syntax-specific variations in
;; color". The doom theme honors that — base/color slots collapse onto these
;; 5 hexes via repetition. Face block uses doom-darken/lighten for the few
;; UI-essential intermediates (modeline, region blends).
;; Two deliberate exceptions: the org-habit graph keeps org's own blue and
;; green (amber has neither, and the colours carry meaning), and the
;; tint / tint-strong / tint-red slots are fg/red blends for surfaces that
;; bg-alt is too faint to show.
;;
;; Column 1 (GUI hex) is always amber. Columns 2 (256-color fallback) and
;; 3 (16-color X11 name) are inherited from doom-themes defaults — they
;; never render in GUI emacs.
(def-doom-theme ax-amber
  "Retrofuturistic amber CRT monochrome — P3 phosphor on warm near-black"
  ;; name        default        256       16
  ((bg         '("#140b05"      nil       nil            )) ;; vim-amber s:bg
   (bg-alt     '("#1c1008"      nil       nil            )) ;; vim-amber s:special

   (base0      '("#140b05"      "black"   "black"        )) ;; = bg
   (base1      '("#1c1008"      "#1e1e1e" "brightblack"  )) ;; = bg-overlay
   (base2      '("#1c1008"      "#2e2e2e" "brightblack"  )) ;; = bg-overlay
   (base3      '("#1c1008"      "#262626" "brightblack"  )) ;; = bg-overlay
   (base4      '("#c56306"      "#3f3f3f" "brightblack"  )) ;; = fg-dim
   (base5      '("#c56306"      "#525252" "brightblack"  )) ;; = fg-dim (line numbers)
   (base6      '("#c56306"      "#6b6b6b" "brightblack"  )) ;; = fg-dim
   (base7      '("#fc9505"      "#979797" "brightblack"  )) ;; = fg
   (base8      '("#fc9505"      "#dfdfdf" "white"        )) ;; = fg

   (fg         '("#fc9505"      "#bfbfbf" "brightwhite"  )) ;; vim-amber s:fg
   (fg-alt     '("#fc9505"      "#2d2d2d" "white"        )) ;; = fg (no brighter amber)
   (fg-dim     '("#c56306"      "#bfbfbf" "white"        )) ;; vim-amber s:subbg (the dimmer amber)

   (grey       base5)
   ;; All "colored" slots collapse onto amber tiers — vim-amber's mono intent.
   ;; red is the only exception, mapping to the danger red upstream uses.
   (red        '("#ff0000"      "#ff6655" "red"          )) ;; vim-amber Error
   (orange     '("#fc9505"      "#dd8844" "brightred"    )) ;; = fg
   (green      '("#fc9505"      "#99bb66" "green"        )) ;; = fg
   (teal       '("#c56306"      "#44b9b1" "cyan"         )) ;; = fg-dim
   (yellow     '("#fc9505"      "#ECBE7B" "yellow"       )) ;; = fg (amber IS yellow-orange)
   (blue       '("#c56306"      "#51afef" "blue"         )) ;; = fg-dim
   (dark-blue  '("#c56306"      "#2257A0" "blue"         )) ;; = fg-dim
   (magenta    '("#fc9505"      "#c678dd" "magenta"      )) ;; = fg
   (violet     '("#c56306"      "#a9a1e1" "brightmagenta")) ;; = fg-dim
   (cyan       '("#fc9505"      "#46D9FF" "brightcyan"   )) ;; = fg
   (dark-cyan  '("#c56306"      "#5699AF" "cyan"         )) ;; = fg-dim

   ;; face categories — required for all themes
   ;; Vim-amber's pattern: most things use fg-on-bg; cursor/region/StatusLine
   ;; inverted (bg-on-fg); sub-inverted things use fg-dim bg; errors red.
   (highlight      fg)
   (vertical-bar   base1)
   (selection      base1)
   (builtin        fg)
   (comments       (if ax-amber-brighter-comments fg base5))
   (doc-comments   base5)
   (constants      fg)
   (functions      fg)
   (keywords       fg)
   (methods        fg)
   (operators      fg)
   (type           fg)
   (strings        fg)
   (variables      fg)
   (numbers        fg)
   (region         `(,(doom-lighten (car bg-alt) 0.1) ,@(doom-lighten (cdr base0) 0.35)))
   (error          red)
   (warning        fg-dim)
   (success        fg)
   (vc-modified    fg-dim)
   (vc-added       fg)
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (tint        `(,(doom-blend (car fg) (car bg) 0.12) nil nil))
   (tint-strong `(,(doom-blend (car fg) (car bg) 0.25) nil nil))
   (tint-red    `(,(doom-blend (car red) (car bg) 0.15) nil nil))
   (-modeline-bright ax-amber-brighter-modeline)
   (-modeline-pad
    (when ax-amber-padded-modeline
      (if (integerp ax-amber-padded-modeline) ax-amber-padded-modeline 4)))

   (modeline-fg     bg)
   (modeline-fg-alt bg)

   ;; Modeline = inverted (amber bg, dark fg) — vim-amber's StatusLine pattern.
   (modeline-bg
    (if -modeline-bright
        fg
      fg))
   (modeline-bg-l
    (if -modeline-bright
        fg
      fg))
   (modeline-bg-inactive   fg-dim)
   (modeline-bg-inactive-l fg-dim))


  ;; --- extra faces ------------------------
  ((evil-goggles-default-face :inherit 'region :background (doom-blend region bg 0.5))

   ((line-number &override) :foreground base5)
   ((line-number-current-line &override) :foreground fg)

   ;; Current line: underline like matrix / meltbus (vantablack). Doom's
   ;; default fill is bg-alt, which is invisible against bg. fg-dim is
   ;; vim-amber s:subbg — dim phosphor, not the cursor/isearch fg.
   (hl-line :underline fg-dim :extend t)
   (solaire-hl-line-face :inherit 'hl-line :background 'unspecified :extend t)

   (font-lock-comment-face
    :foreground comments
    :slant 'italic)
   (font-lock-doc-face
    :inherit 'font-lock-comment-face
    :foreground doc-comments)

   ;; Matrix-style box behind strings so a string arg stands out from the
   ;; surrounding fn name in this mono palette (everything else is fg).
   ;; bg-alt was too faint to read, so blend toward fg for a warmer, more
   ;; visible amber-tinted box (like the region/magit blends the theme
   ;; already computes); base0/bg is unusable since base0 == bg.
   ((font-lock-string-face &override) :background tint)

   ;; Modeline inverted (vim-amber StatusLine: bg on fg)
   (mode-line
    :background modeline-bg :foreground modeline-fg :weight 'bold
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis
    :foreground bg)

   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-l)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-inactive-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive-l)))

   ;; Doom modeline
   ;; Inverted modeline (amber bg): faces that inherit doom palette colors which
   ;; resolve to amber (success, strings) or near-amber (warning=fg-dim,
   ;; comments=fg-dim) become invisible / near-invisible on the amber modeline bg.
   ;; Force them to bg (dark) to match the inverted-modeline design intent.
   (doom-modeline-bar                 :background fg-dim)
   (doom-modeline-buffer-file         :inherit 'mode-line-buffer-id :weight 'bold)
   (doom-modeline-buffer-path         :inherit 'mode-line-emphasis :weight 'bold)
   (doom-modeline-buffer-project-root :foreground bg :weight 'bold)
   (doom-modeline-project-dir         :foreground bg :weight 'bold) ;; strings=amber → invisible
   (doom-modeline-project-parent-dir  :foreground bg :weight 'bold) ;; comments=fg-dim → near-invisible
   (doom-modeline-info                :foreground bg)               ;; success=amber → invisible (git branch)
   (doom-modeline-warning             :foreground bg)               ;; warning=fg-dim → near-invisible (buffer state icon)
   (doom-modeline-evil-insert-state         :inherit '(doom-modeline font-lock-keyword-face) :foreground bg)
   (doom-modeline-evil-emacs-state          :inherit '(doom-modeline font-lock-builtin-face) :foreground bg)
   (doom-modeline-evil-motion-state         :inherit '(doom-modeline font-lock-doc-face) :slant 'normal :foreground bg)
   (doom-modeline-buffer-modified           :inherit '(doom-modeline warning bold) :background fg-dim :foreground bg)
   (doom-modeline-project-name              :inherit '(doom-modeline font-lock-comment-face italic) :foreground bg)
   (doom-modeline-debug                     :inherit '(doom-modeline font-lock-doc-face) :slant 'normal :foreground bg)
   (doom-modeline-debug-visual              :inherit 'doom-modeline :foreground bg)
   (doom-modeline-input-method-alt          :inherit '(doom-modeline font-lock-doc-face) :slant 'normal :foreground bg)
   (doom-modeline-buffer-minor-mode         :inherit '(doom-modeline font-lock-doc-face) :weight 'normal :slant 'normal :foreground bg)
   (doom-modeline-highlight                 :inherit '(doom-modeline mode-line-highlight) :foreground bg :background fg-dim)
   (compilation-mode-line-exit              :inherit 'compilation-info :foreground bg)
   (compilation-mode-line-run               :inherit 'compilation-warning :foreground bg)
   (lsp-modeline-code-actions-face          :inherit 'homoglyph :foreground bg)
   (lsp-modeline-code-actions-preferred-face :foreground bg :weight 'bold)

   ;; column indicator
   (fill-column-indicator :foreground bg-alt :background bg-alt)

   ;; cursor (inverted: bg fg, amber bg)
   (cursor :foreground bg :background fg)

   ;; dired
   (diredfl-dir-heading :foreground fg :weight 'bold)
   (diredfl-dir-name    :foreground fg)
   (diredfl-file-name   :foreground fg)
   (diredfl-symlink     :foreground fg-dim)
   (diredfl-deletion    :foreground red :background (doom-darken base2 0.1))

   ;; eshell
   (+eshell-prompt-git-branch :foreground fg)

   ;; evil
   (evil-ex-lazy-highlight      :foreground bg :background fg-dim)
   (evil-snipe-first-match-face :foreground bg :background fg)

   ;; ivy
   (ivy-current-match           :foreground bg :background fg)
   (ivy-minibuffer-match-face-2 :foreground fg :background bg-alt)

   ;; lsp
   (lsp-face-highlight-read    :foreground bg :background (doom-darken fg-dim 0.3))
   (lsp-face-highlight-textual :foreground bg :background (doom-lighten fg-dim 0.1))
   (lsp-face-highlight-write   :foreground bg :background (doom-darken fg-dim 0.3))
   (lsp-ui-doc-header                     :foreground bg :background fg)
   (lsp-ui-sideline-symbol                :foreground fg-dim :box (list :line-width -1 :color fg-dim) :height 0.99)
   (lsp-installation-buffer-face          :foreground fg)
   (lsp-installation-finished-buffer-face :foreground fg)
   (lsp-dired-path-error-face   :underline (list :style 'wave :color red))
   (lsp-dired-path-warning-face :underline (list :style 'wave :color fg-dim))
   (lsp-dired-path-info-face    :underline (list :style 'wave :color fg))
   (lsp-dired-path-hint-face    :underline (list :style 'wave :color fg))

   ;; magit
   (magit-section-heading :foreground fg :weight 'bold)
   (magit-branch-local    :foreground fg :weight 'bold)
   (magit-branch-remote   :foreground fg-dim :weight 'bold)
   (magit-diff-added             :foreground fg     :background (doom-blend fg bg 0.15) :extend t)
   (magit-diff-added-highlight   :foreground fg     :background tint-strong :weight 'bold :extend t)
   (magit-diff-removed           :foreground red    :background tint-red :extend t)
   (magit-diff-removed-highlight :foreground red    :background (doom-blend red bg 0.25) :weight 'bold :extend t)
   (magit-diff-hunk-heading           :foreground fg-dim :background bg :overline fg-dim :extend t)
   (magit-diff-hunk-heading-selection :extend t :inherit 'magit-diff-hunk-heading-highlight :background fg :foreground bg)
   (magit-diff-file-heading-selection :foreground bg :background fg :weight 'bold :extend t)
   (magit-section-heading-selection   :foreground bg :background fg :weight 'bold :extend t)
   (magit-diff-lines-heading          :foreground bg :background fg :weight 'bold :extend t)
   (magit-diff-lines-boundary         :background fg)
   (magit-header-line                 :background fg-dim :foreground bg :weight 'bold :box (list :line-width 3 :color fg-dim))
   (magit-blame-highlight             :extend t :background tint :foreground fg)
   (magit-diff-added-indicator        :foreground fg)
   (magit-diff-removed-indicator      :foreground red)
   (magit-diff-our-heading            :extend t :background red :foreground bg)
   (magit-diff-their-heading          :extend t :background fg-dim :foreground bg)
   (magit-diff-base-heading           :extend t :background fg :foreground bg)
   (magit-diff-base-indicator         :foreground fg-dim)
   (magit-signature-revoked           :foreground red)
   (magit-signature-error             :foreground fg-dim)
   (magit-signature-untrusted         :foreground fg-dim)
   (magit-signature-expired           :foreground fg-dim)
   (transient-key-exit                :inherit 'transient-key :foreground fg)
   (transient-key-return              :inherit 'transient-key :foreground fg)
   (transient-key-recurse             :inherit 'transient-key :foreground fg)
   (transient-key-stack               :inherit 'transient-key :foreground fg)
   (transient-key-stay                :inherit 'transient-key :foreground fg-dim)
   (transient-key-noop                :inherit 'transient-key :foreground fg-dim :slant 'italic)
   (transient-enabled-suffix          :background fg  :foreground bg :weight 'bold)
   (transient-disabled-suffix         :background red :foreground bg :weight 'bold)
   (transient-higher-level            :box (list :line-width '(-1 . -1) :color fg-dim))
   (transient-mismatched-key          :box (list :line-width '(-1 . -1) :color red))
   (transient-nonstandard-key         :box (list :line-width '(-1 . -1) :color fg-dim))
   (diff-changed-unspecified          :inherit 'diff-changed :background tint :extend t)
   (diff-error                        :foreground red :background bg :weight 'bold)

   ;; markdown
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground fg)
   ((markdown-code-face &override) :background base0)

   ;; org-mode
   (org-hide :foreground hidden)
   (solaire-org-hide-face :foreground hidden)
   (org-drawer                :foreground fg-dim)
   (org-document-info         :foreground fg)
   (org-document-info-keyword :foreground fg-dim)
   (org-document-title        :foreground fg :weight 'bold)
   (org-block            :foreground fg  :background bg-alt)
   (org-block-begin-line :foreground fg-dim :background bg-alt)
   (org-block-end-line   :foreground fg-dim :background bg-alt)
   (org-meta-line        :foreground fg-dim)
   (org-todo             :foreground fg :weight 'bold)
   (org-done             :foreground fg-dim :weight 'bold)
   (org-headline-done    :foreground fg-dim)
   (org-level-1 :foreground fg     :weight 'semi-bold)
   (org-level-2 :foreground fg     :weight 'semi-bold)
   (org-level-3 :foreground fg     :weight 'semi-bold)
   (org-level-4 :foreground fg-dim :weight 'semi-bold)
   (org-level-5 :foreground fg-dim :weight 'semi-bold)
   (org-level-6 :foreground fg-dim :weight 'semi-bold)
   (org-level-7 :foreground fg-dim :weight 'semi-bold)
   (org-level-8 :foreground fg-dim :weight 'semi-bold)

   ;; rainbow-delimiters (mono — alternate fg/fg-dim for visibility)
   (rainbow-delimiters-depth-1-face  :foreground fg)
   (rainbow-delimiters-depth-2-face  :foreground fg-dim)
   (rainbow-delimiters-depth-3-face  :foreground fg)
   (rainbow-delimiters-depth-4-face  :foreground fg-dim)
   (rainbow-delimiters-depth-5-face  :foreground fg)
   (rainbow-delimiters-depth-6-face  :foreground fg-dim)
   (rainbow-delimiters-depth-7-face  :foreground fg)
   (rainbow-delimiters-depth-8-face  :foreground fg-dim)
   (rainbow-delimiters-unmatched-face :foreground red)

   ;; show-paren (tint-strong: base0 == bg and bg-alt are too faint to see the box)
   (show-paren-match :foreground fg :background tint-strong :weight 'bold)

   ;; vertico
   (vertico-current :background tint-strong :extend t)

   ;; isearch (vim-amber IncSearch is reverse-video, ours is inverted)
   (isearch        :foreground bg :background fg)
   (lazy-highlight :foreground bg :background fg-dim :underline fg)

   ;; company
   (company-tooltip-common-selection :foreground bg :background fg)

   ;; tree-sitter / built-in
   (highlight-numbers-number :foreground fg)
   (highlight-quoted-quote   :foreground fg-dim)
   (highlight-quoted-symbol  :foreground fg)

   ;; org agenda
   (org-agenda-done             :foreground fg-dim)
   (org-warning                 :foreground fg :weight 'bold)
   (org-upcoming-deadline       :foreground fg)
   (org-upcoming-distant-deadline :foreground fg)
   (org-agenda-clocking         :background tint-strong)
   (org-agenda-current-time     :inherit 'org-time-grid :foreground fg)
   (org-agenda-dimmed-todo-face :foreground fg-dim :slant 'italic)
   (org-agenda-date             :foreground fg     :weight 'ultra-bold)
   (org-agenda-date-weekend     :foreground fg-dim :weight 'ultra-bold)
   (org-agenda-date-today       :foreground bg :background fg :weight 'ultra-bold)
   (org-agenda-restriction-lock :background tint)
   (org-column                  :background tint :weight 'normal :slant 'normal)
   (org-column-title            :background tint :underline t :weight 'bold)
   (org-clock-overlay           :background tint :foreground fg)
   (org-dispatcher-highlight    :background fg :foreground bg :weight 'bold)
   (org-mode-line-clock-overrun :inherit 'mode-line :background red :foreground bg)
   (org-table-header            :inherit 'org-table :background tint :foreground fg)
   (org-date-selected           :foreground fg :inverse-video t)
   (calfw-sunday-face           :foreground fg-dim :weight 'bold)
   (calfw-saturday-face         :foreground fg-dim :weight 'bold)
   (calfw-calendar-hidden-face  :foreground fg-dim :strike-through t)

   ;; org-habit graph: org's four meaning colours, amber's own where it has one
   (org-habit-clear-face          :background "blue" :foreground fg)
   (org-habit-clear-future-face   :background "midnightblue")
   (org-habit-ready-face          :background "forestgreen" :foreground bg)
   (org-habit-ready-future-face   :background "darkgreen")
   (org-habit-alert-face          :background fg :foreground bg)
   (org-habit-alert-future-face   :background fg-dim)
   (org-habit-overdue-face        :background red :foreground bg)
   (org-habit-overdue-future-face :background "darkred")

   ;; org-modern
   (org-modern-date-active         :inherit 'org-modern-label :background tint :foreground fg)
   (org-modern-date-inactive       :inherit 'org-modern-label :background tint :foreground fg-dim)
   (org-modern-time-active         :inherit 'org-modern-label :weight 'semibold :background tint :foreground fg)
   (org-modern-time-inactive       :inherit 'org-modern-label :background tint :foreground fg-dim)
   (org-modern-done                :inherit 'org-modern-label :background tint :foreground fg-dim)
   (org-modern-tag                 :inherit 'org-modern-label :background tint :foreground fg)
   (org-modern-progress-complete   :background fg :foreground bg)
   (org-modern-progress-incomplete :background tint :foreground fg)
   (org-modern-horizontal-rule     :underline fg-dim :extend t)

   ;; completion and help
   (corfu-current                    :foreground fg :background tint-strong)
   (corfu-indexed                    :height 0.75 :foreground fg-dim :background bg-alt)
   (corfu-bar                        :background fg-dim)
   (corfu-border                     :background fg-dim)
   (corfu-quick1                     :background fg     :foreground bg :inherit 'bold)
   (corfu-quick2                     :background fg-dim :foreground bg :inherit 'bold)
   (vertico-quick1                   :background fg     :foreground bg :inherit 'bold)
   (vertico-quick2                   :background fg-dim :foreground bg :inherit 'bold)
   (which-key-group-description-face :foreground fg :weight 'bold)
   (completions-common-part          :weight 'bold)
   (orderless-match-face-0           :weight 'bold :underline t)
   (orderless-match-face-1           :weight 'bold :underline t)
   (orderless-match-face-2           :weight 'bold :underline t)
   (orderless-match-face-3           :weight 'bold :underline t)
   (help-key-binding                 :inherit 'fixed-pitch :background bg-alt :foreground fg
                                     :box (list :line-width '(-1 . -1) :color fg-dim))

   ;; emacs core
   (link-visited           :inherit 'link :foreground fg-dim)
   (homoglyph              :foreground fg-dim)
   (nobreak-hyphen         :foreground fg-dim)
   (separator-line         :height 0.1 :background fg-dim)
   (icon-button            :inherit 'icon :background fg-dim :foreground bg
                           :box (list :line-width '(3 . -1) :color fg-dim :style 'flat-button))
   (minibuffer-nonselected :background fg-dim :foreground bg :weight 'bold)
   (header-line            :foreground fg :background tint)
   (eww-valid-certificate  :foreground fg :weight 'bold)
   (eww-form-text          :box (list :line-width 1 :color fg-dim) :background bg :foreground fg :distant-foreground bg)
   (tab-bar-tab-highlight  :box (list :line-width 1 :style 'released-button) :background fg-dim :foreground bg)
   (pulse-highlight-start-face :background tint-strong)
   (pulse-highlight-face       :background tint-strong)
   (secondary-selection    :background tint-strong :extend t)
   (wgrep-face             :foreground fg :background tint-strong :weight 'bold)
   (isearch-group-1        :background tint-strong :foreground fg :weight 'bold)
   (isearch-group-2        :background tint :foreground fg)
   (dired-broken-symlink   :foreground bg :background red :weight 'bold)
   (ibuffer-locked-buffer  :foreground fg-dim)
   (info-node              :foreground fg :weight 'bold :slant 'italic)
   (info-menu-star         :foreground fg-dim)
   (diary                  :foreground fg :weight 'bold)
   (holiday                :background tint)
   (lv-separator           :background fg-dim)

   ;; elisp-mode (emacs 31)
   (elisp-condition              :foreground fg)
   (elisp-major-mode-name        :foreground fg)
   (elisp-non-local-exit         :inherit 'elisp-function :underline red)
   (elisp-rx                     :foreground fg)
   (elisp-symbol-at-mouse        :background tint)
   (elisp-symbol-role            :inherit 'font-lock-function-call-face :foreground fg)
   (elisp-symbol-role-definition :inherit 'font-lock-function-name-face :foreground fg)
   (elisp-unknown-call           :inherit 'elisp-function :foreground fg-dim)

   ;; dirvish
   (dirvish-file-modes          :foreground fg-dim)
   (dirvish-file-time           :foreground fg-dim)
   (dirvish-narrow-match-face-0 :weight 'bold :foreground bg :background fg)
   (dirvish-narrow-match-face-1 :weight 'bold :foreground bg :background fg-dim)
   (dirvish-narrow-match-face-2 :weight 'bold :foreground bg :background fg-dim)
   (dirvish-narrow-match-face-3 :weight 'bold :foreground bg :background fg-dim)
   (dirvish-vc-needs-merge-face :background tint-red)
   (ax/dirvish-modeline         :foreground bg)

   ;; emms
   (emms-playlist-track-face            :foreground fg-dim)
   (emms-playlist-selected-face         :foreground fg)
   (emms-metaplaylist-mode-face         :foreground fg-dim)
   (emms-metaplaylist-mode-current-face :foreground fg)
   (emms-browser-year/genre-face        :foreground fg :height 1.5)
   (emms-browser-artist-face            :foreground fg :height 1.3)
   (emms-browser-albumartist-face       :foreground fg :height 1.3)
   (emms-browser-composer-face          :foreground fg :height 1.3)
   (emms-browser-performer-face         :foreground fg :height 1.3)
   (emms-browser-album-face             :foreground fg :height 1.1)
   (emms-browser-track-face             :foreground fg-dim :height 1.0)

   ;; cider, nrepl, macrostep (mono rainbows alternate fg/fg-dim)
   (cider-error-overlay-face       :background tint-red :extend t)
   (cider-fringe-bad-face          :foreground red)
   (cider-fringe-stale-face        :foreground fg-dim)
   (cider-macrostep-expansion-face :background tint :extend t)
   (cider-macrostep-gensym-1-face  :foreground fg)
   (cider-macrostep-gensym-2-face  :foreground fg-dim)
   (cider-macrostep-gensym-3-face  :foreground fg)
   (cider-macrostep-gensym-4-face  :foreground fg-dim)
   (cider-macrostep-gensym-5-face  :foreground fg)
   (cider-macrostep-gensym-6-face  :foreground fg-dim)
   (cider-macrostep-gensym-7-face  :foreground fg)
   (nrepl-message-1-face           :foreground fg)
   (nrepl-message-2-face           :foreground fg-dim)
   (nrepl-message-3-face           :foreground fg)
   (nrepl-message-4-face           :foreground fg-dim)
   (nrepl-message-5-face           :foreground fg)
   (nrepl-message-6-face           :foreground fg-dim)
   (nrepl-message-7-face           :foreground fg)
   (nrepl-message-8-face           :foreground fg-dim)
   (macrostep-expansion-highlight-face :extend t :background tint)
   (macrostep-gensym-1 :foreground fg     :box t :weight 'bold)
   (macrostep-gensym-2 :foreground fg-dim :box t :weight 'bold)
   (macrostep-gensym-3 :foreground fg     :box t :weight 'bold)
   (macrostep-gensym-4 :foreground fg-dim :box t :weight 'bold)
   (macrostep-gensym-5 :foreground fg     :box t :weight 'bold)

   ;; navigation and small tools
   (aw-background-face           :foreground fg-dim)
   (aw-leading-char-face         :foreground bg :background fg)
   (anzu-match-1                 :background fg     :foreground bg)
   (anzu-match-2                 :background fg-dim :foreground bg)
   (anzu-match-3                 :background fg     :foreground bg)
   (vundo-highlight              :inherit 'vundo-node :weight 'bold :foreground bg :background fg)
   (vundo-diff-highlight         :inherit 'vundo-highlight :foreground bg :background fg-dim)
   (vundo-saved                  :inherit 'vundo-node :foreground fg)
   (tmr-tabulated-start-time     :foreground fg-dim)
   (tmr-tabulated-end-time       :foreground fg-dim)
   (tmr-tabulated-remaining-time :foreground fg)
   (flycheck-annotate-error-background   :background tint-red :extend t)
   (flycheck-annotate-warning-background :background tint :extend t)
   (flycheck-annotate-info-background    :background tint :extend t)
   (sp-wrap-overlay-opening-pair :inherit 'sp-wrap-overlay-face :foreground fg)
   (sp-wrap-overlay-closing-pair :inherit 'sp-wrap-overlay-face :foreground fg-dim)
   (eros-result-overlay-face     :background bg-alt :box (list :line-width -1 :color fg-dim))
   (treemacs-marked-file-face         :foreground bg :background fg :weight 'bold)
   (treemacs-peek-mode-indicator-face :background fg-dim)
   (treemacs-git-untracked-face       :foreground fg :slant 'italic)
   (treemacs-git-added-face           :foreground fg :weight 'bold)
   (treemacs-git-renamed-face         :foreground fg-dim)
   (treemacs-git-modified-face        :foreground fg-dim)
   (treemacs-git-ignored-face         :foreground fg-dim :slant 'italic)
   (git-timemachine-minibuffer-author-face :foreground fg)
   (git-timemachine-minibuffer-detail-face :foreground fg-dim)
   (rustic-cargo-outdated         :foreground red)
   (rustic-cargo-outdated-upgrade :foreground fg)
   (rustic-errno-face             :foreground red)
   (rustic-popup-key              :foreground fg)
   (rustic-popup-section          :foreground fg)
   (denote-faces-delimiter        :foreground fg-dim)
   (nix-search-version            :foreground fg-dim)
   (markdown-highlighting-face    :background fg :foreground bg)
   (yaml-tab-face                 :background red :foreground red :weight 'bold)
   (doom-docs-abbr        :underline (list :line-width 1 :color fg-dim))
   (doom-docs-symbol      :inherit 'font-lock-keyword-face :box (list :line-width '(-1 . -1) :color fg-dim))
   (doom-docs-header-link :foreground fg :weight 'bold)
   )


  ;; --- extra variables ---------------------
  ()
  )

;;; ax-amber-theme.el ends here
