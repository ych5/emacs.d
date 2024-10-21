;;; init-misc.el --- Miscellaneous config -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; uniquify
;; {{
(with-eval-after-load 'uniquify
  (setq uniquify-after-kill-buffer-p t
        uniquify-buffer-name-style 'reverse
        uniquify-ignore-buffers-re "^\\*"
        uniquify-separator " • "))
;; }}

;; recentf
;; {{
(setq-default recentf-max-saved-items 1000
              recentf-exclude `("/tmp/" "/ssh:" ,(concat package-user-dir "/.*-autoloads\\.el\\'")))
(add-hook 'after-init-hook 'recentf-mode)
;; }}

;; session
;; {{
(require-package 'session)

;; Any global variable matching `session-globals-regexp' is saved *automatically*.
(setq session-save-file (locate-user-emacs-file ".session"))
(setq session-globals-max-size 2048)

;; Store 8Mb string
(setq session-globals-max-string (* 8 1024 1024))

(setq session-name-disable-regexp "\\(?:\\`'/tmp\\|\\.git/[A-Z_]+\\'\\)")
(setq session-globals-include '(kill-ring
                                (session-file-alist 100 t)
                                file-name-history
                                search-ring
                                regexp-search-ring))

(setq session-save-file-coding-system 'utf-8)
(add-hook 'after-init-hook 'session-initialize)
;; }}

;; isearch
;; {{
(setq isearch-lazy-count t
      lazy-count-prefix-format "%s/%s "
      lazy-highlight-cleanup nil)

;; Use regex to search by default
(global-set-key (kbd "C-M-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-M-r") 'isearch-backward-regexp)

(with-eval-after-load 'isearch
  ;; DEL during isearch should edit the search string, not jump back to the previous result
  (define-key isearch-mode-map [remap isearch-delete-char] 'isearch-del-char)

  (define-key isearch-mode-map (kbd "C-o") 'isearch-occur))
;; }}

;; hippie-expand
;; {{
(global-set-key (kbd "M-/") 'hippie-expand)

(setq hippie-expand-try-functions-list
      '(try-complete-file-name-partially
        try-complete-file-name
        try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill))
;; }}

;; Handy key bindings
;; {{
(global-set-key (kbd "C-.") 'set-mark-command)
(global-set-key (kbd "C-x C-.") 'pop-global-mark)

;; Zap *up* to char is a handy pair for zap-to-char
(global-set-key (kbd "M-Z") 'zap-up-to-char)

;; M-^ is inconvenient, so also bind M-j
(global-set-key (kbd "M-j") 'join-line)

(defun sanityinc/newline-at-end-of-line ()
  "Move to end of line, enter a newline, and reindent."
  (interactive)
  (move-end-of-line 1)
  (newline-and-indent))
(global-set-key (kbd "S-<return>") 'sanityinc/newline-at-end-of-line)
;; }}

;; {{
(setq ring-bell-function 'ignore)

(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message t)

(setq-default auto-save-default nil
              case-fold-search t
              column-number-mode t
              create-lockfiles nil
              ediff-split-window-function 'split-window-horizontally
              ediff-window-setup-function 'ediff-setup-windows-plain
              indent-tabs-mode nil
              indicate-buffer-boundaries 'left
              indicate-empty-lines t
              make-backup-files nil
              mouse-yank-at-point t
              save-interprogram-paste-before-kill t
              set-mark-command-repeat-pop t
              truncate-lines nil)
;; }}

;; Special handling for whitespace
;; {{
(setq-default show-trailing-whitespace nil)

(global-set-key [remap just-one-space] 'cycle-spacing)

(defun sanityinc/show-trailing-whitespace ()
  "Enable display of trailing whitespace in this buffer."
  (setq-local show-trailing-whitespace t))

(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook 'sanityinc/show-trailing-whitespace))
;; }}

;; Hooks
;; {{
(add-hook 'after-init-hook 'delete-selection-mode)
(add-hook 'after-init-hook 'electric-indent-mode)
(add-hook 'after-init-hook 'electric-pair-mode)
(add-hook 'after-init-hook 'global-eldoc-mode)
(add-hook 'after-init-hook 'repeat-mode)
(add-hook 'after-init-hook 'show-paren-mode)
(add-hook 'after-init-hook 'so-long-enable)
(add-hook 'after-init-hook 'transient-mark-mode)

(setq-default display-fill-column-indicator-character ?┊)
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)

(setq-default display-line-numbers-width 3)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(setq auto-revert-verbose nil
      global-auto-revert-non-file-buffers t)
(add-hook 'after-init-hook 'global-auto-revert-mode)
;; }}

;; goto-address
;; {{
(setq goto-address-mail-face 'link)

(add-hook 'prog-mode-hook 'goto-address-prog-mode)
(add-hook 'conf-mode-hook 'goto-address-prog-mode)
;; }}

;; {{
;; Don't disable narrowing commands
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)
(put 'narrow-to-defun 'disabled nil)

;; Don't disable case-change functions
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
;; }}

;; grep and grep-like tools
;; {{
(setq-default grep-highlight-matches t
              grep-scroll-output t)

(require-package 'wgrep)

(with-eval-after-load 'grep
  (define-key grep-mode-map (kbd "C-x C-q") 'wgrep-change-to-wgrep-mode))

(with-eval-after-load 'wgrep
  ;; Save the change after wgrep finishes the job
  (setq wgrep-auto-save-buffer t)
  (setq wgrep-too-many-file-length 2024))

(when (and (executable-find "rg")
           (maybe-require-package 'rg))
  (global-set-key (kbd "M-?") 'rg-project))
;; }}

;; ANSI-escape coloring in compilation-mode
;; {{
(ignore-errors
  (defun my-colorize-compilation-buffer ()
    (when (eq major-mode 'compilation-mode)
      (require 'ansi-color)
      (ansi-color-apply-on-region compilation-filter-start (point-max))))
  (add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer))
;; }}

;; Rime Input Method for Emacs
;; {{
(require-package 'rime)

(setq default-input-method "rime")

(setq rime-user-data-dir "~/.config/fcitx/rime/"
      rime-inline-predicates '(rime-predicate-space-after-cc-p))

(with-eval-after-load 'rime
  (define-key rime-mode-map (kbd "C-`") 'rime-send-keybinding)
  (define-key rime-active-mode-map (kbd "TAB") 'rime-inline-ascii)

  (add-hook 'kill-emacs-hook
            (lambda () (ignore-errors (rime-lib-finalize)))))
;; }}

;; {{
(require-package 'which-key)
(setq-default which-key-idle-delay 1.5)
(add-hook 'after-init-hook 'which-key-mode)
(with-eval-after-load 'which-key
  (diminish 'which-key-mode))

(require-package 'whitespace-cleanup-mode)
(add-hook 'after-init-hook 'global-whitespace-cleanup-mode)
(with-eval-after-load 'whitespace-cleanup-mode
  (diminish 'whitespace-cleanup-mode))

(when (maybe-require-package 'vundo)
  (global-set-key (kbd "C-x u") 'vundo))

(when (maybe-require-package 'avy)
  (global-set-key (kbd "C-;") 'avy-goto-char-timer))

(when (maybe-require-package 'rainbow-delimiters)
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))
;; }}

(provide 'init-misc)

;;; init-misc.el ends here
