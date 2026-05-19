;;; doom-oxocarbon-light-theme.el --- inspired by oxocarbon (IBM Carbon, light) -*- no-byte-compile: t; -*-
;;; Canonical palette source: https://github.com/nyoom-engineering/oxocarbon.nvim
;;; All hex values are drawn from upstream init.lua light branch (line 12 ternary,
;;; "background == 'dark' or {light}" arm). No invented intermediates.
(require 'doom-themes)

(defgroup doom-oxocarbon-light-theme nil
  "Options for doom-oxocarbon-light"
  :group 'doom-themes)

(defcustom doom-oxocarbon-light-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-oxocarbon-light-theme
  :type 'boolean)

(defcustom doom-oxocarbon-light-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-oxocarbon-light-theme
  :type 'boolean)

(defcustom doom-oxocarbon-light-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'doom-oxocarbon-light-theme
  :type '(choice integer boolean))

;; Signature color is blue #0f62fe (base11 in light branch / IBM Carbon blue-60).
;; Light-only — not present in the dark variant which uses #33b1ff instead.
;; Used anywhere the theme should assert identity.
;;
;; The light variant introduces three Material-flavoured warm colors absent
;; from the dark palette: #FF6F00 orange (Error), #673AB7 deep purple
;; (@function), #FFAB91 peach (Number). Combined with reused hues from the
;; dark palette (#08bdba teal, #42be65 green, #be95ff purple, #ee5396 pink,
;; #ff7eb6 light pink), this gives ~10 distinct hues for 11 doom slots —
;; one alias is unavoidable.
;;
;; Slot aliasings (oxocarbon-light's published palette has fewer hues than
;; doom expects):
;;   - yellow    = #FFAB91 (Material peach — no real yellow in palette)
;;   - cyan      = teal    = #08bdba (only one cyan in light palette)
;;   - dark-cyan = #be95ff (light purple — slot name is misleading, role is
;;                          "muted secondary"; matches String/@constant upstream)
;;
;; Column 1 (GUI hex) is always oxocarbon-light. Columns 2 (256-color fallback)
;; and 3 (16-color X11 name) are inherited from doom-themes defaults; they
;; never render in GUI emacs. Affected rows tagged "[256/16 non-oxo: inherited]".
(def-doom-theme doom-oxocarbon-light
  "A light IBM Carbon-inspired theme — IBM blue + Material warm accents on white"
  ;; name        default        256       16
  ((bg         '("#ffffff"      nil       nil            )) ;; base00 = white background
   (bg-alt     '("#f2f4f8"      nil       nil            )) ;; base01 = Carbon gray-10 (elevated panel)

   (base0      '("#FAFAFA"      "white"   "white"        )) ;; blend = lightest float bg
   (base1      '("#ffffff"      "#1e1e1e" "brightblack"  )) ;; bg [256/16 non-oxo: inherited]
   (base2      '("#f2f4f8"      "#2e2e2e" "brightblack"  )) ;; base01 [256/16 non-oxo: inherited]
   (base3      '("#dde1e6"      "#262626" "brightblack"  )) ;; base02 = selection / dim ui [256/16 non-oxo: inherited]
   (base4      '("#90A4AE"      "#3f3f3f" "brightblack"  )) ;; base05 = Material blue-grey 400 [256/16 non-oxo: inherited]
   (base5      '("#525252"      "#525252" "brightblack"  )) ;; base06 = mid grey (comments)
   (base6      '("#37474F"      "#6b6b6b" "brightblack"  )) ;; base04 = Material blue-grey 700 (Normal fg upstream) [256/16 non-oxo: inherited]
   (base7      '("#161616"      "#979797" "brightblack"  )) ;; base03 = near-black [256/16 non-oxo: inherited]
   (base8      '("#161616"      "#dfdfdf" "white"        )) ;; near-black = brightest contrast [256 non-oxo: inherited]

   (fg         '("#37474F"      "#bfbfbf" "brightwhite"  )) ;; base04 [256 non-oxo: inherited]
   (fg-alt     '("#161616"      "#2d2d2d" "white"        )) ;; base03 (brightest contrast) [256 non-oxo: inherited]

   (grey       base5)
   (red        '("#ee5396"      "#ff6655" "red"          )) ;; base09 = Keyword / Type / deep pink [256/16 non-oxo: inherited]
   (orange     '("#FF6F00"      "#dd8844" "brightred"    )) ;; base10 = Error (Material orange, light-only) [256/16 non-oxo: inherited]
   (green      '("#42be65"      "#99bb66" "green"        )) ;; base13 [256/16 non-oxo: inherited]
   (teal       '("#08bdba"      "#44b9b1" "cyan"         )) ;; base07 = IBM cyan / @namespace / @method [256 non-oxo: inherited]
   (yellow     '("#FFAB91"      "#ECBE7B" "yellow"       )) ;; base15 = Number (Material peach; no real yellow in palette) [256/16 non-oxo: inherited]
   (blue       '("#0f62fe"      "#51afef" "blue"         )) ;; base11 = SIGNATURE (IBM Carbon blue-60, light-only) [256 non-oxo: inherited]
   (dark-blue  '("#37474F"      "#2257A0" "blue"         )) ;; base04 = deep blue-grey [256 non-oxo: inherited]
   (magenta    '("#ff7eb6"      "#c678dd" "magenta"      )) ;; base08 = light pink [256/16 non-oxo: inherited]
   (violet     '("#673AB7"      "#a9a1e1" "brightmagenta")) ;; base12 = @function (Material deep purple, light-only) [256 non-oxo: inherited]
   (cyan       '("#08bdba"      "#46D9FF" "brightcyan"   )) ;; = teal (only one cyan in light palette) [256 non-oxo: inherited]
   (dark-cyan  '("#be95ff"      "#5699AF" "cyan"         )) ;; base14 = String / @constant (light purple) [256 non-oxo: inherited]

   ;; face categories -- required for all themes
   (highlight      blue)
   (vertical-bar   (doom-lighten base2 0.1))
   (selection      base3)
   (builtin        teal)
   (comments       (if doom-oxocarbon-light-brighter-comments base4 base5))
   (doc-comments   (doom-darken base5 0.1))
   (constants      dark-cyan)
   (functions      violet)
   (keywords       red)
   (methods        teal)
   (operators      fg)
   (type           red)
   (strings        dark-cyan)
   (variables      fg)
   (numbers        yellow)
   (region         `(,(doom-darken (car bg-alt) 0.1) ,@(doom-darken (cdr base0) 0.1)))
   (error          orange)
   (warning        dark-cyan)
   (success        green)
   (vc-modified    blue)
   (vc-added       green)
   (vc-deleted     orange)

   ;; custom categories
   (hidden     `(,(car bg) "white" "white"))
   (-modeline-bright doom-oxocarbon-light-brighter-modeline)
   (-modeline-pad
    (when doom-oxocarbon-light-padded-modeline
      (if (integerp doom-oxocarbon-light-padded-modeline) doom-oxocarbon-light-padded-modeline 4)))

   (modeline-fg     fg)
   (modeline-fg-alt fg-alt)

   (modeline-bg
    (if -modeline-bright
        (doom-lighten blue 0.4)
      `(,(doom-darken (car bg-alt) 0.05) ,@(cdr base2))))
   (modeline-bg-l
    (if -modeline-bright
        (doom-lighten blue 0.45)
      `(,(doom-darken (car bg-alt) 0.02) ,@(cdr base2))))
   (modeline-bg-inactive   `(,(car bg-alt) ,@(cdr base1)))
   (modeline-bg-inactive-l `(,(doom-lighten (car bg-alt) 0.1) ,@(cdr base1))))


  ;; --- extra faces ------------------------
  ((evil-goggles-default-face :inherit 'region :background (doom-blend region bg 0.5))

   ((line-number &override) :foreground base4)
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
   (css-proprietary-property :foreground violet)
   (css-property             :foreground teal)
   (css-selector             :foreground blue)

   ;; dired
   (diredfl-dir-heading :foreground blue :weight 'bold)
   (diredfl-dir-name    :foreground violet)
   (diredfl-file-name   :foreground fg)
   (diredfl-symlink     :foreground teal)
   (diredfl-deletion    :foreground orange :background (doom-lighten base2 0.1))

   ;; eshell
   (+eshell-prompt-git-branch :foreground blue)

   ;; evil
   (evil-ex-lazy-highlight      :foreground bg :background (doom-darken teal 0.1))
   (evil-snipe-first-match-face :foreground bg :background blue)

   ;; ivy
   (ivy-current-match           :foreground blue :background base3)
   (ivy-minibuffer-match-face-2 :foreground blue :background bg)

   ;; lsp — light variant inverts the dark→lighten relation
   (lsp-face-highlight-read    :foreground fg-alt :background (doom-lighten blue 0.7))
   (lsp-face-highlight-textual :foreground fg-alt :background (doom-lighten blue 0.6))
   (lsp-face-highlight-write   :foreground fg-alt :background (doom-lighten blue 0.7))

   ;; magit
   (magit-section-heading :foreground blue :weight 'bold)
   (magit-branch-local    :foreground violet :weight 'bold)
   (magit-branch-remote   :foreground teal :weight 'bold)
   (magit-diff-added             :foreground green  :background (doom-blend green bg 0.15))
   (magit-diff-added-highlight   :foreground green  :background (doom-blend green bg 0.3))
   (magit-diff-removed           :foreground orange :background (doom-blend orange bg 0.15))
   (magit-diff-removed-highlight :foreground orange :background (doom-blend orange bg 0.3))

   ;; markdown
   (markdown-markup-face :foreground base4)
   (markdown-header-face :inherit 'bold :foreground blue)
   ((markdown-code-face &override) :background base2)

   ;; org-mode
   (org-hide :foreground hidden)
   (solaire-org-hide-face :foreground hidden)
   (org-drawer                :foreground dark-blue)
   (org-document-info         :foreground violet)
   (org-document-info-keyword :foreground dark-blue)
   (org-document-title        :foreground blue :weight 'bold)
   (org-block            :foreground fg  :background bg-alt)
   (org-block-begin-line :foreground teal :background bg-alt)
   (org-block-end-line   :foreground teal :background bg-alt)
   (org-meta-line        :foreground dark-blue)
   (org-todo             :foreground red   :weight 'bold)
   (org-done             :foreground green :weight 'bold)
   (org-headline-done    :foreground base4)
   (org-level-1 :foreground blue      :weight 'semi-bold :height 1.4)
   (org-level-2 :foreground teal      :weight 'semi-bold :height 1.2)
   (org-level-3 :foreground violet    :weight 'semi-bold :height 1.1)
   (org-level-4 :foreground red       :weight 'semi-bold)
   (org-level-5 :foreground magenta   :weight 'semi-bold)
   (org-level-6 :foreground orange    :weight 'semi-bold)
   (org-level-7 :foreground green     :weight 'semi-bold)
   (org-level-8 :foreground dark-cyan :weight 'semi-bold)

   ;; rainbow-delimiters — uses every distinct hue in the light palette
   (rainbow-delimiters-depth-1-face  :foreground blue)
   (rainbow-delimiters-depth-2-face  :foreground teal)
   (rainbow-delimiters-depth-3-face  :foreground violet)
   (rainbow-delimiters-depth-4-face  :foreground red)
   (rainbow-delimiters-depth-5-face  :foreground magenta)
   (rainbow-delimiters-depth-6-face  :foreground orange)
   (rainbow-delimiters-depth-7-face  :foreground green)
   (rainbow-delimiters-depth-8-face  :foreground dark-cyan)
   (rainbow-delimiters-unmatched-face :foreground orange)

   ;; show-paren
   (show-paren-match :foreground bg :background blue :weight 'bold)

   ;; vertico
   (vertico-current :foreground fg :background base3)

   ;; isearch
   (isearch        :foreground bg   :background blue :weight 'bold)
   (lazy-highlight :foreground blue :background base2 :underline blue)

   ;; company
   (company-tooltip-common-selection :foreground bg :background blue)

   ;; tree-sitter / built-in
   (highlight-numbers-number :foreground yellow)
   (highlight-quoted-quote   :foreground violet)
   (highlight-quoted-symbol  :foreground dark-cyan)
   )


  ;; --- extra variables ---------------------
  ()
  )

;;; doom-oxocarbon-light-theme.el ends here
