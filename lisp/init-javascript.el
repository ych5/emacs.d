;;; init-javascript.el --- Support for Javascript and derivatives -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(maybe-require-package 'json-mode)
(maybe-require-package 'js2-mode)
(maybe-require-package 'typescript-mode)
(maybe-require-package 'prettier-js)

;; Basic js-mode setup
;; {{
(setq-default js-indent-level 2)

(with-eval-after-load 'js
  (sanityinc/major-mode-lighter 'js-mode "JS")
  (sanityinc/major-mode-lighter 'js-jsx-mode "JSX"))
;; }}

;; js2-mode
;; {{
(setq-default js2-use-font-lock-faces t
              js2-mode-must-byte-compile nil
              js2-strict-trailing-comma-warning nil ; it's encouraged to use trailing comma in ES6
              js2-idle-timer-delay 0.5 ; NOT too big for real time syntax check
              js2-auto-indent-p nil
              js2-indent-on-enter-key nil ; annoying instead useful
              js2-skip-preprocessor-directives t
              js2-strict-inconsistent-return-warning nil ; return <=> return null
              js2-enter-indents-newline nil
              js2-bounce-indent-p t)

(with-eval-after-load 'js2-mode
  ;; Disable js2 mode's syntax error highlighting by default
  (setq-default js2-mode-show-parse-errors nil
                js2-mode-show-strict-warnings nil)

  (js2-imenu-extras-setup))

(add-to-list 'interpreter-mode-alist (cons "node" 'js2-mode))

(with-eval-after-load 'js2-mode
  (sanityinc/major-mode-lighter 'js2-mode "JS2")
  (sanityinc/major-mode-lighter 'js2-jsx-mode "JSX2"))
;; }}

;; Run and interact with an inferior JS via js-comint.el
;; {{
(when (maybe-require-package 'js-comint)
  (setq js-comint-program-command "node")

  (defvar inferior-js-minor-mode-map (make-sparse-keymap))
  (define-key inferior-js-minor-mode-map "\C-x\C-e" 'js-send-last-sexp)
  (define-key inferior-js-minor-mode-map "\C-cb" 'js-send-buffer)

  (define-minor-mode inferior-js-keys-mode
    "Bindings for communicating with an inferior js interpreter."
    :init-value nil :lighter " InfJS" :keymap inferior-js-minor-mode-map)

  (dolist (hook '(js2-mode-hook js-mode-hook))
    (add-hook hook 'inferior-js-keys-mode)))
;; }}

(provide 'init-javascript)

;;; init-javascript.el ends here
