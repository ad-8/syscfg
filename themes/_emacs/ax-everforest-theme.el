;;; ax-everforest-theme.el --- inspired by Everforest -*- lexical-binding: t; no-byte-compile: t; -*-
;;; https://github.com/sainnhe/everforest
(require 'doom-themes)

;;
(defgroup ax-everforest-theme nil
  "Options for ax-everforest"
  :group 'doom-themes)

(defcustom ax-everforest-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'ax-everforest-theme
  :type 'boolean)

(defcustom ax-everforest-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'ax-everforest-theme
  :type 'boolean)

(defcustom ax-everforest-comment-bg ax-everforest-brighter-comments
  "If non-nil, comments will have a subtle, darker background. Enhancing their
legibility."
  :group 'ax-everforest-theme
  :type 'boolean)

(defcustom ax-everforest-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'ax-everforest-theme
  :type '(choice integer boolean))

(defcustom ax-everforest-background nil
  "Choice between \"soft\", \"medium\" and \"hard\" background contrast.
Defaults to \"hard\""
  :group 'ax-everforest-theme
  :type 'string)
;; colors from
;; https://github.com/sainnhe/everforest/blob/master/autoload/everforest.vim
(cond
 ((equal ax-everforest-background "soft")
  (setq ef/bg           "#333c43"       ;; bg0
        ef/bg-alt       "#293136"       ;; bg_dim
        ef/base1        "#3a464c"       ;; bg1
        ef/base2        "#434f55"       ;; bg2
        ef/base3        "#4d5960"       ;; bg3
        ef/base4        "#555f66"       ;; bg4
        ef/bg-blue      "#3f5865"       ;; bg_blue
        ef/bg-visual    "#5c3f4f"       ;; bg_visual
        ef/bg-red       "#59464c"))     ;; bg_red
 ((equal ax-everforest-background "medium")
  (setq ef/bg           "#2d353b"       ;; bg0
        ef/bg-alt       "#232a2e"       ;; bg_dim
        ef/base1        "#343f44"       ;; bg1
        ef/base2        "#3d484d"       ;; bg2
        ef/base3        "#475258"       ;; bg3
        ef/base4        "#4f585e"       ;; bg4
        ef/bg-blue      "#3a515d"       ;; bg_blue
        ef/bg-visual    "#543a48"       ;; bg_visual
        ef/bg-red       "#514045"))     ;; bg_red
 (t
  (setq ef/bg           "#272e33"       ;; bg0
        ef/bg-alt       "#1e2326"       ;; bg_dim
        ef/base1        "#2e383c"       ;; bg1
        ef/base2        "#374145"       ;; bg2
        ef/base3        "#414b50"       ;; bg3
        ef/base4        "#495156"       ;; bg4
        ef/bg-blue      "#384b55"       ;; bg_blue
        ef/bg-visual    "#4c3743"       ;; bg_visual
        ef/bg-red       "#493b40")))    ;; bg_red

(def-doom-theme ax-everforest
  "A dark theme inspired by Everforest"
  ;; name        default        256       16
  ((bg         `(,ef/bg         nil       nil            ))
   (bg-alt     `(,ef/bg-alt     nil       nil            ))
   (base0      `(,ef/bg-alt     "black"   "black"        )) ;; bg_dim
   (base1      `(,ef/base1      "#1e1e1e" "brightblack"  ))
   (base2      `(,ef/base2      "#2e2e2e" "brightblack"  ))
   (base3      `(,ef/base3      "#262626" "brightblack"  ))
   (base4      `(,ef/base4      "#3f3f3f" "brightblack"  ))
   (base5      '("#7a8478"       "#525252" "brightblack"  )) ;; grey0
   (base6      '("#859289"       "#6b6b6b" "brightblack"  )) ;; grey1
   (base7      '("#9da9a0"       "#979797" "brightblack"  )) ;; grey2
   (base8      '("#d3c6aa"       "#dfdfdf" "white"        )) ;; fg
   (fg         '("#d3c6aa"      "#bfbfbf" "brightwhite"  ))
   (fg-alt     '("#859289"      "#2d2d2d" "white"        )) ;; grey1

   (grey       base5) ;; grey0
   (red        '("#e67e80"      "#ff6655" "red"          ))
   (orange     '("#e69875"      "#dd8844" "brightred"    ))
   (green      '("#a7c080"      "#99bb66" "green"        ))
   (teal       '("#83c092"      "#44b9b1" "brightgreen"  )) ;; aqua
   (yellow     '("#dbbc7f"      "#ECBE7B" "yellow"       ))
   (blue       '("#7fbbb3"      "#51afef" "brightblue"   ))
   (dark-blue  blue)
   (magenta    '("#d699b6"      "#c678dd" "brightmagenta")) ;; purple
   (violet     '("#d699b6"      "#a9a1e1" "magenta"      )) ;; purple
   (cyan       '("#83c092"      "#46D9FF" "brightcyan"   )) ;; aqua
   (dark-cyan  cyan)
   (bg-visual  `(,ef/bg-visual  "#262626" "brightblack"  ))
   (bg-red     `(,ef/bg-red     "#5f0000" "red"          ))
   (bg-blue    `(,ef/bg-blue    "#005f87" "blue"         ))

   ;; face categories -- required for all themes
   (highlight      cyan)
   (vertical-bar   base4)
   (selection      bg-visual)
   (builtin        magenta)
   (comments       (if ax-everforest-brighter-comments base7 base6))
   (doc-comments   teal)
   (constants      violet)
   (functions      green)
   (keywords       red)
   (methods        green)
   (operators      orange)
   (type           yellow)
   (strings        teal)
   (variables      blue)
   (numbers        magenta)
   (region         bg-visual)
   (error          red)
   (warning        yellow)
   (success        green)
   (vc-modified    orange)
   (vc-added       green)
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-bright ax-everforest-brighter-modeline)
   (-modeline-pad
    (when ax-everforest-padded-modeline
      (if (integerp ax-everforest-padded-modeline) ax-everforest-padded-modeline 4)))

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
  ((elscreen-tab-other-screen-face :background base2 :foreground base6)

   (evil-goggles-default-face :inherit 'region :background (doom-blend region bg 0.5))

   ((line-number &override) :foreground base5)
   ((line-number-current-line &override) :foreground fg)

   (font-lock-comment-face
    :foreground comments
    :slant 'italic
    :background (if ax-everforest-comment-bg (doom-lighten bg 0.05)))
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
   (doom-modeline-bar :background (if -modeline-bright modeline-bg highlight))
   (doom-modeline-buffer-file :inherit 'mode-line-buffer-id :weight 'bold)
   (doom-modeline-buffer-path :inherit 'mode-line-emphasis :weight 'bold)
   (doom-modeline-buffer-project-root :foreground green :weight 'bold)

   ;; --- major-mode faces -------------------
   ;; column indicator
   (fill-column-indicator :foreground bg-alt :background bg-alt)

   ;; css-mode / scss-mode
   (css-proprietary-property :foreground orange)
   (css-property             :foreground green)
   (css-selector             :foreground blue)

   ;; cursor
   (cursor :foreground fg :background blue)

   ;; dired
   (diredfl-compressed-file-name :foreground yellow)
   (diredfl-dir-heading :foreground teal)
   (diredfl-dir-name :foreground blue)
   (diredfl-deletion :foreground red :background bg-red)
   (diredfl-deletion-file-name :foreground red :background bg-red)
   (diredfl-file-name :foreground fg)
   (dired-flagged :foreground red :background bg-red)
   (diredfl-symlink :foreground magenta)

   ;; ein
   (ein:basecell-input-area-face :background bg)

   ;; eshell
   (+eshell-prompt-git-branch :foreground cyan)

   ;; evil
   (evil-ex-search :foreground bg :background red :weight 'bold)
   (evil-snipe-first-match-face :foreground bg :background orange)


   ;; ivy
   (ivy-current-match :foreground blue :background bg)
   (ivy-minibuffer-match-face-2 :foreground blue :background bg)

   ;; LaTeX-mode
   (font-latex-math-face :foreground (doom-lighten green 0.15))
   (font-latex-script-char-face :foreground (doom-lighten dark-blue 0.15))

   ;; lsp
   (lsp-face-highlight-textual :background base2)
   (lsp-lsp-flycheck-info-unnecessary-face :foreground (doom-lighten yellow 0.12))

   ;; magit
   (magit-section-heading :foreground blue :weight 'bold)
   (magit-branch-local    :foreground cyan  :weight 'bold)
   (magit-branch-remote   :foreground green :weight 'bold)
   ((magit-diff-file-heading-selection &override) :background bg-blue)
   ((magit-header-line &override) :background bg-blue
    :box `(:line-width 3 :color ,bg-blue))

   ;; markdown-mode
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground red)
   ((markdown-code-face &override) :background (doom-lighten base3 0.05))

   ;; org-mode
   (org-hide :foreground hidden)
   (solaire-org-hide-face :foreground hidden)
   (org-drawer :foreground (doom-darken yellow 0.15))
   (org-document-info :foreground blue)
   (org-document-info-keyword :foreground base6)
   (org-document-title :foreground blue)
   (org-block-begin-line :foreground base6
                         :background bg-alt)
   (org-block-end-line :foreground base6
                         :background bg-alt)
   (org-block :foreground fg :background bg-alt)
   (org-meta-line :foreground base6)
   (org-agenda-done :foreground base5)
   ;; org-habit graph: org's four meaning colours, everforest's own where it has one
   (org-habit-clear-face          :background blue   :foreground bg)
   (org-habit-clear-future-face   :background (doom-blend blue bg-alt 0.3))
   (org-habit-ready-face          :background green  :foreground bg)
   (org-habit-ready-future-face   :background (doom-blend green bg-alt 0.3))
   (org-habit-alert-face          :background yellow :foreground bg)
   (org-habit-alert-future-face   :background (doom-blend yellow bg-alt 0.3))
   (org-habit-overdue-face        :background red    :foreground bg)
   (org-habit-overdue-future-face :background (doom-blend red bg-alt 0.3))
   (org-level-1 :foreground magenta :weight 'semi-bold)
   (org-level-2 :foreground cyan :weight 'semi-bold)
   (org-level-3 :foreground green :weight 'semi-bold)
   (org-level-4 :foreground yellow :weight 'semi-bold)
   (org-level-5 :foreground violet :weight 'semi-bold)
   (org-level-6 :foreground blue :weight 'semi-bold)
   (org-level-7 :foreground (doom-darken green 0.15) :weight 'semi-bold)
   (org-level-8 :foreground (doom-darken yellow 0.15) :weight 'semi-bold)

   ;; org-ref
   (org-ref-ref-face :foreground magenta)

   ;; org-roam
   (org-roam-title :foreground orange :weight 'semi-bold)

   ;; rainbow and parenthesis
   (rainbow-delimiters-depth-1-face :foreground orange)
   (rainbow-delimiters-depth-2-face :foreground violet)
   (rainbow-delimiters-depth-3-face :foreground cyan)
   (rainbow-delimiters-depth-4-face :foreground (doom-darken yellow 0.15))
   (rainbow-delimiters-depth-5-face :foreground green)
   (rainbow-delimiters-depth-6-face :foreground blue)
   (rainbow-delimiters-depth-7-face :foreground red)
   (rainbow-delimiters-depth-8-face :foreground (doom-darken green 0.15))
   (rainbow-delimiters-unmatched-face :foreground red)
   (show-paren-match :foreground (doom-darken red 0.15) :background base4 :weight 'bold)

   ;; vertico
   (vertico-current :foreground fg :background (doom-lighten bg 0.1))

   ;; others
   (secondary-selection :background base4 :extend t)
   (isearch :foreground bg :background red)
   (lazy-highlight :foreground bg :background green)
   (company-tooltip-common-selection :foreground bg-alt :background dark-blue)
   )


  ;; --- extra variables ---------------------
  ()
  )

;;; ax-everforest-theme.el ends here
