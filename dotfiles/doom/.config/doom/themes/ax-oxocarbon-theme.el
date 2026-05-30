;;; ax-oxocarbon-theme.el --- inspired by oxocarbon (IBM Carbon)
;;; Canonical palette source: https://github.com/nyoom-engineering/oxocarbon.nvim
;;; All hex values are drawn from upstream init.lua (dark-mode base table
;;; + named hex literals in face definitions). No invented intermediates.
(require 'doom-themes)

(defgroup ax-oxocarbon-theme nil
  "Options for ax-oxocarbon"
  :group 'doom-themes)

(defcustom ax-oxocarbon-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'ax-oxocarbon-theme
  :type 'boolean)

(defcustom ax-oxocarbon-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'ax-oxocarbon-theme
  :type 'boolean)

(defcustom ax-oxocarbon-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'ax-oxocarbon-theme
  :type '(choice integer boolean))

;; Signature color is blue #78a9ff (base09 / accent / cursor / modeline-bar /
;; highlight / paren-match / org-level-1 / rainbow-depth-1 / isearch).
;; Used anywhere the theme should assert identity — upstream README cites
;; the "vibrant set of blues" as the centerpiece of the IBM Carbon palette.
;;
;; Two slot aliasings (oxocarbon publishes fewer warm hues than doom expects):
;;   - orange  = magenta = #ff7eb6 (base12, pink — fills the warm-accent slot)
;;   - yellow  = violet  = #be95ff (base14, purple — DiagnosticWarn upstream)
;; All other slots are distinct.
;;
;; Column 1 (GUI hex) is always oxocarbon. Columns 2 (256-color fallback hex)
;; and 3 (16-color X11 name) are inherited from doom-themes defaults and may
;; be non-oxocarbon — they never render in GUI emacs. Affected rows are
;; tagged "[256/16 non-oxo: inherited]".
(def-doom-theme ax-oxocarbon
  "A dark IBM Carbon-inspired theme — vibrant blues on industrial grays"
  ;; name        default        256       16
  ((bg         '("#161616"      nil       nil            )) ;; base00 = canonical background
   (bg-alt     '("#262626"      nil       nil            )) ;; base01 = elevated panel (Pmenu)

   (base0      '("#131313"      "black"   "black"        )) ;; blend = float bg (NormalFloat, darkest)
   (base1      '("#161616"      "#1e1e1e" "brightblack"  )) ;; bg [256/16 non-oxo: inherited]
   (base2      '("#262626"      "#2e2e2e" "brightblack"  )) ;; base01 [256/16 non-oxo: inherited]
   (base3      '("#393939"      "#262626" "brightblack"  )) ;; base02 = selection / Visual [256/16 non-oxo: inherited]
   (base4      '("#525252"      "#3f3f3f" "brightblack"  )) ;; base03 = comments / muted [256/16 non-oxo: inherited]
   (base5      '("#525252"      "#525252" "brightblack"  )) ;; base03 = grey/comments alias
   (base6      '("#adadad"      "#6b6b6b" "brightblack"  )) ;; CmpItemAbbr (upstream mid-grey) [256/16 non-oxo: inherited]
   (base7      '("#dde1e6"      "#979797" "brightblack"  )) ;; base04 = fg [256/16 non-oxo: inherited]
   (base8      '("#f2f4f8"      "#dfdfdf" "white"        )) ;; base05 = brighter fg [256 non-oxo: inherited]

   (fg         '("#dde1e6"      "#bfbfbf" "brightwhite"  )) ;; base04 [256 non-oxo: inherited]
   (fg-alt     '("#f2f4f8"      "#2d2d2d" "white"        )) ;; base05 [256 non-oxo: inherited]

   (grey       base5)
   (red        '("#ee5396"      "#ff6655" "red"          )) ;; base10 = Error / pink-red [256/16 non-oxo: inherited]
   (orange     '("#ff7eb6"      "#dd8844" "brightred"    )) ;; base12 = @function (pink fills warm-accent slot) [256/16 non-oxo: inherited]
   (green      '("#42be65"      "#99bb66" "green"        )) ;; base13 = HealthSuccess / DiffAdded [256/16 non-oxo: inherited]
   (teal       '("#08bdba"      "#44b9b1" "cyan"         )) ;; base07 = IBM cyan / @namespace / @method [256 non-oxo: inherited]
   (yellow     '("#be95ff"      "#ECBE7B" "yellow"       )) ;; base14 = DiagnosticWarn (purple, no real yellow) [256/16 non-oxo: inherited]
   (blue       '("#78a9ff"      "#51afef" "blue"         )) ;; base09 = Keyword / Type / SIGNATURE [256 non-oxo: inherited]
   (dark-blue  '("#33b1ff"      "#2257A0" "blue"         )) ;; base11 = DiagnosticInfo [256 non-oxo: inherited]
   (magenta    '("#ff7eb6"      "#c678dd" "magenta"      )) ;; base12 = @function (= orange) [256/16 non-oxo: inherited]
   (violet     '("#be95ff"      "#a9a1e1" "brightmagenta")) ;; base14 = String / @constant (= yellow) [256 non-oxo: inherited]
   (cyan       '("#3ddbd9"      "#46D9FF" "brightcyan"   )) ;; base08 = Function / Directory / PmenuSel [256 non-oxo: inherited]
   (dark-cyan  '("#82cfff"      "#5699AF" "cyan"         )) ;; base15 = Number / @label / sky blue [256 non-oxo: inherited]

   ;; face categories -- required for all themes
   (highlight      blue)
   (vertical-bar   (doom-darken base2 0.1))
   (selection      base3)
   (builtin        teal)
   (comments       (if ax-oxocarbon-brighter-comments (doom-lighten base5 0.2) base5))
   (doc-comments   (doom-lighten base5 0.2))
   (constants      violet)
   (functions      magenta)
   (keywords       blue)
   (methods        cyan)
   (operators      fg)
   (type           blue)
   (strings        violet)
   (variables      fg)
   (numbers        dark-cyan)
   (region         `(,(doom-lighten (car bg-alt) 0.15) ,@(doom-lighten (cdr base0) 0.35)))
   (error          red)
   (warning        yellow)
   (success        green)
   (vc-modified    blue)
   (vc-added       green)
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-bright ax-oxocarbon-brighter-modeline)
   (-modeline-pad
    (when ax-oxocarbon-padded-modeline
      (if (integerp ax-oxocarbon-padded-modeline) ax-oxocarbon-padded-modeline 4)))

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
   (org-todo             :foreground magenta :weight 'bold)
   (org-done             :foreground green   :weight 'bold)
   (org-headline-done    :foreground base5)
   (org-level-1 :foreground blue      :weight 'semi-bold :height 1.4)
   (org-level-2 :foreground teal      :weight 'semi-bold :height 1.2)
   (org-level-3 :foreground magenta   :weight 'semi-bold :height 1.1)
   (org-level-4 :foreground violet    :weight 'semi-bold)
   (org-level-5 :foreground cyan      :weight 'semi-bold)
   (org-level-6 :foreground dark-cyan :weight 'semi-bold)
   (org-level-7 :foreground green     :weight 'semi-bold)
   (org-level-8 :foreground dark-blue :weight 'semi-bold)

   ;; rainbow-delimiters — uses every distinct hue in the palette
   (rainbow-delimiters-depth-1-face  :foreground blue)
   (rainbow-delimiters-depth-2-face  :foreground teal)
   (rainbow-delimiters-depth-3-face  :foreground magenta)
   (rainbow-delimiters-depth-4-face  :foreground violet)
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
   (highlight-numbers-number :foreground dark-cyan)
   (highlight-quoted-quote   :foreground magenta)
   (highlight-quoted-symbol  :foreground violet)
   )


  ;; --- extra variables ---------------------
  ()
  )

;;; ax-oxocarbon-theme.el ends here
