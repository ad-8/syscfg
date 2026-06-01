;;; ax-iceberg-theme.el --- inspired by iceberg (cocopon)
;;; Canonical palette source: https://github.com/cocopon/iceberg.vim
;;; All hex values are drawn from upstream iceberg.vim (dark-variant hi-groups
;;; + terminal ansi table). No invented intermediates.
(require 'doom-themes)

(defgroup ax-iceberg-theme nil
  "Options for ax-iceberg"
  :group 'doom-themes)

(defcustom ax-iceberg-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'ax-iceberg-theme
  :type 'boolean)

(defcustom ax-iceberg-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'ax-iceberg-theme
  :type 'boolean)

(defcustom ax-iceberg-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'ax-iceberg-theme
  :type '(choice integer boolean))

;; Signature color is blue #84a0c6 (Statement / Type / Function / accent /
;; cursor / modeline-bar / highlight / paren-match / org-level-1 / isearch).
;; Iceberg is described upstream as a "bluish" scheme — blue carries identity.
;;
;; Two slot aliasings (iceberg publishes fewer distinct hues than doom expects):
;;   - yellow  = orange  = #e2a478 (the warm accent; iceberg has no real yellow)
;;   - magenta = violet  = #a093c7 (iceberg's single purple, Constant)
;; All other slots are distinct.
;;
;; Column 1 (GUI hex) is always iceberg. Columns 2 (256-color fallback hex)
;; and 3 (16-color X11 name) are inherited from doom-themes defaults and may
;; be non-iceberg — they never render in GUI emacs. Affected rows are
;; tagged "[256/16 non-ice: inherited]".
(def-doom-theme ax-iceberg
  "A dark bluish theme — soft cool hues on muted navy"
  ;; name        default        256       16
  ((bg         '("#161821"      nil       nil            )) ;; Normal background
   (bg-alt     '("#1e2132"      nil       nil            )) ;; CursorLine / SignColumn surface

   (base0      '("#0f1117"      "black"   "black"        )) ;; TabLine / VertSplit (darkest)
   (base1      '("#161821"      "#1e1e1e" "brightblack"  )) ;; = bg [256/16 non-ice: inherited]
   (base2      '("#1e2132"      "#2e2e2e" "brightblack"  )) ;; surface [256/16 non-ice: inherited]
   (base3      '("#272c42"      "#262626" "brightblack"  )) ;; Visual / selection [256/16 non-ice: inherited]
   (base4      '("#3d425b"      "#3f3f3f" "brightblack"  )) ;; Pmenu bg [256/16 non-ice: inherited]
   (base5      '("#6b7089"      "#525252" "brightblack"  )) ;; Comment / muted blue-grey
   (base6      '("#818596"      "#6b6b6b" "brightblack"  )) ;; StatusLine fg [256/16 non-ice: inherited]
   (base7      '("#c6c8d1"      "#979797" "brightblack"  )) ;; Normal fg [256/16 non-ice: inherited]
   (base8      '("#d2d4de"      "#dfdfdf" "white"        )) ;; brightwhite [256 non-ice: inherited]

   (fg         '("#c6c8d1"      "#bfbfbf" "brightwhite"  )) ;; Normal fg [256 non-ice: inherited]
   (fg-alt     '("#d2d4de"      "#2d2d2d" "white"        )) ;; brighter fg [256 non-ice: inherited]

   (grey       base5)
   (red        '("#e27878"      "#ff6655" "red"          )) ;; Error / ansi 1 [256/16 non-ice: inherited]
   (orange     '("#e2a478"      "#dd8844" "brightred"    )) ;; Title / ansi 3 (warm accent) [256/16 non-ice: inherited]
   (green      '("#b4be82"      "#99bb66" "green"        )) ;; PreProc / diffAdded / ansi 2 [256/16 non-ice: inherited]
   (teal       '("#89b8c2"      "#44b9b1" "cyan"         )) ;; String / Identifier / ansi 6 [256 non-ice: inherited]
   (yellow     '("#e2a478"      "#ECBE7B" "yellow"       )) ;; = orange (no real yellow) [256/16 non-ice: inherited]
   (blue       '("#84a0c6"      "#51afef" "blue"         )) ;; Statement / Type / SIGNATURE [256 non-ice: inherited]
   (dark-blue  '("#91acd1"      "#2257A0" "blue"         )) ;; bright blue / ansi 12 [256 non-ice: inherited]
   (magenta    '("#a093c7"      "#c678dd" "magenta"      )) ;; Constant / ansi 5 [256/16 non-ice: inherited]
   (violet     '("#a093c7"      "#a9a1e1" "brightmagenta")) ;; = magenta (single purple) [256 non-ice: inherited]
   (cyan       '("#89b8c2"      "#46D9FF" "brightcyan"   )) ;; String / Directory / ansi 6 [256 non-ice: inherited]
   (dark-cyan  '("#95c4ce"      "#5699AF" "cyan"         )) ;; bright cyan / ansi 14 [256 non-ice: inherited]

   ;; face categories -- required for all themes
   (highlight      blue)
   (vertical-bar   (doom-darken base2 0.1))
   (selection      base3)
   (builtin        green)
   (comments       (if ax-iceberg-brighter-comments (doom-lighten base5 0.2) base5))
   (doc-comments   (doom-lighten base5 0.2))
   (constants      violet)
   (functions      blue)
   (keywords       blue)
   (methods        blue)
   (operators      fg-alt)
   (type           blue)
   (strings        teal)
   (variables      fg)
   (numbers        violet)
   (region         `(,(doom-lighten (car bg-alt) 0.15) ,@(doom-lighten (cdr base0) 0.35)))
   (error          red)
   (warning        orange)
   (success        green)
   (vc-modified    orange)
   (vc-added       green)
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-bright ax-iceberg-brighter-modeline)
   (-modeline-pad
    (when ax-iceberg-padded-modeline
      (if (integerp ax-iceberg-padded-modeline) ax-iceberg-padded-modeline 4)))

   (modeline-fg     fg)
   (modeline-fg-alt fg-alt)

   (modeline-bg
    (if -modeline-bright
        (doom-darken blue 0.475)
      `(,(doom-darken (car bg-alt) 0.15) ,@(cdr base0))))
   (modeline-bg-l
    (if -modeline-bright
        (doom-darken blue 0.45)
      `(,(doom-darken (car bg-alt) 0.1) ,@(cdr base0))))
   (modeline-bg-inactive   `(,(doom-darken (car bg-alt) 0.1) ,@(cdr bg-alt)))
   (modeline-bg-inactive-l `(,(car bg-alt) ,@(cdr base1))))


  ;; --- extra faces ------------------------
  ((evil-goggles-default-face :inherit 'region :background (doom-blend region bg 0.5))

   ((line-number &override) :foreground base5)
   ((line-number-current-line &override) :foreground blue)

   (font-lock-comment-face
    :foreground comments
    :slant 'italic)
   (font-lock-doc-face
    :inherit 'font-lock-comment-face
    :foreground doc-comments)

   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis
    :foreground (if -modeline-bright base8 highlight))

   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-l)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-inactive-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive-l)))

   ;; Doom modeline
   (doom-modeline-bar :background (if -modeline-bright modeline-bg blue))
   (doom-modeline-buffer-file :inherit 'mode-line-buffer-id :weight 'bold)
   (doom-modeline-buffer-path :inherit 'mode-line-emphasis :weight 'bold)
   (doom-modeline-buffer-project-root :foreground blue :weight 'bold)

   ;; column indicator
   (fill-column-indicator :foreground bg-alt :background bg-alt)

   ;; cursor
   (cursor :foreground bg :background blue)

   ;; css-mode / scss-mode
   (css-proprietary-property :foreground magenta)
   (css-property             :foreground teal)
   (css-selector             :foreground blue)

   ;; dired
   (diredfl-dir-heading :foreground blue :weight 'bold)
   (diredfl-dir-name    :foreground cyan)
   (diredfl-file-name   :foreground fg)
   (diredfl-symlink     :foreground teal)
   (diredfl-deletion    :foreground red :background (doom-darken base2 0.1))

   ;; eshell
   (+eshell-prompt-git-branch :foreground blue)

   ;; evil
   (evil-ex-lazy-highlight      :foreground bg :background (doom-darken teal 0.3))
   (evil-snipe-first-match-face :foreground bg :background blue)

   ;; ivy
   (ivy-current-match           :foreground blue :background base3)
   (ivy-minibuffer-match-face-2 :foreground blue :background bg)

   ;; lsp
   (lsp-face-highlight-read    :foreground fg-alt :background (doom-darken dark-blue 0.3))
   (lsp-face-highlight-textual :foreground fg-alt :background (doom-lighten dark-blue 0.3))
   (lsp-face-highlight-write   :foreground fg-alt :background (doom-darken dark-blue 0.3))

   ;; magit
   (magit-section-heading :foreground blue :weight 'bold)
   (magit-branch-local    :foreground cyan :weight 'bold)
   (magit-branch-remote   :foreground teal :weight 'bold)
   (magit-diff-added             :foreground green :background (doom-blend green bg 0.15))
   (magit-diff-added-highlight   :foreground green :background (doom-blend green bg 0.25))
   (magit-diff-removed           :foreground red   :background (doom-blend red bg 0.15))
   (magit-diff-removed-highlight :foreground red   :background (doom-blend red bg 0.25))

   ;; markdown
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground blue)
   ((markdown-code-face &override) :background base0)

   ;; org-mode
   (org-hide :foreground hidden)
   (solaire-org-hide-face :foreground hidden)
   (org-drawer                :foreground dark-blue)
   (org-document-info         :foreground cyan)
   (org-document-info-keyword :foreground dark-blue)
   (org-document-title        :foreground blue :weight 'bold)
   (org-block            :foreground fg  :background bg-alt)
   (org-block-begin-line :foreground teal :background bg-alt)
   (org-block-end-line   :foreground teal :background bg-alt)
   (org-meta-line        :foreground dark-blue)
   (org-todo             :foreground orange :weight 'bold)
   (org-done             :foreground green  :weight 'bold)
   (org-headline-done    :foreground base5)
   (org-level-1 :foreground blue      :weight 'semi-bold)
   (org-level-2 :foreground teal      :weight 'semi-bold)
   (org-level-3 :foreground magenta   :weight 'semi-bold)
   (org-level-4 :foreground orange    :weight 'semi-bold)
   (org-level-5 :foreground cyan      :weight 'semi-bold)
   (org-level-6 :foreground dark-cyan :weight 'semi-bold)
   (org-level-7 :foreground green     :weight 'semi-bold)
   (org-level-8 :foreground dark-blue :weight 'semi-bold)

   ;; rainbow-delimiters — uses every distinct hue in the palette
   (rainbow-delimiters-depth-1-face  :foreground blue)
   (rainbow-delimiters-depth-2-face  :foreground teal)
   (rainbow-delimiters-depth-3-face  :foreground magenta)
   (rainbow-delimiters-depth-4-face  :foreground orange)
   (rainbow-delimiters-depth-5-face  :foreground cyan)
   (rainbow-delimiters-depth-6-face  :foreground dark-cyan)
   (rainbow-delimiters-depth-7-face  :foreground green)
   (rainbow-delimiters-depth-8-face  :foreground dark-blue)
   (rainbow-delimiters-unmatched-face :foreground red)

   ;; show-paren
   (show-paren-match :foreground blue :background base0 :weight 'bold)

   ;; vertico
   (vertico-current :foreground fg :background base3)

   ;; isearch
   (isearch        :foreground bg   :background blue :weight 'bold)
   (lazy-highlight :foreground blue :background base0 :underline blue)

   ;; company
   (company-tooltip-common-selection :foreground bg :background blue)

   ;; tree-sitter / built-in
   (highlight-numbers-number :foreground violet)
   (highlight-quoted-quote   :foreground green)
   (highlight-quoted-symbol  :foreground magenta)
   )


  ;; --- extra variables ---------------------
  ()
  )

;;; ax-iceberg-theme.el ends here
