;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Jamie McFarlane"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "VictorMono NF" :size 12)
       doom-variable-pitch-font (font-spec :family "VictorMono NF" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-nord)
(setq doom-theme 'doom-solarized-light)
(delq! t custom-theme-load-path)

;;(load-theme 'nord t)

;;nicer deafult buffer names
(setq doom-fallback-buffer-name "► Doom"
      +doom-dashboard-name "► Doom")

;;some custom stuff to modify the modeline to remove UTF-8
(defun doom-modeline-conditional-buffer-encoding ()
  "We expect the encoding to be LF UTF-8, so only show the modeline when this is not the case"
  (setq-local doom-modeline-buffer-encoding
              (unless (or (eq buffer-file-coding-system 'utf-8-unix)
                          (eq buffer-file-coding-system 'utf-8)))))

(add-hook 'after-change-major-mode-hook #'doom-modeline-conditional-buffer-encoding)


;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; Time for some manual configuration (18oct20)
;;

;;company settings
(setq company-idle-delay 0)
(setq company-minimum-prefix-length 2)

(use-package company-quickhelp
 ;; :ensure t
  :defer t
  :init (with-eval-after-load 'company
          (company-quickhelp-mode)))

;; now for some extra setup, taken from old config (02Nov20)

;; Instead of audibe alarms, have a visual one
  (setq ring-bell-function
        (lambda ()
          (let ((orig-fg (face-foreground 'mode-line)))
            (set-face-foreground 'mode-line "#F2804F")
            (run-with-idle-timer 0.1 nil
                                 (lambda (fg) (set-face-foreground 'mode-line fg))
                                 orig-fg))))

;; ess stuff
(with-eval-after-load "ess"
  (require 'ess-R-data-view) ;;Custom add: Dont actually know how to work it
  (require 'ess-site)
  (require 'ess-mode)
  ;; standard control-enter evaluation
  (define-key ess-mode-map (kbd "<C-return>") 'ess-eval-region-or-function-or-paragraph-and-step)
  (define-key ess-mode-map (kbd "<C-S-return>") 'ess-eval-buffer)
  (define-key ess-mode-map [remap ess-indent-or-complete] #'company-indent-or-complete-common)
  ;; Set ESS options
  (setq
   ;;ess-auto-width 'window
   ;;ess-use-auto-complete nil
   ;;ess-use-flymake nil
   ;;ess-use-company 't
   ;; ess-r-package-auto-set-evaluation-env nil
   ;;inferior-ess-same-window nil
   ess-indent-with-fancy-comments nil   ; don't indent comments
   ;;ess-eval-visibly t                   ; enable echoing input
   ;;ess-eval-empty t                     ; don't skip non-code lines.
   ;;ess-ask-for-ess-directory nil        ; start R in the working directory by default
   ess-ask-for-ess-directory nil        ; start R in the working directory by default
   ess-R-font-lock-keywords             ; font-lock, but not too much
   (quote
    ((ess-R-fl-keyword:modifiers . t)
     (ess-R-fl-keyword:fun-defs . t)
     (ess-R-fl-keyword:keywords . t)
     (ess-R-fl-keyword:assign-ops  . t)
     (ess-R-fl-keyword:constants . 1)
     (ess-fl-keyword:fun-calls . t)
     (ess-fl-keyword:numbers . t)
     (ess-fl-keyword:operators . t)
     (ess-fl-keyword:delimiters . t)
     (ess-fl-keyword:= . t)
     (ess-R-fl-keyword:F&T . t)))))
;; this line from https://tecosaur.github.io/emacs-config/config.html#centaur-tabs
;;(set-company-backend! 'ess-r-mode '(company-R-args company-R-objects company-dabbrev-code :separate))

;; Adapted with one minor change from Felipe Salazar at
;; http://www.emacswiki.org/emacs/EmacsSpeaksStatistics
(setq ess-ask-for-ess-directory nil)
(setq ess-local-process-name "R")
(setq ansi-color-for-comint-mode 'filter)
(setq comint-scroll-to-bottom-on-input t)
(setq comint-scroll-to-bottom-on-output t)
(setq comint-move-point-for-output t)
(defun my-ess-start-R ()
  (interactive)
  (if (not (member "*R*" (mapcar (function buffer-name) (buffer-list))))
      (progn
        (delete-other-windows)
        (setq w1 (selected-window))
        (setq w1name (buffer-name))
        (setq w2 (split-window w1 nil t))
        (R)
        (set-window-buffer w2 "*R*")
        (set-window-buffer w1 w1name))))
(defun my-ess-eval ()
  (interactive)
  (my-ess-start-R)
  (if (and transient-mark-mode mark-active)
      (call-interactively 'ess-eval-region)
    (call-interactively 'ess-eval-line-and-step)))
(add-hook 'ess-mode-hook
          '(lambda()
             (local-set-key [(shift return)] 'my-ess-eval)))
(add-hook 'inferior-ess-mode-hook
          '(lambda()
             (local-set-key [C-up] 'comint-previous-input)
             (local-set-key [C-down] 'comint-next-input)))
(add-hook 'Rnw-mode-hook
          '(lambda()
             (local-set-key [(shift return)] 'my-ess-eval)))
(require 'ess-site)

;; Congfigure org-ref, for referencing stuff=============
;;Experimental
;;(use-package! org-ref
;;  :after org
;;  :config
;; (setq org-ref-completion-library 'org-ref-ivy-cite))

(require 'org-ref)

;; set some variables
(setq reftex-default-bibliography '("~/Documents/bibliography/references.bib"))

;; see org-ref for use of these variables
(setq org-ref-bibliography-notes "~/Documents/bibliography/notes.org"
      org-ref-default-bibliography '("~/Documents/bibliography/references.bib")
      org-ref-pdf-directory "~/Documents/bibliography/bibtex-pdfs/")

;; helm configuration for searching
(setq bibtex-completion-bibliography "~/Documents/bibliography/references.bib"
      bibtex-completion-library-path "~/Documents/bibliography/bibtex-pdfs"
      bibtex-completion-notes-path "~/Documents/bibliography/helm-bibtex-notes")

;; EMMS setup
(add-to-list 'load-path "~/elisp/emms/lisp/")
(emms-all)
(emms-default-players)
(setq emms-source-file-default-directory "~/Music/")


;; the following comes from https://tecosaur.github.io/emacs-config/config.html#centaur-tabs
;;
;;
;;simple settings
(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
      auto-save-default t                         ; Nobody likes to loose work, I certainly don't
      truncate-string-ellipsis "…")               ; Unicode ellispis are nicer than "...", and also save /precious/ space

(display-time-mode 1)                             ; Enable time in the mode-line
(unless (equal "Battery status not available"
               (battery))
  (display-battery-mode 1))                       ; On laptops it's nice to know how much power you have
(global-subword-mode 1)                           ; Iterate through CamelCase words
;;
;;windows
(setq evil-vsplit-window-right t
      evil-split-window-below t)

(defadvice! prompt-for-buffer (&rest _)         ;prompts for buffers
  :after '(evil-window-split evil-window-vsplit)
  (+ivy/switch-buffer))
(setq +ivy-buffer-preview t)                    ;and previews
;;
;;default buffers in org-mode
(setq-default major-mode 'org-mode)

;;mouse buttons
(map! :n [mouse-8] #'better-jumper-jump-backward
      :n [mouse-9] #'better-jumper-jump-forward)


;;more company
;;(after! company
;;  (setq company-idle-delay 0.5
;;        company-minimum-prefix-length 2)
;;  (setq company-show-numbers t)
;;  (add-hook 'evil-normal-state-entry-hook #'company-abort)) ;; make aborting less annoying.
;;(setq-default history-length 1000)
;;(setq-default prescient-history-length 1000)
;;and more ispell in text and markdown and gfm
;;(set-company-backend!
;;  '(text-mode
;;    markdown-mode
;;    gfm-mode)
;;  '(:seperate
;;    company-ispell
;;    company-files
;;    company-yasnippet))

;;the info colours package
(use-package! info-colors
  :commands (info-colors-fontify-node))

(add-hook 'Info-selection-hook 'info-colors-fontify-node)

(add-hook 'Info-mode-hook #'mixed-pitch-mode)


;;careful here: Might not work. Trying to get icons sorted
;; Whether display the icon for `major-mode'. It respects `doom-modeline-icon'.
(setq doom-modeline-major-mode-icon t)

;; Whether display the colorful icon for `major-mode'.
;; It respects `all-the-icons-color-icons'.
(setq doom-modeline-major-mode-color-icon t)

;; Whether display the icon for the buffer state. It respects `doom-modeline-icon'.
(setq doom-modeline-buffer-state-icon t)

;; Whether display the modification icon for the buffer.
;; It respects `doom-modeline-icon' and `doom-modeline-buffer-state-icon'.
(setq doom-modeline-buffer-modification-icon t)

;;centaur tabs (if it will work)
(after! centaur-tabs
  (centaur-tabs-mode -1)
  (setq centaur-tabs-height 36
        centaur-tabs-set-icons t
        centaur-tabs-modified-marker "o"
        centaur-tabs-close-button "×"
        centaur-tabs-set-bar 'above
        centaur-tabs-gray-out-icons 'buffer))


;;random splash images
(require 'random-splash-image)
(setq random-splash-image-dir "~/.doom.d/misc/splash-images")
(random-splash-image-set)

;;increase which key prompt speed
;;(setq which-key-idle-delay 0.5)
