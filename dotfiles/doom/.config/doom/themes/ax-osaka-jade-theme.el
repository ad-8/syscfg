;;; ax-osaka-jade-theme.el --- inspired by osaka-jade (omarchy)
;;; https://github.com/Justikun/omarchy-osaka-jade-theme
(require 'doom-themes)

(defgroup ax-osaka-jade-theme nil
  "Options for ax-osaka-jade"
  :group 'doom-themes)

(defcustom ax-osaka-jade-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'ax-osaka-jade-theme
  :type 'boolean)

(defcustom ax-osaka-jade-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'ax-osaka-jade-theme
  :type 'boolean)

(defcustom ax-osaka-jade-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'ax-osaka-jade-theme
  :type '(choice integer boolean))

;; Colors sourced from omarchy themes/osaka-jade/colors.toml
(def-doom-theme ax-osaka-jade
  "A calm dark jade theme inspired by osaka-jade"
  ;; name        default        256       16
  ((bg         '("#111c18"      nil       nil            )) ;; background
   (bg-alt     '("#11221C"      nil       nil            )) ;; mako/walker bg

   (base0      '("#0a1410"      "black"   "black"        )) ;; invented; darker than bg
   (base1      '("#152419"      "#1e1e1e" "brightblack"  )) ;; invented; gradient step
   (base2      '("#1a2d22"      "#2e2e2e" "brightblack"  )) ;; invented; gradient step
   (base3      '("#23372B"      "#262626" "brightblack"  )) ;; color0
   (base4      '("#32473B"      "#3f3f3f" "brightblack"  )) ;; btop inactive_fg
   (base5      '("#53685B"      "#525252" "brightblack"  )) ;; color8
   (base6      '("#81B8A8"      "#6b6b6b" "brightblack"  )) ;; btop box border
   (base7      '("#A8BCA5"      "#979797" "brightblack"  )) ;; invented; gradient step
   (base8      '("#F6F5DD"      "#dfdfdf" "white"        )) ;; color7

   (fg         '("#C1C497"      "#bfbfbf" "brightwhite"  )) ;; foreground
   (fg-alt     '("#D6D5BC"      "#2d2d2d" "white"        )) ;; btop title

   (grey       base5)
   (red        '("#FF5345"      "#ff6655" "red"          )) ;; color1
   (orange     '("#E67D64"      "#dd8844" "brightred"    )) ;; btop hi_fg; no real orange in palette
   (green      '("#549E6A"      "#99bb66" "green"        )) ;; color2
   (teal       '("#2DD5B7"      "#44b9b1" "cyan"         )) ;; color6
   (yellow     '("#E5C736"      "#ECBE7B" "yellow"       )) ;; color11 (real gold; color3 is mis-slotted green)
   (blue       '("#509475"      "#51afef" "blue"         )) ;; color4 = jade accent
   (dark-blue  '("#214237"      "#2257A0" "blue"         )) ;; mako/walker border
   (magenta    '("#D2689C"      "#c678dd" "magenta"      )) ;; color5
   (violet     '("#DB9F9C"      "#a9a1e1" "brightmagenta")) ;; color9 dusty rose; no real violet
   (cyan       '("#8CD3CB"      "#46D9FF" "brightcyan"   )) ;; color14
   (dark-cyan  '("#75BBB3"      "#5699AF" "cyan"         )) ;; color13

   ;; face categories -- required for all themes
   (highlight      blue)
   (vertical-bar   (doom-darken base2 0.1))
   (selection      dark-blue)
   (builtin        teal)
   (comments       (if ax-osaka-jade-brighter-comments cyan base5))
   (doc-comments   (doom-lighten teal 0.2))
   (constants      violet)
   (functions      blue)
   (keywords       red)
   (methods        blue)
   (operators      fg-alt)
   (type           yellow)
   (strings        green)
   (variables      cyan)
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
   (-modeline-bright ax-osaka-jade-brighter-modeline)
   (-modeline-pad
    (when ax-osaka-jade-padded-modeline
      (if (integerp ax-osaka-jade-padded-modeline) ax-osaka-jade-padded-modeline 4)))

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
   (diredfl-deletion    :foreground red :background (doom-lighten red 0.55))

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
   (org-block-begin-line :foreground dark-cyan :background bg-alt)
   (org-block-end-line   :foreground dark-cyan :background bg-alt)
   (org-meta-line        :foreground dark-blue)
   (org-todo             :foreground orange :weight 'bold)
   (org-done             :foreground green  :weight 'bold)
   (org-headline-done    :foreground base5)
   (org-level-1 :foreground blue    :weight 'semi-bold)
   (org-level-2 :foreground teal    :weight 'semi-bold)
   (org-level-3 :foreground cyan    :weight 'semi-bold)
   (org-level-4 :foreground yellow  :weight 'semi-bold)
   (org-level-5 :foreground magenta :weight 'semi-bold)
   (org-level-6 :foreground violet  :weight 'semi-bold)
   (org-level-7 :foreground green   :weight 'semi-bold)
   (org-level-8 :foreground (doom-darken cyan 0.2) :weight 'semi-bold)

   ;; rainbow-delimiters
   (rainbow-delimiters-depth-1-face  :foreground blue)
   (rainbow-delimiters-depth-2-face  :foreground teal)
   (rainbow-delimiters-depth-3-face  :foreground cyan)
   (rainbow-delimiters-depth-4-face  :foreground yellow)
   (rainbow-delimiters-depth-5-face  :foreground magenta)
   (rainbow-delimiters-depth-6-face  :foreground violet)
   (rainbow-delimiters-depth-7-face  :foreground green)
   (rainbow-delimiters-depth-8-face  :foreground (doom-lighten blue 0.2))
   (rainbow-delimiters-unmatched-face :foreground red)

   ;; show-paren
   (show-paren-match :foreground blue :background base0 :weight 'bold)

   ;; vertico
   (vertico-current :foreground fg :background base3)

   ;; isearch
   (isearch        :foreground bg   :background blue)
   (lazy-highlight :foreground blue :background base0 :underline blue)

   ;; company
   (company-tooltip-common-selection :foreground bg :background blue)

   ;; tree-sitter / built-in
   (highlight-numbers-number :foreground violet)
   (highlight-quoted-quote   :foreground blue)
   (highlight-quoted-symbol  :foreground green)
   )


  ;; --- extra variables ---------------------
  ()
  )

;;; ax-osaka-jade-theme.el ends here
