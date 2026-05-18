;;; doom-hackerman-theme.el --- inspired by hackerman (omarchy)
;;; https://github.com/bjarneo/hackerman.nvim
(require 'doom-themes)

(defgroup doom-hackerman-theme nil
  "Options for doom-hackerman"
  :group 'doom-themes)

(defcustom doom-hackerman-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-hackerman-theme
  :type 'boolean)

(defcustom doom-hackerman-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-hackerman-theme
  :type 'boolean)

(defcustom doom-hackerman-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'doom-hackerman-theme
  :type '(choice integer boolean))

;; Colors sourced from omarchy themes/hackerman/colors.toml
(def-doom-theme doom-hackerman
  "A dark cyberpunk theme inspired by hackerman"
  ;; name        default        256       16
  ((bg         '("#0b0c16"      nil       nil            ))
   (bg-alt     '("#0f1020"      nil       nil            )) ;; invented; gradient step between bg and base0
   (base0      '("#1e1f32"      "black"   "black"        )) ;; invented; gradient step between bg and color0
   (base1      '("#252639"      "#1e1e1e" "brightblack"  )) ;; invented; gradient step toward color0
   (base2      '("#2e2f48"      "#2e2e2e" "brightblack"  )) ;; invented; gradient step toward color0
   (base3      '("#3e4058"      "#262626" "brightblack"  )) ;; color0
   (base4      '("#4a4d72"      "#3f3f3f" "brightblack"  )) ;; invented; gradient step between color0 and color8
   (base5      '("#6a6e95"      "#525252" "brightblack"  )) ;; color8 / inactive_fg
   (base6      '("#9da5c0"      "#6b6b6b" "brightblack"  )) ;; invented; gradient step between color8 and color12
   (base7      '("#c4d2ed"      "#979797" "brightblack"  )) ;; color12
   (base8      '("#d1fffe"      "#dfdfdf" "white"        )) ;; color14
   (fg         '("#ddf7ff"      "#bfbfbf" "brightwhite"  ))
   (fg-alt     '("#85e1fb"      "#2d2d2d" "white"        )) ;; color7

   (grey       base5)
   (red        '("#e05e6d"      "#ff6655" "red"          )) ;; invented; no red in palette
   (orange     '("#ffa566"      "#dd8844" "brightred"    )) ;; invented; no orange in palette
   (green      '("#82fb9c"      "#99bb66" "green"        )) ;; accent
   (teal       '("#4fe88f"      "#44b9b1" "brightgreen"  )) ;; color2
   (yellow     '("#a4ffec"      "#ECBE7B" "yellow"       )) ;; color11
   (blue       '("#829dd4"      "#51afef" "brightblue"   )) ;; color4
   (dark-blue  '("#6a6e95"      "#2257A0" "blue"         )) ;; color8
   (magenta    '("#86a7df"      "#c678dd" "brightmagenta")) ;; color5
   (violet     '("#cddbf4"      "#a9a1e1" "magenta"      )) ;; color13
   (cyan       '("#7cf8f7"      "#46D9FF" "brightcyan"   )) ;; color6
   (dark-cyan  '("#50f7d4"      "#5699AF" "cyan"         )) ;; color3

   ;; face categories -- required for all themes
   (highlight      green)
   (vertical-bar   (doom-darken base2 0.1))
   (selection      dark-blue)
   (builtin        yellow)
   (comments       (if doom-hackerman-brighter-comments cyan base5))
   (doc-comments   (doom-lighten teal 0.2))
   (constants      violet)
   (functions      cyan)
   (keywords       green)
   (methods        cyan)
   (operators      fg-alt)
   (type           magenta)
   (strings        teal)
   (variables      blue)
   (numbers        dark-cyan)
   (region         `(,(doom-lighten (car bg-alt) 0.15) ,@(doom-lighten (cdr base0) 0.35)))
   (error          red)
   (warning        orange)
   (success        green)
   (vc-modified    orange)
   (vc-added       green)
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-bright doom-hackerman-brighter-modeline)
   (-modeline-pad
    (when doom-hackerman-padded-modeline
      (if (integerp doom-hackerman-padded-modeline) doom-hackerman-padded-modeline 4)))

   (modeline-fg     fg)
   (modeline-fg-alt fg-alt)

   (modeline-bg
    (if -modeline-bright
        (doom-darken green 0.475)
      `(,(doom-darken (car bg-alt) 0.15) ,@(cdr base0))))
   (modeline-bg-l
    (if -modeline-bright
        (doom-darken green 0.45)
      `(,(doom-darken (car bg-alt) 0.1) ,@(cdr base0))))
   (modeline-bg-inactive   `(,(doom-darken (car bg-alt) 0.1) ,@(cdr bg-alt)))
   (modeline-bg-inactive-l `(,(car bg-alt) ,@(cdr base1))))


  ;; --- extra faces ------------------------
  ((evil-goggles-default-face :inherit 'region :background (doom-blend region bg 0.5))

   ((line-number &override) :foreground base5)
   ((line-number-current-line &override) :foreground green)

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
   (doom-modeline-bar :background (if -modeline-bright modeline-bg green))
   (doom-modeline-buffer-file :inherit 'mode-line-buffer-id :weight 'bold)
   (doom-modeline-buffer-path :inherit 'mode-line-emphasis :weight 'bold)
   (doom-modeline-buffer-project-root :foreground green :weight 'bold)

   ;; column indicator
   (fill-column-indicator :foreground bg-alt :background bg-alt)

   ;; cursor
   (cursor :foreground bg :background green)

   ;; css-mode / scss-mode
   (css-proprietary-property :foreground magenta)
   (css-property             :foreground teal)
   (css-selector             :foreground green)

   ;; dired
   (diredfl-dir-heading :foreground green :weight 'bold)
   (diredfl-dir-name    :foreground cyan)
   (diredfl-file-name   :foreground fg)
   (diredfl-symlink     :foreground teal)
   (diredfl-deletion    :foreground red :background (doom-lighten red 0.55))

   ;; eshell
   (+eshell-prompt-git-branch :foreground green)

   ;; evil
   (evil-ex-lazy-highlight      :foreground fg :background (doom-darken teal 0.3))
   (evil-snipe-first-match-face :foreground bg :background green)

   ;; ivy
   (ivy-current-match           :foreground green :background base3)
   (ivy-minibuffer-match-face-2 :foreground green :background bg)

   ;; lsp
   (lsp-face-highlight-read    :foreground fg-alt :background (doom-darken dark-blue 0.3))
   (lsp-face-highlight-textual :foreground fg-alt :background (doom-lighten dark-blue 0.3))
   (lsp-face-highlight-write   :foreground fg-alt :background (doom-darken dark-blue 0.3))

   ;; magit
   (magit-section-heading :foreground green :weight 'bold)
   (magit-branch-local    :foreground cyan  :weight 'bold)
   (magit-branch-remote   :foreground teal  :weight 'bold)
   (magit-diff-added             :foreground green :background (doom-blend green bg 0.15))
   (magit-diff-added-highlight   :foreground green :background (doom-blend green bg 0.25))
   (magit-diff-removed           :foreground red   :background (doom-blend red bg 0.15))
   (magit-diff-removed-highlight :foreground red   :background (doom-blend red bg 0.25))

   ;; markdown
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground green)
   ((markdown-code-face &override) :background base0)

   ;; org-mode
   (org-hide :foreground hidden)
   (solaire-org-hide-face :foreground hidden)
   (org-drawer                :foreground dark-blue)
   (org-document-info         :foreground cyan)
   (org-document-info-keyword :foreground dark-blue)
   (org-document-title        :foreground green :weight 'bold)
   (org-block            :foreground fg  :background bg-alt)
   (org-block-begin-line :foreground dark-cyan :background bg-alt)
   (org-block-end-line   :foreground dark-cyan :background bg-alt)
   (org-meta-line        :foreground dark-blue)
   (org-todo             :foreground orange :weight 'bold)
   (org-done             :foreground green  :weight 'bold)
   (org-headline-done    :foreground base5)
   (org-level-1 :foreground green   :weight 'semi-bold :height 1.4)
   (org-level-2 :foreground cyan    :weight 'semi-bold :height 1.2)
   (org-level-3 :foreground teal    :weight 'semi-bold :height 1.1)
   (org-level-4 :foreground blue    :weight 'semi-bold)
   (org-level-5 :foreground magenta :weight 'semi-bold)
   (org-level-6 :foreground violet  :weight 'semi-bold)
   (org-level-7 :foreground (doom-darken green 0.2) :weight 'semi-bold)
   (org-level-8 :foreground (doom-darken cyan 0.2)  :weight 'semi-bold)

   ;; rainbow-delimiters
   (rainbow-delimiters-depth-1-face  :foreground green)
   (rainbow-delimiters-depth-2-face  :foreground cyan)
   (rainbow-delimiters-depth-3-face  :foreground teal)
   (rainbow-delimiters-depth-4-face  :foreground blue)
   (rainbow-delimiters-depth-5-face  :foreground magenta)
   (rainbow-delimiters-depth-6-face  :foreground violet)
   (rainbow-delimiters-depth-7-face  :foreground dark-cyan)
   (rainbow-delimiters-depth-8-face  :foreground (doom-lighten green 0.2))
   (rainbow-delimiters-unmatched-face :foreground red)

   ;; show-paren
   (show-paren-match :foreground bg :background green)

   ;; vertico
   (vertico-current :foreground fg :background base3)

   ;; isearch
   (isearch        :foreground bg    :background green)
   (lazy-highlight :foreground green :background base0 :underline green)

   ;; company
   (company-tooltip-common-selection :foreground bg :background green)

   ;; tree-sitter / built-in
   (highlight-numbers-number :foreground dark-cyan)
   (highlight-quoted-quote   :foreground green)
   (highlight-quoted-symbol  :foreground teal)
   )


  ;; --- extra variables ---------------------
  ()
  )

;;; doom-hackerman-theme.el ends here
