;;; init.el --- Single-file DWIM-centered setup -*- lexical-binding: t; -*-
;;;
;; Version: 0.2.0
;; Package-Requires: ((emacs "30.1"))
;; URL: https://github.com/your-name/doom-dwim
;;
;;; Commentary:
;; A modern vanilla Emacs configuration centered around doom-dwim.
;;
;; Installation notes:
;; 1. Put this file at ~/.emacs.d/init.el.
;; 2. Start Emacs.  straight.el will bootstrap itself and install packages.
;;
;; doom-dwim is inlined below from the attached doom-dwim.el.
;; This file does not install, require, or load doom-dwim as an external package.
;;
;; The only custom global keybinding defined here is M-RET -> doom-dwim.
;; All other actions are discovered by doom-dwim providers at runtime.

;;; Code:

;;;; Early startup hygiene

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 64 1024 1024)
                  gc-cons-percentage 0.1)
            (message "Emacs ready in %.2fs with %d garbage collections."
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

(setq read-process-output-max (* 1024 1024)
      inhibit-startup-screen t
      ring-bell-function #'ignore
      use-short-answers t
      sentence-end-double-space nil
      make-backup-files nil
      auto-save-default t
      create-lockfiles nil
      custom-file (expand-file-name "custom.el" user-emacs-directory))

(when (file-exists-p custom-file)
  (load custom-file nil 'nomessage))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(tab-bar-mode -1)

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 88)

;;;; straight.el + use-package

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t
      use-package-always-defer t
      use-package-expand-minimally t)

(require 'use-package)

;;;; Completion stack used by init-dwim's completing-read UI

(use-package no-littering
  :demand t)

(use-package vertico
  :demand t
  :custom
  (vertico-cycle t)
  (vertico-resize t)
  :init
  (vertico-mode 1))

(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :demand t
  :init
  (marginalia-mode 1))

(use-package consult
  :demand t
  :custom
  (consult-preview-key '(:debounce 0.25 any)))

(use-package embark
  :defer t)

(use-package which-key
  :demand t
  :custom
  (which-key-idle-delay 0.5)
  :init
  (which-key-mode 1))

;;;; Editing foundation

(use-package evil
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-respect-visual-line-mode t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-preview-current nil)
  :init
  (global-corfu-mode 1))

(use-package cape
  :after corfu
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

(use-package yasnippet
  :demand t
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package smartparens
  :hook ((prog-mode markdown-mode org-mode) . smartparens-mode))

(use-package expand-region
  :defer t)

;;;; Projects, files, version control, and search providers

(use-package projectile
  :demand t
  :custom
  (projectile-completion-system 'default)
  (projectile-project-search-path '("~/src" "~/work" "~/projects" "~/git"))
  :config
  (projectile-mode 1))

(use-package magit
  :defer t)

(use-package git-gutter
  :demand t
  :config
  (global-git-gutter-mode 1))

(use-package ripgrep
  :defer t)

(use-package rg
  :after ripgrep)

;;;; Programming providers: LSP/Eglot, diagnostics, formatting, REPL-ish tools

(use-package eglot
  :straight nil
  :defer t
  :custom
  (eglot-autoshutdown t)
  (eglot-confirm-server-initiated-edits nil))

(use-package flymake
  :straight nil
  :ensure nil
  :hook ((emacs-lisp-mode . flymake-mode)
         (prog-mode . flymake-mode))
  :custom
  (flymake-no-changes-timeout 0.5)
  (flymake-start-on-flymake-mode t)
  (flymake-start-on-save-buffer t))

(use-package apheleia
  :demand t
  :config
  (apheleia-global-mode 1))

(use-package format-all
  :defer t)

(use-package highlight-symbol
  :hook (prog-mode . highlight-symbol-mode))

(use-package tree-sitter-langs
  :if (fboundp 'global-tree-sitter-mode)
  :config
  (global-tree-sitter-mode 1)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

;; Language/provider integrations that init-dwim can discover when relevant.
(use-package cider :defer t)
(use-package sly :defer t)
(use-package pytest :defer t)
(use-package jest-test-mode :defer t)
(use-package go-mode :defer t)
(use-package rust-mode :defer t)
(use-package typescript-mode :defer t)
(use-package json-mode :defer t)
(use-package yaml-mode :defer t)
(use-package dockerfile-mode :defer t)

;;;; Text, Org, Markdown, spelling, and export providers

(use-package org
  :straight nil
  :defer t
  :custom
  (org-directory (expand-file-name "org" user-emacs-directory))
  (org-default-notes-file (expand-file-name "inbox.org" org-directory))
  (org-log-done 'time)
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-capture-templates
   '(("t" "Task" entry (file+headline org-default-notes-file "Tasks")
      "* TODO %?\n  %U\n  %a")
     ("n" "Note" entry (file+headline org-default-notes-file "Notes")
      "* %?\n  %U\n  %a"))))

(use-package org-modern
  :after org
  :hook (org-mode . org-modern-mode))

(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

(use-package markdown-toc
  :after markdown-mode)

(use-package grip-mode
  :after markdown-mode)

(use-package langtool
  :defer t
  :custom
  (langtool-default-language "en-US"))

(use-package writeroom-mode
  :defer t)

;;;; Dired, diff, merge-conflict, shell, and terminal providers

(use-package dired
  :straight nil
  :defer t
  :custom
  (dired-dwim-target t)
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'top))

(use-package diredfl
  :hook (dired-mode . diredfl-mode))

(use-package diff-mode
  :straight nil
  :defer t)

(use-package smerge-mode
  :straight nil
  :defer t)

(use-package eat
  :defer t)

;;;; AI provider backends

(use-package gptel
  :defer t
  :custom
  (gptel-default-mode 'org-mode))

(use-package ellama
  :defer t)

;; Nice dark theme
(use-package doom-themes
  :straight t
  :demand t
  :init
  ;; Prevent Emacs from asking whether the theme is safe.
  (setq custom-safe-themes t)
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)

  ;; Disable any already-enabled theme before loading this one.
  (mapc #'disable-theme custom-enabled-themes)

  (load-theme 'doom-one t)

  ;; Optional org tweaks.
  (doom-themes-org-config))

;; Good modeline
(use-package doom-modeline
  :straight t
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 28)
  (doom-modeline-bar-width 4)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (doom-modeline-project-detection 'project)
  (doom-modeline-enable-word-count t)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-vcs-max-length 24))

(use-package restclient
  :defer t
  :mode ("\\.http\\'" . restclient-mode))

(use-package olivetti
  :defer t
  :custom
  (olivetti-body-width 88))

(use-package package-lint
  :defer t)

(require 'cl-lib)
(require 'subr-x)
(require 'thingatpt)
(require 'url-util nil t)
(require 'project nil t)

(defgroup init-dwim nil
  "Context-aware Do What I Mean command."
  :group 'convenience
  :prefix "init-dwim-")

(defcustom init-dwim-max-candidates nil
  "Maximum number of action candidates shown by `init-dwim'.
If nil, show all collected candidates."
  :type '(choice (const :tag "No limit" nil)
                 (integer :tag "Maximum candidates"))
  :group 'init-dwim)

(defcustom init-dwim-include-low-confidence-actions t
  "Whether `init-dwim' should include lower-confidence fallback actions.
When nil, providers should prefer only actions that are strongly related to
the current context."
  :type 'boolean
  :group 'init-dwim)

(defcustom init-dwim-completion-backend 'completing-read
  "Completion backend used by `init-dwim'.

Supported values are:

- `completing-read': always use built-in `completing-read'.
- `consult-if-available': use Consult internals when available, otherwise
  fall back to `completing-read'.

Most Doom users should leave this as `completing-read', because Doom's active
completion UI, such as Vertico, Ivy, or Helm, usually enhances
`completing-read' automatically."
  :type '(choice (const :tag "completing-read" completing-read)
                 (const :tag "Consult if available" consult-if-available))
  :group 'init-dwim)

(defcustom init-dwim-disabled-providers nil
  "List of provider symbols disabled by `init-dwim'.
Provider symbols are compared against entries in `init-dwim-providers'."
  :type '(repeat symbol)
  :group 'init-dwim)

(defcustom init-dwim-project-notes-file "notes.org"
  "Project-relative notes file opened by the project notes action.
If nil, no project notes action is offered."
  :type '(choice (const :tag "Disabled" nil)
                 (string :tag "Project-relative file path"))
  :group 'init-dwim)

(defcustom init-dwim-debug-buffer-name "*init-dwim-debug*"
  "Name of the debug buffer used by `init-dwim-explain'."
  :type 'string
  :group 'init-dwim)

(defcustom init-dwim-ai-system-prompt
  "You are a helpful coding assistant. Be concise."
  "System prompt used by `init-dwim-ai-provider' when sending text to an AI backend."
  :type 'string
  :group 'init-dwim)

(defvar init-dwim-debug-mode nil
  "Non-nil means record debug information while collecting actions.")

(defvar init-dwim--last-debug-log nil
  "Internal list of debug messages for the last `init-dwim' collection.")

(defun init-dwim-debug-mode (&optional arg)
  "Toggle `init-dwim' debug logging.

With prefix ARG, enable debug logging if ARG is positive, otherwise disable it.
This is a global toggle used by `init-dwim-explain'."
  (interactive "P")
  (setq init-dwim-debug-mode
        (if arg
            (> (prefix-numeric-value arg) 0)
          (not init-dwim-debug-mode)))
  (message "init-dwim debug mode %s"
           (if init-dwim-debug-mode "enabled" "disabled")))

(defun init-dwim--log (fmt &rest args)
  "Record a debug message FMT with ARGS when debugging is enabled."
  (when init-dwim-debug-mode
    (push (apply #'format fmt args) init-dwim--last-debug-log)))

(defun init-dwim--call-safely (fn &rest args)
  "Call FN with ARGS and return nil on error.
Errors are recorded in the debug log."
  (condition-case err
      (apply fn args)
    (error
     (init-dwim--log "Error in %S: %S" fn err)
     nil)))

(defun init-dwim-make-action (&rest plist)
  "Create a `init-dwim' action from PLIST.

Recognized keys are:

:title        Human-readable action title. Required.
:description  Short description. Optional.
:category     Category string. Optional.
:priority     Numeric priority. Higher means more relevant. Optional.
:predicate    Zero-argument function checked during collection. Optional.
:action       Zero-argument callable action. Required.
:provider     Provider symbol or function. Usually added automatically.
:confidence   Symbol describing confidence, such as `high', `medium', `low'.

The returned value is a plist."
  (unless (stringp (plist-get plist :title))
    (error "An init-dwim action requires string :title"))
  (unless (functionp (plist-get plist :action))
    (error "An init-dwim action requires callable :action"))
  (unless (plist-member plist :priority)
    (setq plist (plist-put plist :priority 0)))
  (unless (plist-member plist :category)
    (setq plist (plist-put plist :category "General")))
  (unless (plist-member plist :description)
    (setq plist (plist-put plist :description "")))
  (unless (plist-member plist :confidence)
    (setq plist (plist-put plist :confidence 'high)))
  plist)

(defun init-dwim-action-title (action)
  "Return ACTION title."
  (plist-get action :title))

(defun init-dwim-action-description (action)
  "Return ACTION description."
  (plist-get action :description))

(defun init-dwim-action-category (action)
  "Return ACTION category."
  (plist-get action :category))

(defun init-dwim-action-priority (action)
  "Return ACTION priority."
  (or (plist-get action :priority) 0))

(defun init-dwim-action-provider (action)
  "Return ACTION provider."
  (plist-get action :provider))

(defun init-dwim-action-confidence (action)
  "Return ACTION confidence."
  (or (plist-get action :confidence) 'high))

(defun init-dwim-action-valid-p (action)
  "Return non-nil if ACTION has the minimum valid shape."
  (and (listp action)
       (stringp (plist-get action :title))
       (functionp (plist-get action :action))))

(defun init-dwim-action-applicable-p (action)
  "Return non-nil if ACTION should be offered in the current context."
  (let ((pred (plist-get action :predicate))
        (confidence (init-dwim-action-confidence action)))
    (and
     (init-dwim-action-valid-p action)
     (or init-dwim-include-low-confidence-actions
         (not (eq confidence 'low)))
     (or (null pred)
         (and (functionp pred)
              (init-dwim--call-safely pred))))))

(defvar init-dwim-providers nil
  "List of provider functions used by `init-dwim'.

Each provider is called with no arguments and should return a list of action
plists created by `init-dwim-make-action'.  A provider may return nil when it
has no relevant actions for the current context.")

(defun init-dwim-register-provider (provider &optional append)
  "Register PROVIDER in `init-dwim-providers'.

PROVIDER should be a function or symbol naming a function.  When APPEND is
non-nil, add PROVIDER to the end of the provider list; otherwise add it to the
front.  Duplicate registrations are ignored."
  (unless (functionp provider)
    (unless (and (symbolp provider) (fboundp provider))
      (error "Provider is not callable: %S" provider)))
  (unless (memq provider init-dwim-providers)
    (setq init-dwim-providers
          (if append
              (append init-dwim-providers (list provider))
            (cons provider init-dwim-providers))))
  provider)

(defun init-dwim-unregister-provider (provider)
  "Remove PROVIDER from `init-dwim-providers'."
  (setq init-dwim-providers (delq provider init-dwim-providers)))

(defun init-dwim-provider-enabled-p (provider)
  "Return non-nil if PROVIDER is enabled."
  (not (memq provider init-dwim-disabled-providers)))

(defun init-dwim-collect-actions ()
  "Collect applicable `init-dwim' actions from all enabled providers.

A broken provider is isolated and recorded in the debug log; it never prevents
the command from showing actions from other providers."
  (setq init-dwim--last-debug-log nil)
  (init-dwim--log "Collecting actions in buffer %S, mode %S"
                  (buffer-name) major-mode)
  (let (actions)
    (dolist (provider init-dwim-providers)
      (if (not (init-dwim-provider-enabled-p provider))
          (init-dwim--log "Provider disabled: %S" provider)
        (let ((raw (condition-case err
                       (funcall provider)
                     (error
                      (init-dwim--log "Provider %S failed: %S" provider err)
                      nil))))
          (init-dwim--log "Provider %S returned %d raw action(s)"
                          provider (length raw))
          (dolist (action raw)
            (cond
             ((not (init-dwim-action-valid-p action))
              (init-dwim--log "Rejected invalid action from %S: %S"
                              provider action))
             ((not (init-dwim-action-applicable-p action))
              (init-dwim--log "Rejected inapplicable action: %s"
                              (init-dwim-action-title action)))
             (t
              (unless (plist-member action :provider)
                (setq action (plist-put action :provider provider)))
              (push action actions)))))))
    (let ((sorted (init-dwim-sort-actions actions)))
      (if init-dwim-max-candidates
          (seq-take sorted init-dwim-max-candidates)
        sorted))))

(defun init-dwim-sort-actions (actions)
  "Sort ACTIONS by priority, category, and title.

Higher priority actions are placed first.  Ties are sorted alphabetically by
category and title for stable, predictable display."
  (sort (copy-sequence actions)
        (lambda (a b)
          (let ((pa (init-dwim-action-priority a))
                (pb (init-dwim-action-priority b)))
            (if (/= pa pb)
                (> pa pb)
              (let ((ca (init-dwim-action-category a))
                    (cb (init-dwim-action-category b)))
                (if (not (string= ca cb))
                    (string< ca cb)
                  (string< (init-dwim-action-title a)
                           (init-dwim-action-title b)))))))))

(defun init-dwim--display-string (action)
  "Return display string for ACTION."
  (format "%-16s  %s"
          (init-dwim-action-category action)
          (init-dwim-action-title action)))

(defun init-dwim-read-action (actions)
  "Read one action from ACTIONS using the configured completion backend."
  (unless actions
    (user-error "No relevant init-dwim actions found"))
  (let* ((table (cl-loop for action in actions
                         collect (cons (init-dwim--display-string action)
                                       action)))
         (max-candidate-width
          (apply #'max
                 (mapcar (lambda (cell)
                           (string-width (car cell)))
                         table)))
         (metadata
          `(metadata
            (category . init-dwim-action)
            (annotation-function
             . ,(lambda (candidate)
                  (let* ((action (cdr (assoc candidate table)))
                         (desc (and action
                                    (init-dwim-action-description action))))
                    (if (and desc (not (string-empty-p desc)))
                        (let* ((padding-width
                                (+ 2 (- max-candidate-width
                                        (string-width candidate))))
                               (padding
                                (make-string (max 1 padding-width) ?\s)))
                          (propertize
                           (concat padding "— " desc)
                           'face 'completions-annotations))
                      "")))))))
    (cond
     ((and (eq init-dwim-completion-backend 'consult-if-available)
           (fboundp 'consult--read))
      (cdr (assoc
            (funcall 'consult--read
                     (lambda (str pred action)
                       (if (eq action 'metadata)
                           metadata
                         (complete-with-action
                          action
                          (mapcar #'car table)
                          str pred)))
                     :prompt "Do what? "
                     :require-match t
                     :sort nil)
            table)))
     (t
      (cdr (assoc
            (completing-read
             "Do what? "
             (lambda (str pred action)
               (if (eq action 'metadata)
                   metadata
                 (complete-with-action
                  action
                  (mapcar #'car table)
                  str pred)))
             nil t)
            table))))))

(defun init-dwim-execute-action (action)
  "Execute ACTION."
  (unless (init-dwim-action-valid-p action)
    (user-error "Invalid init-dwim action"))
  (let ((fn (plist-get action :action)))
    (init-dwim--log "Executing action: %s" (init-dwim-action-title action))
    (funcall fn)))

;;;###autoload
(defun init-dwim ()
  "Inspect the current context and offer relevant actions.

The command checks active region, URL at point, file path at point, symbol at
point, Org headings, programming buffers, text/Markdown buffers, Dired, Magit,
and project context.  Optional packages are integrated only when available."
  (interactive)
  (init-dwim-execute-action
   (init-dwim-read-action
    (init-dwim-collect-actions))))

;;;###autoload
(defun init-dwim-explain ()
  "Collect actions and show a debug explanation buffer.

This helps users and provider authors understand why candidates appeared or
were rejected."
  (interactive)
  (let ((init-dwim-debug-mode t))
    (init-dwim-collect-actions))
  (with-current-buffer (get-buffer-create init-dwim-debug-buffer-name)
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert "init-dwim debug log\n\n")
      (dolist (line (reverse init-dwim--last-debug-log))
        (insert line "\n"))
      (special-mode))
    (pop-to-buffer (current-buffer))))

;;;###autoload
(defun init-dwim-for-category (category)
  "Run `init-dwim' filtered to actions in CATEGORY.

When called interactively, prompt for a category from the currently available
actions."
  (interactive
   (let* ((all (init-dwim-collect-actions))
          (cats (delete-dups (mapcar #'init-dwim-action-category all))))
     (list (completing-read "Category: " cats nil t))))
  (let* ((all (init-dwim-collect-actions))
         (filtered (seq-filter
                    (lambda (a) (string= (init-dwim-action-category a) category))
                    all)))
    (init-dwim-execute-action (init-dwim-read-action filtered))))

;;;; Helpers

(defun init-dwim--focus-mode-active-p ()
  "Return non-nil if any focus/writing mode is active."
  (or (and (boundp 'writeroom-mode) writeroom-mode)
      (and (boundp 'olivetti-mode) olivetti-mode)
      (and (boundp 'darkroom-mode) darkroom-mode)))

(defun init-dwim--eat-buffer-p ()
  "Return non-nil when inside an eat terminal buffer."
  (derived-mode-p 'eat-mode))

(defun init-dwim--restclient-mode-p ()
  "Return non-nil in restclient or verb buffers."
  (or (derived-mode-p 'restclient-mode)
      (derived-mode-p 'verb-mode)
      (and (buffer-file-name)
           (string-match-p "\\.http\\'" (buffer-file-name)))))

(defun init-dwim--elisp-mode-p ()
  "Return non-nil in Emacs Lisp buffers."
  (derived-mode-p 'emacs-lisp-mode 'lisp-interaction-mode))

(defun init-dwim--number-at-point ()
  "Return the number at point as a number, or nil."
  (number-at-point))

(defun init-dwim--number-bounds-at-point ()
  "Return bounds of number at point, or nil."
  (bounds-of-thing-at-point 'number))

(defun init-dwim--replace-number-at-point (n)
  "Replace the number at point with N."
  (when-let ((bounds (init-dwim--number-bounds-at-point)))
    (delete-region (car bounds) (cdr bounds))
    (insert (number-to-string n))))

(defun init-dwim--region-active-p ()
  "Return non-nil when there is an active region."
  (use-region-p))

(defun init-dwim--region-bounds ()
  "Return active region bounds as a cons cell, or nil."
  (when (init-dwim--region-active-p)
    (cons (region-beginning) (region-end))))

(defun init-dwim--region-string ()
  "Return active region string without text properties."
  (when-let ((bounds (init-dwim--region-bounds)))
    (buffer-substring-no-properties (car bounds) (cdr bounds))))

(defun init-dwim--symbol-string ()
  "Return symbol at point as a string, or nil."
  (let ((sym (thing-at-point 'symbol t)))
    (when (and sym (not (string-empty-p sym)))
      (substring-no-properties sym))))

(defun init-dwim--url-at-point ()
  "Return URL at point, or nil."
  (or (when (fboundp 'thing-at-point-url-at-point)
        (thing-at-point-url-at-point))
      (thing-at-point 'url t)))

(defun init-dwim--bounds-of-url-at-point ()
  "Return URL bounds at point, or nil."
  (bounds-of-thing-at-point 'url))

(defun init-dwim--clean-path (path)
  "Clean PATH extracted from point."
  (when path
    (string-trim path "[\"'`<({[]" "[\"'`>)}\n\t ]")))

(defun init-dwim--file-path-at-point ()
  "Return existing file path at point, or nil."
  (when-let* ((raw (or (thing-at-point 'filename t)
                       (thing-at-point 'word t)))
              (path (init-dwim--clean-path raw))
              (expanded (expand-file-name path default-directory)))
    (when (file-exists-p expanded)
      expanded)))

(defun init-dwim--project-root ()
  "Return current project root, or nil."
  (or
   (when (and (fboundp 'project-current)
              (project-current nil))
     (expand-file-name
      (if (fboundp 'project-root)
          (project-root (project-current nil))
        (car (project-roots (project-current nil))))))
   (when (and (fboundp 'projectile-project-p)
              (funcall 'projectile-project-p)
              (fboundp 'projectile-project-root))
     (funcall 'projectile-project-root))
   (when (fboundp 'vc-root-dir)
     (vc-root-dir))
   nil))

(defun init-dwim--in-project-p ()
  "Return non-nil if current buffer is in a project."
  (not (null (init-dwim--project-root))))

(defun init-dwim--lsp-available-p ()
  "Return non-nil when LSP-style actions are available in this buffer."
  (or
   (and (boundp 'lsp-mode) lsp-mode)
   (and (fboundp 'eglot-current-server)
        (ignore-errors (eglot-current-server)))))

(defun init-dwim--format-region (beg end)
  "Format region from BEG to END using the best available formatter."
  (cond
   ((and (boundp 'lsp-mode) lsp-mode (fboundp 'lsp-format-region))
    (lsp-format-region beg end))
   ((and (fboundp 'eglot-format) (ignore-errors (eglot-current-server)))
    (eglot-format beg end))
   ((fboundp 'apheleia-format-region)
    (apheleia-format-region beg end))
   ((fboundp 'format-all-region)
    (format-all-region beg end))
   (t
    (indent-region beg end))))

(defun init-dwim--format-buffer ()
  "Format current buffer using the best available formatter."
  (cond
   ((and (boundp 'lsp-mode) lsp-mode (fboundp 'lsp-format-buffer))
    (lsp-format-buffer))
   ((and (fboundp 'eglot-format) (ignore-errors (eglot-current-server)))
    (eglot-format (point-min) (point-max)))
   ((fboundp 'apheleia-format-buffer)
    (apheleia-format-buffer))
   ((fboundp 'format-all-buffer)
    (format-all-buffer))
   (t
    (indent-region (point-min) (point-max)))))

(defun init-dwim--project-search (query)
  "Search current project for QUERY."
  (cond
   ((and (fboundp 'consult-ripgrep) (init-dwim--project-root))
    (consult-ripgrep (init-dwim--project-root) query))
   ((and (fboundp 'projectile-ripgrep) (init-dwim--project-root))
    (projectile-ripgrep query))
   ((and (fboundp 'projectile-grep) (init-dwim--project-root))
    (projectile-grep query))
   ((and (fboundp 'rgrep) (init-dwim--project-root))
    (rgrep query "*" (init-dwim--project-root)))
   (t
    (grep (read-shell-command "Grep command: "
                              (format "grep -RIn %s ."
                                      (shell-quote-argument query)))))))

(defun init-dwim--find-project-file ()
  "Find a file in the current project."
  (cond
   ((and (fboundp 'projectile-find-file) (init-dwim--project-root))
    (projectile-find-file))
   ((and (fboundp 'project-find-file) (project-current nil))
    (project-find-file))
   (t
    (call-interactively #'find-file))))

(defun init-dwim--switch-project ()
  "Switch project using Projectile or project.el."
  (cond
   ((fboundp 'projectile-switch-project)
    (projectile-switch-project))
   ((fboundp 'project-switch-project)
    (call-interactively #'project-switch-project))
   (t
    (user-error "No project switching command available"))))

(defun init-dwim--open-project-dired ()
  "Open current project root in Dired."
  (if-let ((root (init-dwim--project-root)))
      (dired root)
    (user-error "No project root found")))

(defun init-dwim--open-git-status (&optional dir)
  "Open Git status for DIR or current project."
  (let ((root (or dir (init-dwim--project-root) default-directory)))
    (cond
     ((fboundp 'magit-status)
      (magit-status root))
     ((fboundp 'vc-dir)
      (vc-dir root))
     (t
      (user-error "Neither Magit nor vc-dir is available")))))

(defun init-dwim--open-externally (path)
  "Open PATH externally using the platform's default handler."
  (cond
   ((fboundp 'browse-url-of-file)
    (browse-url-of-file path))
   ((eq system-type 'darwin)
    (start-process "init-dwim-open" nil "open" path))
   ((eq system-type 'windows-nt)
    (w32-shell-execute "open" path))
   ((executable-find "xdg-open")
    (start-process "init-dwim-open" nil "xdg-open" path))
   (t
    (user-error "No external opener available"))))

(defun init-dwim--replace-bounds-with (bounds text)
  "Replace BOUNDS with TEXT."
  (delete-region (car bounds) (cdr bounds))
  (insert text))

(defun init-dwim--fetch-url-title (url)
  "Fetch URL title synchronously and copy it to the kill ring.

This function uses a short timeout and performs minimal HTML title extraction."
  (unless (fboundp 'url-retrieve-synchronously)
    (user-error "url-retrieve-synchronously is unavailable"))
  (let ((buffer (url-retrieve-synchronously url t t 5)))
    (unless buffer
      (user-error "Could not retrieve URL"))
    (unwind-protect
        (with-current-buffer buffer
          (goto-char (point-min))
          (let ((case-fold-search t))
            (if (re-search-forward "<title[^>]*>\\([^<]+\\)</title>" nil t)
                (let ((title (string-trim
                              (replace-regexp-in-string
                               "[\n\t ]+" " "
                               (match-string-no-properties 1)))))
                  (kill-new title)
                  (message "Copied title: %s" title))
              (user-error "No title found"))))
      (kill-buffer buffer))))

(defun init-dwim--send-region-to-repl (beg end)
  "Send region from BEG to END to a suitable REPL."
  (cond
   ((derived-mode-p 'emacs-lisp-mode)
    (eval-region beg end))
   ((and (derived-mode-p 'python-mode) (fboundp 'python-shell-send-region))
    (python-shell-send-region beg end))
   ((fboundp 'cider-eval-region)
    (cider-eval-region beg end))
   ((fboundp 'slime-eval-region)
    (slime-eval-region beg end))
   ((fboundp 'sly-eval-region)
    (sly-eval-region beg end))
   ((derived-mode-p 'comint-mode)
    (comint-send-region (get-buffer-process (current-buffer)) beg end))
   (t
    (user-error "No suitable REPL/evaluator found"))))

(defun init-dwim--repl-available-p ()
  "Return non-nil when a region can likely be sent to a REPL/evaluator."
  (or (derived-mode-p 'emacs-lisp-mode)
      (and (derived-mode-p 'python-mode) (fboundp 'python-shell-send-region))
      (fboundp 'cider-eval-region)
      (fboundp 'slime-eval-region)
      (fboundp 'sly-eval-region)
      (derived-mode-p 'comint-mode)))

(defun init-dwim--insert-markdown-link (url)
  "Replace URL at point with a Markdown link."
  (let* ((bounds (init-dwim--bounds-of-url-at-point))
         (title (read-string "Markdown link text: " url)))
    (if bounds
        (init-dwim--replace-bounds-with bounds (format "[%s](%s)" title url))
      (insert (format "[%s](%s)" title url)))))

(defun init-dwim--insert-org-link (url)
  "Replace URL at point with an Org link."
  (let* ((bounds (init-dwim--bounds-of-url-at-point))
         (title (read-string "Org link description: " url)))
    (if bounds
        (init-dwim--replace-bounds-with bounds (format "[[%s][%s]]" url title))
      (insert (format "[[%s][%s]]" url title)))))

(defun init-dwim--org-heading-p ()
  "Return non-nil if point is in an Org heading or subtree."
  (and (derived-mode-p 'org-mode)
       (fboundp 'org-before-first-heading-p)
       (not (org-before-first-heading-p))))

(defun init-dwim--markdown-mode-p ()
  "Return non-nil if current buffer is a Markdown buffer."
  (or (derived-mode-p 'markdown-mode)
      (derived-mode-p 'gfm-mode)))

(defun init-dwim--text-like-mode-p ()
  "Return non-nil if current buffer is a text-like buffer."
  (and (derived-mode-p 'text-mode)
       (not (derived-mode-p 'org-mode))
       (not (derived-mode-p 'special-mode))))

;;; New helper: AI backend detection

(defun init-dwim--ai-available-p ()
  "Return non-nil if any AI backend is available."
  (or (fboundp 'gptel)
      (fboundp 'gptel-send)
      (fboundp 'ellama-ask-about)
      (and (boundp 'copilot-mode) copilot-mode)
      (fboundp 'chatgpt-shell-send-region)))

(defun init-dwim--ai-send-region (beg end &optional prompt)
  "Send region from BEG to END to the available AI backend, with optional PROMPT."
  (let ((text (buffer-substring-no-properties beg end)))
    (cond
     ((fboundp 'gptel-send)
      ;; gptel: open a dedicated chat buffer seeded with the region
      (let ((buf (get-buffer-create "*init-dwim-gptel*")))
        (with-current-buffer buf
          (unless (eq major-mode 'gptel-mode)
            (gptel-mode 1))
          (goto-char (point-max))
          (when prompt (insert prompt "\n"))
          (insert text))
        (pop-to-buffer buf)
        (when (fboundp 'gptel-send)
          (gptel-send))))
     ((fboundp 'ellama-ask-about)
      (ellama-ask-about text (or prompt "What does this code do?")))
     ((fboundp 'chatgpt-shell-send-region)
      (chatgpt-shell-send-region beg end))
     (t
      (user-error "No AI backend available")))))


(defun init-dwim--in-smerge-conflict-p ()
  "Return non-nil if point is inside a smerge conflict marker."
  (and (fboundp 'smerge-check)
       (ignore-errors (smerge-check 1))))

;;; New helper: buffer writable check

(defun init-dwim--buffer-file-p ()
  "Return non-nil if the current buffer is visiting a file."
  (buffer-file-name))

;;; New helper: word count string

(defun init-dwim--word-count-message ()
  "Return a word/line/char summary message for the buffer or region."
  (if (use-region-p)
      (format "Region: %d words, %d chars"
              (count-words (region-beginning) (region-end))
              (- (region-end) (region-beginning)))
    (format "Buffer: %d words, %d lines, %d chars"
            (count-words (point-min) (point-max))
            (line-number-at-pos (point-max))
            (- (point-max) (point-min)))))

;;;; Providers

;;; ── Region ────────────────────────────────────────────────────────────────

(defun init-dwim-region-provider ()
  "Return actions relevant to an active region."
  (when-let ((bounds (init-dwim--region-bounds)))
    (let ((beg (car bounds))
          (end (cdr bounds))
          (text (init-dwim--region-string)))
      (list
       (init-dwim-make-action
        :title "Copy region"
        :description "Copy the selected text to the kill ring"
        :category "Region"
        :priority 100
        :action (lambda () (kill-new text) (message "Region copied")))

       (init-dwim-make-action
        :title "URL-encode region"
        :description "Percent-encode the selected text"
        :category "Region"
        :priority 70
        :predicate (lambda () (fboundp 'url-hexify-string))
        :action (lambda ()
                  (delete-region beg end)
                  (insert (url-hexify-string text))))

       (init-dwim-make-action
        :title "URL-decode region"
        :description "Decode percent-encoding in the selected text"
        :category "Region"
        :priority 68
        :predicate (lambda () (fboundp 'url-unhex-string))
        :action (lambda ()
                  (delete-region beg end)
                  (insert (url-unhex-string text))))

       (init-dwim-make-action
        :title "JSON pretty-print region"
        :description "Format the selected JSON text"
        :category "Region"
        :priority 80
        :action (lambda ()
                  (condition-case err
                      (let* ((parsed (json-read-from-string text))
                             (pretty (with-temp-buffer
                                       (insert (json-encode parsed))
                                       (json-pretty-print (point-min) (point-max))
                                       (buffer-string))))
                        (delete-region beg end)
                        (insert pretty))
                    (error (user-error "Invalid JSON: %s" err)))))

       (init-dwim-make-action
        :title "Kill region"
        :description "Cut the selected text"
        :category "Region"
        :priority 95
        :action (lambda () (kill-region beg end)))

       (init-dwim-make-action
        :title "Indent region"
        :description "Indent the selected text"
        :category "Region"
        :priority 85
        :action (lambda () (indent-region beg end)))

       (init-dwim-make-action
        :title "Format region"
        :description "Format the selected text if a formatter is available"
        :category "Region"
        :priority 82
        :predicate (lambda ()
                     (or (and (boundp 'lsp-mode) lsp-mode
                              (fboundp 'lsp-format-region))
                         (and (fboundp 'eglot-current-server)
                              (ignore-errors (eglot-current-server)))
                         (fboundp 'apheleia-format-region)
                         (fboundp 'format-all-region)))
        :action (lambda () (init-dwim--format-region beg end)))

       (init-dwim-make-action
        :title "Comment or uncomment region"
        :description "Toggle comments in the selected text"
        :category "Region"
        :priority 80
        :predicate (lambda () (fboundp 'comment-or-uncomment-region))
        :action (lambda () (comment-or-uncomment-region beg end)))

       (init-dwim-make-action
        :title "Search region in project"
        :description "Search for the selected text in the current project"
        :category "Region"
        :priority 78
        :predicate #'init-dwim--in-project-p
        :action (lambda () (init-dwim--project-search text)))

       (init-dwim-make-action
        :title "Send region to REPL/evaluator"
        :description "Evaluate or send the selected text using a suitable REPL"
        :category "Region"
        :priority 75
        :predicate #'init-dwim--repl-available-p
        :action (lambda () (init-dwim--send-region-to-repl beg end)))

       (init-dwim-make-action
        :title "Send region to AI"
        :description "Send the selected text to an AI backend (gptel, ellama, etc.)"
        :category "Region"
        :priority 72
        :predicate #'init-dwim--ai-available-p
        :action (lambda ()
                  (let ((prompt (read-string "Ask AI: " "Explain this: ")))
                    (init-dwim--ai-send-region beg end prompt))))

       (init-dwim-make-action
        :title "Sort lines in region"
        :description "Sort the lines in the selected region alphabetically"
        :category "Region"
        :priority 60
        :action (lambda () (sort-lines nil beg end)))

       (init-dwim-make-action
        :title "Reverse region lines"
        :description "Reverse the order of lines in the selection"
        :category "Region"
        :priority 55
        :action (lambda ()
                  (let* ((lines (split-string text "\n"))
                         (reversed (string-join (nreverse lines) "\n")))
                    (delete-region beg end)
                    (insert reversed))))

       (init-dwim-make-action
        :title "Delete duplicate lines"
        :description "Remove duplicate lines from the selected region"
        :category "Region"
        :priority 55
        :action (lambda () (delete-duplicate-lines beg end)))

       (init-dwim-make-action
        :title "Upcase region"
        :description "Convert the selected text to uppercase"
        :category "Region"
        :priority 50
        :action (lambda () (upcase-region beg end)))

       (init-dwim-make-action
        :title "Downcase region"
        :description "Convert the selected text to lowercase"
        :category "Region"
        :priority 49
        :action (lambda () (downcase-region beg end)))

       (init-dwim-make-action
        :title "Fill region"
        :description "Fill (re-wrap) the selected text to fill-column"
        :category "Region"
        :priority 45
        :action (lambda () (fill-region beg end)))

       (init-dwim-make-action
        :title "Narrow to region"
        :description "Narrow the buffer to show only the selected region"
        :category "Region"
        :priority 42
        :action (lambda () (narrow-to-region beg end)))

       (init-dwim-make-action
        :title "Write region to file"
        :description "Save the selected region as a new file"
        :category "Region"
        :priority 38
        :action (lambda ()
                  (let ((file (read-file-name "Write region to file: ")))
                    (write-region beg end file))))

       (init-dwim-make-action
        :title "Capitalize region"
        :description "Capitalize every word in the selected region"
        :category "Region"
        :priority 48
        :action (lambda () (capitalize-region beg end)))

       (init-dwim-make-action
        :title "Base64 encode region"
        :description "Base64-encode the selected text in place"
        :category "Region"
        :priority 35
        :action (lambda () (base64-encode-region beg end t)))

       (init-dwim-make-action
        :title "Base64 decode region"
        :description "Base64-decode the selected text in place"
        :category "Region"
        :priority 34
        :action (lambda () (base64-decode-region beg end)))

       (init-dwim-make-action
        :title "Pipe region through shell command"
        :description "Pass region through a shell command, replacing it with output"
        :category "Region"
        :priority 58
        :action (lambda ()
                  (let ((cmd (read-shell-command "Pipe region through: ")))
                    (shell-command-on-region beg end cmd nil t))))

       (init-dwim-make-action
        :title "Align region"
        :description "Align region to a regexp (align-regexp)"
        :category "Region"
        :priority 44
        :action (lambda () (call-interactively #'align-regexp)))

       (init-dwim-make-action
        :title "Replace in region"
        :description "Query-replace a pattern within the active region only"
        :category "Region"
        :priority 85
        :action (lambda ()
                  ;; query-replace restricts to region when region is active
                  (call-interactively #'query-replace-regexp)))

       (init-dwim-make-action
        :title "Count pattern occurrences"
        :description "Count occurrences of a regexp in the region"
        :category "Region"
        :priority 32
        :action (lambda ()
                  (let ((re (read-regexp "Count occurrences of: "
                                         (regexp-quote text))))
                    (message "%d occurrence(s) of %s"
                             (count-matches re beg end)
                             re))))))))

;;; ── URL ───────────────────────────────────────────────────────────────────

(defun init-dwim-url-provider ()
  "Return actions relevant to a URL at point."
  (when-let ((url (init-dwim--url-at-point)))
    (list
     (init-dwim-make-action
      :title "Open URL"
      :description "Open the URL in a browser"
      :category "URL"
      :priority 100
      :action (lambda () (browse-url url)))

     (init-dwim-make-action
      :title "Copy URL"
      :description "Copy the URL at point"
      :category "URL"
      :priority 95
      :action (lambda () (kill-new url) (message "Copied URL: %s" url)))

     (init-dwim-make-action
      :title "Insert Markdown link"
      :description "Replace the URL with a Markdown link"
      :category "URL"
      :priority 80
      :action (lambda () (init-dwim--insert-markdown-link url)))

     (init-dwim-make-action
      :title "Insert Org link"
      :description "Replace the URL with an Org link"
      :category "URL"
      :priority 80
      :action (lambda () (init-dwim--insert-org-link url)))

     (init-dwim-make-action
      :title "Fetch URL title"
      :description "Fetch the page title and copy it"
      :category "URL"
      :priority 60
      :confidence 'low
      :predicate (lambda () (fboundp 'url-retrieve-synchronously))
      :action (lambda () (init-dwim--fetch-url-title url)))

     (init-dwim-make-action
      :title "Open URL in EWW"
      :description "Open the URL in Emacs' built-in browser (EWW)"
      :category "URL"
      :priority 58
      :predicate (lambda () (fboundp 'eww))
      :action (lambda () (eww url)))

     (init-dwim-make-action
      :title "Download URL"
      :description "Download the URL to a file using url-copy-file"
      :category "URL"
      :priority 50
      :predicate (lambda () (fboundp 'url-copy-file))
      :action (lambda ()
                (let ((dest (read-file-name "Download to: ")))
                  (url-copy-file url dest 1)
                  (message "Downloaded to %s" dest))))

     (init-dwim-make-action
      :title "Copy as Org link with fetched title"
      :description "Fetch the page title and insert a formatted Org link"
      :category "URL"
      :priority 55
      :predicate (lambda () (fboundp 'url-retrieve-synchronously))
      :action (lambda ()
                (let ((buf (url-retrieve-synchronously url t t 5)))
                  (if (not buf)
                      (user-error "Could not retrieve URL")
                    (unwind-protect
                        (with-current-buffer buf
                          (goto-char (point-min))
                          (let* ((case-fold-search t)
                                 (title (if (re-search-forward
                                             "<title[^>]*>\\([^<]+\\)</title>"
                                             nil t)
                                            (string-trim
                                             (replace-regexp-in-string
                                              "[\n\t ]+" " "
                                              (match-string-no-properties 1)))
                                          url))
                                 (link (format "[[%s][%s]]" url title)))
                            (kill-new link)
                            (message "Copied Org link: %s" link)))
                      (kill-buffer buf))))))

     (init-dwim-make-action
      :title "Open URL in EWW (readable)"
      :description "Open the URL in EWW and switch to readable mode"
      :category "URL"
      :priority 56
      :predicate (lambda () (fboundp 'eww))
      :action (lambda ()
                (eww url)
                (when (fboundp 'eww-readable)
                  (run-with-idle-timer 1 nil #'eww-readable)))))))

;;; ── File path ─────────────────────────────────────────────────────────────

(defun init-dwim-file-path-provider ()
  "Return actions relevant to a file path at point."
  (when-let ((path (init-dwim--file-path-at-point)))
    (list
     (init-dwim-make-action
      :title "Open file"
      :description "Open the file path at point"
      :category "File"
      :priority 100
      :action (lambda () (find-file path)))

     (init-dwim-make-action
      :title "Copy path"
      :description "Copy the file path at point"
      :category "File"
      :priority 95
      :action (lambda () (kill-new path) (message "Copied path: %s" path)))

     (init-dwim-make-action
      :title "Reveal in Dired"
      :description "Open Dired at the file's directory"
      :category "File"
      :priority 85
      :action (lambda ()
                (dired (file-name-directory path))
                (when (fboundp 'dired-goto-file)
                  (dired-goto-file path))))

     (init-dwim-make-action
      :title "Open externally"
      :description "Open the file with the system default application"
      :category "File"
      :priority 75
      :action (lambda () (init-dwim--open-externally path)))

     (init-dwim-make-action
      :title "Insert Org file link"
      :description "Insert an Org link to this file"
      :category "File"
      :priority 65
      :action (lambda ()
                (insert (format "[[file:%s][%s]]"
                                path
                                (file-name-nondirectory path)))))

     (init-dwim-make-action
      :title "Insert Markdown file link"
      :description "Insert a Markdown link to this file"
      :category "File"
      :priority 65
      :action (lambda ()
                (insert (format "[%s](%s)"
                                (file-name-nondirectory path)
                                path))))

     (init-dwim-make-action
      :title "Delete file"
      :description "Delete the file at point (with confirmation)"
      :category "File"
      :priority 40
      :action (lambda ()
                (when (yes-or-no-p (format "Delete file %s? " path))
                  (delete-file path t)
                  (message "Deleted %s" path))))

     (init-dwim-make-action
      :title "Copy file to…"
      :description "Copy the file at point to another location"
      :category "File"
      :priority 55
      :action (lambda ()
                (let ((dest (read-file-name "Copy to: "
                                            (file-name-directory path))))
                  (copy-file path dest 1)
                  (message "Copied %s → %s" path dest))))

     (init-dwim-make-action
      :title "Diff file with…"
      :description "Diff the file at point against another file"
      :category "File"
      :priority 48
      :action (lambda ()
                (let ((other (read-file-name "Diff against: "
                                             (file-name-directory path))))
                  (diff path other))))

     (init-dwim-make-action
      :title "Open file in other window"
      :description "Open the file at point in another window"
      :category "File"
      :priority 90
      :action (lambda () (find-file-other-window path)))

     (init-dwim-make-action
      :title "Rename/move file"
      :description "Move the file at point to a new name or directory"
      :category "File"
      :priority 52
      :action (lambda ()
                (let ((dest (read-file-name "Move to: "
                                            (file-name-directory path)
                                            nil nil
                                            (file-name-nondirectory path))))
                  (rename-file path dest 1)
                  (message "Moved %s → %s" path dest))))

     (init-dwim-make-action
      :title "Show file attributes"
      :description "Display size, modification time, and permissions for the file"
      :category "File"
      :priority 30
      :action (lambda ()
                (let* ((attrs (file-attributes path))
                       (size  (nth 7 attrs))
                       (mtime (format-time-string "%Y-%m-%d %H:%M" (nth 5 attrs)))
                       (modes (nth 8 attrs)))
                  (message "%s  size:%d  modified:%s  modes:%s"
                           (file-name-nondirectory path)
                           size mtime modes)))))))

;;; ── Symbol ────────────────────────────────────────────────────────────────

(defun init-dwim-symbol-provider ()
  "Return actions relevant to the symbol at point."
  (when-let ((symbol (init-dwim--symbol-string)))
    (list
     (init-dwim-make-action
      :title "Jump to definition"
      :description "Jump to the definition of the symbol at point"
      :category "Symbol"
      :priority 100
      :predicate (lambda () (fboundp 'xref-find-definitions))
      :action (lambda () (xref-find-definitions symbol)))

     (init-dwim-make-action
      :title "Find references"
      :description "Find references to the symbol at point"
      :category "Symbol"
      :priority 95
      :predicate (lambda () (fboundp 'xref-find-references))
      :action (lambda () (xref-find-references symbol)))

     (init-dwim-make-action
      :title "Rename symbol"
      :description "Rename the symbol through LSP/Eglot when available"
      :category "Symbol"
      :priority 90
      :predicate #'init-dwim--lsp-available-p
      :action (lambda ()
                (cond
                 ((and (boundp 'lsp-mode) lsp-mode (fboundp 'lsp-rename))
                  (call-interactively #'lsp-rename))
                 ((and (fboundp 'eglot-rename)
                       (ignore-errors (eglot-current-server)))
                  (call-interactively #'eglot-rename))
                 (t
                  (user-error "No LSP rename command available")))))

     (init-dwim-make-action
      :title "Search symbol in project"
      :description "Search for the symbol in the current project"
      :category "Symbol"
      :priority 85
      :predicate #'init-dwim--in-project-p
      :action (lambda () (init-dwim--project-search symbol)))

     (init-dwim-make-action
      :title "Describe Elisp symbol"
      :description "Describe the Elisp symbol at point"
      :category "Symbol"
      :priority 80
      :predicate (lambda ()
                   (and (derived-mode-p 'emacs-lisp-mode 'lisp-interaction-mode)
                        (intern-soft symbol)))
      :action (lambda () (describe-symbol (intern symbol))))

     (init-dwim-make-action
      :title "Copy symbol"
      :description "Copy the symbol at point"
      :category "Symbol"
      :priority 70
      :action (lambda () (kill-new symbol) (message "Copied symbol: %s" symbol)))

     (init-dwim-make-action
      :title "Occur: list all occurrences"
      :description "List all occurrences of the symbol in the current buffer"
      :category "Symbol"
      :priority 68
      :action (lambda () (occur (regexp-quote symbol))))

     (init-dwim-make-action
      :title "Highlight symbol"
      :description "Highlight all occurrences of the symbol in the buffer"
      :category "Symbol"
      :priority 62
      :predicate (lambda () (fboundp 'highlight-symbol-at-point))
      :action (lambda () (highlight-symbol-at-point)))

     (init-dwim-make-action
      :title "Unhighlight all"
      :description "Remove all highlights from the buffer"
      :category "Symbol"
      :priority 55
      :predicate (lambda ()
                   (or (fboundp 'unhighlight-regexp)
                       (fboundp 'hi-lock-unface-buffer)))
      :action (lambda ()
                (cond
                 ((fboundp 'hi-lock-unface-buffer)
                  (hi-lock-unface-buffer (regexp-quote symbol)))
                 (t
                  (unhighlight-regexp (regexp-quote symbol))))))

     (init-dwim-make-action
      :title "Query-replace symbol"
      :description "Interactively replace the symbol across the buffer"
      :category "Symbol"
      :priority 65
      :action (lambda ()
                (let ((replacement (read-string
                                    (format "Replace %s with: " symbol)
                                    symbol)))
                  (query-replace symbol replacement))))

     (init-dwim-make-action
      :title "Show eldoc"
      :description "Show eldoc documentation for the symbol at point"
      :category "Symbol"
      :priority 58
      :predicate (lambda ()
                   (and (fboundp 'eldoc-doc-buffer)
                        (or (and (boundp 'lsp-mode) lsp-mode)
                            (and (fboundp 'eglot-current-server)
                                 (ignore-errors (eglot-current-server)))
                            (derived-mode-p 'emacs-lisp-mode))))
      :action (lambda () (eldoc-doc-buffer)))

     (init-dwim-make-action
      :title "Code actions (LSP)"
      :description "Show LSP/Eglot code actions at point"
      :category "Symbol"
      :priority 88
      :predicate #'init-dwim--lsp-available-p
      :action (lambda ()
                (cond
                 ((and (boundp 'lsp-mode) lsp-mode (fboundp 'lsp-execute-code-action))
                  (call-interactively #'lsp-execute-code-action))
                 ((and (fboundp 'eglot-code-actions)
                       (ignore-errors (eglot-current-server)))
                  (call-interactively #'eglot-code-actions))
                 (t
                  (user-error "No LSP code-actions command available")))))

     (init-dwim-make-action
      :title "Peek hover type"
      :description "Show type/hover documentation for the symbol at point"
      :category "Symbol"
      :priority 59
      :predicate #'init-dwim--lsp-available-p
      :action (lambda ()
                (cond
                 ((and (boundp 'lsp-mode) lsp-mode (fboundp 'lsp-describe-thing-at-point))
                  (lsp-describe-thing-at-point))
                 ((and (fboundp 'eglot-current-server)
                       (ignore-errors (eglot-current-server))
                       (fboundp 'eldoc-doc-buffer))
                  (eldoc-doc-buffer))
                 (t (user-error "No hover command available")))))

     (init-dwim-make-action
      :title "Add TODO comment above"
      :description "Insert a TODO comment at the start of the current defun"
      :category "Symbol"
      :priority 40
      :predicate (lambda () (derived-mode-p 'prog-mode))
      :action (lambda ()
                (save-excursion
                  (beginning-of-defun)
                  (open-line 1)
                  (insert
                   (format "%s TODO: " comment-start))
                  (end-of-line)))))))

;;; ── Org ───────────────────────────────────────────────────────────────────

(defun init-dwim-org-provider ()
  "Return actions relevant to Org headings."
  (when (init-dwim--org-heading-p)
    (list
     (init-dwim-make-action
      :title "Toggle TODO state"
      :description "Cycle the TODO state for this heading"
      :category "Org"
      :priority 100
      :predicate (lambda () (fboundp 'org-todo))
      :action (lambda () (call-interactively #'org-todo)))

     (init-dwim-make-action
      :title "Schedule"
      :description "Set or change the scheduled date"
      :category "Org"
      :priority 95
      :predicate (lambda () (fboundp 'org-schedule))
      :action (lambda () (call-interactively #'org-schedule)))

     (init-dwim-make-action
      :title "Set deadline"
      :description "Set or change the deadline"
      :category "Org"
      :priority 94
      :predicate (lambda () (fboundp 'org-deadline))
      :action (lambda () (call-interactively #'org-deadline)))

     (init-dwim-make-action
      :title "Refile subtree"
      :description "Refile this Org subtree"
      :category "Org"
      :priority 90
      :predicate (lambda () (fboundp 'org-refile))
      :action (lambda () (call-interactively #'org-refile)))

     (init-dwim-make-action
      :title "Archive subtree"
      :description "Archive this Org subtree"
      :category "Org"
      :priority 85
      :predicate (lambda () (fboundp 'org-archive-subtree))
      :action (lambda () (call-interactively #'org-archive-subtree)))

     (init-dwim-make-action
      :title "Clock in"
      :description "Clock into this heading"
      :category "Org"
      :priority 80
      :predicate (lambda () (fboundp 'org-clock-in))
      :action (lambda () (call-interactively #'org-clock-in)))

     (init-dwim-make-action
      :title "Clock out"
      :description "Clock out of the current task"
      :category "Org"
      :priority 79
      :predicate (lambda () (fboundp 'org-clock-out))
      :action (lambda () (call-interactively #'org-clock-out)))

     (init-dwim-make-action
      :title "Copy link to heading"
      :description "Store a link to this heading and copy it"
      :category "Org"
      :priority 78
      :predicate (lambda () (and (fboundp 'org-store-link)
                                 (boundp 'org-stored-links)))
      :action (lambda ()
                (require 'org)
                (org-store-link nil)
                (let ((link (caar org-stored-links)))
                  (kill-new link)
                  (message "Copied Org link: %s" link))))

     (init-dwim-make-action
      :title "Export subtree"
      :description "Export this Org subtree"
      :category "Org"
      :priority 70
      :predicate (lambda () (fboundp 'org-export-dispatch))
      :action (lambda ()
                (let ((current-prefix-arg '(4)))
                  (call-interactively #'org-export-dispatch))))

     ;; ── New Org actions ──────────────────────────────────────────────────

     (init-dwim-make-action
      :title "Set tags"
      :description "Add or change tags on this heading"
      :category "Org"
      :priority 83
      :predicate (lambda () (fboundp 'org-set-tags-command))
      :action (lambda () (call-interactively #'org-set-tags-command)))

     (init-dwim-make-action
      :title "Set property"
      :description "Set a property on this heading"
      :category "Org"
      :priority 76
      :predicate (lambda () (fboundp 'org-set-property))
      :action (lambda () (call-interactively #'org-set-property)))

     (init-dwim-make-action
      :title "Set priority"
      :description "Set or change the priority cookie"
      :category "Org"
      :priority 77
      :predicate (lambda () (fboundp 'org-priority))
      :action (lambda () (call-interactively #'org-priority)))

     (init-dwim-make-action
      :title "Insert heading below"
      :description "Insert a new sibling heading below the current one"
      :category "Org"
      :priority 74
      :predicate (lambda () (fboundp 'org-insert-heading-respect-content))
      :action (lambda () (org-insert-heading-respect-content)))

     (init-dwim-make-action
      :title "Promote subtree"
      :description "Promote this heading one level up"
      :category "Org"
      :priority 72
      :predicate (lambda () (fboundp 'org-promote-subtree))
      :action (lambda () (org-promote-subtree)))

     (init-dwim-make-action
      :title "Demote subtree"
      :description "Demote this heading one level down"
      :category "Org"
      :priority 71
      :predicate (lambda () (fboundp 'org-demote-subtree))
      :action (lambda () (org-demote-subtree)))

     (init-dwim-make-action
      :title "Move subtree up"
      :description "Move this subtree before the previous heading"
      :category "Org"
      :priority 69
      :predicate (lambda () (fboundp 'org-move-subtree-up))
      :action (lambda () (org-move-subtree-up)))

     (init-dwim-make-action
      :title "Move subtree down"
      :description "Move this subtree after the next heading"
      :category "Org"
      :priority 68
      :predicate (lambda () (fboundp 'org-move-subtree-down))
      :action (lambda () (org-move-subtree-down)))

     (init-dwim-make-action
      :title "Insert template / structure"
      :description "Insert an Org structure template (#+BEGIN_…)"
      :category "Org"
      :priority 55
      :predicate (lambda () (fboundp 'org-insert-structure-template))
      :action (lambda () (call-interactively #'org-insert-structure-template)))

     (init-dwim-make-action
      :title "Capture to Org"
      :description "Open the Org capture menu"
      :category "Org"
      :priority 50
      :predicate (lambda () (fboundp 'org-capture))
      :action (lambda () (call-interactively #'org-capture)))

     (init-dwim-make-action
      :title "Show agenda"
      :description "Open the Org agenda"
      :category "Org"
      :priority 48
      :predicate (lambda () (fboundp 'org-agenda))
      :action (lambda () (call-interactively #'org-agenda)))

     (init-dwim-make-action
      :title "Evaluate source block"
      :description "Evaluate the Org Babel source block at point"
      :category "Org"
      :priority 86
      :predicate (lambda () (fboundp 'org-babel-execute-src-block))
      :action (lambda () (org-babel-execute-src-block)))

     (init-dwim-make-action
      :title "Tangle file"
      :description "Tangle all source blocks in this Org file"
      :category "Org"
      :priority 60
      :predicate (lambda () (fboundp 'org-babel-tangle))
      :action (lambda () (org-babel-tangle)))

     (init-dwim-make-action
      :title "Toggle heading visibility"
      :description "Fold or unfold this heading (org-cycle)"
      :category "Org"
      :priority 92
      :predicate (lambda () (fboundp 'org-cycle))
      :action (lambda () (org-cycle)))

     (init-dwim-make-action
      :title "Column view"
      :description "Enter Org column view for this heading"
      :category "Org"
      :priority 42
      :predicate (lambda () (fboundp 'org-columns))
      :action (lambda () (org-columns))))))

;;; ── Programming ──────────────────────────────────────────────────────────

(defun init-dwim-programming-provider ()
  "Return actions relevant to programming buffers."
  (when (derived-mode-p 'prog-mode)
    (list
     (init-dwim-make-action
      :title "Run nearest test"
      :description "Run the nearest test when a test runner can detect it"
      :category "Code"
      :priority 95
      :predicate (lambda ()
                   (or (fboundp 'projectile-test-project)
                       (fboundp 'pytest-one)
                       (fboundp 'rspec-verify-single)
                       (fboundp 'go-test-current-test)
                       (fboundp 'jest-file-dwim)))
      :action (lambda ()
                (cond
                 ((fboundp 'pytest-one) (call-interactively #'pytest-one))
                 ((fboundp 'rspec-verify-single) (rspec-verify-single))
                 ((fboundp 'go-test-current-test) (go-test-current-test))
                 ((fboundp 'jest-file-dwim) (jest-file-dwim))
                 ((fboundp 'projectile-test-project) (projectile-test-project))
                 (t (user-error "No nearest-test command available")))))

     (init-dwim-make-action
      :title "Run project tests"
      :description "Run test command for the current project"
      :category "Code"
      :priority 90
      :predicate (lambda ()
                   (or (fboundp 'projectile-test-project)
                       (and (fboundp 'project-compile)
                            (project-current nil))))
      :action (lambda ()
                (cond
                 ((fboundp 'projectile-test-project)
                  (projectile-test-project))
                 ((fboundp 'project-compile)
                  (project-compile))
                 (t
                  (call-interactively #'compile)))))

     (init-dwim-make-action
      :title "Format buffer"
      :description "Format or indent the current buffer"
      :category "Code"
      :priority 88
      :action #'init-dwim--format-buffer)

     (init-dwim-make-action
      :title "Show diagnostics"
      :description "Open diagnostics for Flycheck, Flymake, or LSP"
      :category "Code"
      :priority 84
      :predicate (lambda ()
                   (or (fboundp 'flycheck-list-errors)
                       (fboundp 'flymake-show-buffer-diagnostics)
                       (fboundp 'lsp-treemacs-errors-list)))
      :action (lambda ()
                (cond
                 ((fboundp 'flycheck-list-errors)
                  (flycheck-list-errors))
                 ((fboundp 'flymake-show-buffer-diagnostics)
                  (flymake-show-buffer-diagnostics))
                 ((fboundp 'lsp-treemacs-errors-list)
                  (lsp-treemacs-errors-list))
                 (t
                  (user-error "No diagnostics command available")))))

     (init-dwim-make-action
      :title "Jump to next error"
      :description "Go to the next diagnostic or compilation error"
      :category "Code"
      :priority 83
      :predicate (lambda ()
                   (or (fboundp 'flycheck-next-error)
                       (fboundp 'flymake-goto-next-error)
                       (fboundp 'next-error)))
      :action (lambda ()
                (cond
                 ((and (boundp 'flycheck-mode) flycheck-mode
                       (fboundp 'flycheck-next-error))
                  (flycheck-next-error))
                 ((and (boundp 'flymake-mode) flymake-mode
                       (fboundp 'flymake-goto-next-error))
                  (flymake-goto-next-error))
                 ((fboundp 'next-error)
                  (next-error))
                 (t
                  (user-error "No next-error command available")))))

     (init-dwim-make-action
      :title "Open REPL"
      :description "Open a REPL suitable for this buffer"
      :category "Code"
      :priority 80
      :predicate (lambda ()
                   (or (and (derived-mode-p 'emacs-lisp-mode)
                            (fboundp 'ielm))
                       (and (derived-mode-p 'python-mode)
                            (fboundp 'run-python))
                       (fboundp 'cider-jack-in)
                       (fboundp 'sly)
                       (fboundp 'slime)))
      :action (lambda ()
                (cond
                 ((and (derived-mode-p 'emacs-lisp-mode) (fboundp 'ielm))
                  (ielm))
                 ((and (derived-mode-p 'python-mode) (fboundp 'run-python))
                  (run-python))
                 ((fboundp 'cider-jack-in)
                  (cider-jack-in))
                 ((fboundp 'sly)
                  (sly))
                 ((fboundp 'slime)
                  (slime))
                 (t
                  (user-error "No REPL command available")))))

     (init-dwim-make-action
      :title "Evaluate expression or defun"
      :description "Evaluate the expression, defun, or language-specific unit"
      :category "Code"
      :priority 78
      :predicate (lambda ()
                   (or (derived-mode-p 'emacs-lisp-mode 'lisp-interaction-mode)
                       (and (derived-mode-p 'python-mode)
                            (fboundp 'python-shell-send-defun))
                       (fboundp 'cider-eval-defun-at-point)
                       (fboundp 'slime-eval-defun)
                       (fboundp 'sly-eval-defun)))
      :action (lambda ()
                (cond
                 ((derived-mode-p 'emacs-lisp-mode 'lisp-interaction-mode)
                  (call-interactively #'eval-defun))
                 ((and (derived-mode-p 'python-mode)
                       (fboundp 'python-shell-send-defun))
                  (python-shell-send-defun))
                 ((fboundp 'cider-eval-defun-at-point)
                  (cider-eval-defun-at-point))
                 ((fboundp 'sly-eval-defun)
                  (sly-eval-defun))
                 ((fboundp 'slime-eval-defun)
                  (slime-eval-defun))
                 (t
                  (user-error "No evaluator command available")))))

     (init-dwim-make-action
      :title "Open related test/source file"
      :description "Switch between implementation and test file when possible"
      :category "Code"
      :priority 74
      :predicate (lambda ()
                   (or (fboundp 'projectile-toggle-between-implementation-and-test)
                       (fboundp 'ff-find-other-file)))
      :action (lambda ()
                (cond
                 ((fboundp 'projectile-toggle-between-implementation-and-test)
                  (projectile-toggle-between-implementation-and-test))
                 ((fboundp 'ff-find-other-file)
                  (ff-find-other-file))
                 (t
                  (user-error "No related-file command available")))))

     ;; ── New programming actions ──────────────────────────────────────────

     (init-dwim-make-action
      :title "Jump to previous error"
      :description "Go to the previous diagnostic or compilation error"
      :category "Code"
      :priority 82
      :predicate (lambda ()
                   (or (fboundp 'flycheck-previous-error)
                       (fboundp 'flymake-goto-prev-error)
                       (fboundp 'previous-error)))
      :action (lambda ()
                (cond
                 ((and (boundp 'flycheck-mode) flycheck-mode
                       (fboundp 'flycheck-previous-error))
                  (flycheck-previous-error))
                 ((and (boundp 'flymake-mode) flymake-mode
                       (fboundp 'flymake-goto-prev-error))
                  (flymake-goto-prev-error))
                 ((fboundp 'previous-error)
                  (previous-error))
                 (t
                  (user-error "No previous-error command available")))))

     (init-dwim-make-action
      :title "Imenu jump"
      :description "Jump to a definition via imenu"
      :category "Code"
      :priority 73
      :predicate (lambda ()
                   (or (fboundp 'consult-imenu)
                       (fboundp 'imenu)))
      :action (lambda ()
                (if (fboundp 'consult-imenu)
                    (consult-imenu)
                  (call-interactively #'imenu))))

     (init-dwim-make-action
      :title "Toggle comment (line)"
      :description "Comment or uncomment the current line"
      :category "Code"
      :priority 67
      :action (lambda ()
                (comment-or-uncomment-region
                 (line-beginning-position)
                 (line-end-position))))

     (init-dwim-make-action
      :title "Insert inline doc comment"
      :description "Insert a language-appropriate documentation comment"
      :category "Code"
      :priority 56
      :predicate (lambda ()
                   (or (fboundp 'add-log-current-defun)
                       (derived-mode-p 'emacs-lisp-mode 'python-mode
                                       'java-mode 'js-mode 'typescript-mode)))
      :action (lambda ()
                (let* ((defun-name (or (add-log-current-defun) "function"))
                       (doc (read-string
                             (format "Doc comment for %s: " defun-name))))
                  (beginning-of-defun)
                  (open-line 1)
                  (cond
                   ((derived-mode-p 'emacs-lisp-mode)
                    (insert (format ";; %s" doc)))
                   ((derived-mode-p 'python-mode)
                    (insert (format "# %s" doc)))
                   (t
                    (insert (format "// %s" doc)))))))

     (init-dwim-make-action
      :title "Start Emacs profiler"
      :description "Start the built-in Emacs profiler (CPU)"
      :category "Code"
      :priority 35
      :predicate (lambda () (fboundp 'profiler-start))
      :action (lambda ()
                (profiler-start 'cpu)
                (message "Profiler started — call init-dwim → Stop profiler when done")))

     (init-dwim-make-action
      :title "Stop profiler and show report"
      :description "Stop the built-in Emacs profiler and open the report"
      :category "Code"
      :priority 35
      :predicate (lambda () (and (fboundp 'profiler-running-p)
                                 (profiler-running-p)))
      :action (lambda () (profiler-stop) (profiler-report)))

     (init-dwim-make-action
      :title "Compile project"
      :description "Run the project compile command"
      :category "Code"
      :priority 65
      :action (lambda ()
                (cond
                 ((and (fboundp 'projectile-compile-project)
                       (init-dwim--in-project-p))
                  (projectile-compile-project nil))
                 ((and (fboundp 'project-compile)
                       (project-current nil))
                  (project-compile))
                 (t
                  (call-interactively #'compile)))))

     (init-dwim-make-action
      :title "Send buffer to AI for review"
      :description "Ask an AI to review the current buffer"
      :category "Code"
      :priority 45
      :predicate #'init-dwim--ai-available-p
      :action (lambda ()
                (init-dwim--ai-send-region
                 (point-min) (point-max)
                 "Please review this code and suggest improvements:")))

     (init-dwim-make-action
      :title "Restart LSP/Eglot server"
      :description "Reconnect or restart the language server for this buffer"
      :category "Code"
      :priority 50
      :predicate #'init-dwim--lsp-available-p
      :action (lambda ()
                (cond
                 ((and (boundp 'lsp-mode) lsp-mode (fboundp 'lsp-restart-workspace))
                  (lsp-restart-workspace))
                 ((and (fboundp 'eglot-current-server)
                       (ignore-errors (eglot-current-server)))
                  (call-interactively #'eglot-reconnect))
                 (t (user-error "No LSP server active")))))

     (init-dwim-make-action
      :title "Show hover documentation"
      :description "Show LSP hover documentation for symbol at point"
      :category "Code"
      :priority 77
      :predicate #'init-dwim--lsp-available-p
      :action (lambda ()
                (cond
                 ((and (boundp 'lsp-mode) lsp-mode (fboundp 'lsp-describe-thing-at-point))
                  (lsp-describe-thing-at-point))
                 ((fboundp 'eldoc-doc-buffer)
                  (eldoc-doc-buffer))
                 (t (user-error "No hover command available")))))

     (init-dwim-make-action
      :title "Run current file"
      :description "Execute the current file with the appropriate interpreter"
      :category "Code"
      :priority 60
      :predicate (lambda ()
                   (or (derived-mode-p 'python-mode)
                       (derived-mode-p 'ruby-mode)
                       (derived-mode-p 'js-mode 'typescript-mode)
                       (derived-mode-p 'sh-mode)
                       (derived-mode-p 'emacs-lisp-mode)))
      :action (lambda ()
                (let ((f (buffer-file-name)))
                  (unless f (user-error "Buffer is not visiting a file"))
                  (cond
                   ((derived-mode-p 'python-mode)
                    (compile (format "python3 %s" (shell-quote-argument f))))
                   ((derived-mode-p 'ruby-mode)
                    (compile (format "ruby %s" (shell-quote-argument f))))
                   ((derived-mode-p 'js-mode 'typescript-mode)
                    (compile (format "node %s" (shell-quote-argument f))))
                   ((derived-mode-p 'sh-mode)
                    (compile (format "bash %s" (shell-quote-argument f))))
                   ((derived-mode-p 'emacs-lisp-mode)
                    (load-file f))
                   (t (user-error "No runner for %s" major-mode))))))

     (init-dwim-make-action
      :title "Add missing import (LSP)"
      :description "Trigger LSP code action to add missing import"
      :category "Code"
      :priority 76
      :predicate #'init-dwim--lsp-available-p
      :action (lambda ()
                (cond
                 ((and (boundp 'lsp-mode) lsp-mode (fboundp 'lsp-execute-code-action))
                  (lsp-execute-code-action "source.addMissingImports"))
                 ((and (fboundp 'eglot-code-actions)
                       (ignore-errors (eglot-current-server)))
                  (eglot-code-actions nil nil "source.addMissingImports"))
                 (t (user-error "No LSP import action available"))))))))

;;; ── Text / Markdown ───────────────────────────────────────────────────────

(defun init-dwim-text-provider ()
  "Return actions relevant to Markdown and text buffers."
  (when (or (init-dwim--markdown-mode-p)
            (init-dwim--text-like-mode-p))
    (let ((word (or (init-dwim--region-string)
                    (init-dwim--symbol-string)
                    (thing-at-point 'word t))))
      (list
       (init-dwim-make-action
        :title "Preview buffer"
        :description "Preview Markdown/text buffer when supported"
        :category "Text"
        :priority 90
        :predicate (lambda ()
                     (or (fboundp 'markdown-preview)
                         (fboundp 'markdown-live-preview-mode)
                         (fboundp 'grip-mode)))
        :action (lambda ()
                  (cond
                   ((fboundp 'markdown-preview)
                    (markdown-preview))
                   ((fboundp 'markdown-live-preview-mode)
                    (markdown-live-preview-mode 'toggle))
                   ((fboundp 'grip-mode)
                    (grip-mode 'toggle))
                   (t
                    (user-error "No preview command available")))))

       (init-dwim-make-action
        :title "Insert link"
        :description "Insert a Markdown or Org-style link"
        :category "Text"
        :priority 85
        :action (lambda ()
                  (let ((url (read-string "URL: "))
                        (title (read-string "Text: ")))
                    (if (derived-mode-p 'org-mode)
                        (insert (format "[[%s][%s]]" url title))
                      (insert (format "[%s](%s)" title url))))))

       (init-dwim-make-action
        :title "Count words"
        :description "Count words in the region or buffer"
        :category "Text"
        :priority 82
        :action (lambda ()
                  (if (use-region-p)
                      (count-words-region (region-beginning) (region-end))
                    (count-words-region (point-min) (point-max)))))

       (init-dwim-make-action
        :title "Export buffer"
        :description "Export Markdown buffer when supported"
        :category "Text"
        :priority 75
        :predicate (lambda ()
                     (or (fboundp 'markdown-export)
                         (fboundp 'org-export-dispatch)))
        :action (lambda ()
                  (cond
                   ((fboundp 'markdown-export)
                    (markdown-export))
                   ((and (derived-mode-p 'org-mode)
                         (fboundp 'org-export-dispatch))
                    (call-interactively #'org-export-dispatch))
                   (t
                    (user-error "No export command available")))))

       (init-dwim-make-action
        :title "Toggle outline/folding"
        :description "Toggle outline or code folding"
        :category "Text"
        :priority 70
        :predicate (lambda ()
                     (or (fboundp 'outline-toggle-children)
                         (fboundp 'hs-toggle-hiding)))
        :action (lambda ()
                  (cond
                   ((fboundp 'outline-toggle-children)
                    (outline-toggle-children))
                   ((fboundp 'hs-toggle-hiding)
                    (hs-toggle-hiding))
                   (t
                    (user-error "No folding command available")))))

       (init-dwim-make-action
        :title "Search text in project"
        :description "Search selected text or word in the project"
        :category "Text"
        :priority 68
        :predicate (lambda ()
                     (and word (init-dwim--in-project-p)))
        :action (lambda ()
                  (init-dwim--project-search
                   (string-trim (substring-no-properties word)))))

       (init-dwim-make-action
        :title "Table of contents"
        :description "Generate/update a table of contents when supported"
        :category "Text"
        :priority 55
        :predicate (lambda ()
                     (or (fboundp 'markdown-toc-generate-or-refresh-toc)
                         (and (derived-mode-p 'org-mode)
                              (fboundp 'org-make-toc))))
        :action (lambda ()
                  (cond
                   ((fboundp 'markdown-toc-generate-or-refresh-toc)
                    (markdown-toc-generate-or-refresh-toc))
                   ((fboundp 'org-make-toc)
                    (org-make-toc))
                   (t
                    (user-error "No TOC command available")))))))))

;;; ── Dired ─────────────────────────────────────────────────────────────────

(defun init-dwim-dired-provider ()
  "Return actions relevant to Dired buffers."
  (when (derived-mode-p 'dired-mode)
    (let ((file (ignore-errors (dired-get-file-for-visit))))
      (list
       (init-dwim-make-action
        :title "Open file"
        :description "Open the Dired file at point"
        :category "Dired"
        :priority 100
        :predicate (lambda () file)
        :action (lambda () (find-file file)))

       (init-dwim-make-action
        :title "Rename"
        :description "Rename the Dired file at point"
        :category "Dired"
        :priority 95
        :predicate (lambda () (fboundp 'dired-do-rename))
        :action (lambda () (call-interactively #'dired-do-rename)))

       (init-dwim-make-action
        :title "Copy"
        :description "Copy the Dired file at point"
        :category "Dired"
        :priority 90
        :predicate (lambda () (fboundp 'dired-do-copy))
        :action (lambda () (call-interactively #'dired-do-copy)))

       (init-dwim-make-action
        :title "Delete"
        :description "Delete the Dired file at point"
        :category "Dired"
        :priority 85
        :predicate (lambda () (fboundp 'dired-do-delete))
        :action (lambda () (call-interactively #'dired-do-delete)))

       (init-dwim-make-action
        :title "Compress"
        :description "Compress the Dired file at point"
        :category "Dired"
        :priority 80
        :predicate (lambda () (fboundp 'dired-do-compress))
        :action (lambda () (call-interactively #'dired-do-compress)))

       (init-dwim-make-action
        :title "Open externally"
        :description "Open selected file externally"
        :category "Dired"
        :priority 78
        :predicate (lambda () file)
        :action (lambda () (init-dwim--open-externally file)))

       (init-dwim-make-action
        :title "Copy path"
        :description "Copy selected file path"
        :category "Dired"
        :priority 76
        :predicate (lambda () file)
        :action (lambda () (kill-new file) (message "Copied path: %s" file)))

       (init-dwim-make-action
        :title "Git status for directory"
        :description "Open Git status for this Dired directory"
        :category "Dired"
        :priority 70
        :predicate (lambda () (or (fboundp 'magit-status)
                                  (fboundp 'vc-dir)))
        :action (lambda () (init-dwim--open-git-status default-directory)))

       ;; ── New Dired actions ───────────────────────────────────────────────

       (init-dwim-make-action
        :title "Mark by extension"
        :description "Mark all files with a given extension"
        :category "Dired"
        :priority 65
        :predicate (lambda () (fboundp 'dired-mark-files-regexp))
        :action (lambda ()
                  (let ((ext (read-string "Extension (without dot): ")))
                    (dired-mark-files-regexp (format "\\.%s$" ext)))))

       (init-dwim-make-action
        :title "Search file contents"
        :description "Grep inside Dired-marked files"
        :category "Dired"
        :priority 62
        :predicate (lambda () (fboundp 'dired-do-find-regexp))
        :action (lambda () (call-interactively #'dired-do-find-regexp)))

       (init-dwim-make-action
        :title "Diff marked files"
        :description "Show diff between two marked Dired files"
        :category "Dired"
        :priority 58
        :predicate (lambda () (fboundp 'dired-diff))
        :action (lambda () (call-interactively #'dired-diff)))

       (init-dwim-make-action
        :title "Open in wdired"
        :description "Edit file names inline (wdired mode)"
        :category "Dired"
        :priority 55
        :predicate (lambda () (fboundp 'wdired-change-to-wdired-mode))
        :action (lambda () (wdired-change-to-wdired-mode)))

       (init-dwim-make-action
        :title "Sort by date / name / size"
        :description "Toggle or change Dired sort order"
        :category "Dired"
        :priority 50
        :predicate (lambda () (fboundp 'dired-sort-toggle-or-edit))
        :action (lambda () (dired-sort-toggle-or-edit)))

       (init-dwim-make-action
        :title "Create directory"
        :description "Create a new subdirectory here"
        :category "Dired"
        :priority 48
        :predicate (lambda () (fboundp 'dired-create-directory))
        :action (lambda () (call-interactively #'dired-create-directory)))

       (init-dwim-make-action
        :title "Ediff marked files"
        :description "Open Ediff on two marked Dired files"
        :category "Dired"
        :priority 45
        :predicate (lambda () (fboundp 'ediff-files))
        :action (lambda ()
                  (let ((files (dired-get-marked-files)))
                    (if (= (length files) 2)
                        (ediff-files (car files) (cadr files))
                      (user-error "Mark exactly two files for ediff")))))

       (init-dwim-make-action
        :title "Create symlink"
        :description "Create a symbolic link to the file at point"
        :category "Dired"
        :priority 42
        :predicate (lambda () (fboundp 'dired-do-symlink))
        :action (lambda () (call-interactively #'dired-do-symlink)))))))

;;; ── Magit ─────────────────────────────────────────────────────────────────

(defun init-dwim-magit-provider ()
  "Return actions relevant to Magit buffers, plus always-available Magit entry points."
  (let ((in-magit (derived-mode-p 'magit-mode)))
    (append
     ;; ── Always-available Magit entry points (moved from personal-provider) ─
     (list
      (init-dwim-make-action
       :title "Magit status"
       :description "Open Magit for the current repository"
       :category "Git"
       :priority 100
       :predicate (lambda () (fboundp 'magit-status))
       :action (lambda () (call-interactively #'magit-status)))

      (init-dwim-make-action
       :title "Magit project status"
       :description "Open Magit at the current project root"
       :category "Git"
       :priority 98
       :predicate (lambda ()
                    (and (fboundp 'magit-status)
                         (fboundp 'project-current)
                         (project-current nil)))
       :action (lambda ()
                 (magit-status (project-root (project-current t)))))

      (init-dwim-make-action
       :title "Magit dispatch"
       :description "Open Magit transient dispatch"
       :category "Git"
       :priority 92
       :predicate (lambda () (fboundp 'magit-dispatch))
       :action (lambda () (call-interactively #'magit-dispatch)))

      (init-dwim-make-action
       :title "Magit file dispatch"
       :description "Open Magit actions for the current file"
       :category "Git"
       :priority 88
       :predicate (lambda ()
                    (and buffer-file-name (fboundp 'magit-file-dispatch)))
       :action (lambda () (call-interactively #'magit-file-dispatch)))

      (init-dwim-make-action
       :title "Magit blame"
       :description "Show git blame annotations for the current file"
       :category "Git"
       :priority 82
       :predicate (lambda ()
                    (and buffer-file-name (fboundp 'magit-blame-addition)))
       :action (lambda () (call-interactively #'magit-blame-addition))))

     ;; ── Magit-buffer-specific actions ──────────────────────────────────────
     (when in-magit
       (list
        (init-dwim-make-action
         :title "Stage item"
         :description "Stage item at point"
         :category "Magit"
         :priority 100
         :predicate (lambda () (fboundp 'magit-stage))
         :action (lambda () (call-interactively #'magit-stage)))

        (init-dwim-make-action
         :title "Unstage item"
         :description "Unstage item at point"
         :category "Magit"
         :priority 98
         :predicate (lambda () (fboundp 'magit-unstage))
         :action (lambda () (call-interactively #'magit-unstage)))

        (init-dwim-make-action
         :title "Commit"
         :description "Create a Git commit"
         :category "Magit"
         :priority 90
         :predicate (lambda () (fboundp 'magit-commit-create))
         :action (lambda () (call-interactively #'magit-commit-create)))

        (init-dwim-make-action
         :title "Push"
         :description "Push changes"
         :category "Magit"
         :priority 85
         :predicate (lambda () (fboundp 'magit-push))
         :action (lambda () (call-interactively #'magit-push)))

        (init-dwim-make-action
         :title "Pull"
         :description "Pull changes"
         :category "Magit"
         :priority 84
         :predicate (lambda () (fboundp 'magit-pull))
         :action (lambda () (call-interactively #'magit-pull)))

        (init-dwim-make-action
         :title "Show diff"
         :description "Show diff for item at point"
         :category "Magit"
         :priority 82
         :predicate (lambda () (fboundp 'magit-diff-dwim))
         :action (lambda () (call-interactively #'magit-diff-dwim)))

        (init-dwim-make-action
         :title "Copy commit hash"
         :description "Copy commit hash at point"
         :category "Magit"
         :priority 80
         :predicate (lambda ()
                      (and (fboundp 'magit-thing-at-point)
                           (magit-thing-at-point 'git-revision t)))
         :action (lambda ()
                   (let ((rev (magit-thing-at-point 'git-revision t)))
                     (kill-new rev)
                     (message "Copied revision: %s" rev))))

        ;; ── New Magit actions ───────────────────────────────────────────────

        (init-dwim-make-action
         :title "Create branch"
         :description "Create and checkout a new Git branch"
         :category "Magit"
         :priority 75
         :predicate (lambda () (fboundp 'magit-branch-create))
         :action (lambda () (call-interactively #'magit-branch-create)))

        (init-dwim-make-action
         :title "Checkout branch"
         :description "Checkout an existing branch"
         :category "Magit"
         :priority 74
         :predicate (lambda () (fboundp 'magit-checkout))
         :action (lambda () (call-interactively #'magit-checkout)))

        (init-dwim-make-action
         :title "Stash changes"
         :description "Stash current working tree changes"
         :category "Magit"
         :priority 72
         :predicate (lambda () (fboundp 'magit-stash))
         :action (lambda () (call-interactively #'magit-stash)))

        (init-dwim-make-action
         :title "Pop stash"
         :description "Apply and drop the top stash"
         :category "Magit"
         :priority 71
         :predicate (lambda () (fboundp 'magit-stash-pop))
         :action (lambda () (call-interactively #'magit-stash-pop)))

        (init-dwim-make-action
         :title "Rebase"
         :description "Start an interactive rebase"
         :category "Magit"
         :priority 70
         :predicate (lambda () (fboundp 'magit-rebase))
         :action (lambda () (call-interactively #'magit-rebase)))

        (init-dwim-make-action
         :title "Cherry pick"
         :description "Cherry-pick commit at point"
         :category "Magit"
         :priority 68
         :predicate (lambda () (fboundp 'magit-cherry-pick))
         :action (lambda () (call-interactively #'magit-cherry-pick)))

        (init-dwim-make-action
         :title "Show log"
         :description "Open the Magit log"
         :category "Magit"
         :priority 65
         :predicate (lambda () (fboundp 'magit-log-current))
         :action (lambda () (magit-log-current nil)))

        (init-dwim-make-action
         :title "Fetch"
         :description "Fetch from a remote"
         :category "Magit"
         :priority 78
         :predicate (lambda () (fboundp 'magit-fetch))
         :action (lambda () (call-interactively #'magit-fetch)))

        (init-dwim-make-action
         :title "Amend last commit"
         :description "Amend the most recent commit"
         :category "Magit"
         :priority 76
         :predicate (lambda () (fboundp 'magit-commit-amend))
         :action (lambda () (call-interactively #'magit-commit-amend))))))))

;;; ── Project ───────────────────────────────────────────────────────────────

(defun init-dwim-project-provider ()
  "Return actions relevant to the current project."
  (when-let ((root (init-dwim--project-root)))
    (let ((notes (and init-dwim-project-notes-file
                      (expand-file-name init-dwim-project-notes-file root))))
      (list
       (init-dwim-make-action
        :title "Search project"
        :description "Search in the current project"
        :category "Project"
        :priority 75
        :action (lambda ()
                  (init-dwim--project-search
                   (read-string "Search project for: "
                                (or (init-dwim--region-string)
                                    (init-dwim--symbol-string)
                                    "")))))

       (init-dwim-make-action
        :title "Open project file"
        :description "Find a file in the current project"
        :category "Project"
        :priority 72
        :action #'init-dwim--find-project-file)

       (init-dwim-make-action
        :title "Switch project"
        :description "Switch to another project"
        :category "Project"
        :priority 68
        :predicate (lambda ()
                     (or (fboundp 'projectile-switch-project)
                         (fboundp 'project-switch-project)))
        :action #'init-dwim--switch-project)

       (init-dwim-make-action
        :title "Run project command"
        :description "Compile or run a project command"
        :category "Project"
        :priority 66
        :action (lambda ()
                  (cond
                   ((fboundp 'project-compile)
                    (project-compile))
                   ((fboundp 'projectile-compile-project)
                    (projectile-compile-project nil))
                   (t
                    (call-interactively #'compile)))))

       (init-dwim-make-action
        :title "Open project root in Dired"
        :description "Open the project root directory"
        :category "Project"
        :priority 64
        :action #'init-dwim--open-project-dired)

       (init-dwim-make-action
        :title "Open project notes"
        :description "Open the configured project notes file"
        :category "Project"
        :priority 62
        :predicate (lambda () notes)
        :action (lambda () (find-file notes)))

       (init-dwim-make-action
        :title "Open Git status"
        :description "Open Magit or vc-dir for this project"
        :category "Project"
        :priority 60
        :predicate (lambda () (or (fboundp 'magit-status)
                                  (fboundp 'vc-dir)))
        :action (lambda () (init-dwim--open-git-status root)))

       ;; ── New project actions ─────────────────────────────────────────────

       (init-dwim-make-action
        :title "Kill all project buffers"
        :description "Kill every buffer belonging to the current project"
        :category "Project"
        :priority 42
        :action (lambda ()
                  (when (yes-or-no-p
                         (format "Kill all buffers for project %s? "
                                 (abbreviate-file-name root)))
                    (cond
                     ((fboundp 'projectile-kill-buffers)
                      (projectile-kill-buffers))
                     ((fboundp 'project-kill-buffers)
                      (project-kill-buffers nil))
                     (t
                      (dolist (buf (buffer-list))
                        (when-let ((fname (buffer-file-name buf)))
                          (when (string-prefix-p root fname)
                            (kill-buffer buf)))))))))

       (init-dwim-make-action
        :title "Open project eshell"
        :description "Open an eshell rooted at the project root"
        :category "Project"
        :priority 48
        :action (lambda ()
                  (cond
                   ((fboundp 'projectile-run-eshell)
                    (projectile-run-eshell))
                   (t
                    (let ((default-directory root))
                      (eshell t))))))

       (init-dwim-make-action
        :title "Open project terminal"
        :description "Open a terminal emulator at the project root"
        :category "Project"
        :priority 47
        :predicate (lambda ()
                     (or (fboundp 'projectile-run-vterm)
                         (fboundp 'vterm)
                         (fboundp 'eat)))
        :action (lambda ()
                  (cond
                   ((fboundp 'projectile-run-vterm)
                    (projectile-run-vterm))
                   ((fboundp 'vterm)
                    (let ((default-directory root)) (vterm)))
                   ((fboundp 'eat)
                    (let ((default-directory root)) (eat)))
                   (t
                    (user-error "No terminal command available")))))

       (init-dwim-make-action
        :title "List recent project files"
        :description "Browse recently visited files in this project"
        :category "Project"
        :priority 55
        :predicate (lambda ()
                     (or (fboundp 'projectile-recentf)
                         (fboundp 'consult-recent-file)))
        :action (lambda ()
                  (cond
                   ((fboundp 'projectile-recentf)
                    (projectile-recentf))
                   ((fboundp 'consult-recent-file)
                    (consult-recent-file)))))))))

;;; ── Buffer (NEW) ──────────────────────────────────────────────────────────

(defun init-dwim-buffer-provider ()
  "Return general buffer-management actions."
  (list
   (init-dwim-make-action
    :title "Save buffer"
    :description "Save the current buffer to its file"
    :category "Buffer"
    :priority 90
    :predicate (lambda ()
                 (and (init-dwim--buffer-file-p)
                      (buffer-modified-p)))
    :action (lambda () (save-buffer)))

   (init-dwim-make-action
    :title "Revert buffer"
    :description "Reload the current buffer from disk"
    :category "Buffer"
    :priority 85
    :predicate #'init-dwim--buffer-file-p
    :action (lambda () (revert-buffer nil t t)
              (message "Buffer reverted")))

   (init-dwim-make-action
    :title "Rename buffer"
    :description "Rename the current buffer"
    :category "Buffer"
    :priority 80
    :action (lambda () (call-interactively #'rename-buffer)))

   (init-dwim-make-action
    :title "Rename file and buffer"
    :description "Rename the file the buffer is visiting and update the buffer name"
    :category "Buffer"
    :priority 78
    :predicate #'init-dwim--buffer-file-p
    :action (lambda ()
              (let* ((old (buffer-file-name))
                     (new (read-file-name "Rename to: " (file-name-directory old)
                                          nil nil (file-name-nondirectory old))))
                (rename-file old new 1)
                (set-visited-file-name new t t)
                (message "Renamed to %s" new))))

   (init-dwim-make-action
    :title "Kill buffer"
    :description "Kill the current buffer"
    :category "Buffer"
    :priority 75
    :action (lambda () (kill-current-buffer)))

   (init-dwim-make-action
    :title "Clone buffer"
    :description "Create an indirect clone of the current buffer"
    :category "Buffer"
    :priority 60
    :action (lambda () (clone-indirect-buffer nil t)))

   (init-dwim-make-action
    :title "Copy buffer contents"
    :description "Copy the entire buffer text to the kill ring"
    :category "Buffer"
    :priority 55
    :action (lambda ()
              (kill-new (buffer-substring-no-properties (point-min) (point-max)))
              (message "Buffer contents copied (%d chars)"
                       (- (point-max) (point-min)))))

   (init-dwim-make-action
    :title "Copy buffer file path"
    :description "Copy the full path of the file this buffer is visiting"
    :category "Buffer"
    :priority 53
    :predicate #'init-dwim--buffer-file-p
    :action (lambda ()
              (let ((path (buffer-file-name)))
                (kill-new path)
                (message "Copied: %s" path))))

   (init-dwim-make-action
    :title "Show word/line count"
    :description "Display word and line statistics for the buffer or region"
    :category "Buffer"
    :priority 50
    :action (lambda () (message "%s" (init-dwim--word-count-message))))

   (init-dwim-make-action
    :title "Toggle read-only"
    :description "Toggle the buffer's read-only state"
    :category "Buffer"
    :priority 48
    :action (lambda () (read-only-mode 'toggle)
              (message "Buffer is now %s"
                       (if buffer-read-only "read-only" "writable"))))

   (init-dwim-make-action
    :title "Toggle auto-fill"
    :description "Toggle automatic line-wrapping in this buffer"
    :category "Buffer"
    :priority 40
    :action (lambda () (auto-fill-mode 'toggle)
              (message "Auto-fill %s"
                       (if auto-fill-function "on" "off"))))

   (init-dwim-make-action
    :title "Set coding system"
    :description "Change the coding system used to save this buffer"
    :category "Buffer"
    :priority 35
    :action (lambda () (call-interactively #'set-buffer-file-coding-system)))

   (init-dwim-make-action
    :title "Narrow to defun"
    :description "Narrow the buffer to the current function/definition"
    :category "Buffer"
    :priority 42
    :predicate (lambda () (derived-mode-p 'prog-mode))
    :action (lambda () (narrow-to-defun)))

   (init-dwim-make-action
    :title "Widen"
    :description "Remove narrowing and show the entire buffer"
    :category "Buffer"
    :priority 44
    :predicate (lambda () (buffer-narrowed-p))
    :action (lambda () (widen) (message "Buffer widened")))

   (init-dwim-make-action
    :title "Whitespace cleanup"
    :description "Remove trailing whitespace and normalize the buffer"
    :category "Buffer"
    :priority 38
    :action (lambda ()
              (whitespace-cleanup)
              (message "Whitespace cleaned")))

   (init-dwim-make-action
    :title "Switch to scratch buffer"
    :description "Jump to the *scratch* buffer"
    :category "Buffer"
    :priority 30
    :action (lambda () (switch-to-buffer "*scratch*")))

   (init-dwim-make-action
    :title "Open file in other window"
    :description "Open the current file's path in another window"
    :category "Buffer"
    :priority 32
    :predicate #'init-dwim--buffer-file-p
    :action (lambda () (find-file-other-window (buffer-file-name))))

   (init-dwim-make-action
    :title "Switch to buffer"
    :description "Switch to another buffer by name"
    :category "Buffer"
    :priority 92
    :action (lambda ()
              (if (fboundp 'consult-buffer)
                  (consult-buffer)
                (call-interactively #'switch-to-buffer))))

   (init-dwim-make-action
    :title "Kill all unmodified buffers"
    :description "Kill every buffer that has no unsaved changes"
    :category "Buffer"
    :priority 25
    :action (lambda ()
              (when (yes-or-no-p "Kill all unmodified buffers? ")
                (let ((count 0))
                  (dolist (buf (buffer-list))
                    (unless (or (buffer-modified-p buf)
                                (get-buffer-process buf)
                                (string-prefix-p " " (buffer-name buf)))
                      (kill-buffer buf)
                      (cl-incf count)))
                  (message "Killed %d buffer(s)" count)))))

   (init-dwim-make-action
    :title "Diff buffer against file"
    :description "Show what has changed since the last save"
    :category "Buffer"
    :priority 36
    :predicate #'init-dwim--buffer-file-p
    :action (lambda () (diff-buffer-with-file (current-buffer))))))

;;; ── Window (NEW) ──────────────────────────────────────────────────────────

(defun init-dwim-window-provider ()
  "Return window management actions."
  (list
   (init-dwim-make-action
    :title "Split window right"
    :description "Split the current window horizontally"
    :category "Window"
    :priority 80
    :action (lambda () (split-window-right) (other-window 1)))

   (init-dwim-make-action
    :title "Split window below"
    :description "Split the current window vertically"
    :category "Window"
    :priority 78
    :action (lambda () (split-window-below) (other-window 1)))

   (init-dwim-make-action
    :title "Delete window"
    :description "Close the current window"
    :category "Window"
    :priority 75
    :predicate (lambda () (> (length (window-list)) 1))
    :action (lambda () (delete-window)))

   (init-dwim-make-action
    :title "Delete other windows"
    :description "Make the current window fill the frame"
    :category "Window"
    :priority 72
    :predicate (lambda () (> (length (window-list)) 1))
    :action (lambda () (delete-other-windows)))

   (init-dwim-make-action
    :title "Balance windows"
    :description "Make all windows the same size"
    :category "Window"
    :priority 65
    :predicate (lambda () (> (length (window-list)) 1))
    :action (lambda () (balance-windows)))

   (init-dwim-make-action
    :title "Swap buffers in windows"
    :description "Swap the buffers of the current and the next window"
    :category "Window"
    :priority 60
    :predicate (lambda () (> (length (window-list)) 1))
    :action (lambda ()
              (let* ((this-win (selected-window))
                     (next-win (next-window))
                     (this-buf (window-buffer this-win))
                     (next-buf (window-buffer next-win)))
                (set-window-buffer this-win next-buf)
                (set-window-buffer next-win this-buf)
                (other-window 1))))

   (init-dwim-make-action
    :title "Rotate windows"
    :description "Rotate all visible windows clockwise"
    :category "Window"
    :priority 55
    :predicate (lambda () (> (length (window-list)) 1))
    :action (lambda ()
              (let* ((wins (window-list))
                     (bufs (mapcar #'window-buffer wins)))
                (cl-loop for win in wins
                         for buf in (append (cdr bufs) (list (car bufs)))
                         do (set-window-buffer win buf)))))

   ;; ── Window navigation (moved from personal-provider) ───────────────────

   (init-dwim-make-action
    :title "Other window"
    :description "Move focus to the next window"
    :category "Window"
    :priority 90
    :predicate (lambda () (> (count-windows) 1))
    :action (lambda () (other-window 1)))

   (init-dwim-make-action
    :title "Previous window"
    :description "Move focus to the previous window"
    :category "Window"
    :priority 89
    :predicate (lambda () (> (count-windows) 1))
    :action (lambda () (other-window -1)))

   (init-dwim-make-action
    :title "Windmove left"
    :description "Move to the window on the left"
    :category "Window"
    :priority 86
    :predicate (lambda () (fboundp 'windmove-left))
    :action (lambda () (windmove-left)))

   (init-dwim-make-action
    :title "Windmove right"
    :description "Move to the window on the right"
    :category "Window"
    :priority 85
    :predicate (lambda () (fboundp 'windmove-right))
    :action (lambda () (windmove-right)))

   (init-dwim-make-action
    :title "Windmove up"
    :description "Move to the window above"
    :category "Window"
    :priority 84
    :predicate (lambda () (fboundp 'windmove-up))
    :action (lambda () (windmove-up)))

   (init-dwim-make-action
    :title "Windmove down"
    :description "Move to the window below"
    :category "Window"
    :priority 83
    :predicate (lambda () (fboundp 'windmove-down))
    :action (lambda () (windmove-down)))

   (init-dwim-make-action
    :title "Move buffer to new frame"
    :description "Display the current buffer in a new frame"
    :category "Window"
    :priority 45
    :action (lambda () (make-frame-command)))

   (init-dwim-make-action
    :title "Zoom / toggle frame maximization"
    :description "Maximize or restore the current frame"
    :category "Window"
    :priority 42
    :action (lambda ()
              (cond
               ((fboundp 'toggle-frame-maximized)
                (toggle-frame-maximized))
               (t
                (set-frame-parameter nil 'fullscreen
                                     (if (frame-parameter nil 'fullscreen)
                                         nil 'maximized))))))))

;;; ── Bookmark (NEW) ────────────────────────────────────────────────────────

(defun init-dwim-bookmark-provider ()
  "Return bookmark management actions."
  (list
   (init-dwim-make-action
    :title "Set bookmark"
    :description "Create a bookmark at the current position"
    :category "Bookmark"
    :priority 80
    :action (lambda () (call-interactively #'bookmark-set)))

   (init-dwim-make-action
    :title "Jump to bookmark"
    :description "Jump to a previously set bookmark"
    :category "Bookmark"
    :priority 78
    :action (lambda ()
              (if (fboundp 'consult-bookmark)
                  (consult-bookmark)
                (call-interactively #'bookmark-jump))))

   (init-dwim-make-action
    :title "List bookmarks"
    :description "Open the bookmark list buffer"
    :category "Bookmark"
    :priority 70
    :action (lambda () (bookmark-bmenu-list)))

   (init-dwim-make-action
    :title "Delete bookmark"
    :description "Delete a named bookmark"
    :category "Bookmark"
    :priority 55
    :action (lambda () (call-interactively #'bookmark-delete)))

   (init-dwim-make-action
    :title "Save bookmarks"
    :description "Persist all bookmarks to disk"
    :category "Bookmark"
    :priority 45
    :action (lambda () (bookmark-save) (message "Bookmarks saved")))))

;;; ── Snippet (NEW) ─────────────────────────────────────────────────────────

(defun init-dwim-snippet-provider ()
  "Return snippet / abbreviation actions."
  (list
   (init-dwim-make-action
    :title "Expand snippet"
    :description "Expand a yasnippet at point"
    :category "Snippet"
    :priority 85
    :predicate (lambda () (and (fboundp 'yas-expand)
                               (boundp 'yas-minor-mode)
                               yas-minor-mode))
    :action (lambda () (yas-expand)))

   (init-dwim-make-action
    :title "Insert snippet"
    :description "Choose and insert a yasnippet"
    :category "Snippet"
    :priority 80
    :predicate (lambda () (and (fboundp 'yas-insert-snippet)
                               (boundp 'yas-minor-mode)
                               yas-minor-mode))
    :action (lambda () (call-interactively #'yas-insert-snippet)))

   (init-dwim-make-action
    :title "New snippet"
    :description "Create a new yasnippet for the current mode"
    :category "Snippet"
    :priority 55
    :predicate (lambda () (fboundp 'yas-new-snippet))
    :action (lambda () (yas-new-snippet)))

   (init-dwim-make-action
    :title "Expand abbrev"
    :description "Expand the abbreviation at point"
    :category "Snippet"
    :priority 70
    :action (lambda () (expand-abbrev)))

   (init-dwim-make-action
    :title "Define word abbrev"
    :description "Interactively define a new word abbreviation"
    :category "Snippet"
    :priority 48
    :action (lambda () (call-interactively #'define-global-abbrev)))))

;;; ── Smerge (NEW) ──────────────────────────────────────────────────────────

(defun init-dwim-smerge-provider ()
  "Return smerge conflict-resolution actions when inside a conflict."
  (when (and (fboundp 'smerge-mode)
             (or (bound-and-true-p smerge-mode)
                 (save-excursion
                   (goto-char (point-min))
                   (re-search-forward "^<<<<<<" nil t))))
    (list
     (init-dwim-make-action
      :title "Keep mine (upper/ours)"
      :description "Resolve conflict by accepting the upper (ours) version"
      :category "Conflict"
      :priority 100
      :predicate (lambda () (fboundp 'smerge-keep-mine))
      :action (lambda () (smerge-keep-mine)))

     (init-dwim-make-action
      :title "Keep theirs (lower)"
      :description "Resolve conflict by accepting the lower (theirs) version"
      :category "Conflict"
      :priority 98
      :predicate (lambda () (fboundp 'smerge-keep-other))
      :action (lambda () (smerge-keep-other)))

     (init-dwim-make-action
      :title "Keep base"
      :description "Resolve conflict by accepting the base version"
      :category "Conflict"
      :priority 95
      :predicate (lambda () (fboundp 'smerge-keep-base))
      :action (lambda () (smerge-keep-base)))

     (init-dwim-make-action
      :title "Keep all (combine)"
      :description "Resolve conflict by keeping all variants"
      :category "Conflict"
      :priority 90
      :predicate (lambda () (fboundp 'smerge-keep-all))
      :action (lambda () (smerge-keep-all)))

     (init-dwim-make-action
      :title "Resolve with Ediff"
      :description "Open Ediff to resolve this conflict interactively"
      :category "Conflict"
      :priority 85
      :predicate (lambda () (fboundp 'smerge-ediff))
      :action (lambda () (smerge-ediff)))

     (init-dwim-make-action
      :title "Next conflict"
      :description "Jump to the next merge conflict in the buffer"
      :category "Conflict"
      :priority 80
      :predicate (lambda () (fboundp 'smerge-next))
      :action (lambda () (smerge-next)))

     (init-dwim-make-action
      :title "Previous conflict"
      :description "Jump to the previous merge conflict in the buffer"
      :category "Conflict"
      :priority 78
      :predicate (lambda () (fboundp 'smerge-prev))
      :action (lambda () (smerge-prev)))

     (init-dwim-make-action
      :title "Auto-resolve all"
      :description "Automatically resolve all unambiguous conflicts"
      :category "Conflict"
      :priority 60
      :predicate (lambda () (fboundp 'smerge-resolve-all))
      :action (lambda () (smerge-resolve-all)
                (message "Auto-resolved conflicts"))))))

;;; ── Diff / Patch (NEW) ────────────────────────────────────────────────────

(defun init-dwim-diff-provider ()
  "Return actions relevant to diff and patch buffers."
  (when (or (derived-mode-p 'diff-mode)
            (derived-mode-p 'ediff-mode))
    (list
     (init-dwim-make-action
      :title "Apply patch"
      :description "Apply the current diff/patch to a file"
      :category "Diff"
      :priority 100
      :predicate (lambda () (fboundp 'diff-apply-hunk))
      :action (lambda () (call-interactively #'diff-apply-hunk)))

     (init-dwim-make-action
      :title "Reverse patch"
      :description "Reverse-apply (undo) the hunk at point"
      :category "Diff"
      :priority 90
      :predicate (lambda () (fboundp 'diff-apply-hunk))
      :action (lambda () (diff-apply-hunk t)))

     (init-dwim-make-action
      :title "Jump to source"
      :description "Jump to the source file location for the hunk at point"
      :category "Diff"
      :priority 85
      :predicate (lambda () (fboundp 'diff-goto-source))
      :action (lambda () (diff-goto-source)))

     (init-dwim-make-action
      :title "Next hunk"
      :description "Move to the next diff hunk"
      :category "Diff"
      :priority 80
      :predicate (lambda () (fboundp 'diff-hunk-next))
      :action (lambda () (diff-hunk-next)))

     (init-dwim-make-action
      :title "Previous hunk"
      :description "Move to the previous diff hunk"
      :category "Diff"
      :priority 78
      :predicate (lambda () (fboundp 'diff-hunk-prev))
      :action (lambda () (diff-hunk-prev)))

     (init-dwim-make-action
      :title "Copy hunk"
      :description "Copy the hunk at point to the kill ring"
      :category "Diff"
      :priority 65
      :predicate (lambda () (fboundp 'diff-bounds-of-hunk))
      :action (lambda ()
                (let ((bounds (diff-bounds-of-hunk)))
                  (kill-new (buffer-substring-no-properties
                             (car bounds) (cdr bounds)))
                  (message "Hunk copied")))))))

;;; ── Help buffers (NEW) ────────────────────────────────────────────────────

(defun init-dwim-help-provider ()
  "Return actions relevant to help and messages buffers."
  (when (or (derived-mode-p 'help-mode)
            (string= (buffer-name) "*Messages*")
            (string= (buffer-name) "*Warnings*"))
    (list
     (init-dwim-make-action
      :title "Copy buffer to kill ring"
      :description "Copy entire help/messages text"
      :category "Help"
      :priority 90
      :action (lambda ()
                (kill-new (buffer-substring-no-properties (point-min) (point-max)))
                (message "Help buffer contents copied")))

     (init-dwim-make-action
      :title "Follow link at point"
      :description "Follow the help cross-reference link at point"
      :category "Help"
      :priority 85
      :predicate (lambda ()
                   (and (derived-mode-p 'help-mode)
                        (fboundp 'push-button)))
      :action (lambda () (push-button)))

     (init-dwim-make-action
      :title "Go back in help history"
      :description "Navigate back in the help buffer history"
      :category "Help"
      :priority 80
      :predicate (lambda ()
                   (and (derived-mode-p 'help-mode)
                        (fboundp 'help-go-back)))
      :action (lambda () (help-go-back)))

     (init-dwim-make-action
      :title "Clear messages"
      :description "Erase the *Messages* buffer"
      :category "Help"
      :priority 70
      :predicate (lambda () (string= (buffer-name) "*Messages*"))
      :action (lambda ()
                (let ((inhibit-read-only t))
                  (erase-buffer))
                (message "Messages cleared")))

     (init-dwim-make-action
      :title "Search in buffer"
      :description "Incremental search within the help buffer"
      :category "Help"
      :priority 65
      :action (lambda () (call-interactively #'isearch-forward))))))

;;; ── Evil (NEW) ────────────────────────────────────────────────────────────

(defun init-dwim-evil-provider ()
  "Return actions specific to Evil-mode when it is active."
  (when (and (boundp 'evil-mode) evil-mode)
    (list
     (init-dwim-make-action
      :title "Normal state"
      :description "Switch to Evil normal state"
      :category "Evil"
      :priority 90
      :predicate (lambda () (fboundp 'evil-normal-state))
      :action (lambda () (evil-normal-state)))

     (init-dwim-make-action
      :title "Visual line state"
      :description "Enter Evil visual-line mode"
      :category "Evil"
      :priority 80
      :predicate (lambda () (fboundp 'evil-visual-line))
      :action (lambda () (evil-visual-line)))

     (init-dwim-make-action
      :title "Record macro"
      :description "Start recording an Evil macro (q)"
      :category "Evil"
      :priority 75
      :predicate (lambda () (fboundp 'evil-record-macro))
      :action (lambda () (call-interactively #'evil-record-macro)))

     (init-dwim-make-action
      :title "Execute macro"
      :description "Execute the last recorded Evil macro"
      :category "Evil"
      :priority 72
      :predicate (lambda () (fboundp 'evil-execute-macro))
      :action (lambda () (call-interactively #'evil-execute-macro)))

     (init-dwim-make-action
      :title "Jump to mark"
      :description "Jump to an Evil mark"
      :category "Evil"
      :priority 68
      :predicate (lambda () (fboundp 'evil-goto-mark))
      :action (lambda () (call-interactively #'evil-goto-mark)))

     (init-dwim-make-action
      :title "Show registers"
      :description "Display Evil / Emacs registers"
      :category "Evil"
      :priority 60
      :action (lambda () (view-register nil)))

     (init-dwim-make-action
      :title "Toggle Evil-mode"
      :description "Enable or disable Evil-mode in this buffer"
      :category "Evil"
      :priority 40
      :action (lambda () (evil-mode 'toggle)))

     (init-dwim-make-action
      :title "Set mark"
      :description "Set an Evil mark at point (prompted for register)"
      :category "Evil"
      :priority 65
      :predicate (lambda () (fboundp 'evil-set-marker))
      :action (lambda () (call-interactively #'evil-set-marker)))

     (init-dwim-make-action
      :title "Join lines"
      :description "Join the current line with the line below (Evil J)"
      :category "Evil"
      :priority 62
      :predicate (lambda () (fboundp 'evil-join))
      :action (lambda () (call-interactively #'evil-join))))))

;;; ── AI (NEW) ──────────────────────────────────────────────────────────────

(defun init-dwim-ai-provider ()
  "Return AI-backend actions when a supported backend is available."
  (when (init-dwim--ai-available-p)
    (list
     (init-dwim-make-action
      :title "Open AI chat"
      :description "Open an AI chat buffer (gptel or ellama)"
      :category "AI"
      :priority 70
      :action (lambda ()
                (cond
                 ((fboundp 'gptel)
                  (gptel "*init-dwim-ai*"))
                 ((fboundp 'ellama-chat)
                  (ellama-chat))
                 (t
                  (user-error "No AI chat command available")))))

     (init-dwim-make-action
      :title "Ask AI about buffer"
      :description "Send the entire buffer to the AI for analysis"
      :category "AI"
      :priority 65
      :action (lambda ()
                (let ((prompt (read-string "Ask AI: " "Summarize or review this: ")))
                  (init-dwim--ai-send-region (point-min) (point-max) prompt))))

     (init-dwim-make-action
      :title "Ask AI about symbol"
      :description "Ask the AI to explain the symbol at point"
      :category "AI"
      :priority 62
      :predicate (lambda () (init-dwim--symbol-string))
      :action (lambda ()
                (let* ((sym (init-dwim--symbol-string))
                       (prompt (format "Explain `%s` in the context of %s:"
                                       sym major-mode)))
                  (init-dwim--ai-send-region
                   (or (car (bounds-of-thing-at-point 'symbol)) (point))
                   (or (cdr (bounds-of-thing-at-point 'symbol)) (point))
                   prompt))))

     (init-dwim-make-action
      :title "AI: fix current error"
      :description "Send the error at point and surrounding context to AI for a fix suggestion"
      :category "AI"
      :priority 60
      :predicate (lambda ()
                   (and (derived-mode-p 'prog-mode)
                        (or (and (boundp 'flycheck-mode) flycheck-mode)
                            (and (boundp 'flymake-mode) flymake-mode))))
      :action (lambda ()
                (let* ((beg (line-beginning-position))
                       (end (min (point-max) (+ beg 500)))
                       (prompt "Suggest a fix for the error in this code:"))
                  (init-dwim--ai-send-region beg end prompt))))

     (init-dwim-make-action
      :title "AI: generate docstring"
      :description "Ask AI to generate a docstring for the function at point"
      :category "AI"
      :priority 58
      :predicate (lambda () (derived-mode-p 'prog-mode))
      :action (lambda ()
                (save-excursion
                  (beginning-of-defun)
                  (let* ((beg (point))
                         (end (save-excursion (end-of-defun) (point)))
                         (prompt "Write a concise docstring for this function:"))
                    (init-dwim--ai-send-region beg end prompt)))))

     (init-dwim-make-action
      :title "AI: write unit tests for defun"
      :description "Ask AI to generate unit tests for the function at point"
      :category "AI"
      :priority 55
      :predicate (lambda () (derived-mode-p 'prog-mode))
      :action (lambda ()
                (save-excursion
                  (beginning-of-defun)
                  (let* ((beg (point))
                         (end (save-excursion (end-of-defun) (point)))
                         (prompt (format "Write unit tests for this %s function:"
                                         major-mode)))
                    (init-dwim--ai-send-region beg end prompt)))))

     (init-dwim-make-action
      :title "AI: explain error in *Messages*"
      :description "Send the last error message to AI for an explanation"
      :category "AI"
      :priority 56
      :action (lambda ()
                (let* ((msgs (with-current-buffer "*Messages*"
                               (buffer-substring-no-properties
                                (max (point-min) (- (point-max) 1000))
                                (point-max))))
                       (prompt "Explain this Emacs error and how to fix it:"))
                  (init-dwim--ai-send-region
                   (with-current-buffer "*Messages*"
                     (max (point-min) (- (point-max) 1000)))
                   (with-current-buffer "*Messages*" (point-max))
                   prompt)
                  (ignore msgs))))

     (init-dwim-make-action
      :title "AI: suggest commit message"
      :description "Ask AI to write a commit message from the staged diff"
      :category "AI"
      :priority 54
      :predicate (lambda ()
                   (and (fboundp 'magit-git-string)
                        (init-dwim--project-root)))
      :action (lambda ()
                (let* ((diff (shell-command-to-string
                              (format "git -C %s diff --cached"
                                      (shell-quote-argument
                                       (init-dwim--project-root)))))
                       (prompt "Write a concise git commit message for this diff:"))
                  (if (string-empty-p (string-trim diff))
                      (user-error "No staged changes to generate a message for")
                    (let ((buf (get-buffer-create "*init-dwim-gptel*")))
                      (with-current-buffer buf
                        (unless (eq major-mode 'org-mode) (org-mode))
                        (goto-char (point-max))
                        (insert "\n" prompt "\n\n#+begin_src diff\n" diff "#+end_src\n"))
                      (pop-to-buffer buf)
                      (when (fboundp 'gptel-send) (gptel-send))))))))))

;;; ── Output / compilation buffers

(defun init-dwim-output-buffer-provider ()
  "Return actions relevant to grep, compilation, and xref result buffers."
  (when (or (derived-mode-p 'compilation-mode)
            (derived-mode-p 'grep-mode)
            (derived-mode-p 'xref--xref-buffer-mode))
    (list
     (init-dwim-make-action
      :title "Jump to match"
      :description "Visit the file location of the match at point"
      :category "Output"
      :priority 100
      :action (lambda ()
                (cond
                 ((derived-mode-p 'grep-mode 'compilation-mode)
                  (compile-goto-error))
                 ((derived-mode-p 'xref--xref-buffer-mode)
                  (xref-goto-xref))
                 (t
                  (user-error "Cannot jump from this buffer")))))

     (init-dwim-make-action
      :title "Next match"
      :description "Move to the next result in the output buffer"
      :category "Output"
      :priority 95
      :action (lambda ()
                (cond
                 ((derived-mode-p 'compilation-mode 'grep-mode)
                  (compilation-next-error 1))
                 ((derived-mode-p 'xref--xref-buffer-mode)
                  (xref-next-line))
                 (t
                  (user-error "No next-match command available")))))

     (init-dwim-make-action
      :title "Previous match"
      :description "Move to the previous result in the output buffer"
      :category "Output"
      :priority 93
      :action (lambda ()
                (cond
                 ((derived-mode-p 'compilation-mode 'grep-mode)
                  (compilation-previous-error 1))
                 ((derived-mode-p 'xref--xref-buffer-mode)
                  (xref-prev-line))
                 (t
                  (user-error "No previous-match command available")))))

     (init-dwim-make-action
      :title "Rerun / recompile"
      :description "Re-run the last compilation or grep command"
      :category "Output"
      :priority 85
      :predicate (lambda () (fboundp 'recompile))
      :action (lambda () (recompile)))

     (init-dwim-make-action
      :title "Kill process"
      :description "Kill the running compilation/grep process"
      :category "Output"
      :priority 70
      :predicate (lambda ()
                   (and (derived-mode-p 'compilation-mode)
                        (get-buffer-process (current-buffer))))
      :action (lambda ()
                (kill-compilation)
                (message "Compilation process killed")))

     (init-dwim-make-action
      :title "Copy all matches"
      :description "Copy the entire output buffer to the kill ring"
      :category "Output"
      :priority 60
      :action (lambda ()
                (kill-new (buffer-substring-no-properties (point-min) (point-max)))
                (message "Output buffer copied")))

     (init-dwim-make-action
      :title "Search in results"
      :description "Incremental search within the results buffer"
      :category "Output"
      :priority 55
      :action (lambda () (call-interactively #'isearch-forward))))))

;;; ── Tab bar (NEW) ─────────────────────────────────────────────────────────

(defun init-dwim-tab-bar-provider ()
  "Return tab-bar actions when `tab-bar-mode' is active."
  (when (and (fboundp 'tab-bar-mode)
             (bound-and-true-p tab-bar-mode))
    (list
     (init-dwim-make-action
      :title "New tab"
      :description "Create a new tab-bar tab"
      :category "Tab"
      :priority 80
      :action (lambda () (tab-bar-new-tab)))

     (init-dwim-make-action
      :title "Switch tab"
      :description "Switch to another tab by name"
      :category "Tab"
      :priority 78
      :predicate (lambda () (fboundp 'tab-bar-switch-to-tab))
      :action (lambda () (call-interactively #'tab-bar-switch-to-tab)))

     (init-dwim-make-action
      :title "Close tab"
      :description "Close the current tab-bar tab"
      :category "Tab"
      :priority 72
      :action (lambda () (tab-bar-close-tab)))

     (init-dwim-make-action
      :title "Rename tab"
      :description "Rename the current tab-bar tab"
      :category "Tab"
      :priority 68
      :predicate (lambda () (fboundp 'tab-bar-rename-tab))
      :action (lambda () (call-interactively #'tab-bar-rename-tab)))

     (init-dwim-make-action
      :title "Duplicate tab"
      :description "Duplicate the current tab-bar tab"
      :category "Tab"
      :priority 60
      :predicate (lambda () (fboundp 'tab-bar-duplicate-tab))
      :action (lambda () (tab-bar-duplicate-tab)))

     (init-dwim-make-action
      :title "Undo closed tab"
      :description "Re-open the last closed tab"
      :category "Tab"
      :priority 55
      :predicate (lambda () (fboundp 'tab-bar-undo-close-tab))
      :action (lambda () (tab-bar-undo-close-tab))))))

;;; ── Registers (NEW) ───────────────────────────────────────────────────────

(defun init-dwim-register-provider ()
  "Return register / rectangle actions."
  (list
   (init-dwim-make-action
    :title "Save point to register"
    :description "Record the current position in a register"
    :category "Register"
    :priority 75
    :action (lambda ()
              (let ((reg (read-char "Register: ")))
                (point-to-register reg)
                (message "Point saved to register %c" reg))))

   (init-dwim-make-action
    :title "Jump to register"
    :description "Jump to a position saved in a register"
    :category "Register"
    :priority 73
    :action (lambda ()
              (let ((reg (read-char "Jump to register: ")))
                (jump-to-register reg))))

   (init-dwim-make-action
    :title "Copy region to register"
    :description "Save the selected region text into a register"
    :category "Register"
    :priority 70
    :predicate #'init-dwim--region-active-p
    :action (lambda ()
              (let ((reg (read-char "Register: ")))
                (copy-to-register reg (region-beginning) (region-end))
                (message "Region copied to register %c" reg))))

   (init-dwim-make-action
    :title "Insert register"
    :description "Insert the contents of a register at point"
    :category "Register"
    :priority 68
    :action (lambda ()
              (let ((reg (read-char "Insert register: ")))
                (insert-register reg))))

   (init-dwim-make-action
    :title "List registers"
    :description "Show all saved registers"
    :category "Register"
    :priority 60
    :action (lambda () (list-registers)))

   (init-dwim-make-action
    :title "Copy rectangle to register"
    :description "Save a rectangle (column selection) to a register"
    :category "Register"
    :priority 50
    :predicate #'init-dwim--region-active-p
    :action (lambda ()
              (let ((reg (read-char "Rectangle register: ")))
                (copy-rectangle-to-register
                 reg (region-beginning) (region-end))
                (message "Rectangle saved to register %c" reg))))))

;;; ── Spelling / prose (NEW) ────────────────────────────────────────────────

(defun init-dwim-spelling-provider ()
  "Return spelling and prose-quality actions."
  (when (or (derived-mode-p 'text-mode)
            (derived-mode-p 'org-mode)
            (derived-mode-p 'markdown-mode)
            ;; Also offer in prog-mode for comments / strings
            (derived-mode-p 'prog-mode))
    (list
     (init-dwim-make-action
      :title "Check spelling (Ispell)"
      :description "Run Ispell spell checker on the buffer or region"
      :category "Spell"
      :priority 80
      :predicate (lambda () (fboundp 'ispell))
      :action (lambda ()
                (if (use-region-p)
                    (ispell-region (region-beginning) (region-end))
                  (ispell))))

     (init-dwim-make-action
      :title "Correct word at point"
      :description "Interactively correct the misspelled word at point"
      :category "Spell"
      :priority 90
      :predicate (lambda () (fboundp 'ispell-word))
      :action (lambda () (ispell-word)))

     (init-dwim-make-action
      :title "Toggle flyspell"
      :description "Enable or disable flyspell in this buffer"
      :category "Spell"
      :priority 70
      :predicate (lambda () (fboundp 'flyspell-mode))
      :action (lambda ()
                (flyspell-mode 'toggle)
                (message "Flyspell %s"
                         (if (bound-and-true-p flyspell-mode) "on" "off"))))

     (init-dwim-make-action
      :title "Flyspell buffer"
      :description "Run flyspell over the whole buffer"
      :category "Spell"
      :priority 65
      :predicate (lambda () (fboundp 'flyspell-buffer))
      :action (lambda () (flyspell-buffer)))

     (init-dwim-make-action
      :title "Next spelling error"
      :description "Jump to the next flyspell error"
      :category "Spell"
      :priority 75
      :predicate (lambda ()
                   (and (fboundp 'flyspell-goto-next-error)
                        (bound-and-true-p flyspell-mode)))
      :action (lambda () (flyspell-goto-next-error)))

     (init-dwim-make-action
      :title "Change dictionary"
      :description "Select the Ispell dictionary to use"
      :category "Spell"
      :priority 50
      :predicate (lambda () (fboundp 'ispell-change-dictionary))
      :action (lambda () (call-interactively #'ispell-change-dictionary)))

     (init-dwim-make-action
      :title "Check grammar (langtool)"
      :description "Run LanguageTool grammar check on the buffer"
      :category "Spell"
      :priority 60
      :predicate (lambda () (fboundp 'langtool-check))
      :action (lambda ()
                (if (use-region-p)
                    (langtool-check (region-beginning) (region-end))
                  (langtool-check)))))))

;;; ── Macro / keyboard (NEW) ────────────────────────────────────────────────

(defun init-dwim-macro-provider ()
  "Return keyboard macro and repeat actions."
  (list
   (init-dwim-make-action
    :title "Start keyboard macro"
    :description "Begin recording a keyboard macro"
    :category "Macro"
    :priority 75
    :predicate (lambda () (not defining-kbd-macro))
    :action (lambda () (kmacro-start-macro nil)
              (message "Keyboard macro recording started — press init-dwim → End macro when done")))

   (init-dwim-make-action
    :title "End keyboard macro"
    :description "Stop recording the current keyboard macro"
    :category "Macro"
    :priority 90
    :predicate (lambda () defining-kbd-macro)
    :action (lambda () (kmacro-end-macro nil)))

   (init-dwim-make-action
    :title "Execute last macro"
    :description "Run the last recorded keyboard macro"
    :category "Macro"
    :priority 80
    :predicate (lambda () (and (not defining-kbd-macro)
                               last-kbd-macro))
    :action (lambda () (call-interactively #'kmacro-call-macro)))

   (init-dwim-make-action
    :title "Name last macro"
    :description "Assign a name to the last keyboard macro"
    :category "Macro"
    :priority 60
    :predicate (lambda () (and last-kbd-macro
                               (not defining-kbd-macro)))
    :action (lambda () (call-interactively #'kmacro-name-last-macro)))

   (init-dwim-make-action
    :title "Edit keyboard macro"
    :description "Open the last macro in an editable buffer"
    :category "Macro"
    :priority 55
    :predicate (lambda () (and last-kbd-macro
                               (not defining-kbd-macro)
                               (fboundp 'edit-kbd-macro)))
    :action (lambda () (edit-kbd-macro (kbd "C-x e"))))

   (init-dwim-make-action
    :title "Repeat last command"
    :description "Repeat the most recently executed command"
    :category "Macro"
    :priority 45
    :action (lambda () (call-interactively #'repeat)))))

;;; ── Narrowing / focus (NEW) ───────────────────────────────────────────────

(defun init-dwim-narrow-provider ()
  "Return narrowing and focus actions."
  (list
   (init-dwim-make-action
    :title "Narrow to region"
    :description "Show only the selected region"
    :category "Narrow"
    :priority 85
    :predicate #'init-dwim--region-active-p
    :action (lambda ()
              (narrow-to-region (region-beginning) (region-end))))

   (init-dwim-make-action
    :title "Narrow to defun"
    :description "Show only the current function definition"
    :category "Narrow"
    :priority 80
    :predicate (lambda ()
                 (and (derived-mode-p 'prog-mode)
                      (not (buffer-narrowed-p))))
    :action (lambda () (narrow-to-defun)))

   (init-dwim-make-action
    :title "Narrow to page"
    :description "Show only the current page (delimited by ^L)"
    :category "Narrow"
    :priority 70
    :predicate (lambda () (not (buffer-narrowed-p)))
    :action (lambda () (narrow-to-page)))

   (init-dwim-make-action
    :title "Widen (remove narrowing)"
    :description "Restore the full buffer view"
    :category "Narrow"
    :priority 95
    :predicate (lambda () (buffer-narrowed-p))
    :action (lambda () (widen) (message "Buffer widened")))

   (init-dwim-make-action
    :title "Toggle narrowing"
    :description "Toggle between narrowed and widened view"
    :category "Narrow"
    :priority 75
    :action (lambda ()
              (if (buffer-narrowed-p)
                  (widen)
                (cond
                 ((derived-mode-p 'prog-mode) (narrow-to-defun))
                 ((use-region-p)
                  (narrow-to-region (region-beginning) (region-end)))
                 (t (narrow-to-page))))))

   (init-dwim-make-action
    :title "Indirect buffer to region"
    :description "Open a new indirect buffer showing only the selected region"
    :category "Narrow"
    :priority 68
    :predicate #'init-dwim--region-active-p
    :action (lambda ()
              (let ((beg (region-beginning))
                    (end (region-end)))
                (clone-indirect-buffer nil t)
                (narrow-to-region beg end)
                (message "Indirect buffer narrowed to region"))))))

;;; ── Shell / terminal (NEW) ────────────────────────────────────────────────

(defun init-dwim-shell-provider ()
  "Return shell/terminal actions."
  (list
   (init-dwim-make-action
    :title "Open eshell"
    :description "Open an eshell buffer"
    :category "Shell"
    :priority 70
    :action (lambda () (eshell)))

   (init-dwim-make-action
    :title "Open vterm"
    :description "Open a vterm terminal buffer"
    :category "Shell"
    :priority 68
    :predicate (lambda () (fboundp 'vterm))
    :action (lambda () (vterm)))

   (init-dwim-make-action
    :title "Run shell command"
    :description "Run a shell command and show output"
    :category "Shell"
    :priority 65
    :action (lambda () (call-interactively #'shell-command)))

   (init-dwim-make-action
    :title "Run shell command on region"
    :description "Pass the selected region through a shell command"
    :category "Shell"
    :priority 62
    :predicate #'init-dwim--region-active-p
    :action (lambda ()
              (call-interactively #'shell-command-on-region)))

   (init-dwim-make-action
    :title "Async shell command"
    :description "Run a shell command asynchronously"
    :category "Shell"
    :priority 58
    :action (lambda () (call-interactively #'async-shell-command)))

   (init-dwim-make-action
    :title "Send line to eshell"
    :description "Send the current line to a running eshell"
    :category "Shell"
    :priority 55
    :predicate (lambda () (get-buffer "*eshell*"))
    :action (lambda ()
              (let ((line (buffer-substring-no-properties
                           (line-beginning-position)
                           (line-end-position))))
                (with-current-buffer "*eshell*"
                  (goto-char (point-max))
                  (insert line)
                  (eshell-send-input))
                (pop-to-buffer "*eshell*"))))

   (init-dwim-make-action
    :title "Insert shell command output"
    :description "Run a command and insert its stdout at point"
    :category "Shell"
    :priority 50
    :action (lambda ()
              (let ((cmd (read-shell-command "Insert output of: ")))
                (insert (shell-command-to-string cmd)))))

   (init-dwim-make-action
    :title "Run make target"
    :description "Choose and run a target from the project Makefile"
    :category "Shell"
    :priority 63
    :predicate (lambda ()
                 (let ((mk (and (init-dwim--project-root)
                                (expand-file-name "Makefile"
                                                  (init-dwim--project-root)))))
                   (and mk (file-exists-p mk))))
    :action (lambda ()
              (let* ((root (init-dwim--project-root))
                     (mk (expand-file-name "Makefile" root))
                     (targets
                      (with-temp-buffer
                        (call-process "make" nil t nil "-qp" "-f" mk)
                        (let (ts)
                          (goto-char (point-min))
                          (while (re-search-forward "^\\([a-zA-Z0-9_%-]+\\):" nil t)
                            (push (match-string 1) ts))
                          (delete-dups (nreverse ts)))))
                     (target (completing-read "Make target: " targets nil t)))
                (compile (format "make -C %s %s"
                                 (shell-quote-argument root)
                                 (shell-quote-argument target))))))))

;;; ── Emacs meta-actions (NEW) ──────────────────────────────────────────────

(defun init-dwim-emacs-provider ()
  "Return general Emacs meta-actions."
  (list
   (init-dwim-make-action
    :title "Execute command (M-x)"
    :description "Run any Emacs command by name"
    :category "Emacs"
    :priority 50
    :action (lambda () (call-interactively #'execute-extended-command)))

   (init-dwim-make-action
    :title "Describe key"
    :description "Show the command bound to a key sequence"
    :category "Emacs"
    :priority 48
    :action (lambda () (call-interactively #'describe-key)))

   (init-dwim-make-action
    :title "Describe function"
    :description "Show documentation for a function"
    :category "Emacs"
    :priority 46
    :action (lambda () (call-interactively #'describe-function)))

   (init-dwim-make-action
    :title "Describe variable"
    :description "Show documentation for a variable"
    :category "Emacs"
    :priority 44
    :action (lambda () (call-interactively #'describe-variable)))

   (init-dwim-make-action
    :title "Open init file"
    :description "Visit your Emacs init file"
    :category "Emacs"
    :priority 40
    :action (lambda () (find-file user-init-file)))

   (init-dwim-make-action
    :title "Reload init file"
    :description "Re-evaluate your Emacs init file"
    :category "Emacs"
    :priority 35
    :action (lambda ()
              (when (yes-or-no-p "Reload init file? ")
                (load-file user-init-file)
                (message "Init file reloaded"))))

   (init-dwim-make-action
    :title "Open Customize"
    :description "Open the Emacs customization interface"
    :category "Emacs"
    :priority 30
    :action (lambda () (call-interactively #'customize-group)))

   (init-dwim-make-action
    :title "Toggle line numbers"
    :description "Toggle display-line-numbers-mode"
    :category "Emacs"
    :priority 35
    :action (lambda () (display-line-numbers-mode 'toggle)))

   (init-dwim-make-action
    :title "Toggle truncate lines"
    :description "Toggle whether long lines are truncated or wrapped"
    :category "Emacs"
    :priority 33
    :action (lambda () (toggle-truncate-lines)))

   (init-dwim-make-action
    :title "Set font size"
    :description "Interactively change the font size"
    :category "Emacs"
    :priority 28
    :action (lambda ()
              (let ((size (read-number "Font size (pt): "
                                       (/ (face-attribute 'default :height) 10))))
                (set-face-attribute 'default nil :height (* size 10))
                (message "Font size set to %dpt" size))))

   (init-dwim-make-action
    :title "garbage-collect"
    :description "Run a manual garbage collection cycle"
    :category "Emacs"
    :priority 20
    :action (lambda ()
              (message "GC freed %s" (garbage-collect))))

   (init-dwim-make-action
    :title "Toggle theme"
    :description "Load a different color theme interactively"
    :category "Emacs"
    :priority 25
    :action (lambda ()
              (let ((theme (intern
                            (completing-read "Load theme: "
                                             (mapcar #'symbol-name
                                                     (custom-available-themes))))))
                (mapc #'disable-theme custom-enabled-themes)
                (load-theme theme t)
                (message "Loaded theme: %s" theme))))

   (init-dwim-make-action
    :title "Open recent file"
    :description "Visit a recently opened file"
    :category "Emacs"
    :priority 45
    :predicate (lambda () (or (fboundp 'consult-recent-file)
                              (fboundp 'recentf-open-files)))
    :action (lambda ()
              (if (fboundp 'consult-recent-file)
                  (consult-recent-file)
                (recentf-open-files))))

   (init-dwim-make-action
    :title "Evaluate expression"
    :description "Evaluate an Elisp expression (M-:)"
    :category "Emacs"
    :priority 42
    :action (lambda () (call-interactively #'eval-expression)))))

(defun init-dwim-session-provider ()
  "Always-available session-level DWIM actions."
  (list
   (init-dwim-make-action
    :title "Save buffers and quit Emacs"
    :description "Run `save-buffers-kill-terminal'"
    :category "Session"
    :priority 95
    :action (lambda ()
              (call-interactively #'save-buffers-kill-terminal)))

   (init-dwim-make-action
    :title "Restart Emacs"
    :description "Restart Emacs if `restart-emacs' is available"
    :category "Session"
    :priority 70
    :predicate (lambda () (fboundp 'restart-emacs))
    :action (lambda ()
              (call-interactively #'restart-emacs)))

   (init-dwim-make-action
    :title "Explain DWIM actions"
    :description "Show why DWIM actions are available or filtered out"
    :category "DWIM"
    :priority 120
    :predicate (lambda () (fboundp 'init-dwim-explain))
    :action (lambda ()
              (call-interactively #'init-dwim-explain)))))

;;; ── Git gutter (NEW) ──────────────────────────────────────────────────────

(defun init-dwim-git-gutter-provider ()
  "Return git-gutter hunk actions when git-gutter-mode is active."
  (when (bound-and-true-p git-gutter-mode)
    (list
     (init-dwim-make-action
      :title "Next hunk"
      :description "Jump to the next git-gutter hunk"
      :category "GitGutter"
      :priority 90
      :predicate (lambda () (fboundp 'git-gutter:next-hunk))
      :action (lambda () (git-gutter:next-hunk 1)))

     (init-dwim-make-action
      :title "Previous hunk"
      :description "Jump to the previous git-gutter hunk"
      :category "GitGutter"
      :priority 88
      :predicate (lambda () (fboundp 'git-gutter:previous-hunk))
      :action (lambda () (git-gutter:previous-hunk 1)))

     (init-dwim-make-action
      :title "Stage hunk"
      :description "Stage the hunk at point via git-gutter"
      :category "GitGutter"
      :priority 85
      :predicate (lambda () (fboundp 'git-gutter:stage-hunk))
      :action (lambda () (git-gutter:stage-hunk)))

     (init-dwim-make-action
      :title "Revert hunk"
      :description "Revert the hunk at point to the HEAD version"
      :category "GitGutter"
      :priority 80
      :predicate (lambda () (fboundp 'git-gutter:revert-hunk))
      :action (lambda () (git-gutter:revert-hunk)))

     (init-dwim-make-action
      :title "Popup diff for hunk"
      :description "Show the diff popup for the hunk at point"
      :category "GitGutter"
      :priority 75
      :predicate (lambda () (fboundp 'git-gutter:popup-hunk))
      :action (lambda () (git-gutter:popup-hunk))))))

;;; ── Comint / process buffers (NEW) ────────────────────────────────────────

(defun init-dwim-comint-provider ()
  "Return actions relevant to comint/process buffers."
  (when (derived-mode-p 'comint-mode)
    (list
     (init-dwim-make-action
      :title "Clear process output"
      :description "Erase all output in the comint buffer"
      :category "Comint"
      :priority 80
      :predicate (lambda () (fboundp 'comint-clear-buffer))
      :action (lambda () (comint-clear-buffer)))

     (init-dwim-make-action
      :title "Send input"
      :description "Send the current input line to the process"
      :category "Comint"
      :priority 95
      :action (lambda () (comint-send-input)))

     (init-dwim-make-action
      :title "Interrupt process"
      :description "Send interrupt (C-c) to the running process"
      :category "Comint"
      :priority 90
      :predicate (lambda () (fboundp 'comint-interrupt-subjob))
      :action (lambda () (comint-interrupt-subjob)))

     (init-dwim-make-action
      :title "Kill process"
      :description "Kill the process running in this buffer"
      :category "Comint"
      :priority 70
      :predicate (lambda () (get-buffer-process (current-buffer)))
      :action (lambda ()
                (kill-process (get-buffer-process (current-buffer)))
                (message "Process killed")))

     (init-dwim-make-action
      :title "Copy last output"
      :description "Copy the most recent process output to the kill ring"
      :category "Comint"
      :priority 60
      :action (lambda ()
                (save-excursion
                  (let* ((end (point-max))
                         (beg (save-excursion
                                (goto-char end)
                                (comint-previous-prompt 1)
                                (forward-line 1)
                                (point))))
                    (kill-new (buffer-substring-no-properties beg end))
                    (message "Last output copied")))))

     (init-dwim-make-action
      :title "Search input history"
      :description "Search comint input history with isearch"
      :category "Comint"
      :priority 55
      :predicate (lambda () (fboundp 'comint-history-isearch-backward))
      :action (lambda () (comint-history-isearch-backward))))))

;;; ── Xref navigation (NEW) ─────────────────────────────────────────────────

(defun init-dwim-xref-provider ()
  "Return xref navigation history actions in programming buffers."
  (when (derived-mode-p 'prog-mode)
    (list
     (init-dwim-make-action
      :title "Xref go back"
      :description "Go back to the previous xref location"
      :category "Xref"
      :priority 85
      :predicate (lambda () (fboundp 'xref-go-back))
      :action (lambda () (xref-go-back)))

     (init-dwim-make-action
      :title "Xref go forward"
      :description "Go forward to the next xref location"
      :category "Xref"
      :priority 83
      :predicate (lambda () (fboundp 'xref-go-forward))
      :action (lambda () (xref-go-forward)))

     (init-dwim-make-action
      :title "Find definitions in project"
      :description "Find all definitions of a symbol across the project"
      :category "Xref"
      :priority 78
      :predicate (lambda () (fboundp 'xref-find-definitions))
      :action (lambda ()
                (let ((sym (read-string "Find definitions of: "
                                        (init-dwim--symbol-string))))
                  (xref-find-definitions sym))))

     (init-dwim-make-action
      :title "Find apropos"
      :description "Find symbols matching a pattern via xref-find-apropos"
      :category "Xref"
      :priority 70
      :predicate (lambda () (fboundp 'xref-find-apropos))
      :action (lambda () (call-interactively #'xref-find-apropos))))))

;;; ── Diagnostics (NEW) ─────────────────────────────────────────────────────

(defun init-dwim-diagnostics-provider ()
  "Return diagnostic actions when flycheck or flymake is active."
  (when (or (and (boundp 'flycheck-mode) flycheck-mode)
            (and (boundp 'flymake-mode) flymake-mode))
    (list
     (init-dwim-make-action
      :title "List all errors"
      :description "Show the full diagnostic list for this buffer"
      :category "Diagnostics"
      :priority 90
      :action (lambda ()
                (cond
                 ((and (boundp 'flycheck-mode) flycheck-mode
                       (fboundp 'flycheck-list-errors))
                  (flycheck-list-errors))
                 ((and (boundp 'flymake-mode) flymake-mode
                       (fboundp 'flymake-show-buffer-diagnostics))
                  (flymake-show-buffer-diagnostics))
                 (t (user-error "No diagnostic list available")))))

     (init-dwim-make-action
      :title "Next error"
      :description "Jump to the next diagnostic error"
      :category "Diagnostics"
      :priority 88
      :action (lambda ()
                (cond
                 ((and (boundp 'flycheck-mode) flycheck-mode
                       (fboundp 'flycheck-next-error))
                  (flycheck-next-error))
                 ((and (boundp 'flymake-mode) flymake-mode
                       (fboundp 'flymake-goto-next-error))
                  (flymake-goto-next-error))
                 (t (next-error)))))

     (init-dwim-make-action
      :title "Previous error"
      :description "Jump to the previous diagnostic error"
      :category "Diagnostics"
      :priority 86
      :action (lambda ()
                (cond
                 ((and (boundp 'flycheck-mode) flycheck-mode
                       (fboundp 'flycheck-previous-error))
                  (flycheck-previous-error))
                 ((and (boundp 'flymake-mode) flymake-mode
                       (fboundp 'flymake-goto-prev-error))
                  (flymake-goto-prev-error))
                 (t (previous-error)))))

     (init-dwim-make-action
      :title "Clear diagnostics"
      :description "Dismiss all current diagnostic overlays"
      :category "Diagnostics"
      :priority 60
      :action (lambda ()
                (cond
                 ((and (boundp 'flycheck-mode) flycheck-mode
                       (fboundp 'flycheck-clear))
                  (flycheck-clear))
                 ((and (boundp 'flymake-mode) flymake-mode
                       (fboundp 'flymake-start))
                  ;; flymake has no clear; restart to reset overlays
                  (flymake-start t))
                 (t (user-error "No clear command available")))))

     (init-dwim-make-action
      :title "Toggle checker"
      :description "Enable or disable the active checker in this buffer"
      :category "Diagnostics"
      :priority 55
      :action (lambda ()
                (cond
                 ((and (boundp 'flycheck-mode) flycheck-mode
                       (fboundp 'flycheck-mode))
                  (flycheck-mode 'toggle))
                 ((fboundp 'flymake-mode)
                  (flymake-mode 'toggle)))))

     (init-dwim-make-action
      :title "Explain error at point"
      :description "Show a detailed explanation of the diagnostic at point"
      :category "Diagnostics"
      :priority 82
      :predicate (lambda ()
                   (and (boundp 'flycheck-mode) flycheck-mode
                        (fboundp 'flycheck-explain-error-at-point)))
      :action (lambda () (flycheck-explain-error-at-point))))))

;;; ── Org clock (NEW) ───────────────────────────────────────────────────────

(defun init-dwim-org-clock-provider ()
  "Return Org clock actions when a clock is running."
  (when (and (fboundp 'org-clock-is-active)
             (org-clock-is-active))
    (list
     (init-dwim-make-action
      :title "Clock out"
      :description "Stop the running Org clock"
      :category "OrgClock"
      :priority 100
      :predicate (lambda () (fboundp 'org-clock-out))
      :action (lambda () (org-clock-out)))

     (init-dwim-make-action
      :title "Show current clock"
      :description "Display information about the running clock"
      :category "OrgClock"
      :priority 90
      :predicate (lambda () (fboundp 'org-clock-display))
      :action (lambda ()
                (message "Clocked in: %s (since %s)"
                         (org-clock-get-clocked-time)
                         (format-time-string "%H:%M" org-clock-start-time))))

     (init-dwim-make-action
      :title "Cancel clock"
      :description "Cancel the running clock without recording time"
      :category "OrgClock"
      :priority 80
      :predicate (lambda () (fboundp 'org-clock-cancel))
      :action (lambda () (org-clock-cancel)))

     (init-dwim-make-action
      :title "Jump to clocked task"
      :description "Visit the heading of the currently clocked task"
      :category "OrgClock"
      :priority 75
      :predicate (lambda () (fboundp 'org-clock-goto))
      :action (lambda () (org-clock-goto))))))

;;; ── Isearch (NEW) ─────────────────────────────────────────────────────────

(defun init-dwim-isearch-provider ()
  "Return actions available while an isearch is active."
  (when (bound-and-true-p isearch-mode)
    (list
     (init-dwim-make-action
      :title "Occur from search string"
      :description "Open an occur buffer for the current isearch pattern"
      :category "Isearch"
      :priority 90
      :predicate (lambda () (fboundp 'isearch-occur))
      :action (lambda () (isearch-occur isearch-string)))

     (init-dwim-make-action
      :title "Query-replace from search"
      :description "Switch to query-replace using the current search string"
      :category "Isearch"
      :priority 85
      :predicate (lambda () (fboundp 'isearch-query-replace))
      :action (lambda () (isearch-query-replace)))

     (init-dwim-make-action
      :title "Copy search string"
      :description "Copy the current isearch pattern to the kill ring"
      :category "Isearch"
      :priority 70
      :action (lambda ()
                (kill-new isearch-string)
                (message "Copied search: %s" isearch-string)))

     (init-dwim-make-action
      :title "Exit isearch"
      :description "Exit isearch, leaving point at the current match"
      :category "Isearch"
      :priority 60
      :action (lambda () (isearch-exit))))))

;;; ── Ediff session (NEW) ───────────────────────────────────────────────────

(defun init-dwim-ediff-provider ()
  "Return actions for an active Ediff session."
  (when (bound-and-true-p ediff-mode)
    (list
     (init-dwim-make-action
      :title "Copy A to B"
      :description "Copy the current diff from buffer A to B"
      :category "Ediff"
      :priority 100
      :predicate (lambda () (fboundp 'ediff-copy-A-to-B))
      :action (lambda () (ediff-copy-A-to-B nil)))

     (init-dwim-make-action
      :title "Copy B to A"
      :description "Copy the current diff from buffer B to A"
      :category "Ediff"
      :priority 98
      :predicate (lambda () (fboundp 'ediff-copy-B-to-A))
      :action (lambda () (ediff-copy-B-to-A nil)))

     (init-dwim-make-action
      :title "Next difference"
      :description "Move to the next ediff difference"
      :category "Ediff"
      :priority 90
      :predicate (lambda () (fboundp 'ediff-next-difference))
      :action (lambda () (ediff-next-difference)))

     (init-dwim-make-action
      :title "Previous difference"
      :description "Move to the previous ediff difference"
      :category "Ediff"
      :priority 88
      :predicate (lambda () (fboundp 'ediff-previous-difference))
      :action (lambda () (ediff-previous-difference)))

     (init-dwim-make-action
      :title "Quit ediff"
      :description "Exit the ediff session"
      :category "Ediff"
      :priority 70
      :predicate (lambda () (fboundp 'ediff-quit))
      :action (lambda () (ediff-quit nil))))))

;;; ── History / navigation (NEW) ────────────────────────────────────────────

(defun init-dwim-history-provider ()
  "Return history and navigation convenience actions."
  (list
   (init-dwim-make-action
    :title "Open recent file"
    :description "Visit a recently opened file"
    :category "History"
    :priority 85
    :predicate (lambda () (or (fboundp 'consult-recent-file)
                              (fboundp 'recentf-open-files)))
    :action (lambda ()
              (if (fboundp 'consult-recent-file)
                  (consult-recent-file)
                (recentf-open-files))))

   (init-dwim-make-action
    :title "Browse kill ring"
    :description "Select and yank from kill ring history"
    :category "History"
    :priority 80
    :predicate (lambda () (or (fboundp 'consult-yank-pop)
                              (fboundp 'browse-kill-ring)))
    :action (lambda ()
              (cond
               ((fboundp 'consult-yank-pop)
                (consult-yank-pop))
               ((fboundp 'browse-kill-ring)
                (browse-kill-ring))
               (t (call-interactively #'yank-pop)))))

   (init-dwim-make-action
    :title "Jump to last edit"
    :description "Jump to the position of the last text change"
    :category "History"
    :priority 75
    :predicate (lambda () (fboundp 'goto-last-change))
    :action (lambda () (goto-last-change nil)))

   (init-dwim-make-action
    :title "Resume last search"
    :description "Resume the last consult search session"
    :category "History"
    :priority 65
    :predicate (lambda () (fboundp 'consult-resume))
    :action (lambda () (consult-resume)))))

;;; ── Number at point ───────────────────────────────────────────────────────

(defun init-dwim-number-provider ()
  "Return actions when point is on or near a number."
  (when-let ((num (init-dwim--number-at-point)))
    (list
     (init-dwim-make-action
      :title "Increment number"
      :description "Increase the number at point by 1"
      :category "Number"
      :priority 90
      :action (lambda () (init-dwim--replace-number-at-point (1+ num))))

     (init-dwim-make-action
      :title "Decrement number"
      :description "Decrease the number at point by 1"
      :category "Number"
      :priority 88
      :action (lambda () (init-dwim--replace-number-at-point (1- num))))

     (init-dwim-make-action
      :title "Increment by N"
      :description "Add a custom amount to the number at point"
      :category "Number"
      :priority 82
      :action (lambda ()
                (let ((delta (read-number "Increment by: " 1)))
                  (init-dwim--replace-number-at-point (+ num delta)))))

     (init-dwim-make-action
      :title "Convert to hex"
      :description "Replace decimal number at point with its hex representation"
      :category "Number"
      :priority 75
      :action (lambda ()
                (when-let ((b (init-dwim--number-bounds-at-point)))
                  (delete-region (car b) (cdr b)))
                (insert (format "0x%x" num))))

     (init-dwim-make-action
      :title "Copy number"
      :description "Copy the number at point to the kill ring"
      :category "Number"
      :priority 60
      :action (lambda ()
                (kill-new (number-to-string num))
                (message "Copied: %s" num))))))

;;; ── Emacs Lisp development ────────────────────────────────────────────────

(defun init-dwim-elisp-provider ()
  "Return actions specific to Emacs Lisp buffers."
  (when (init-dwim--elisp-mode-p)
    (list
     (init-dwim-make-action
      :title "Evaluate defun"
      :description "Evaluate the top-level form at point"
      :category "Elisp"
      :priority 100
      :action (lambda () (call-interactively #'eval-defun)))

     (init-dwim-make-action
      :title "Evaluate last sexp"
      :description "Evaluate the expression before point"
      :category "Elisp"
      :priority 98
      :action (lambda () (call-interactively #'eval-last-sexp)))

     (init-dwim-make-action
      :title "Evaluate buffer"
      :description "Evaluate all forms in this buffer"
      :category "Elisp"
      :priority 92
      :action (lambda () (eval-buffer) (message "Buffer evaluated")))

     (init-dwim-make-action
      :title "Macroexpand at point"
      :description "Expand the macro form at point and display the result"
      :category "Elisp"
      :priority 85
      :action (lambda () (call-interactively #'pp-macroexpand-expression)))

     (init-dwim-make-action
      :title "Macroexpand-1 at point"
      :description "Expand one step of the macro at point"
      :category "Elisp"
      :priority 84
      :predicate (lambda () (fboundp 'macroexpand-1))
      :action (lambda ()
                (let* ((form (sexp-at-point))
                       (expanded (macroexpand-1 form)))
                  (pp-display-expression expanded "*Macroexpand-1*"))))

     (init-dwim-make-action
      :title "Jump to definition"
      :description "Jump to the definition of the symbol at point"
      :category "Elisp"
      :priority 90
      :predicate (lambda () (init-dwim--symbol-string))
      :action (lambda ()
                (let ((sym (intern-soft (init-dwim--symbol-string))))
                  (when sym
                    (cond
                     ((fboundp sym) (find-function sym))
                     ((boundp sym) (find-variable sym))
                     (t (user-error "Cannot find definition of %s" sym)))))))

     (init-dwim-make-action
      :title "Describe symbol at point"
      :description "Show help for the function or variable at point"
      :category "Elisp"
      :priority 88
      :predicate (lambda () (init-dwim--symbol-string))
      :action (lambda ()
                (let ((sym (intern-soft (init-dwim--symbol-string))))
                  (when sym
                    (cond
                     ((fboundp sym) (describe-function sym))
                     ((boundp sym) (describe-variable sym))
                     (t (user-error "Unknown symbol %s" sym)))))))

     (init-dwim-make-action
      :title "Byte-compile this file"
      :description "Byte-compile the current Emacs Lisp file"
      :category "Elisp"
      :priority 70
      :predicate (lambda ()
                   (and (buffer-file-name)
                        (string-match-p "\\.el\\'" (buffer-file-name))))
      :action (lambda ()
                (byte-compile-file (buffer-file-name))
                (message "Byte-compiled %s" (buffer-file-name))))

     (init-dwim-make-action
      :title "Byte-compile and load"
      :description "Byte-compile and immediately load this file"
      :category "Elisp"
      :priority 68
      :predicate (lambda ()
                   (and (buffer-file-name)
                        (string-match-p "\\.el\\'" (buffer-file-name))))
      :action (lambda ()
                (byte-recompile-file (buffer-file-name) nil 0)
                (load-file (concat (file-name-sans-extension (buffer-file-name)) ".elc"))))

     (init-dwim-make-action
      :title "Check for checkdoc issues"
      :description "Run checkdoc to find documentation style problems"
      :category "Elisp"
      :priority 60
      :predicate (lambda () (fboundp 'checkdoc))
      :action (lambda () (checkdoc)))

     (init-dwim-make-action
      :title "Lint with package-lint"
      :description "Run package-lint on this file"
      :category "Elisp"
      :priority 55
      :predicate (lambda () (fboundp 'package-lint-current-buffer))
      :action (lambda () (package-lint-current-buffer)))

     (init-dwim-make-action
      :title "Disassemble function"
      :description "Show bytecode disassembly for the function at point"
      :category "Elisp"
      :priority 50
      :predicate (lambda () (init-dwim--symbol-string))
      :action (lambda ()
                (when-let ((sym (intern-soft (init-dwim--symbol-string))))
                  (disassemble sym))))

     (init-dwim-make-action
      :title "Edebug defun"
      :description "Instrument the top-level form for Edebug stepping"
      :category "Elisp"
      :priority 65
      :predicate (lambda () (fboundp 'edebug-defun))
      :action (lambda () (call-interactively #'edebug-defun))))))

;;; ── REST / HTTP client ────────────────────────────────────────────────────

(defun init-dwim-restclient-provider ()
  "Return actions for REST client buffers (restclient, verb, .http files)."
  (when (init-dwim--restclient-mode-p)
    (list
     (init-dwim-make-action
      :title "Send request at point"
      :description "Execute the HTTP request at point"
      :category "HTTP"
      :priority 100
      :action (lambda ()
                (cond
                 ((fboundp 'restclient-http-send-current)
                  (restclient-http-send-current))
                 ((fboundp 'verb-send-request-on-point)
                  (verb-send-request-on-point))
                 (t (user-error "No HTTP send command available")))))

     (init-dwim-make-action
      :title "Send request and focus response"
      :description "Execute the request and jump to the response buffer"
      :category "HTTP"
      :priority 95
      :predicate (lambda () (fboundp 'restclient-http-send-current-stay-in-window))
      :action (lambda () (restclient-http-send-current-stay-in-window)))

     (init-dwim-make-action
      :title "Copy request as curl"
      :description "Copy the current request as a curl command"
      :category "HTTP"
      :priority 80
      :predicate (lambda () (fboundp 'restclient-copy-curl-command))
      :action (lambda () (restclient-copy-curl-command)))

     (init-dwim-make-action
      :title "Jump to next request"
      :description "Move point to the next HTTP request in the file"
      :category "HTTP"
      :priority 70
      :predicate (lambda () (fboundp 'restclient-jump-next))
      :action (lambda () (restclient-jump-next)))

     (init-dwim-make-action
      :title "Jump to previous request"
      :description "Move point to the previous HTTP request in the file"
      :category "HTTP"
      :priority 68
      :predicate (lambda () (fboundp 'restclient-jump-prev))
      :action (lambda () (restclient-jump-prev)))

     (init-dwim-make-action
      :title "Toggle narrowing to request"
      :description "Narrow buffer to the current HTTP request"
      :category "HTTP"
      :priority 60
      :predicate (lambda () (fboundp 'restclient-narrow-to-current))
      :action (lambda ()
                (if (buffer-narrowed-p)
                    (widen)
                  (when (fboundp 'restclient-narrow-to-current)
                    (restclient-narrow-to-current))))))))

;;; ── eat terminal buffer ───────────────────────────────────────────────────

(defun init-dwim-eat-provider ()
  "Return actions for eat terminal buffers."
  (when (init-dwim--eat-buffer-p)
    (list
     (init-dwim-make-action
      :title "Send region to eat"
      :description "Paste the active region into this eat terminal"
      :category "Terminal"
      :priority 95
      :predicate (lambda ()
                   (and (use-region-p)
                        (fboundp 'eat-send-string)))
      :action (lambda ()
                (when (use-region-p)
                  (eat-send-string
                   (buffer-substring-no-properties
                    (region-beginning) (region-end))))))

     (init-dwim-make-action
      :title "Clear terminal"
      :description "Send a clear command to the eat terminal"
      :category "Terminal"
      :priority 85
      :predicate (lambda () (fboundp 'eat-send-string))
      :action (lambda () (eat-send-string "clear\n")))

     (init-dwim-make-action
      :title "Copy last output"
      :description "Copy the last command output to the kill ring"
      :category "Terminal"
      :priority 80
      :action (lambda ()
                ;; Heuristic: copy from last prompt line to point-max
                (let ((text (buffer-substring-no-properties
                             (save-excursion
                               (goto-char (point-max))
                               (re-search-backward "^[^[:space:]]" nil t)
                               (line-beginning-position))
                             (point-max))))
                  (kill-new text)
                  (message "Copied %d chars from terminal" (length text)))))

     (init-dwim-make-action
      :title "Rename eat buffer"
      :description "Give this terminal buffer a descriptive name"
      :category "Terminal"
      :priority 70
      :action (lambda () (call-interactively #'rename-buffer)))

     (init-dwim-make-action
      :title "Toggle eat line/char mode"
      :description "Switch between eat line mode and char mode"
      :category "Terminal"
      :priority 65
      :action (lambda ()
                (cond
                 ((fboundp 'eat-emacs-mode) (eat-emacs-mode))
                 (t (message "eat mode toggle not available"))))))))

;;; ── Focus / writing mode ─────────────────────────────────────────────────

(defun init-dwim-focus-provider ()
  "Return writing focus and distraction-free actions."
  (when (or (derived-mode-p 'text-mode 'org-mode 'markdown-mode)
            (init-dwim--focus-mode-active-p))
    (list
     (init-dwim-make-action
      :title "Toggle focus / writeroom mode"
      :description "Enter or exit distraction-free writing mode"
      :category "Focus"
      :priority 90
      :predicate (lambda ()
                   (or (fboundp 'writeroom-mode)
                       (fboundp 'olivetti-mode)
                       (fboundp 'darkroom-mode)))
      :action (lambda ()
                (cond
                 ((fboundp 'writeroom-mode) (writeroom-mode 'toggle))
                 ((fboundp 'olivetti-mode) (olivetti-mode 'toggle))
                 ((fboundp 'darkroom-mode) (darkroom-mode 'toggle))
                 (t (user-error "No focus mode available")))))

     (init-dwim-make-action
      :title "Increase focus width"
      :description "Widen the writing column in focus mode"
      :category "Focus"
      :priority 80
      :predicate (lambda ()
                   (or (and (boundp 'writeroom-mode) writeroom-mode
                            (fboundp 'writeroom-increase-width))
                       (and (boundp 'olivetti-mode) olivetti-mode
                            (fboundp 'olivetti-expand))))
      :action (lambda ()
                (cond
                 ((and (boundp 'writeroom-mode) writeroom-mode
                       (fboundp 'writeroom-increase-width))
                  (writeroom-increase-width))
                 ((and (fboundp 'olivetti-expand))
                  (olivetti-expand)))))

     (init-dwim-make-action
      :title "Decrease focus width"
      :description "Narrow the writing column in focus mode"
      :category "Focus"
      :priority 78
      :predicate (lambda ()
                   (or (and (boundp 'writeroom-mode) writeroom-mode
                            (fboundp 'writeroom-decrease-width))
                       (and (boundp 'olivetti-mode) olivetti-mode
                            (fboundp 'olivetti-shrink))))
      :action (lambda ()
                (cond
                 ((and (boundp 'writeroom-mode) writeroom-mode
                       (fboundp 'writeroom-decrease-width))
                  (writeroom-decrease-width))
                 ((fboundp 'olivetti-shrink)
                  (olivetti-shrink)))))

     (init-dwim-make-action
      :title "Toggle line numbers"
      :description "Show or hide line numbers in this buffer"
      :category "Focus"
      :priority 70
      :action (lambda () (display-line-numbers-mode 'toggle)))

     (init-dwim-make-action
      :title "Toggle visual line mode"
      :description "Toggle word-wrapped visual lines"
      :category "Focus"
      :priority 68
      :action (lambda () (visual-line-mode 'toggle)))

     (init-dwim-make-action
      :title "Goal line length"
      :description "Set fill-column and activate fill-column-indicator"
      :category "Focus"
      :priority 60
      :action (lambda ()
                (let ((col (read-number "Fill column: " fill-column)))
                  (setq-local fill-column col)
                  (when (fboundp 'display-fill-column-indicator-mode)
                    (display-fill-column-indicator-mode 1))
                  (message "fill-column set to %d" col)))))))

;;; ── Consult augmentation ─────────────────────────────────────────────────

(defun init-dwim-consult-provider ()
  "Return consult-specific search and navigation actions."
  (when (fboundp 'consult-line)
    (list
     (init-dwim-make-action
      :title "Search lines (consult)"
      :description "Incrementally search lines in the buffer with preview"
      :category "Search"
      :priority 88
      :action (lambda () (consult-line)))

     (init-dwim-make-action
      :title "Search all buffers"
      :description "Search across all open buffers with consult-line-multi"
      :category "Search"
      :priority 82
      :predicate (lambda () (fboundp 'consult-line-multi))
      :action (lambda () (consult-line-multi nil)))

     (init-dwim-make-action
      :title "Outline / headings"
      :description "Navigate the buffer outline or Org/Markdown headings"
      :category "Search"
      :priority 85
      :predicate (lambda () (fboundp 'consult-outline))
      :action (lambda () (consult-outline)))

     (init-dwim-make-action
      :title "Find file in directory"
      :description "Find file using consult-find from current directory"
      :category "Search"
      :priority 75
      :predicate (lambda () (fboundp 'consult-find))
      :action (lambda () (consult-find default-directory)))

     (init-dwim-make-action
      :title "Jump to error in buffer"
      :description "Use consult-flymake or consult-flycheck to jump to errors"
      :category "Search"
      :priority 78
      :predicate (lambda ()
                   (or (fboundp 'consult-flymake)
                       (fboundp 'consult-flycheck)))
      :action (lambda ()
                (cond
                 ((fboundp 'consult-flycheck) (consult-flycheck))
                 ((fboundp 'consult-flymake) (consult-flymake)))))

     (init-dwim-make-action
      :title "Search man pages"
      :description "Browse man pages interactively with consult-man"
      :category "Search"
      :priority 60
      :predicate (lambda () (fboundp 'consult-man))
      :action (lambda () (consult-man (init-dwim--symbol-string))))

     (init-dwim-make-action
      :title "Switch to open buffer (other window)"
      :description "Pick an open buffer and display in another window"
      :category "Search"
      :priority 65
      :predicate (lambda () (fboundp 'consult-buffer-other-window))
      :action (lambda () (consult-buffer-other-window)))

     (init-dwim-make-action
      :title "Browse themes"
      :description "Preview and switch themes interactively"
      :category "Search"
      :priority 40
      :predicate (lambda () (fboundp 'consult-theme))
      :action (lambda () (call-interactively #'consult-theme))))))

;;;; Provider registration

(setq init-dwim-providers
      '(init-dwim-session-provider
        init-dwim-consult-provider
        init-dwim-region-provider
        init-dwim-url-provider
        init-dwim-file-path-provider
        init-dwim-org-provider
        init-dwim-org-clock-provider
        init-dwim-dired-provider
        init-dwim-magit-provider
        init-dwim-git-gutter-provider
        init-dwim-smerge-provider
        init-dwim-diff-provider
        init-dwim-ediff-provider
        init-dwim-output-buffer-provider
        init-dwim-comint-provider
        init-dwim-isearch-provider
        init-dwim-symbol-provider
        init-dwim-number-provider
        init-dwim-xref-provider
        init-dwim-elisp-provider
        init-dwim-programming-provider
        init-dwim-diagnostics-provider
        init-dwim-text-provider
        init-dwim-project-provider
        init-dwim-buffer-provider
        init-dwim-window-provider
        init-dwim-bookmark-provider
        init-dwim-register-provider
        init-dwim-snippet-provider
        init-dwim-help-provider
        init-dwim-evil-provider
        init-dwim-ai-provider
        init-dwim-tab-bar-provider
        init-dwim-spelling-provider
        init-dwim-macro-provider
        init-dwim-narrow-provider
        init-dwim-shell-provider
        init-dwim-eat-provider
        init-dwim-history-provider
        init-dwim-restclient-provider
        init-dwim-focus-provider
        init-dwim-emacs-provider))

(provide 'init-dwim)

;;; init-dwim.el ends here

;;;; init-dwim user configuration

(setq init-dwim-max-candidates nil
      init-dwim-include-low-confidence-actions t
      init-dwim-completion-backend 'consult-if-available
      init-dwim-project-notes-file "NOTES.org"
      init-dwim-ai-system-prompt
      "You are a senior engineer helping inside Emacs. Be concise and actionable.")

;; The one custom keybinding in this setup.
;; M-RET is a good default because it is mnemonic, easy to press, works in GUI
;; and terminal Emacs on most systems, and is explicitly suggested by init-dwim.
(with-eval-after-load 'evil
  (evil-set-leader '(normal visual motion emacs) (kbd "SPC"))
  (evil-define-key '(normal visual motion emacs) 'global
    (kbd "<leader> SPC") #'init-dwim))

(provide 'init)
;;; init.el ends here
