;;; ax-matte-black-theme.el --- inspired by matte-black (omarchy / tahayvr)
;;; Canonical palette source: https://github.com/tahayvr/matte-black-theme
(require 'doom-themes)

(defgroup ax-matte-black-theme nil
  "Options for ax-matte-black"
  :group 'doom-themes)

(defcustom ax-matte-black-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'ax-matte-black-theme
  :type 'boolean)

(defcustom ax-matte-black-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'ax-matte-black-theme
  :type 'boolean)

(defcustom ax-matte-black-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'ax-matte-black-theme
  :type '(choice integer boolean))

;; Strict warm-monochrome palette from author sources (alacritty.toml,
;; colors.toml, btop.theme by tahayvr). The palette has only oranges
;; (#e68e0d / #f59e0b), amber (#FFC107), reds (#D35F5F / #B91C1C),
;; and greys — no real blues, greens, cyans, magentas, or violets
;; exist. Missing doom slots collapse to grey or warm shades;
;; semantic distinction is encoded via luminance rather than hue.
;; Pattern adapted from ax-lumon-theme.el.
;;
;; Column 1 (GUI hex) is always matte-black. Columns 2 (256-color
;; fallback hex) and 3 (16-color X11 name) are inherited from
;; doom-themes defaults and may be non-matte-black — they never render
;; in GUI emacs. Affected rows are tagged "[256/16 non-mb: inherited]".
;;
;; Signature color is orange #e68e0d — applied to cursor, modeline-bar,
;; highlight, org-level-1, rainbow-delimiters depth 1, isearch,
;; paren-match.
(def-doom-theme ax-matte-black
  "A sleek warm-monochrome dark theme — near-black with burnt orange"
  ;; name        default        256       16
  ((bg         '("#121212"      nil       nil            )) ;; matte-black background
   (bg-alt     '("#1e1e1e"      nil       nil            )) ;; surface (waybar/mako bg)

   (base0      '("#0a0a0a"      "black"   "black"        )) ;; invented; gradient step toward pure black
   (base1      '("#1a1a1a"      "#1e1e1e" "brightblack"  )) ;; invented; gradient step [256/16 non-mb: inherited]
   (base2      '("#272727"      "#2e2e2e" "brightblack"  )) ;; invented; gradient step [256/16 non-mb: inherited]
   (base3      '("#333333"      "#262626" "brightblack"  )) ;; color0 [256/16 non-mb: inherited]
   (base4      '("#515151"      "#3f3f3f" "brightblack"  )) ;; selection_background [256/16 non-mb: inherited]
   (base5      '("#8a8a8d"      "#525252" "brightblack"  )) ;; color8 / dim fg [256/16 non-mb: inherited]
   (base6      '("#a4a4a6"      "#6b6b6b" "brightblack"  )) ;; invented; gradient step between color8 and fg [256/16 non-mb: inherited]
   (base7      '("#bebebe"      "#979797" "brightblack"  )) ;; fg / color7 [256/16 non-mb: inherited]
   (base8      '("#eaeaea"      "#dfdfdf" "white"        )) ;; color14 (brightest before pure white)

   (fg         '("#bebebe"      "#bfbfbf" "brightwhite"  )) ;; foreground [256 non-mb: inherited]
   (fg-alt     '("#ffffff"      "#2d2d2d" "white"        )) ;; color15

   (grey       base5)
   ;; "Colored" slots that have no matte-black equivalent collapse to
   ;; greys or warms. Roles distinguished by luminance only.
   (red        '("#D35F5F"      "#ff6655" "red"          )) ;; color1 (regular red) [256/16 non-mb: inherited]
   (orange     '("#e68e0d"      "#dd8844" "brightred"    )) ;; accent (SIGNATURE) [256 non-mb: inherited]
   (green      '("#FFC107"      "#99bb66" "green"        )) ;; color2 — author maps green slot to amber [256/16 non-mb: inherited]
   (teal       '("#8a8a8d"      "#44b9b1" "cyan"         )) ;; no teal in palette; collapse to dim grey [256/16 non-mb: inherited]
   (yellow     '("#f59e0b"      "#ECBE7B" "yellow"       )) ;; alt orange — no real yellow [256/16 non-mb: inherited]
   (blue       '("#e68e0d"      "#51afef" "blue"         )) ;; no blue; author maps color4 to orange (signature) [256/16 non-mb: inherited]
   (dark-blue  '("#515151"      "#2257A0" "blue"         )) ;; no dark-blue; collapse to selection grey [256/16 non-mb: inherited]
   (magenta    '("#D35F5F"      "#c678dd" "magenta"      )) ;; no magenta; author maps color5 to red [256/16 non-mb: inherited]
   (violet     '("#bebebe"      "#a9a1e1" "brightmagenta")) ;; no violet; collapse to fg grey [256/16 non-mb: inherited]
   (cyan       '("#bebebe"      "#46D9FF" "brightcyan"   )) ;; no cyan; author maps color6 to fg grey [256/16 non-mb: inherited]
   (dark-cyan  '("#8a8a8d"      "#5699AF" "cyan"         )) ;; no dark-cyan; dim grey [256/16 non-mb: inherited]

   ;; face categories -- required for all themes
   ;; Warm-mono semantic mapping: comments dim, functions = orange (signature),
   ;; keywords = amber, constants/numbers = red, errors = deep red.
   (highlight      orange)
   (vertical-bar   (doom-darken base2 0.1))
   (selection      base4)
   (builtin        green)
   (comments       (if ax-matte-black-brighter-comments base6 base5))
   (doc-comments   (doom-lighten base5 0.2))
   (constants      red)
   (functions      orange)
   (keywords       green)
   (methods        orange)
   (operators      fg)
   (type           yellow)
   (strings        green)
   (variables      fg)
   (numbers        red)
   (region         `(,(doom-lighten (car bg-alt) 0.15) ,@(doom-lighten (cdr base0) 0.35)))
   (error          red)
   (warning        yellow)
   (success        green)
   (vc-modified    orange)
   (vc-added       green)
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-bright ax-matte-black-brighter-modeline)
   (-modeline-pad
    (when ax-matte-black-padded-modeline
      (if (integerp ax-matte-black-padded-modeline) ax-matte-black-padded-modeline 4)))

   (modeline-fg     fg)
   (modeline-fg-alt fg-alt)

   (modeline-bg
    (if -modeline-bright
        (doom-darken orange 0.475)
      `(,(doom-darken (car bg-alt) 0.15) ,@(cdr base0))))
   (modeline-bg-l
    (if -modeline-bright
        (doom-darken orange 0.45)
      `(,(doom-darken (car bg-alt) 0.1) ,@(cdr base0))))
   (modeline-bg-inactive   `(,(doom-darken (car bg-alt) 0.1) ,@(cdr bg-alt)))
   (modeline-bg-inactive-l `(,(car bg-alt) ,@(cdr base1))))


  ;; --- extra faces ------------------------
  ((evil-goggles-default-face :inherit 'region :background (doom-blend region bg 0.5))

   ((line-number &override) :foreground base5)
   ((line-number-current-line &override) :foreground orange)

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
   (doom-modeline-bar :background (if -modeline-bright modeline-bg orange))
   (doom-modeline-buffer-file :inherit 'mode-line-buffer-id :weight 'bold)
   (doom-modeline-buffer-path :inherit 'mode-line-emphasis :weight 'bold)
   (doom-modeline-buffer-project-root :foreground orange :weight 'bold)

   ;; column indicator
   (fill-column-indicator :foreground bg-alt :background bg-alt)

   ;; cursor
   (cursor :foreground bg :background orange)

   ;; css-mode / scss-mode
   (css-proprietary-property :foreground red)
   (css-property             :foreground green)
   (css-selector             :foreground orange)

   ;; dired
   (diredfl-dir-heading :foreground orange :weight 'bold)
   (diredfl-dir-name    :foreground green)
   (diredfl-file-name   :foreground fg)
   (diredfl-symlink     :foreground yellow)
   (diredfl-deletion    :foreground red :background (doom-blend red bg 0.25))

   ;; eshell
   (+eshell-prompt-git-branch :foreground orange)

   ;; evil
   (evil-ex-lazy-highlight      :foreground fg :background (doom-darken orange 0.3))
   (evil-snipe-first-match-face :foreground bg :background orange)

   ;; ivy
   (ivy-current-match           :foreground orange :background base3)
   (ivy-minibuffer-match-face-2 :foreground orange :background bg)

   ;; lsp
   (lsp-face-highlight-read    :foreground fg-alt :background (doom-darken base4 0.3))
   (lsp-face-highlight-textual :foreground fg-alt :background (doom-lighten base4 0.3))
   (lsp-face-highlight-write   :foreground fg-alt :background (doom-darken base4 0.3))

   ;; magit
   (magit-section-heading :foreground orange :weight 'bold)
   (magit-branch-local    :foreground green  :weight 'bold)
   (magit-branch-remote   :foreground yellow :weight 'bold)
   (magit-diff-added             :foreground green :background (doom-blend green bg 0.15))
   (magit-diff-added-highlight   :foreground green :background (doom-blend green bg 0.25))
   (magit-diff-removed           :foreground red   :background (doom-blend red bg 0.15))
   (magit-diff-removed-highlight :foreground red   :background (doom-blend red bg 0.25))

   ;; markdown
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground orange)
   ((markdown-code-face &override) :background base0)

   ;; org-mode
   (org-hide :foreground hidden)
   (solaire-org-hide-face :foreground hidden)
   (org-drawer                :foreground base5)
   (org-document-info         :foreground green)
   (org-document-info-keyword :foreground base5)
   (org-document-title        :foreground orange :weight 'bold)
   (org-block            :foreground fg  :background bg-alt)
   (org-block-begin-line :foreground base5 :background bg-alt)
   (org-block-end-line   :foreground base5 :background bg-alt)
   (org-meta-line        :foreground base5)
   (org-todo             :foreground red    :weight 'bold)
   (org-done             :foreground green  :weight 'bold)
   (org-headline-done    :foreground base5)
   (org-level-1 :foreground orange  :weight 'semi-bold :height 1.4)
   (org-level-2 :foreground green   :weight 'semi-bold :height 1.2)
   (org-level-3 :foreground yellow  :weight 'semi-bold :height 1.1)
   (org-level-4 :foreground red     :weight 'semi-bold)
   (org-level-5 :foreground fg      :weight 'semi-bold)
   (org-level-6 :foreground base6   :weight 'semi-bold)
   (org-level-7 :foreground base5   :weight 'semi-bold)
   (org-level-8 :foreground (doom-darken orange 0.2) :weight 'semi-bold)

   ;; rainbow-delimiters — cycle 4 accents + 4 grey-luminance steps
   (rainbow-delimiters-depth-1-face  :foreground orange)
   (rainbow-delimiters-depth-2-face  :foreground green)
   (rainbow-delimiters-depth-3-face  :foreground yellow)
   (rainbow-delimiters-depth-4-face  :foreground red)
   (rainbow-delimiters-depth-5-face  :foreground base7)
   (rainbow-delimiters-depth-6-face  :foreground base6)
   (rainbow-delimiters-depth-7-face  :foreground base5)
   (rainbow-delimiters-depth-8-face  :foreground (doom-darken orange 0.2))
   (rainbow-delimiters-unmatched-face :foreground red)

   ;; show-paren
   (show-paren-match :foreground bg :background orange)

   ;; vertico
   (vertico-current :foreground fg :background base3)

   ;; isearch
   (isearch        :foreground bg     :background orange)
   (lazy-highlight :foreground orange :background base0 :underline orange)

   ;; company
   (company-tooltip-common-selection :foreground bg :background orange)

   ;; tree-sitter / built-in
   (highlight-numbers-number :foreground red)
   (highlight-quoted-quote   :foreground orange)
   (highlight-quoted-symbol  :foreground green)
   )


  ;; --- extra variables ---------------------
  ()
  )

;;; ax-matte-black-theme.el ends here
