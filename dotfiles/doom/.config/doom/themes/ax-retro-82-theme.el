;;; ax-retro-82-theme.el --- inspired by retro-82 (omarchy)
;;; Canonical palette source: https://github.com/OldJobobo/omarchy-retro-82-theme
;;; Editor Base24 extension: https://github.com/OldJobobo/retro-82.nvim
(require 'doom-themes)

(defgroup ax-retro-82-theme nil
  "Options for ax-retro-82"
  :group 'doom-themes)

(defcustom ax-retro-82-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'ax-retro-82-theme
  :type 'boolean)

(defcustom ax-retro-82-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'ax-retro-82-theme
  :type 'boolean)

(defcustom ax-retro-82-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'ax-retro-82-theme
  :type '(choice integer boolean))

;; All hex values are drawn from author-published sources:
;;   - omarchy-retro-82-theme (colors.toml + retro80.yaml base16 spec)
;;   - retro-82.nvim palette.lua (Base24 editor extension by the same author)
;;
;; Signature color is orange #faa968 (base0A / accent / function /
;; preproc / keyword). Used for cursor, modeline-bar, highlight, org-level-1,
;; rainbow-delimiters depth 1, isearch, paren-match — anywhere the theme
;; should assert identity.
;;
;; Slot picks deviate from the nvim port in one place: strings use
;; #19a7a8 (success/bright teal) rather than nvim's #f6dcac (cream), which
;; would equal fg and make strings invisible against plain text. This is
;; the only deviation; everything else follows nvim's palette.lua aliases.
(def-doom-theme ax-retro-82
  "A retro 80s navy + cream + orange theme inspired by retro-82"
  ;; name        default        256       16
  ((bg         '("#00172e"      nil       nil            )) ;; base00 = canonical background
   (bg-alt     '("#01204e"      nil       nil            )) ;; base01 = navy step (solaire elevated)

   (base0      '("#000f1f"      "black"   "black"        )) ;; base10 = surface_deep
   (base1      '("#011935"      "#1e1e1e" "brightblack"  )) ;; base11 = surface_deeper
   (base2      '("#01204e"      "#2e2e2e" "brightblack"  )) ;; base01
   (base3      '("#0a3a45"      "#262626" "brightblack"  )) ;; base02 = surface
   (base4      '("#134e5a"      "#3f3f3f" "brightblack"  )) ;; base03 = comment / color8 / selection
   (base5      '("#2a6a73"      "#525252" "brightblack"  )) ;; base04 = muted
   (base6      '("#5f8f96"      "#6b6b6b" "brightblack"  )) ;; base05 = fg_dim
   (base7      '("#a7c9c6"      "#979797" "brightblack"  )) ;; base06 = fg0 / color7
   (base8      '("#fff1da"      "#dfdfdf" "white"        )) ;; base07 = sand (brightest)

   (fg         '("#f6dcac"      "#bfbfbf" "brightwhite"  )) ;; cream (color15)
   (fg-alt     '("#fff1da"      "#2d2d2d" "white"        )) ;; brightest sand

   (grey       base5)
   (red        '("#f85525"      "#ff6655" "red"          )) ;; base08 = error / color1
   (orange     '("#faa968"      "#dd8844" "brightred"    )) ;; base0A = function / keyword / accent (SIGNATURE)
   (green      '("#19a7a8"      "#99bb66" "green"        )) ;; base14 = success / string
   (teal       '("#8cbfb8"      "#44b9b1" "cyan"         )) ;; base0C = support / color6
   (yellow     '("#e97b3c"      "#ECBE7B" "yellow"       )) ;; base09 = warning / color3 (mid-orange — no real yellow)
   (blue       '("#6fa6c8"      "#51afef" "blue"         )) ;; base1D = type (cool blue)
   (dark-blue  '("#2c7c88"      "#2257A0" "blue"         )) ;; base17 = module / namespace
   (magenta    '("#ff8a6b"      "#c678dd" "magenta"      )) ;; base18 = constant / number (peach — no real magenta)
   (violet     '("#e0b55e"      "#a9a1e1" "brightmagenta")) ;; base19 = tag.attribute (amber — no real violet)
   (cyan       '("#39b5d4"      "#46D9FF" "brightcyan"   )) ;; base1C = annotation / info
   (dark-cyan  '("#028391"      "#5699AF" "cyan"         )) ;; base0E = statement / operator / color2

   ;; face categories -- required for all themes
   (highlight      orange)
   (vertical-bar   (doom-darken base2 0.1))
   (selection      base4)
   (builtin        teal)
   (comments       (if ax-retro-82-brighter-comments (doom-lighten base5 0.2) base4))
   (doc-comments   (doom-lighten base5 0.2))
   (constants      magenta)
   (functions      orange)
   (keywords       orange)
   (methods        orange)
   (operators      dark-cyan)
   (type           blue)
   (strings        green)
   (variables      fg)
   (numbers        magenta)
   (region         `(,(doom-lighten (car bg-alt) 0.15) ,@(doom-lighten (cdr base0) 0.35)))
   (error          red)
   (warning        yellow)
   (success        green)
   (vc-modified    violet)
   (vc-added       green)
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-bright ax-retro-82-brighter-modeline)
   (-modeline-pad
    (when ax-retro-82-padded-modeline
      (if (integerp ax-retro-82-padded-modeline) ax-retro-82-padded-modeline 4)))

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
   (css-proprietary-property :foreground magenta)
   (css-property             :foreground teal)
   (css-selector             :foreground orange)

   ;; dired
   (diredfl-dir-heading :foreground orange :weight 'bold)
   (diredfl-dir-name    :foreground blue)
   (diredfl-file-name   :foreground fg)
   (diredfl-symlink     :foreground teal)
   (diredfl-deletion    :foreground red :background (doom-darken base2 0.1))

   ;; eshell
   (+eshell-prompt-git-branch :foreground orange)

   ;; evil
   (evil-ex-lazy-highlight      :foreground bg :background (doom-darken teal 0.3))
   (evil-snipe-first-match-face :foreground bg :background orange)

   ;; ivy
   (ivy-current-match           :foreground orange :background base3)
   (ivy-minibuffer-match-face-2 :foreground orange :background bg)

   ;; lsp
   (lsp-face-highlight-read    :foreground fg-alt :background (doom-darken dark-blue 0.3))
   (lsp-face-highlight-textual :foreground fg-alt :background (doom-lighten dark-blue 0.3))
   (lsp-face-highlight-write   :foreground fg-alt :background (doom-darken dark-blue 0.3))

   ;; magit
   (magit-section-heading :foreground orange :weight 'bold)
   (magit-branch-local    :foreground cyan :weight 'bold)
   (magit-branch-remote   :foreground teal :weight 'bold)
   (magit-diff-added            :foreground green     :background (doom-blend green bg 0.15))
   (magit-diff-added-highlight  :foreground green     :background (doom-blend green bg 0.25))
   (magit-diff-removed          :foreground red       :background (doom-blend red bg 0.15))
   (magit-diff-removed-highlight :foreground red      :background (doom-blend red bg 0.25))

   ;; markdown
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground orange)
   ((markdown-code-face &override) :background base0)

   ;; org-mode
   (org-hide :foreground hidden)
   (solaire-org-hide-face :foreground hidden)
   (org-drawer                :foreground dark-blue)
   (org-document-info         :foreground cyan)
   (org-document-info-keyword :foreground dark-blue)
   (org-document-title        :foreground orange :weight 'bold)
   (org-block            :foreground fg  :background bg-alt)
   (org-block-begin-line :foreground dark-cyan :background bg-alt)
   (org-block-end-line   :foreground dark-cyan :background bg-alt)
   (org-meta-line        :foreground dark-blue)
   (org-todo             :foreground orange :weight 'bold)
   (org-done             :foreground green  :weight 'bold)
   (org-headline-done    :foreground base5)
   (org-level-1 :foreground orange  :weight 'semi-bold)
   (org-level-2 :foreground teal    :weight 'semi-bold)
   (org-level-3 :foreground cyan    :weight 'semi-bold)
   (org-level-4 :foreground blue    :weight 'semi-bold)
   (org-level-5 :foreground green   :weight 'semi-bold)
   (org-level-6 :foreground magenta :weight 'semi-bold)
   (org-level-7 :foreground violet  :weight 'semi-bold)
   (org-level-8 :foreground dark-cyan :weight 'semi-bold)

   ;; rainbow-delimiters
   (rainbow-delimiters-depth-1-face  :foreground orange)
   (rainbow-delimiters-depth-2-face  :foreground teal)
   (rainbow-delimiters-depth-3-face  :foreground cyan)
   (rainbow-delimiters-depth-4-face  :foreground blue)
   (rainbow-delimiters-depth-5-face  :foreground green)
   (rainbow-delimiters-depth-6-face  :foreground magenta)
   (rainbow-delimiters-depth-7-face  :foreground violet)
   (rainbow-delimiters-depth-8-face  :foreground dark-cyan)
   (rainbow-delimiters-unmatched-face :foreground red)

   ;; show-paren
   (show-paren-match :foreground orange :background base0 :weight 'bold)

   ;; vertico
   (vertico-current :foreground fg :background base3)

   ;; isearch
   (isearch        :foreground bg     :background orange :weight 'bold)
   (lazy-highlight :foreground orange :background base0  :underline orange)

   ;; company
   (company-tooltip-common-selection :foreground bg :background orange)

   ;; tree-sitter / built-in
   (highlight-numbers-number   :foreground magenta)
   (highlight-quoted-quote     :foreground orange)
   (highlight-quoted-symbol    :foreground green)
   )


  ;; --- extra variables ---------------------
  ()
  )

;;; ax-retro-82-theme.el ends here
