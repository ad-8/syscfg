;;; doom-lumon-theme.el --- inspired by lumon (omarchy / Severance)
;;; https://github.com/OldJobobo/omarchy-lumon-theme
(require 'doom-themes)

(defgroup doom-lumon-theme nil
  "Options for doom-lumon"
  :group 'doom-themes)

(defcustom doom-lumon-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-lumon-theme
  :type 'boolean)

(defcustom doom-lumon-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-lumon-theme
  :type 'boolean)

(defcustom doom-lumon-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'doom-lumon-theme
  :type '(choice integer boolean))

;; Strict monochrome blue palette from omarchy-lumon-theme.
;; Semantic distinction is encoded via luminance steps, not hue:
;; comments dim, functions accent, error brightest.
;;
;; Column 1 (GUI hex) is always lumon. Columns 2 (256-color fallback hex) and
;; 3 (16-color X11 name) are inherited from doom-themes defaults and may be
;; non-lumon — they never render in GUI emacs. Affected rows are tagged
;; "[256/16 non-lumon: inherited]".
(def-doom-theme doom-lumon
  "A cold corporate Severance-inspired theme — strict monochrome blue"
  ;; name        default        256       16
  ((bg         '("#1b2d40"      nil       nil            )) ;; lumon background
   (bg-alt     '("#0c1822"      nil       nil            )) ;; walker panel

   (base0      '("#071018"      "black"   "black"        )) ;; foot cursor text (darkest) [16 name "black" resolves via terminal palette]
   (base1      '("#102231"      "#1e1e1e" "brightblack"  )) ;; walker hover [256/16 non-lumon: inherited]
   (base2      '("#112a3c"      "#2e2e2e" "brightblack"  )) ;; walker selected-bg [256/16 non-lumon: inherited]
   (base3      '("#1b2d40"      "#262626" "brightblack"  )) ;; color0 / bg [256/16 non-lumon: inherited]
   (base4      '("#304860"      "#3f3f3f" "brightblack"  )) ;; bundle color8 [256/16 non-lumon: inherited]
   (base5      '("#4A6B80"      "#525252" "brightblack"  )) ;; color8 / walker border [256/16 non-lumon: inherited]
   (base6      '("#89a1b8"      "#6b6b6b" "brightblack"  )) ;; walker muted [256/16 non-lumon: inherited]
   (base7      '("#b1d8ee"      "#979797" "brightblack"  )) ;; color13 [256/16 non-lumon: inherited]
   (base8      '("#ffffff"      "#dfdfdf" "white"        )) ;; color15 [256 non-lumon: inherited]

   (fg         '("#d6e2ee"      "#bfbfbf" "brightwhite"  )) ;; foreground [256 non-lumon: inherited]
   (fg-alt     '("#f2fcff"      "#2d2d2d" "white"        )) ;; color12 / brightest [256 non-lumon: inherited]

   (grey       base5)
   ;; All "colored" slots are blues — strict monochrome palette.
   ;; Roles distinguished by luminance only.
   (red        '("#4d86b0"      "#ff6655" "red"          )) ;; color1 (dimmer blue) [256/16 non-lumon: inherited]
   (orange     '("#5e95bc"      "#dd8844" "brightred"    )) ;; color2 [256/16 non-lumon: inherited]
   (green      '("#6fa4c9"      "#99bb66" "green"        )) ;; color3 [256/16 non-lumon: inherited]
   (teal       '("#b4e4f6"      "#44b9b1" "cyan"         )) ;; color6 (bright) [256 non-lumon: inherited]
   (yellow     '("#9dcae5"      "#ECBE7B" "yellow"       )) ;; color11 [256/16 non-lumon: inherited]
   (blue       '("#6fb8e3"      "#51afef" "blue"         )) ;; color4 = lumon accent (signature) [256 non-lumon: inherited]
   (dark-blue  '("#4d86b0"      "#2257A0" "blue"         )) ;; color1 [256 non-lumon: inherited]
   (magenta    '("#8bc9eb"      "#c678dd" "magenta"      )) ;; color5 [256/16 non-lumon: inherited]
   (violet     '("#73a6cb"      "#a9a1e1" "brightmagenta")) ;; color9 [256 non-lumon: inherited]
   (cyan       '("#d1eef8"      "#46D9FF" "brightcyan"   )) ;; color14 (very bright) [256 non-lumon: inherited]
   (dark-cyan  '("#86b7d8"      "#5699AF" "cyan"         )) ;; color10 [256 non-lumon: inherited]

   ;; face categories — required for all themes
   ;; Strict-palette semantic mapping: comments lowest luminance, functions = accent,
   ;; errors brightest. Brightness IS the severity signal.
   (highlight      blue)
   (vertical-bar   (doom-darken base2 0.1))
   (selection      base2)
   (builtin        cyan)
   (comments       (if doom-lumon-brighter-comments magenta base5))
   (doc-comments   (doom-lighten base5 0.2))
   (constants      violet)
   (functions      blue)
   (keywords       magenta)
   (methods        blue)
   (operators      fg)
   (type           yellow)
   (strings        green)
   (variables      teal)
   (numbers        violet)
   (region         `(,(doom-lighten (car bg-alt) 0.15) ,@(doom-lighten (cdr base0) 0.35)))
   (error          fg-alt)
   (warning        cyan)
   (success        blue)
   (vc-modified    fg)
   (vc-added       blue)
   (vc-deleted     fg-alt)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-bright doom-lumon-brighter-modeline)
   (-modeline-pad
    (when doom-lumon-padded-modeline
      (if (integerp doom-lumon-padded-modeline) doom-lumon-padded-modeline 4)))

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
   (diredfl-deletion    :foreground fg-alt :background (doom-darken base2 0.1))

   ;; eshell
   (+eshell-prompt-git-branch :foreground blue)

   ;; evil
   (evil-ex-lazy-highlight      :foreground fg :background (doom-darken teal 0.3))
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
   (org-block-begin-line :foreground dark-cyan :background bg-alt)
   (org-block-end-line   :foreground dark-cyan :background bg-alt)
   (org-meta-line        :foreground dark-blue)
   (org-level-1 :foreground blue    :weight 'semi-bold :height 1.4)
   (org-level-2 :foreground teal    :weight 'semi-bold :height 1.2)
   (org-level-3 :foreground cyan    :weight 'semi-bold :height 1.1)
   (org-level-4 :foreground magenta :weight 'semi-bold)
   (org-level-5 :foreground violet  :weight 'semi-bold)
   (org-level-6 :foreground yellow  :weight 'semi-bold)
   (org-level-7 :foreground green   :weight 'semi-bold)
   (org-level-8 :foreground dark-cyan :weight 'semi-bold)

   ;; rainbow-delimiters
   (rainbow-delimiters-depth-1-face  :foreground blue)
   (rainbow-delimiters-depth-2-face  :foreground teal)
   (rainbow-delimiters-depth-3-face  :foreground cyan)
   (rainbow-delimiters-depth-4-face  :foreground magenta)
   (rainbow-delimiters-depth-5-face  :foreground violet)
   (rainbow-delimiters-depth-6-face  :foreground yellow)
   (rainbow-delimiters-depth-7-face  :foreground green)
   (rainbow-delimiters-depth-8-face  :foreground dark-cyan)
   (rainbow-delimiters-unmatched-face :foreground fg-alt)

   ;; show-paren
   (show-paren-match :foreground bg :background blue)

   ;; vertico
   (vertico-current :foreground fg :background base3)

   ;; isearch
   (isearch        :foreground bg   :background blue)
   (lazy-highlight :foreground blue :background base0 :underline blue)

   ;; company
   (company-tooltip-common-selection :foreground bg :background blue)
   )


  ;; --- extra variables ---------------------
  ()
  )

;;; doom-lumon-theme.el ends here
