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

   (font-lock-comment-face
    :foreground comments
    :slant 'italic)
   (font-lock-doc-face
    :inherit 'font-lock-comment-face
    :foreground doc-comments)

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
   (doom-modeline-bar                 :background (if -modeline-bright modeline-bg fg))
   (doom-modeline-buffer-file         :inherit 'mode-line-buffer-id :weight 'bold)
   (doom-modeline-buffer-path         :inherit 'mode-line-emphasis :weight 'bold)
   (doom-modeline-buffer-project-root :foreground bg :weight 'bold)
   (doom-modeline-project-dir         :foreground bg :weight 'bold) ;; strings=amber → invisible
   (doom-modeline-project-parent-dir  :foreground bg :weight 'bold) ;; comments=fg-dim → near-invisible
   (doom-modeline-info                :foreground bg)               ;; success=amber → invisible (git branch)
   (doom-modeline-warning             :foreground bg)               ;; warning=fg-dim → near-invisible (buffer state icon)

   ;; Powerline (elfeed-goodies header + any package using powerline segments)
   ;; doom-themes-base sets only :background on active0/1 and inactive0/1/2,
   ;; relying on the inherited mode-line foreground. With our inverted
   ;; modeline that fg resolves to bg (dark) → dark-on-dark invisible against
   ;; the lightened-bg backgrounds. Override :foreground explicitly — same
   ;; pattern upstream already applies to active2 (which is why Tags + the
   ;; unread count are the only readable segments out-of-the-box).
   (powerline-active0   :inherit 'mode-line :foreground base8 :background bg)
   (powerline-active1   :inherit 'mode-line :foreground base8 :background (doom-lighten bg 0.025))
   (powerline-inactive0 :inherit 'mode-line-inactive :foreground fg-dim :background base2)
   (powerline-inactive1 :inherit 'mode-line-inactive :foreground fg-dim :background (doom-lighten base2 0.02))
   (powerline-inactive2 :inherit 'mode-line-inactive :foreground fg-dim :background (doom-lighten base2 0.04))

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

   ;; magit
   (magit-section-heading :foreground fg :weight 'bold)
   (magit-branch-local    :foreground fg :weight 'bold)
   (magit-branch-remote   :foreground fg-dim :weight 'bold)
   (magit-diff-added             :foreground fg     :background (doom-blend fg bg 0.15))
   (magit-diff-added-highlight   :foreground fg     :background (doom-blend fg bg 0.25))
   (magit-diff-removed           :foreground red    :background (doom-blend red bg 0.15))
   (magit-diff-removed-highlight :foreground red    :background (doom-blend red bg 0.25))

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
   (org-level-1 :foreground fg     :weight 'semi-bold :height 1.4)
   (org-level-2 :foreground fg     :weight 'semi-bold :height 1.2)
   (org-level-3 :foreground fg     :weight 'semi-bold :height 1.1)
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

   ;; show-paren
   (show-paren-match :foreground fg :background base0 :weight 'bold)

   ;; vertico
   (vertico-current :foreground bg :background fg)

   ;; isearch (vim-amber IncSearch is reverse-video, ours is inverted)
   (isearch        :foreground bg :background fg)
   (lazy-highlight :foreground bg :background fg-dim :underline fg)

   ;; company
   (company-tooltip-common-selection :foreground bg :background fg)

   ;; tree-sitter / built-in
   (highlight-numbers-number :foreground fg)
   (highlight-quoted-quote   :foreground fg-dim)
   (highlight-quoted-symbol  :foreground fg)
   )


  ;; --- extra variables ---------------------
  ()
  )

;;; ax-amber-theme.el ends here
