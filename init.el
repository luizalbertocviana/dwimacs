;;; init.el --- Single-file DWIM-centered setup -*- lexical-binding: t; -*-
;;;
;; Version: 0.3.0
;; Package-Requires: ((emacs "30.1"))
;; URL: https://github.com/luizalbertocviana/dwimacs
;;
;;; Commentary:
;; A modern vanilla Emacs configuration centered around dwim.
;;
;; Installation notes:
;; 1. Put this file at ~/.emacs.d/init.el.
;; 2. Start Emacs.  straight.el will bootstrap itself and install packages.
;;
;; The only custom global keybinding defined here is SPC SPC -> init-dwim.
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
(winner-mode 1)

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

(use-package embark-consult
  :demand t)

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
(use-package clojure-mode :defer t)

;; Optional editing enhancements surfaced by DWIM providers.
(use-package wgrep :defer t)
(use-package wgrep-ag :after wgrep)
(use-package dap-mode :defer t)
(use-package vundo :defer t)

;;;; Text, Org, Markdown, spelling, and export providers

(use-package org
  :straight nil
  :defer t
  :init
  (setq org-directory (expand-file-name "org" user-emacs-directory))
  :custom
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

(defcustom init-dwim-extra-inbox-file
  (expand-file-name "inbox.org" org-directory)
  "Org file used by extra DWIM quick note actions."
  :type 'file
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

(defun init-dwim-extra--append-org-note (heading body)
  "Append HEADING and BODY to `init-dwim-extra-inbox-file'."
  (make-directory (file-name-directory init-dwim-extra-inbox-file) t)
  (with-current-buffer (find-file-noselect init-dwim-extra-inbox-file)
    (goto-char (point-max))
    (unless (bolp) (insert "\n"))
    (insert "* " heading "\n")
    (insert "  " (format-time-string "[%Y-%m-%d %a %H:%M]") "\n")
    (when body
      (insert "\n" body "\n"))
    (save-buffer)))

(defun init-dwim-extra--docker-compose-file-p ()
  "Return non-nil when the project has a Docker Compose file."
  (or (init-dwim-extra--project-has-file-p "compose.yaml")
      (init-dwim-extra--project-has-file-p "compose.yml")
      (init-dwim-extra--project-has-file-p "docker-compose.yaml")
      (init-dwim-extra--project-has-file-p "docker-compose.yml")))

(defun init-dwim-extra--eglot-managed-p ()
  "Return non-nil when current buffer is managed by Eglot."
  (and (featurep 'eglot)
       (fboundp 'eglot-managed-p)
       (eglot-managed-p)))

(defun init-dwim-extra--package-json-scripts ()
  "Return script names from package.json in the current project."
  (when-let ((json (init-dwim-extra--json-file-read "package.json")))
    (when-let ((scripts (alist-get 'scripts json)))
      (mapcar (lambda (cell) (symbol-name (car cell))) scripts))))

(defun init-dwim-extra--npm-run-action (script &optional priority)
  "Create an action that runs npm SCRIPT."
  (init-dwim-make-action
   :title (format "npm run %s" script)
   :description (format "Run package.json script: %s" script)
   :category "Project"
   :priority (or priority 74)
   :action (lambda ()
             (init-dwim-extra--compile-in-project
              (format "npm run %s" script)))))

(defun init-dwim-extra--project-file (file)
  "Return absolute path to FILE in the current project."
  (expand-file-name file (init-dwim--project-root)))

(defun init-dwim-extra--project-has-file-p (file)
  "Return non-nil when FILE exists in the current project."
  (file-exists-p (init-dwim-extra--project-file file)))

(defun init-dwim-extra--compile-in-project (command)
  "Run COMMAND with `compile' from the current project root."
  (let ((default-directory (init-dwim--project-root)))
    (compile command)))

(defun init-dwim-extra--shell-command-in-project (command)
  "Run async shell COMMAND from the current project root."
  (let ((default-directory (init-dwim--project-root)))
    (async-shell-command command)))

(defun init-dwim-extra--buffer-file-relative-name ()
  "Return current buffer file path relative to project root, or nil."
  (when-let ((file (buffer-file-name)))
    (file-relative-name file (init-dwim--project-root))))

(defun init-dwim-extra--json-file-read (file)
  "Read JSON FILE from project root and return an alist, or nil."
  (let ((path (init-dwim-extra--project-file file)))
    (when (file-readable-p path)
      (with-temp-buffer
        (insert-file-contents path)
        (let ((json-object-type 'alist)
              (json-array-type 'list)
              (json-key-type 'symbol))
          (json-read))))))

(defun init-dwim--gptel-buffer-p ()
  "Return non-nil when inside a gptel chat buffer."
  (and (fboundp 'gptel-mode)
       (bound-and-true-p gptel-mode)))

(defun init-dwim--python-mode-p ()
  "Return non-nil in Python buffers."
  (derived-mode-p 'python-mode 'python-ts-mode))

(defun init-dwim--sp-active-p ()
  "Return non-nil when smartparens-mode is active."
  (bound-and-true-p smartparens-mode))

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
      (and (init-dwim--buffer-file-p)
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
  "Return current project root, falling back to `default-directory'.
Tries project.el, then Projectile, then `vc-root-dir', then
`default-directory' so callers always receive a usable directory."
  (or
   (when (and (fboundp 'project-current)
              (project-current nil))
     (expand-file-name
      (if (fboundp 'project-root)
          (project-root (project-current nil))
        (car (project-roots (project-current nil))))))
   (when (and (fboundp 'projectile-project-p)
              (ignore-errors (projectile-project-p))
              (fboundp 'projectile-project-root))
     (projectile-project-root))
   (when (fboundp 'vc-root-dir)
     (vc-root-dir))
   default-directory))

(defun init-dwim--project-detected-p ()
  "Return non-nil if the current buffer is inside a recognized project."
  (or
   (and (fboundp 'projectile-project-p)
        (ignore-errors (projectile-project-p)))
   (and (fboundp 'project-current)
        (project-current nil))
   (and (fboundp 'vc-root-dir)
        (vc-root-dir))))

(defun init-dwim--in-project-p ()
  "Return non-nil if the current buffer is inside a recognized project."
  (not (null (init-dwim--project-detected-p))))

(defun init-dwim--lsp-available-p ()
  "Return non-nil when LSP-style actions are available in this buffer."
  (or
   (and (boundp 'lsp-mode) lsp-mode)
   (and (fboundp 'eglot-current-server)
        (ignore-errors (eglot-current-server)))))

(defun init-dwim--format-region (beg end)
  "Format region from BEG to END using the best available formatter."
  (cond
   ((and (fboundp 'eglot-format) (ignore-errors (eglot-current-server)))
    (eglot-format beg end))
   ((and (boundp 'lsp-mode) lsp-mode (fboundp 'lsp-format-region))
    (lsp-format-region beg end))
   ((fboundp 'apheleia-format-region)
    (apheleia-format-region beg end))
   ((fboundp 'format-all-region)
    (format-all-region beg end))
   (t
    (indent-region beg end))))

(defun init-dwim--format-buffer ()
  "Format current buffer using the best available formatter."
  (cond
   ((and (fboundp 'eglot-format) (ignore-errors (eglot-current-server)))
    (eglot-format (point-min) (point-max)))
   ((and (boundp 'lsp-mode) lsp-mode (fboundp 'lsp-format-buffer))
    (lsp-format-buffer))
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
      (format "Region: %d words, %d lines, %d chars"
              (count-words (region-beginning) (region-end))
              (- (line-number-at-pos (region-end)) (line-number-at-pos (region-beginning)))
              (- (region-end) (region-beginning)))
    (format "Buffer: %d words, %d lines, %d chars"
            (count-words (point-min) (point-max))
            (line-number-at-pos (point-max))
            (- (point-max) (point-min)))))


(defun init-dwim--json-mode-p ()
  "Return non-nil in JSON buffers."
  (or (derived-mode-p 'json-mode 'json-ts-mode)
      (and (init-dwim--buffer-file-p)
           (string-match-p "\\.json\\'" (buffer-file-name)))))

(defun init-dwim--yaml-mode-p ()
  "Return non-nil in YAML buffers."
  (or (derived-mode-p 'yaml-mode 'yaml-ts-mode)
      (and (init-dwim--buffer-file-p)
           (string-match-p "\\.ya?ml\\'" (buffer-file-name)))))

(defun init-dwim--json-path-at-point ()
  "Return a simple dot-notation JSON path for the key at point, or nil.
Walks up by counting matching braces/brackets — best-effort, not a parser."
  (save-excursion
    (let ((keys '()))
      (condition-case nil
          (progn
            (while t
              (backward-up-list)
              (let ((ch (char-after)))
                (cond
                 ((eq ch ?\{)
                  ;; look backward for the key that opened this object value
                  (save-excursion
                    (backward-sexp)
                    (when (looking-at "\"\\([^\"]+\\)\"")
                      (push (match-string 1) keys))))
                 ((eq ch ?\[)
                  (push "[]" keys))))))
        (scan-error nil))
      (when keys
        (string-join (nreverse keys) ".")))))

;;; New helpers: project file, run-in-project, mode predicates

(defun init-dwim-extra--project-has-any-file-p (&rest files)
  "Return non-nil when ANY of FILES exists in the current project root."
  (cl-some #'init-dwim-extra--project-has-file-p files))

(defun init-dwim--run-in-project (command &optional async)
  "Run COMMAND from the current project root.
If ASYNC is non-nil use `async-shell-command', otherwise use `compile'."
  (let ((default-directory (init-dwim--project-root)))
    (if async
        (async-shell-command command)
      (compile command))))

(defun init-dwim--clojure-mode-p ()
  "Return non-nil in Clojure buffers."
  (derived-mode-p 'clojure-mode 'clojurescript-mode 'clojurec-mode
                  'clojure-ts-mode))

(defun init-dwim--common-lisp-mode-p ()
  "Return non-nil in Common Lisp buffers."
  (derived-mode-p 'lisp-mode 'sly-mrepl-mode))

(defun init-dwim--rust-mode-p ()
  "Return non-nil in Rust buffers."
  (derived-mode-p 'rust-mode 'rust-ts-mode))

(defun init-dwim--go-mode-p ()
  "Return non-nil in Go buffers."
  (derived-mode-p 'go-mode 'go-ts-mode))

(defun init-dwim--typescript-mode-p ()
  "Return non-nil in TypeScript buffers."
  (derived-mode-p 'typescript-mode 'typescript-ts-mode 'tsx-ts-mode))

(defun init-dwim--javascript-mode-p ()
  "Return non-nil in JavaScript buffers (but not TypeScript)."
  (and (derived-mode-p 'js-mode 'js-ts-mode 'js2-mode)
       (not (init-dwim--typescript-mode-p))))

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
                             re))))

       (init-dwim-make-action
        :title "HTML-escape region"
        :description "Escape <, >, &, and \" for safe HTML embedding"
        :category "Region"
        :priority 36
        :action (lambda ()
                  (let ((escaped
                         (replace-regexp-in-string
                          "&" "&amp;"
                          (replace-regexp-in-string
                           "<" "&lt;"
                           (replace-regexp-in-string
                            ">" "&gt;"
                            (replace-regexp-in-string
                             "\"" "&quot;" text))))))
                    (delete-region beg end)
                    (insert escaped))))

       (init-dwim-make-action
        :title "HTML-unescape region"
        :description "Decode HTML entities in the selected text"
        :category "Region"
        :priority 35
        :action (lambda ()
                  (let ((unescaped
                         (replace-regexp-in-string
                          "&amp;" "&"
                          (replace-regexp-in-string
                           "&lt;" "<"
                           (replace-regexp-in-string
                            "&gt;" ">"
                            (replace-regexp-in-string
                             "&quot;" "\"" text))))))
                    (delete-region beg end)
                    (insert unescaped))))

       (init-dwim-make-action
        :title "ROT13 region"
        :description "Apply ROT13 substitution cipher to the selection"
        :category "Region"
        :priority 20
        :action (lambda () (rot13-region beg end)))

       (init-dwim-make-action
        :title "SHA-256 hash region"
        :description "Replace selection with its SHA-256 hex digest"
        :category "Region"
        :priority 30
        :action (lambda ()
                  (let ((hash (secure-hash 'sha256 text)))
                    (delete-region beg end)
                    (insert hash))))

       (init-dwim-make-action
        :title "Titlecase region"
        :description "Capitalise the first letter of every word (upcase-initials)"
        :category "Region"
        :priority 47
        :action (lambda ()
                  (delete-region beg end)
                  (insert (upcase-initials text))))))))

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
                  (run-with-idle-timer 1 nil #'eww-readable))))

     (init-dwim-make-action
      :title "Extract domain"
      :description "Copy just the host/domain part of the URL"
      :category "URL"
      :priority 45
      :predicate (lambda () (fboundp 'url-host))
      :action (lambda ()
                (require 'url-parse)
                (let ((host (url-host (url-generic-parse-url url))))
                  (if (and host (not (string-empty-p host)))
                      (progn (kill-new host)
                             (message "Copied domain: %s" host))
                    (user-error "Could not extract domain from URL")))))

     (init-dwim-make-action
      :title "Download URL with curl"
      :description "Download the URL using curl (progress shown in *compilation*)"
      :category "URL"
      :priority 42
      :confidence 'low
      :predicate (lambda () (executable-find "curl"))
      :action (lambda ()
                (let ((dest (read-file-name "Download to: ")))
                  (compile (format "curl -L -o %s %s"
                                   (shell-quote-argument
                                    (expand-file-name dest))
                                   (shell-quote-argument url))))))

     (init-dwim-make-action
      :title "Open in Wayback Machine"
      :description "Open the URL via web.archive.org"
      :category "URL"
      :priority 38
      :confidence 'low
      :action (lambda ()
                (browse-url
                 (concat "https://web.archive.org/web/*/" url))))

     (init-dwim-make-action
      :title "Search URL in project"
      :description "Find all occurrences of this URL in the current project"
      :category "URL"
      :priority 40
      :predicate #'init-dwim--in-project-p
      :action (lambda () (init-dwim--project-search url))))))

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
                           size mtime modes))))

     (init-dwim-make-action
      :title "View in hexl"
      :description "Open the file in Emacs' hex-dump viewer"
      :category "File"
      :priority 28
      :action (lambda () (hexl-find-file path)))

     (init-dwim-make-action
      :title "SHA-256 checksum"
      :description "Compute SHA-256 of the file and copy it to the kill ring"
      :category "File"
      :priority 26
      :action (lambda ()
                (let* ((cmd (cond
                             ((executable-find "sha256sum")
                              (format "sha256sum %s" (shell-quote-argument path)))
                             ((executable-find "shasum")
                              (format "shasum -a 256 %s" (shell-quote-argument path)))
                             (t nil)))
                       (result (if cmd
                                   (car (split-string
                                         (shell-command-to-string cmd)))
                                 (with-temp-buffer
                                   (insert-file-contents-literally path)
                                   (secure-hash 'sha256 (current-buffer))))))
                  (kill-new result)
                  (message "SHA-256: %s" result))))

     (init-dwim-make-action
      :title "Set file permissions (chmod)"
      :description "Change the file's permission bits"
      :category "File"
      :priority 24
      :action (lambda ()
                (let* ((current (format "%o" (file-modes path)))
                       (new-mode (read-string
                                  (format "New permissions (octal, current %s): "
                                          current)
                                  current)))
                  (set-file-modes path (string-to-number new-mode 8))
                  (message "Permissions set to %s on %s"
                           new-mode (file-name-nondirectory path))))))))

;;; ── File utility ──────────────────────────────────────────────────────────

(defun init-dwim-file-utility-provider ()
  "Return utility actions for the current file/buffer."
  (let ((file (buffer-file-name)))
    (when file
      (list
       (init-dwim-make-action
        :title "Copy relative file path"
        :description "Copy current file path relative to project root"
        :category "File"
        :priority 91
        :action
        (lambda ()
          (let ((relative (init-dwim-extra--buffer-file-relative-name)))
            (kill-new relative)
            (message "Copied: %s" relative))))

       (init-dwim-make-action
        :title "Copy file path with line"
        :description "Copy file path plus current line number"
        :category "File"
        :priority 89
        :action
        (lambda ()
          (let ((location
                 (format "%s:%d"
                         (or (init-dwim-extra--buffer-file-relative-name)
                             file)
                         (line-number-at-pos))))
            (kill-new location)
            (message "Copied: %s" location))))

       (init-dwim-make-action
        :title "Make file executable"
        :description "Add executable bit to the current file"
        :category "File"
        :priority 82
        :predicate
        (lambda ()
          (and file
               (not (file-executable-p file))
               (not (file-directory-p file))))
        :action
        (lambda ()
          (set-file-modes file
                          (logior (file-modes file) #o111))
          (message "Made executable: %s" file)))

       (init-dwim-make-action
        :title "Edit file as root"
        :description "Reopen current file using sudo via TRAMP"
        :category "File"
        :priority 78
        :predicate
        (lambda ()
          (and file
               (not (file-remote-p file))))
        :action
        (lambda ()
          (find-alternate-file
           (concat "/sudo:root@localhost:" file))))

       (init-dwim-make-action
        :title "Open file URL in browser"
        :description "Open the current file using a file:// URL"
        :category "File"
        :priority 66
        :predicate
        (lambda ()
          (and file
               (fboundp 'browse-url-of-file)))
        :action
        (lambda ()
          (browse-url-of-file file)))

       (init-dwim-make-action
        :title "Copy directory path"
        :description "Copy the directory of the current file"
        :category "File"
        :priority 64
        :action
        (lambda ()
          (let ((dir (file-name-directory file)))
            (kill-new dir)
            (message "Copied: %s" dir))))

       (init-dwim-make-action
        :title "Add to .gitignore"
        :description "Append this file's name to the project .gitignore"
        :category "File"
        :priority 60
        :predicate
        (lambda ()
          (and file (init-dwim--in-project-p)))
        :action
        (lambda ()
          (let* ((root (init-dwim--project-root))
                 (gitignore (expand-file-name ".gitignore" root))
                 (rel (file-relative-name file root)))
            (with-current-buffer (find-file-noselect gitignore)
              (goto-char (point-max))
              (unless (bolp) (insert "\n"))
              (insert rel "\n")
              (save-buffer))
            (message "Added %s to .gitignore" rel))))

       (init-dwim-make-action
        :title "Toggle auto-save"
        :description "Enable or disable auto-save for this buffer"
        :category "File"
        :priority 55
        :action
        (lambda ()
          (auto-save-mode 'toggle)
          (message "Auto-save %s"
                   (if buffer-auto-save-file-name "on" "off"))))))))

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
                  (end-of-line))))

     (init-dwim-make-action
      :title "Pulse / flash symbol"
      :description "Briefly highlight all occurrences for visual confirmation"
      :category "Symbol"
      :priority 38
      :predicate (lambda () (fboundp 'pulse-momentary-highlight-region))
      :action (lambda ()
                (save-excursion
                  (goto-char (point-min))
                  (while (re-search-forward (regexp-quote symbol) nil t)
                    (pulse-momentary-highlight-region
                     (match-beginning 0) (match-end 0))))))

     (init-dwim-make-action
      :title "Add to .dir-locals"
      :description "Append a dir-locals entry for the symbol at point"
      :category "Symbol"
      :priority 35
      :predicate (lambda () (init-dwim--in-project-p))
      :action (lambda ()
                (let* ((var (intern symbol))
                       (val (read--expression
                             (format "Value for %s: " symbol)))
                       (root (init-dwim--project-root))
                       (dir-locals (expand-file-name ".dir-locals.el" root)))
                  (with-current-buffer (find-file-noselect dir-locals)
                    (goto-char (point-max))
                    (unless (bolp) (insert "\n"))
                    (insert (format ";; Added by init-dwim\n((nil . ((%s . %S))))\n"
                                    var val))
                    (save-buffer))
                  (message "Added %s to .dir-locals.el" symbol)))))))

;;; ── Org ───────────────────────────────────────────────────────────────────

(defun init-dwim-org-provider ()
  "Return actions relevant to Org headings."
  (when (derived-mode-p 'org-mode)
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

     (init-dwim-make-action
      :title "Export buffer"
      :description "Export this Org file via the export dispatcher"
      :category "Org"
      :priority 80
      :predicate (lambda () (fboundp 'org-export-dispatch))
      :action (lambda () (call-interactively #'org-export-dispatch)))
     
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
      :title "Cycle global visibility"
      :description "Cycle all headings between folded/children/subtree views"
      :category "Org"
      :priority 75
      :predicate (lambda () (fboundp 'org-global-cycle))
      :action (lambda () (org-global-cycle nil)))
     
     (init-dwim-make-action
      :title "Show sparse todo tree"
      :description "Show all TODO items in a sparse tree"
      :category "Org"
      :priority 72
      :predicate (lambda () (fboundp 'org-show-todo-tree))
      :action (lambda () (org-show-todo-tree nil)))
     
     (init-dwim-make-action
      :title "Insert date stamp"
      :description "Insert an inactive date stamp at point"
      :category "Org"
      :priority 70
      :predicate (lambda () (fboundp 'org-time-stamp-inactive))
      :action (lambda () (call-interactively #'org-time-stamp-inactive)))
     
     (init-dwim-make-action
      :title "Insert active timestamp"
      :description "Insert an active (agenda-visible) timestamp at point"
      :category "Org"
      :priority 68
      :predicate (lambda () (fboundp 'org-time-stamp))
      :action (lambda () (call-interactively #'org-time-stamp)))
     
     (init-dwim-make-action
      :title "Update all dynamic blocks"
      :description "Recalculate all dynamic blocks in the file"
      :category "Org"
      :priority 55
      :predicate (lambda () (fboundp 'org-update-all-dblocks))
      :action (lambda () (org-update-all-dblocks)))
     
     (init-dwim-make-action
      :title "Align all tags"
      :description "Re-align tag columns across all headings"
      :category "Org"
      :priority 50
      :predicate (lambda () (fboundp 'org-align-all-tags))
      :action (lambda () (org-align-all-tags)))
     
     (init-dwim-make-action
      :title "Column view"
      :description "Enter Org column view for this heading"
      :category "Org"
      :priority 42
      :predicate (lambda () (fboundp 'org-columns))
      :action (lambda () (org-columns)))

     (init-dwim-make-action
      :title "Cut subtree"
      :description "Cut this Org subtree to the kill ring"
      :category "Org"
      :priority 67
      :predicate (lambda () (fboundp 'org-cut-subtree))
      :action (lambda () (org-cut-subtree)))

     (init-dwim-make-action
      :title "Copy subtree"
      :description "Copy this Org subtree to the kill ring"
      :category "Org"
      :priority 66
      :predicate (lambda () (fboundp 'org-copy-subtree))
      :action (lambda () (org-copy-subtree)))

     (init-dwim-make-action
      :title "Paste subtree"
      :description "Paste a previously cut/copied Org subtree"
      :category "Org"
      :priority 65
      :predicate (lambda () (fboundp 'org-paste-subtree))
      :action (lambda () (org-paste-subtree)))

     (init-dwim-make-action
      :title "Narrow to subtree"
      :description "Narrow the buffer to show only this subtree"
      :category "Org"
      :priority 64
      :predicate (lambda () (fboundp 'org-narrow-to-subtree))
      :action (lambda () (org-narrow-to-subtree)))

     (init-dwim-make-action
      :title "Mark subtree"
      :description "Select the entire current subtree as the active region"
      :category "Org"
      :priority 63
      :predicate (lambda () (fboundp 'org-mark-subtree))
      :action (lambda () (org-mark-subtree)))

     (init-dwim-make-action
      :title "Sparse tree by tag"
      :description "Show a sparse tree filtered by tag"
      :category "Org"
      :priority 62
      :predicate (lambda () (fboundp 'org-match-sparse-tree))
      :action (lambda () (call-interactively #'org-match-sparse-tree)))

     (init-dwim-make-action
      :title "Recalculate table"
      :description "Recalculate the Org table at point"
      :category "Org"
      :priority 61
      :predicate (lambda ()
                   (and (fboundp 'org-table-recalculate)
                        (org-at-table-p)))
      :action (lambda () (org-table-recalculate t))))))

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
                  (call-interactively #'projectile-test-project))
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
      :title "Run current file"
      :description "Execute the current file with the appropriate interpreter"
      :category "Code"
      :priority 60
      :predicate (lambda ()
                   (or (derived-mode-p 'ruby-mode)
                       (derived-mode-p 'js-mode 'typescript-mode)
                       (derived-mode-p 'sh-mode)
                       (derived-mode-p 'emacs-lisp-mode)))
      :action (lambda ()
                (let ((f (buffer-file-name)))
                  (unless f (user-error "Buffer is not visiting a file"))
                  (cond
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
      :title "Toggle breakpoint"
      :description "Add or remove a breakpoint at the current line"
      :category "Code"
      :priority 62
      :predicate (lambda ()
                   (or (and (fboundp 'dap-breakpoint-toggle)
                            (bound-and-true-p dap-mode))
                       (fboundp 'realgud:cmd-break)))
      :action (lambda ()
                (cond
                 ((and (fboundp 'dap-breakpoint-toggle)
                       (bound-and-true-p dap-mode))
                  (dap-breakpoint-toggle))
                 ((fboundp 'realgud:cmd-break)
                  (realgud:cmd-break))
                 (t (user-error "No breakpoint command available")))))

     (init-dwim-make-action
      :title "Fold / unfold function"
      :description "Toggle code folding for the function at point"
      :category "Code"
      :priority 58
      :predicate (lambda ()
                   (or (fboundp 'hs-toggle-hiding)
                       (fboundp 'evil-toggle-fold)))
      :action (lambda ()
                (cond
                 ((fboundp 'hs-toggle-hiding)
                  (hs-minor-mode 1)
                  (hs-toggle-hiding))
                 ((fboundp 'evil-toggle-fold)
                  (evil-toggle-fold))
                 (t (user-error "No fold command available")))))

     (init-dwim-make-action
      :title "Copy function signature"
      :description "Copy the current defun's signature line to the kill ring"
      :category "Code"
      :priority 50
      :predicate (lambda () (fboundp 'add-log-current-defun))
      :action (lambda ()
                (save-excursion
                  (beginning-of-defun)
                  (let ((sig (buffer-substring-no-properties
                              (line-beginning-position)
                              (line-end-position))))
                    (kill-new sig)
                    (message "Copied: %s" sig))))))))

;;; ── Eglot workspace ───────────────────────────────────────────────────────

(defun init-dwim-eglot-workspace-provider ()
  "Return workspace-level Eglot actions."
  (when (init-dwim-extra--eglot-managed-p)
    (list
     (init-dwim-make-action
      :title "LSP workspace symbols"
      :description "Search workspace symbols through Eglot"
      :category "LSP"
      :priority 91
      :predicate (lambda () (fboundp 'eglot-workspace-symbol))
      :action #'eglot-workspace-symbol)

     (init-dwim-make-action
      :title "LSP organize imports"
      :description "Ask the language server to organize imports"
      :category "LSP"
      :priority 88
      :predicate (lambda () (fboundp 'eglot-code-actions))
      :action
      (lambda ()
        (eglot-code-actions nil nil "source.organizeImports" t)))

     (init-dwim-make-action
      :title "LSP quick fix"
      :description "Run quick-fix code actions at point"
      :category "LSP"
      :priority 86
      :predicate (lambda () (fboundp 'eglot-code-actions))
      :action
      (lambda ()
        (eglot-code-actions nil nil "quickfix" t)))

     (init-dwim-make-action
      :title "LSP reconnect"
      :description "Reconnect Eglot for this buffer"
      :category "LSP"
      :priority 72
      :predicate (lambda () (fboundp 'eglot-reconnect))
      :action #'eglot-reconnect)

     (init-dwim-make-action
      :title "LSP shutdown server"
      :description "Shutdown the current Eglot server"
      :category "LSP"
      :priority 62
      :predicate (lambda () (fboundp 'eglot-shutdown))
      :action #'eglot-shutdown))))

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

;;; ── Markdown ──────────────────────────────────────────────────────────────

(defun init-dwim-markdown-provider ()
  "Return Markdown-specific actions."
  (when (init-dwim--markdown-mode-p)
    (list
     (init-dwim-make-action
      :title "Markdown preview with grip"
      :description "Preview current Markdown file with grip-mode"
      :category "Markdown"
      :priority 90
      :predicate (lambda () (fboundp 'grip-mode))
      :action #'grip-mode)

     (init-dwim-make-action
      :title "Generate Markdown TOC"
      :description "Insert or update a Markdown table of contents"
      :category "Markdown"
      :priority 86
      :predicate (lambda () (fboundp 'markdown-toc-generate-toc))
      :action #'markdown-toc-generate-toc)

     (init-dwim-make-action
      :title "Markdown follow link"
      :description "Open the Markdown link at point"
      :category "Markdown"
      :priority 82
      :predicate (lambda () (fboundp 'markdown-follow-thing-at-point))
      :action #'markdown-follow-thing-at-point)

     (init-dwim-make-action
      :title "Markdown insert link"
      :description "Insert a Markdown link"
      :category "Markdown"
      :priority 72
      :predicate (lambda () (fboundp 'markdown-insert-link))
      :action #'markdown-insert-link)

     (init-dwim-make-action
      :title "Markdown toggle markup hiding"
      :description "Toggle Markdown markup visibility"
      :category "Markdown"
      :priority 60
      :predicate (lambda () (boundp 'markdown-hide-markup))
      :action
      (lambda ()
        (setq-local markdown-hide-markup
                    (not markdown-hide-markup))
        (font-lock-flush))))))

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
        :action (lambda () (call-interactively #'dired-do-symlink)))

       (init-dwim-make-action
        :title "Unmark all"
        :description "Remove all marks in this Dired buffer"
        :category "Dired"
        :priority 38
        :predicate (lambda () (fboundp 'dired-unmark-all-marks))
        :action (lambda () (dired-unmark-all-marks)))

       (init-dwim-make-action
        :title "Open marked files"
        :description "Visit all marked files in separate buffers"
        :category "Dired"
        :priority 36
        :predicate (lambda () (fboundp 'dired-do-find-marked-files))
        :action (lambda () (dired-do-find-marked-files)))

       (init-dwim-make-action
        :title "Toggle hidden files"
        :description "Show or hide dot-files via dired-omit-mode"
        :category "Dired"
        :priority 34
        :predicate (lambda () (fboundp 'dired-omit-mode))
        :action (lambda ()
                  (require 'dired-x)
                  (dired-omit-mode 'toggle)
                  (message "Hidden files %s"
                           (if dired-omit-mode "hidden" "visible"))))))))

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
                    (and (init-dwim--buffer-file-p) (fboundp 'magit-file-dispatch)))
       :action (lambda () (call-interactively #'magit-file-dispatch)))

      (init-dwim-make-action
       :title "Magit blame"
       :description "Show git blame annotations for the current file"
       :category "Git"
       :priority 82
       :predicate (lambda ()
                    (and (init-dwim--buffer-file-p) (fboundp 'magit-blame-addition)))
       :action (lambda () (call-interactively #'magit-blame-addition)))

      (init-dwim-make-action
       :title "Magit blame quit"
       :description "Hide git blame annotations for the current file"
       :category "Git"
       :priority 82
       :predicate (lambda ()
                    (bound-and-true-p magit-blame-mode))
       :action (lambda () (call-interactively #'magit-blame-quit))))

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
         :action (lambda () (call-interactively #'magit-commit-amend)))

        (init-dwim-make-action
         :title "Magit worktree"
         :description "Manage Git worktrees"
         :category "Magit"
         :priority 60
         :predicate (lambda () (fboundp 'magit-worktree))
         :action (lambda () (call-interactively #'magit-worktree)))

        (init-dwim-make-action
         :title "Magit tag"
         :description "Create, list, or delete Git tags"
         :category "Magit"
         :priority 58
         :predicate (lambda () (fboundp 'magit-tag))
         :action (lambda () (call-interactively #'magit-tag)))

        (init-dwim-make-action
         :title "Magit submodule"
         :description "Manage Git submodules"
         :category "Magit"
         :priority 56
         :predicate (lambda () (fboundp 'magit-submodule))
         :action (lambda () (call-interactively #'magit-submodule)))

        (init-dwim-make-action
         :title "Magit bisect"
         :description "Binary search for the commit that introduced a bug"
         :category "Magit"
         :priority 54
         :predicate (lambda () (fboundp 'magit-bisect))
         :action (lambda () (call-interactively #'magit-bisect))))))))

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
                   ((fboundp 'eat)
                    (let ((default-directory root)) (eat)))
                   ((fboundp 'vterm)
                    (let ((default-directory root)) (vterm)))
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
                    (consult-recent-file)))))

       (init-dwim-make-action
        :title "Find TODO/FIXME in project"
        :description "Search for TODO, FIXME, HACK, and XXX annotations"
        :category "Project"
        :priority 52
        :action (lambda ()
                  (init-dwim--project-search
                   "TODO\\|FIXME\\|HACK\\|XXX\\|REVIEW")))

       (init-dwim-make-action
        :title "Open project changelog"
        :description "Open CHANGELOG, HISTORY, or NEWS file in the project root"
        :category "Project"
        :priority 50
        :predicate (lambda ()
                     (cl-some (lambda (f)
                                (init-dwim-extra--project-has-any-file-p
                                 f (concat f ".md") (concat f ".org")
                                 (concat f ".rst") (downcase f)))
                              '("CHANGELOG" "CHANGES" "HISTORY" "NEWS")))
        :action (lambda ()
                  (let ((candidates
                         (cl-remove-if-not
                          #'file-exists-p
                          (mapcan (lambda (base)
                                    (mapcar (lambda (ext)
                                              (expand-file-name
                                               (concat base ext)
                                               (init-dwim--project-root)))
                                            '("" ".md" ".org" ".rst" ".txt")))
                                  '("CHANGELOG" "CHANGES" "HISTORY" "NEWS"
                                    "changelog" "changes" "history" "news")))))
                    (if candidates
                        (find-file (car candidates))
                      (user-error "No changelog file found")))))

       (init-dwim-make-action
        :title "Add project to known list"
        :description "Register a directory as a known project"
        :category "Project"
        :priority 45
        :predicate (lambda ()
                     (or (fboundp 'projectile-add-known-project)
                         (fboundp 'project-remember-project)))
        :action (lambda ()
                  (let ((dir (read-directory-name "Add project: ")))
                    (cond
                     ((fboundp 'projectile-add-known-project)
                      (projectile-add-known-project dir)
                      (message "Project added: %s" dir))
                     ((fboundp 'project-remember-project)
                      (project-remember-project (project-current nil dir))
                      (message "Project remembered: %s" dir))))))))))

;;; ── Buffer (NEW) ──────────────────────────────────────────────────────────

(defun init-dwim-buffer-provider ()
  "Return general buffer-management actions."
  (list
   (init-dwim-make-action
    :title "Save buffer to file"
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
    :title "Open current file in other window"
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
    :action (lambda () (diff-buffer-with-file (current-buffer))))

   (init-dwim-make-action
    :title "Bury buffer"
    :description "Move the current buffer to the back of the buffer list"
    :category "Buffer"
    :priority 22
    :action (lambda () (bury-buffer)))

   (init-dwim-make-action
    :title "Open ibuffer"
    :description "Open the full interactive buffer manager"
    :category "Buffer"
    :priority 88
    :action (lambda () (ibuffer)))

   (init-dwim-make-action
    :title "Set major mode"
    :description "Change the major mode of this buffer"
    :category "Buffer"
    :priority 20
    :action (lambda ()
              (let* ((modes (cl-remove-if-not
                             (lambda (s) (string-suffix-p "-mode" (symbol-name s)))
                             (apropos-internal "" #'commandp)))
                     (choice (completing-read
                              "Major mode: "
                              (mapcar #'symbol-name modes)
                              nil t nil nil
                              (symbol-name major-mode))))
                (funcall (intern choice)))))

   (init-dwim-make-action
    :title "Toggle word-wrap"
    :description "Toggle wrapping of long lines at word boundaries"
    :category "Buffer"
    :priority 39
    :action (lambda ()
              (toggle-word-wrap)
              (message "Word-wrap %s"
                       (if word-wrap "on" "off"))))

   (init-dwim-make-action
    :title "Toggle fill-column indicator"
    :description "Show or hide the fill-column ruler line"
    :category "Buffer"
    :priority 37
    :predicate (lambda () (fboundp 'display-fill-column-indicator-mode))
    :action (lambda ()
              (display-fill-column-indicator-mode 'toggle)
              (message "Fill-column indicator %s"
                       (if display-fill-column-indicator "on" "off"))))))

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
                                         nil 'maximized))))))

   (init-dwim-make-action
    :title "Winner undo"
    :description "Restore the previous window layout (winner-undo)"
    :category "Window"
    :priority 70
    :predicate (lambda () (and (fboundp 'winner-undo)
                               (bound-and-true-p winner-mode)))
    :action (lambda () (winner-undo)))

   (init-dwim-make-action
    :title "Winner redo"
    :description "Re-apply the next window layout (winner-redo)"
    :category "Window"
    :priority 68
    :predicate (lambda () (and (fboundp 'winner-redo)
                               (bound-and-true-p winner-mode)))
    :action (lambda () (winner-redo)))

   (init-dwim-make-action
    :title "Dedicate window"
    :description "Toggle dedicated mode — prevent buffer switching in this window"
    :category "Window"
    :priority 40
    :action (lambda ()
              (let ((dedicated (window-dedicated-p (selected-window))))
                (set-window-dedicated-p (selected-window) (not dedicated))
                (message "Window %s"
                         (if (not dedicated) "dedicated" "undedicated")))))

   (init-dwim-make-action
    :title "Fit window to buffer"
    :description "Shrink the window to fit its buffer contents"
    :category "Window"
    :priority 38
    :predicate (lambda () (fboundp 'fit-window-to-buffer))
    :action (lambda () (fit-window-to-buffer)))))

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
    :action (lambda () (call-interactively #'define-global-abbrev)))

   (init-dwim-make-action
    :title "List snippets for mode"
    :description "Show all yasnippets available for the current major mode"
    :category "Snippet"
    :priority 60
    :predicate (lambda () (fboundp 'yas-describe-tables))
    :action (lambda () (yas-describe-tables)))

   (init-dwim-make-action
    :title "Try snippet in temp buffer"
    :description "Open a scratch buffer in the current mode for snippet testing"
    :category "Snippet"
    :priority 45
    :action (lambda ()
              (let ((mode major-mode))
                (with-current-buffer
                    (get-buffer-create
                     (format "*snippet-scratch-%s*" mode))
                  (funcall mode)
                  (when (fboundp 'yas-minor-mode)
                    (yas-minor-mode 1))
                  (pop-to-buffer (current-buffer))))))))

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
                      (when (fboundp 'gptel-send) (gptel-send)))))))

     (init-dwim-make-action
      :title "AI: explain in plain English"
      :description "Translate the selected code to a plain English description"
      :category "AI"
      :priority 52
      :predicate (lambda ()
                   (and (init-dwim--ai-available-p)
                        (init-dwim--region-active-p)))
      :action (lambda ()
                (let ((beg (region-beginning))
                      (end (region-end)))
                  (init-dwim--ai-send-region
                   beg end
                   "Explain what this code does in plain English, step by step:"))))

     (init-dwim-make-action
      :title "AI: suggest better name"
      :description "Ask AI to propose a clearer name for the symbol at point"
      :category "AI"
      :priority 50
      :predicate (lambda ()
                   (and (init-dwim--ai-available-p)
                        (init-dwim--symbol-string)))
      :action (lambda ()
                (when-let ((sym (init-dwim--symbol-string)))
                  (let* ((ctx (buffer-substring-no-properties
                               (max (point-min) (- (point) 300))
                               (min (point-max) (+ (point) 300))))
                         (prompt (format
                                  "Suggest 3 clearer names for `%s' in this context:"
                                  sym)))
                    (init-dwim--ai-send-region
                     (max (point-min) (- (point) 300))
                     (min (point-max) (+ (point) 300))
                     prompt)
                    (ignore ctx)))))

     (init-dwim-make-action
      :title "AI: refactor for readability"
      :description "Ask AI to refactor the selected code without changing behaviour"
      :category "AI"
      :priority 48
      :predicate (lambda ()
                   (and (init-dwim--ai-available-p)
                        (init-dwim--region-active-p)))
      :action (lambda ()
                (let ((beg (region-beginning))
                      (end (region-end)))
                  (init-dwim--ai-send-region
                   beg end
                   "Refactor this code for readability without changing its behaviour. Show the improved version:")))))))

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
                  (langtool-check))))

     (init-dwim-make-action
      :title "Add word to personal dictionary"
      :description "Add the word at point to the personal Ispell dictionary"
      :category "Spell"
      :priority 68
      :predicate (lambda ()
                   (and (fboundp 'ispell-word)
                        (thing-at-point 'word t)))
      :action (lambda ()
                (let ((word (thing-at-point 'word t)))
                  (ispell-word)
                  (message "Word processed: %s" word))))

     (init-dwim-make-action
      :title "Auto-detect and set dictionary"
      :description "Detect buffer language and switch Ispell dictionary"
      :category "Spell"
      :priority 48
      :predicate (lambda ()
                   (and (fboundp 'ispell-change-dictionary)
                        (fboundp 'langdetect-detect)))
      :action (lambda ()
                (let* ((text (buffer-substring-no-properties
                              (point-min) (min (point-max) 1000)))
                       (lang (ignore-errors
                               (car (langdetect-detect text)))))
                  (if lang
                      (progn
                        (ispell-change-dictionary lang)
                        (message "Dictionary set to: %s" lang))
                    (call-interactively #'ispell-change-dictionary))))))))

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
                                 (shell-quote-argument target))))))

   (init-dwim-make-action
    :title "Open eat terminal"
    :description "Open an eat terminal emulator buffer"
    :category "Terminal"
    :priority 72
    :predicate (lambda () (fboundp 'eat))
    :action (lambda () (eat)))

   (init-dwim-make-action
    :title "Open ansi-term"
    :description "Open a full ANSI terminal buffer"
    :category "Terminal"
    :priority 62
    :action (lambda ()
              (let ((shell (or (getenv "SHELL") "/bin/bash")))
                (ansi-term shell))))

   (init-dwim-make-action
    :title "Change default directory"
    :description "Set the working directory for this buffer"
    :category "Shell"
    :priority 48
    :action (lambda ()
              (let ((dir (read-directory-name "Set default-directory: "
                                              default-directory)))
                (setq-local default-directory dir)
                (message "default-directory → %s" dir))))))

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
    :title "Evaluate expression"
    :description "Evaluate an Elisp expression (M-:)"
    :category "Emacs"
    :priority 42
    :action (lambda () (call-interactively #'eval-expression)))

   (init-dwim-make-action
    :title "Toggle debug-on-quit"
    :description "Enter debugger on C-g when debug-on-quit is on"
    :category "Emacs"
    :priority 30
    :action (lambda ()
              (setq debug-on-quit (not debug-on-quit))
              (message "debug-on-quit: %s"
                       (if debug-on-quit "on" "off"))))

   (init-dwim-make-action
    :title "Open *Backtrace* buffer"
    :description "Jump to the most recent Emacs backtrace"
    :category "Emacs"
    :priority 28
    :predicate (lambda () (get-buffer "*Backtrace*"))
    :action (lambda () (pop-to-buffer "*Backtrace*")))

   (init-dwim-make-action
    :title "List all keybindings"
    :description "Open a buffer showing all active key bindings"
    :category "Emacs"
    :priority 26
    :action (lambda () (describe-bindings)))))

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
    :category "Session"
    :priority 120
    :predicate (lambda () (fboundp 'init-dwim-explain))
    :action (lambda ()
              (call-interactively #'init-dwim-explain)))

   (init-dwim-make-action
    :title "Suspend / iconify frame"
    :description "Iconify the current Emacs frame"
    :category "Session"
    :priority 40
    :action (lambda () (suspend-zframe)))

   (init-dwim-make-action
    :title "Clear recent files list"
    :description "Run recentf-cleanup to purge stale entries"
    :category "Session"
    :priority 35
    :predicate (lambda () (and (fboundp 'recentf-cleanup)
                               (bound-and-true-p recentf-mode)))
    :action (lambda ()
              (recentf-cleanup)
              (message "recentf list cleaned")))

   (init-dwim-make-action
    :title "Save desktop session"
    :description "Persist open buffers to the desktop file"
    :category "Session"
    :priority 32
    :predicate (lambda () (fboundp 'desktop-save-in-desktop-dir))
    :action (lambda ()
              (desktop-save-in-desktop-dir)
              (message "Desktop session saved")))))

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
  "Return diagnostic actions when flycheck or flymake is active.
Flymake-specific actions are included here; init-dwim-flymake-provider
is retained for compatibility but returns nil."
  (when (or (and (boundp 'flymake-mode) flymake-mode)
            (and (boundp 'flycheck-mode) flycheck-mode))
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
      :action (lambda () (flycheck-explain-error-at-point)))

     ;; Flymake-specific (merged from init-dwim-flymake-provider)
     (init-dwim-make-action
      :title "Flymake: show project diagnostics"
      :description "Open Flymake's project-wide diagnostics buffer"
      :category "Diagnostics"
      :priority 73
      :predicate (lambda ()
                   (and (bound-and-true-p flymake-mode)
                        (fboundp 'flymake-show-project-diagnostics)))
      :action #'flymake-show-project-diagnostics)

     (init-dwim-make-action
      :title "Flymake: start check"
      :description "Ask Flymake to re-check the current buffer"
      :category "Diagnostics"
      :priority 64
      :predicate (lambda ()
                   (and (bound-and-true-p flymake-mode)
                        (fboundp 'flymake-start)))
      :action #'flymake-start)

     (init-dwim-make-action
      :title "Flymake: show diagnostic at point"
      :description "Display Flymake diagnostic details at point"
      :category "Diagnostics"
      :priority 63
      :predicate (lambda ()
                   (and (bound-and-true-p flymake-mode)
                        (fboundp 'flymake-show-diagnostic)))
      :action #'flymake-show-diagnostic))))

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
    :action (lambda () (consult-resume)))

   (init-dwim-make-action
    :title "Browse command history"
    :description "Repeat a complex Elisp command from history (M-x, M-:)"
    :category "History"
    :priority 60
    :predicate (lambda () (fboundp 'consult-complex-command))
    :action (lambda () (consult-complex-command)))

   (init-dwim-make-action
    :title "Visual undo tree (vundo)"
    :description "Browse undo history as a navigable tree"
    :category "History"
    :priority 78
    :predicate (lambda () (fboundp 'vundo))
    :action (lambda () (vundo)))

   (init-dwim-make-action
    :title "Search buffer with last pattern"
    :description "Re-run the previous search pattern with consult-line"
    :category "History"
    :priority 55
    :predicate (lambda ()
                 (and (fboundp 'consult-line)
                      (bound-and-true-p isearch-string)
                      (not (string-empty-p isearch-string))))
    :action (lambda ()
              (consult-line isearch-string)))))

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
                   (and (init-dwim--buffer-file-p)
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
                   (and (init-dwim--buffer-file-p)
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
      :action (lambda () (call-interactively #'edebug-defun)))

     (init-dwim-make-action
      :title "Find all callers"
      :description "Find all references to the function at point"
      :category "Elisp"
      :priority 58
      :predicate (lambda () (init-dwim--symbol-string))
      :action (lambda ()
                (when-let ((sym (init-dwim--symbol-string)))
                  (xref-find-references sym))))

     (init-dwim-make-action
      :title "Toggle debug-on-error"
      :description "Enable or disable Emacs Lisp error debugging"
      :category "Elisp"
      :priority 56
      :action (lambda ()
                (setq debug-on-error (not debug-on-error))
                (message "debug-on-error: %s"
                         (if debug-on-error "on" "off"))))

     (init-dwim-make-action
      :title "Benchmark expression"
      :description "Time the expression at point with benchmark-run"
      :category "Elisp"
      :priority 52
      :predicate (lambda () (fboundp 'benchmark-run))
      :action (lambda ()
                (let* ((form (read-from-minibuffer
                              "Benchmark expression: "
                              (when (fboundp 'thing-at-point)
                                (thing-at-point 'sexp t))))
                       (result (benchmark-run 1 (eval (read form)))))
                  (message "Time: %.6fs  GC runs: %d  GC time: %.6fs"
                           (car result) (cadr result) (caddr result))))))))

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

;;; ── Expand-region ─────────────────────────────────────────────────────────

(defun init-dwim-expand-region-provider ()
  "Return expand-region actions when the package is available."
  (when (fboundp 'er/expand-region)
    (list
     (init-dwim-make-action
      :title "Expand region"
      :description "Expand the selection to the next semantic unit"
      :category "Selection"
      :priority 88
      :action (lambda () (er/expand-region 1)))

     (init-dwim-make-action
      :title "Contract region"
      :description "Shrink the selection to the previous semantic unit"
      :category "Selection"
      :priority 85
      :predicate (lambda () (use-region-p))
      :action (lambda () (er/contract-region 1)))

     (init-dwim-make-action
      :title "Expand to word"
      :description "Select the word at point"
      :category "Selection"
      :priority 80
      :predicate (lambda () (fboundp 'er/mark-word))
      :action (lambda () (er/mark-word)))

     (init-dwim-make-action
      :title "Expand to symbol"
      :description "Select the symbol at point"
      :category "Selection"
      :priority 78
      :predicate (lambda () (fboundp 'er/mark-symbol))
      :action (lambda () (er/mark-symbol)))

     (init-dwim-make-action
      :title "Expand to defun"
      :description "Select the current function definition"
      :category "Selection"
      :priority 75
      :predicate (lambda ()
                   (and (derived-mode-p 'prog-mode)
                        (fboundp 'er/mark-defun)))
      :action (lambda () (er/mark-defun)))

     (init-dwim-make-action
      :title "Expand to string contents"
      :description "Select the contents of the string at point"
      :category "Selection"
      :priority 72
      :predicate (lambda () (fboundp 'er/mark-inside-quotes))
      :action (lambda () (er/mark-inside-quotes)))

     (init-dwim-make-action
      :title "Expand to balanced expression"
      :description "Select the innermost balanced pair (parens/brackets/braces)"
      :category "Selection"
      :priority 70
      :predicate (lambda () (fboundp 'er/mark-inside-pairs))
      :action (lambda () (er/mark-inside-pairs))))))

;;; ── Smartparens ───────────────────────────────────────────────────────────

(defun init-dwim-smartparens-provider ()
  "Return smartparens structural editing actions."
  (when (init-dwim--sp-active-p)
    (list
     (init-dwim-make-action
      :title "Slurp forward"
      :description "Extend the current sexp to include the next form"
      :category "Parens"
      :priority 90
      :predicate (lambda () (fboundp 'sp-forward-slurp-sexp))
      :action (lambda () (sp-forward-slurp-sexp)))

     (init-dwim-make-action
      :title "Barf forward"
      :description "Shrink the current sexp by expelling the last form"
      :category "Parens"
      :priority 88
      :predicate (lambda () (fboundp 'sp-forward-barf-sexp))
      :action (lambda () (sp-forward-barf-sexp)))

     (init-dwim-make-action
      :title "Slurp backward"
      :description "Extend the current sexp to include the previous form"
      :category "Parens"
      :priority 86
      :predicate (lambda () (fboundp 'sp-backward-slurp-sexp))
      :action (lambda () (sp-backward-slurp-sexp)))

     (init-dwim-make-action
      :title "Barf backward"
      :description "Shrink the current sexp by expelling the first form"
      :category "Parens"
      :priority 84
      :predicate (lambda () (fboundp 'sp-backward-barf-sexp))
      :action (lambda () (sp-backward-barf-sexp)))

     (init-dwim-make-action
      :title "Splice sexp"
      :description "Remove the surrounding pair, keeping its contents"
      :category "Parens"
      :priority 82
      :predicate (lambda () (fboundp 'sp-splice-sexp))
      :action (lambda () (sp-splice-sexp)))

     (init-dwim-make-action
      :title "Wrap with parens"
      :description "Wrap the expression at point in parentheses"
      :category "Parens"
      :priority 80
      :predicate (lambda () (fboundp 'sp-wrap-round))
      :action (lambda () (sp-wrap-round)))

     (init-dwim-make-action
      :title "Wrap with brackets"
      :description "Wrap the expression at point in square brackets"
      :category "Parens"
      :priority 78
      :predicate (lambda () (fboundp 'sp-wrap-square))
      :action (lambda () (sp-wrap-square)))

     (init-dwim-make-action
      :title "Wrap with braces"
      :description "Wrap the expression at point in curly braces"
      :category "Parens"
      :priority 76
      :predicate (lambda () (fboundp 'sp-wrap-curly))
      :action (lambda () (sp-wrap-curly)))

     (init-dwim-make-action
      :title "Kill sexp"
      :description "Kill the balanced expression at point"
      :category "Parens"
      :priority 74
      :predicate (lambda () (fboundp 'sp-kill-sexp))
      :action (lambda () (sp-kill-sexp)))

     (init-dwim-make-action
      :title "Select containing sexp"
      :description "Select the entire containing balanced expression"
      :category "Parens"
      :priority 72
      :predicate (lambda () (fboundp 'sp-select-next-thing))
      :action (lambda () (sp-select-next-thing))))))

;;; ── JSON / YAML ───────────────────────────────────────────────────────────

(defun init-dwim-json-yaml-provider ()
  "Return actions for JSON and YAML buffers."
  (cond
   ((init-dwim--json-mode-p)
    (list
     (init-dwim-make-action
      :title "Pretty-print buffer"
      :description "Format the entire JSON buffer with indentation"
      :category "JSON"
      :priority 95
      :action (lambda ()
                (json-pretty-print-buffer)
                (message "JSON pretty-printed")))

     (init-dwim-make-action
      :title "Minify buffer"
      :description "Collapse the JSON buffer to a single line"
      :category "JSON"
      :priority 85
      :predicate (lambda () (executable-find "jq"))
      :action (lambda ()
                (shell-command-on-region
                 (point-min) (point-max)
                 "jq -c ." nil t)
                (message "JSON minified")))

     (init-dwim-make-action
      :title "Validate JSON"
      :description "Check whether the buffer contains valid JSON"
      :category "JSON"
      :priority 90
      :action (lambda ()
                (condition-case err
                    (progn
                      (json-read-from-string
                       (buffer-substring-no-properties (point-min) (point-max)))
                      (message "✓ Valid JSON"))
                  (error (message "✗ Invalid JSON: %s" err)))))

     (init-dwim-make-action
      :title "Copy JSON path at point"
      :description "Copy the dot-notation key path for the value at point"
      :category "JSON"
      :priority 80
      :predicate (lambda () (init-dwim--json-path-at-point))
      :action (lambda ()
                (let ((path (init-dwim--json-path-at-point)))
                  (if path
                      (progn (kill-new path) (message "Copied path: %s" path))
                    (user-error "Could not determine JSON path")))))

     (init-dwim-make-action
      :title "jq query on buffer"
      :description "Run a jq expression and show the result"
      :category "JSON"
      :priority 78
      :predicate (lambda () (executable-find "jq"))
      :action (lambda ()
                (let* ((expr (read-string "jq expression: " "."))
                       (result (shell-command-to-string
                                (format "echo %s | jq %s"
                                        (shell-quote-argument
                                         (buffer-substring-no-properties
                                          (point-min) (point-max)))
                                        (shell-quote-argument expr)))))
                  (with-current-buffer (get-buffer-create "*jq output*")
                    (erase-buffer)
                    (insert result)
                    (json-mode))
                  (pop-to-buffer "*jq output*"))))

     (init-dwim-make-action
      :title "Sort JSON keys"
      :description "Sort all object keys alphabetically"
      :category "JSON"
      :priority 70
      :predicate (lambda () (executable-find "jq"))
      :action (lambda ()
                (shell-command-on-region
                 (point-min) (point-max)
                 "jq --sort-keys ." nil t)))))

   ((init-dwim--yaml-mode-p)
    (list
     (init-dwim-make-action
      :title "Validate YAML"
      :description "Check whether the buffer is valid YAML (via python/ruby)"
      :category "YAML"
      :priority 90
      :predicate (lambda () (or (executable-find "python3")
                                (executable-find "ruby")))
      :action (lambda ()
                (let* ((file (or (buffer-file-name)
                                 (let ((tmp (make-temp-file "dwim-yaml" nil ".yaml")))
                                   (write-region (point-min) (point-max) tmp)
                                   tmp)))
                       (cmd (if (executable-find "python3")
                                (format "python3 -c \"import yaml,sys; yaml.safe_load(open('%s'))\" && echo OK"
                                        file)
                              (format "ruby -ryaml -e \"YAML.load_file('%s'); puts 'OK'\"" file)))
                       (result (shell-command-to-string cmd)))
                  (message (if (string-match-p "OK" result)
                               "✓ Valid YAML"
                             (concat "✗ " (string-trim result)))))))

     (init-dwim-make-action
      :title "Convert YAML to JSON"
      :description "Convert this YAML buffer to JSON and display it"
      :category "YAML"
      :priority 80
      :predicate (lambda () (executable-find "python3"))
      :action (lambda ()
                (let* ((yaml-text (buffer-substring-no-properties (point-min) (point-max)))
                       (result (with-temp-buffer
                                 (insert yaml-text)
                                 (shell-command-on-region
                                  (point-min) (point-max)
                                  "python3 -c 'import sys,yaml,json; print(json.dumps(yaml.safe_load(sys.stdin), indent=2))'"
                                  nil t)
                                 (buffer-string))))
                  (with-current-buffer (get-buffer-create "*yaml→json*")
                    (erase-buffer)
                    (insert result)
                    (when (fboundp 'json-mode) (json-mode)))
                  (pop-to-buffer "*yaml→json*"))))

     (init-dwim-make-action
      :title "Indent YAML region"
      :description "Re-indent the YAML region or buffer"
      :category "YAML"
      :priority 75
      :action (lambda ()
                (if (use-region-p)
                    (indent-region (region-beginning) (region-end))
                  (indent-region (point-min) (point-max)))))))))

;;; ── Python ────────────────────────────────────────────────────────────────

(defun init-dwim-python-provider ()
  "Return actions specific to Python buffers."
  (when (init-dwim--python-mode-p)
    (list
     (init-dwim-make-action
      :title "Run file with Python"
      :description "Execute the current file with python3"
      :category "Python"
      :priority 95
      :predicate (lambda () (and (init-dwim--buffer-file-p) (executable-find "python3")))
      :action (lambda ()
                (compile (format "python3 %s"
                                 (shell-quote-argument (buffer-file-name))))))

     (init-dwim-make-action
      :title "Run pytest on file"
      :description "Run pytest for the current test file"
      :category "Python"
      :priority 92
      :predicate (lambda ()
                   (or (fboundp 'pytest-one)
                       (fboundp 'pytest-module)
                       (executable-find "pytest")))
      :action (lambda ()
                (cond
                 ((fboundp 'pytest-module) (pytest-module))
                 ((executable-find "pytest")
                  (compile (format "pytest %s -v"
                                   (shell-quote-argument (buffer-file-name)))))
                 (t (user-error "pytest not available")))))

     (init-dwim-make-action
      :title "Run nearest pytest"
      :description "Run the test function nearest to point"
      :category "Python"
      :priority 90
      :predicate (lambda () (fboundp 'pytest-one))
      :action (lambda () (call-interactively #'pytest-one)))

     (init-dwim-make-action
      :title "Start Python shell"
      :description "Open a Python interactive shell for this buffer"
      :category "Python"
      :priority 88
      :predicate (lambda () (fboundp 'run-python))
      :action (lambda () (run-python nil nil t)))

     (init-dwim-make-action
      :title "Send defun to Python shell"
      :description "Evaluate the function at point in the Python shell"
      :category "Python"
      :priority 85
      :predicate (lambda () (fboundp 'python-shell-send-defun))
      :action (lambda () (python-shell-send-defun nil)))

     (init-dwim-make-action
      :title "Send buffer to Python shell"
      :description "Evaluate the entire buffer in the Python shell"
      :category "Python"
      :priority 82
      :predicate (lambda () (fboundp 'python-shell-send-buffer))
      :action (lambda () (python-shell-send-buffer)))

     (init-dwim-make-action
      :title "Check with flake8"
      :description "Run flake8 on the current file"
      :category "Python"
      :priority 78
      :predicate (lambda () (and (init-dwim--buffer-file-p) (executable-find "flake8")))
      :action (lambda ()
                (compile (format "flake8 %s"
                                 (shell-quote-argument (buffer-file-name))))))

     (init-dwim-make-action
      :title "Type-check with mypy"
      :description "Run mypy type checker on the current file"
      :category "Python"
      :priority 76
      :predicate (lambda () (and (init-dwim--buffer-file-p) (executable-find "mypy")))
      :action (lambda ()
                (compile (format "mypy %s"
                                 (shell-quote-argument (buffer-file-name))))))

     (init-dwim-make-action
      :title "Format with black"
      :description "Format the buffer with the black formatter"
      :category "Python"
      :priority 80
      :predicate (lambda () (and (init-dwim--buffer-file-p) (executable-find "black")))
      :action (lambda ()
                (shell-command
                 (format "black %s" (shell-quote-argument (buffer-file-name))))
                (revert-buffer nil t t)))

     (init-dwim-make-action
      :title "Sort imports with isort"
      :description "Sort and organise imports using isort"
      :category "Python"
      :priority 75
      :predicate (lambda () (and (init-dwim--buffer-file-p) (executable-find "isort")))
      :action (lambda ()
                (shell-command
                 (format "isort %s" (shell-quote-argument (buffer-file-name))))
                (revert-buffer nil t t)))

     (init-dwim-make-action
      :title "Insert breakpoint"
      :description "Insert a breakpoint() call at point"
      :category "Python"
      :priority 70
      :action (lambda ()
                (back-to-indentation)
                (open-line 1)
                (insert "breakpoint()  # noqa")
                (python-indent-line))))))

;;; ── gptel buffer ──────────────────────────────────────────────────────────

(defun init-dwim-gptel-provider ()
  "Return actions specific to gptel chat buffers."
  (when (init-dwim--gptel-buffer-p)
    (list
     (init-dwim-make-action
      :title "Send to AI"
      :description "Send the current input to the AI backend"
      :category "AI"
      :priority 100
      :predicate (lambda () (fboundp 'gptel-send))
      :action (lambda () (gptel-send)))

     (init-dwim-make-action
      :title "Change AI model"
      :description "Switch the model used by gptel in this buffer"
      :category "AI"
      :priority 85
      :predicate (lambda () (fboundp 'gptel-menu))
      :action (lambda () (call-interactively #'gptel-menu)))

     (init-dwim-make-action
      :title "Set system prompt"
      :description "Edit the system prompt for this gptel session"
      :category "AI"
      :priority 80
      :predicate (lambda () (fboundp 'gptel-system-prompt))
      :action (lambda () (call-interactively #'gptel-system-prompt)))

     (init-dwim-make-action
      :title "Copy last AI response"
      :description "Copy the most recent AI reply to the kill ring"
      :category "AI"
      :priority 75
      :action (lambda ()
                (save-excursion
                  (goto-char (point-max))
                  ;; gptel marks responses with text-property gptel 'response
                  (let* ((end (point))
                         (beg (or (previous-single-property-change
                                   end 'gptel (current-buffer) (point-min))
                                  (point-min)))
                         (text (buffer-substring-no-properties beg end)))
                    (kill-new (string-trim text))
                    (message "Last response copied (%d chars)" (length text))))))

     (init-dwim-make-action
      :title "Clear chat buffer"
      :description "Erase the entire gptel conversation"
      :category "AI"
      :priority 60
      :action (lambda ()
                (when (yes-or-no-p "Clear gptel conversation? ")
                  (let ((inhibit-read-only t))
                    (erase-buffer))
                  (message "Conversation cleared"))))

     (init-dwim-make-action
      :title "Save chat to file"
      :description "Write the gptel buffer to a dated log file"
      :category "AI"
      :priority 55
      :action (lambda ()
                (let* ((dir (expand-file-name "gptel-logs/"
                                              user-emacs-directory))
                       (_ (make-directory dir t))
                       (file (expand-file-name
                              (format "chat-%s.org"
                                      (format-time-string "%Y%m%d-%H%M%S"))
                              dir)))
                  (write-region (point-min) (point-max) file)
                  (message "Saved to %s" file)))))))

;;; ── Package management ────────────────────────────────────────────────────

(defun init-dwim-package-provider ()
  "Return package and straight.el management actions."
  (list
   (init-dwim-make-action
    :title "List installed packages"
    :description "Open the package list buffer"
    :category "Package"
    :priority 70
    :action (lambda () (list-packages)))

   (init-dwim-make-action
    :title "Install package"
    :description "Install a package with straight or package.el"
    :category "Package"
    :priority 68
    :action (lambda ()
              (if (fboundp 'straight-use-package)
                  (call-interactively #'straight-use-package)
                (call-interactively #'package-install))))

   (init-dwim-make-action
    :title "straight: pull all"
    :description "Update all straight.el recipes from their remotes"
    :category "Package"
    :priority 65
    :predicate (lambda () (fboundp 'straight-pull-all))
    :action (lambda () (straight-pull-all)))

   (init-dwim-make-action
    :title "straight: rebuild all"
    :description "Rebuild all straight.el packages"
    :category "Package"
    :priority 62
    :predicate (lambda () (fboundp 'straight-rebuild-all))
    :action (lambda () (straight-rebuild-all)))

   (init-dwim-make-action
    :title "straight: check for updates"
    :description "Fetch and check for updates without applying them"
    :category "Package"
    :priority 60
    :predicate (lambda () (fboundp 'straight-fetch-all))
    :action (lambda () (straight-fetch-all)))

   (init-dwim-make-action
    :title "straight: freeze lockfile"
    :description "Write the current package versions to a lockfile"
    :category "Package"
    :priority 55
    :predicate (lambda () (fboundp 'straight-freeze-versions))
    :action (lambda () (straight-freeze-versions)))

   (init-dwim-make-action
    :title "straight: thaw lockfile"
    :description "Restore package versions from the lockfile"
    :category "Package"
    :priority 53
    :predicate (lambda () (fboundp 'straight-thaw-versions))
    :action (lambda () (straight-thaw-versions)))

   (init-dwim-make-action
    :title "Describe package at point"
    :description "Show information about the package named at point"
    :category "Package"
    :priority 72
    :predicate (lambda ()
                 (and (init-dwim--symbol-string)
                      (intern-soft (init-dwim--symbol-string))
                      (or (fboundp 'describe-package)
                          (fboundp 'straight--get-package))))
    :action (lambda ()
              (let ((sym (intern-soft (init-dwim--symbol-string))))
                (when sym
                  (describe-package sym)))))))

;;; Embark DWIM provider

(defun init-dwim-embark-provider ()
  "Return Embark actions for the thing at point."
  (when (featurep 'embark)
    (list
     (init-dwim-make-action
      :title "Embark act"
      :description "Open Embark actions for the target at point"
      :category "Embark"
      :priority 98
      :predicate (lambda () (fboundp 'embark-act))
      :action #'embark-act)

     (init-dwim-make-action
      :title "Embark DWIM"
      :description "Run Embark's default action for the target at point"
      :category "Embark"
      :priority 100
      :predicate (lambda () (fboundp 'embark-dwim))
      :action #'embark-dwim)

     (init-dwim-make-action
      :title "Embark collect"
      :description "Collect candidates related to the current target"
      :category "Embark"
      :priority 70
      :predicate (lambda () (fboundp 'embark-collect))
      :action #'embark-collect)

     (init-dwim-make-action
      :title "Embark export"
      :description "Export current minibuffer or target candidates"
      :category "Embark"
      :priority 68
      :predicate (lambda () (fboundp 'embark-export))
      :action #'embark-export))))

;;; Project task / build DWIM provider

(defun init-dwim-project-task-provider ()
  "Return project task actions inferred from common project files."
  (let ((actions nil))

    ;; package.json
    (when (init-dwim-extra--project-has-file-p "package.json")
      (push
       (init-dwim-make-action
        :title "npm install"
        :description "Install JavaScript dependencies"
        :category "Project"
        :priority 67
        :action (lambda ()
                  (init-dwim-extra--compile-in-project "npm install")))
       actions)

      (dolist (script (init-dwim-extra--package-json-scripts))
        (push (init-dwim-extra--npm-run-action
               script
               (cond
                ((member script '("test" "check")) 92)
                ((member script '("build" "compile")) 88)
                ((member script '("lint" "format")) 82)
                ((member script '("dev" "start")) 78)
                (t 70)))
              actions)))

    ;; Makefile
    (when (or (init-dwim-extra--project-has-file-p "Makefile")
              (init-dwim-extra--project-has-file-p "makefile"))
      (push
       (init-dwim-make-action
        :title "make"
        :description "Run default Makefile target"
        :category "Project"
        :priority 86
        :action (lambda ()
                  (init-dwim-extra--compile-in-project "make")))
       actions)

      (push
       (init-dwim-make-action
        :title "make test"
        :description "Run Makefile test target"
        :category "Project"
        :priority 84
        :action (lambda ()
                  (init-dwim-extra--compile-in-project "make test")))
       actions))

    ;; Justfile
    (when (or (init-dwim-extra--project-has-file-p "Justfile")
              (init-dwim-extra--project-has-file-p "justfile"))
      (push
       (init-dwim-make-action
        :title "just"
        :description "Run default just recipe"
        :category "Project"
        :priority 86
        :predicate (lambda () (executable-find "just"))
        :action (lambda ()
                  (init-dwim-extra--compile-in-project "just")))
       actions)

      (push
       (init-dwim-make-action
        :title "choose just recipe"
        :description "Choose and run a just recipe"
        :category "Project"
        :priority 80
        :predicate (lambda () (executable-find "just"))
        :action
        (lambda ()
          (let* ((default-directory (init-dwim--project-root))
                 (recipes
                  (split-string
                   (shell-command-to-string "just --summary")
                   "[ \n]+" t))
                 (recipe (completing-read "Just recipe: " recipes nil t)))
            (init-dwim-extra--compile-in-project
             (format "just %s" recipe)))))
       actions))

    ;; Cargo
    (when (init-dwim-extra--project-has-file-p "Cargo.toml")
      (dolist (pair '(("cargo test" . 92)
                      ("cargo check" . 88)
                      ("cargo build" . 84)
                      ("cargo fmt" . 80)
                      ("cargo clippy" . 78)))
        (push
         (init-dwim-make-action
          :title (car pair)
          :description (format "Run `%s' in the project" (car pair))
          :category "Project"
          :priority (cdr pair)
          :predicate (lambda () (executable-find "cargo"))
          :action (lambda ()
                    (init-dwim-extra--compile-in-project (car pair))))
         actions)))

    ;; Go
    (when (init-dwim-extra--project-has-file-p "go.mod")
      (dolist (pair '(("go test ./..." . 92)
                      ("go test ./... -race" . 86)
                      ("go vet ./..." . 82)
                      ("go mod tidy" . 78)))
        (push
         (init-dwim-make-action
          :title (car pair)
          :description (format "Run `%s' in the project" (car pair))
          :category "Project"
          :priority (cdr pair)
          :predicate (lambda () (executable-find "go"))
          :action (lambda ()
                    (init-dwim-extra--compile-in-project (car pair))))
         actions)))

    ;; Python
    (when (or (init-dwim-extra--project-has-file-p "uv.lock") 
              (init-dwim-extra--project-has-file-p "pyproject.toml")
              (init-dwim-extra--project-has-file-p "setup.py")
              (init-dwim-extra--project-has-file-p "pytest.ini"))
      (dolist (pair '(("pytest" . 92)
                      ("python -m pytest" . 90)
                      ("ruff check ." . 84)
                      ("ruff format ." . 80)))
        (push
         (init-dwim-make-action
          :title (car pair)
          :description (format "Run `%s' in the project" (car pair))
          :category "Project"
          :priority (cdr pair)
          :predicate (lambda ()
                       (executable-find
                        (car (split-string (car pair)))))
          :action (lambda ()
                    (init-dwim-extra--compile-in-project (car pair))))
         actions)))

    ;; Ruby / Bundler / RSpec
    (when (init-dwim-extra--project-has-any-file-p "Gemfile" "Gemfile.lock")
      (dolist (pair '(("bundle install" . 80)
                      ("bundle exec rspec" . 92)
                      ("bundle exec rake" . 82)
                      ("bundle exec rubocop" . 78)
                      ("bundle exec rubocop -a" . 76)))
        (push
         (init-dwim-make-action
          :title (car pair)
          :description (format "Run `%s' in the project" (car pair))
          :category "Project"
          :priority (cdr pair)
          :predicate (lambda () (executable-find "bundle"))
          :action (let ((cmd (car pair)))
                    (lambda ()
                      (init-dwim-extra--compile-in-project cmd))))
         actions)))

    ;; Java / Maven
    (when (init-dwim-extra--project-has-file-p "pom.xml")
      (dolist (pair '(("mvn test" . 92)
                      ("mvn package" . 86)
                      ("mvn compile" . 82)
                      ("mvn clean" . 78)))
        (push
         (init-dwim-make-action
          :title (car pair)
          :description (format "Run `%s' in the project" (car pair))
          :category "Project"
          :priority (cdr pair)
          :predicate (lambda () (executable-find "mvn"))
          :action (let ((cmd (car pair)))
                    (lambda ()
                      (init-dwim-extra--compile-in-project cmd))))
         actions)))

    ;; Java / Gradle
    (when (init-dwim-extra--project-has-any-file-p "build.gradle" "build.gradle.kts")
      (dolist (pair '(("gradle test" . 92)
                      ("gradle build" . 86)
                      ("gradle clean" . 78)
                      ("gradle check" . 84)))
        (push
         (init-dwim-make-action
          :title (car pair)
          :description (format "Run `%s' in the project" (car pair))
          :category "Project"
          :priority (cdr pair)
          :predicate (lambda ()
                       (or (executable-find "gradle")
                           (file-executable-p
                            (expand-file-name "gradlew"
                                              (init-dwim--project-root)))))
          :action (let ((cmd (car pair)))
                    (lambda ()
                      (init-dwim-extra--compile-in-project
                       (if (file-executable-p
                            (expand-file-name "gradlew"
                                              (init-dwim--project-root)))
                           (concat "./gradlew " (cadr (split-string cmd)))
                         cmd)))))
         actions)))

    ;; Elixir / Mix
    (when (init-dwim-extra--project-has-file-p "mix.exs")
      (dolist (pair '(("mix test" . 92)
                      ("mix compile" . 86)
                      ("mix format" . 82)
                      ("mix deps.get" . 78)
                      ("mix credo" . 76)))
        (push
         (init-dwim-make-action
          :title (car pair)
          :description (format "Run `%s' in the project" (car pair))
          :category "Project"
          :priority (cdr pair)
          :predicate (lambda () (executable-find "mix"))
          :action (let ((cmd (car pair)))
                    (lambda ()
                      (init-dwim-extra--compile-in-project cmd))))
         actions)))

    actions))

;;; ── Docker ────────────────────────────────────────────────────────────────

(defun init-dwim-docker-provider ()
  "Return Docker and Docker Compose actions."
  (let ((actions nil))

    (when (init-dwim-extra--project-has-file-p "Dockerfile")
      (push
       (init-dwim-make-action
        :title "docker build project"
        :description "Build Docker image from project Dockerfile"
        :category "Docker"
        :priority 84
        :predicate (lambda () (executable-find "docker"))
        :action
        (lambda ()
          (let* ((root (directory-file-name
                        (file-name-nondirectory
                         (directory-file-name
                          (init-dwim--project-root)))))
                 (tag (read-string "Docker tag: " root)))
            (init-dwim-extra--compile-in-project
             (format "docker build -t %s ." tag)))))
       actions)

      (push
       (init-dwim-make-action
        :title "docker run image"
        :description "Run a Docker image by name"
        :category "Docker"
        :priority 70
        :predicate (lambda () (executable-find "docker"))
        :action
        (lambda ()
          (let ((image (read-string "Image: ")))
            (init-dwim-extra--shell-command-in-project
             (format "docker run --rm -it %s" image)))))
       actions))

    (when (init-dwim-extra--docker-compose-file-p)
      (dolist (pair '(("docker compose up" . 88)
                      ("docker compose up --build" . 86)
                      ("docker compose down" . 78)
                      ("docker compose ps" . 72)
                      ("docker compose logs -f" . 70)))
        (push
         (init-dwim-make-action
          :title (car pair)
          :description (format "Run `%s' in the project" (car pair))
          :category "Docker"
          :priority (cdr pair)
          :predicate (lambda () (executable-find "docker"))
          :action
          (let ((cmd (car pair)))
            (lambda ()
              (init-dwim-extra--compile-in-project cmd))))
         actions)))

    ;; Always-available Docker commands (don't require a project file)
    (when (executable-find "docker")
      (push
       (init-dwim-make-action
        :title "docker ps"
        :description "List currently running containers"
        :category "Docker"
        :priority 75
        :predicate (lambda () (executable-find "docker"))
        :action (lambda ()
                  (compile "docker ps")))
       actions)

      (push
       (init-dwim-make-action
        :title "docker stop container"
        :description "Stop a running container by name"
        :category "Docker"
        :priority 68
        :predicate (lambda () (executable-find "docker"))
        :action (lambda ()
                  (let ((name (read-string "Container name: ")))
                    (compile (format "docker stop %s"
                                     (shell-quote-argument name))))))
       actions)

      (push
       (init-dwim-make-action
        :title "docker rm container"
        :description "Remove a stopped container by name"
        :category "Docker"
        :priority 66
        :predicate (lambda () (executable-find "docker"))
        :action (lambda ()
                  (let ((name (read-string "Container name: ")))
                    (compile (format "docker rm %s"
                                     (shell-quote-argument name))))))
       actions)

      (push
       (init-dwim-make-action
        :title "docker exec shell"
        :description "Open a shell inside a running container"
        :category "Docker"
        :priority 74
        :predicate (lambda () (executable-find "docker"))
        :action (lambda ()
                  (let ((name (read-string "Container name: ")))
                    (async-shell-command
                     (format "docker exec -it %s sh"
                             (shell-quote-argument name))))))
       actions)

      (push
       (init-dwim-make-action
        :title "docker compose exec"
        :description "Exec a command in a running compose service"
        :category "Docker"
        :priority 72
        :predicate (lambda ()
                     (and (executable-find "docker")
                          (init-dwim-extra--docker-compose-file-p)))
        :action (lambda ()
                  (let* ((svc (read-string "Service: "))
                         (cmd (read-string "Command: " "sh")))
                    (async-shell-command
                     (format "docker compose exec %s %s"
                             (shell-quote-argument svc)
                             cmd)))))
       actions)

      (push
       (init-dwim-make-action
        :title "docker image ls"
        :description "List locally available Docker images"
        :category "Docker"
        :priority 64
        :predicate (lambda () (executable-find "docker"))
        :action (lambda () (compile "docker image ls")))
       actions)

      (push
       (init-dwim-make-action
        :title "docker system prune"
        :description "Reclaim disk space by removing unused Docker data"
        :category "Docker"
        :priority 55
        :predicate (lambda () (executable-find "docker"))
        :action (lambda ()
                  (when (yes-or-no-p
                         "Run docker system prune? This removes unused data: ")
                    (compile "docker system prune -f"))))
       actions))

    actions))

;;; Quick notes DWIM provider

(defun init-dwim-quick-note-provider ()
  "Return quick note and capture actions."
  (list
   (init-dwim-make-action
    :title "Quick note"
    :description "Append a quick note to the DWIM inbox file"
    :category "Notes"
    :priority 77
    :action
    (lambda ()
      (let ((note (read-string "Note: ")))
        (init-dwim-extra--append-org-note note nil)
        (message "Saved note"))))

   (init-dwim-make-action
    :title "Capture region as note"
    :description "Append selected text to the DWIM inbox file"
    :category "Notes"
    :priority 93
    :predicate #'init-dwim--region-active-p
    :action
    (lambda ()
      (let ((heading (read-string "Heading: "))
            (body (buffer-substring-no-properties
                   (region-beginning)
                   (region-end))))
        (init-dwim-extra--append-org-note heading body)
        (message "Captured region"))))

   (init-dwim-make-action
    :title "Open DWIM inbox"
    :description "Open the quick note inbox file"
    :category "Notes"
    :priority 65
    :action
    (lambda ()
      (find-file init-dwim-extra-inbox-file)))

   (init-dwim-make-action
    :title "Timestamped journal entry"
    :description "Append a dated entry to the journal file"
    :category "Notes"
    :priority 75
    :action
    (lambda ()
      (let* ((journal (or (and (boundp 'init-dwim-journal-file)
                               init-dwim-journal-file)
                          (expand-file-name "journal.org"
                                            (or (bound-and-true-p org-directory)
                                                user-emacs-directory))))
             (note (read-string "Journal entry: ")))
        (with-current-buffer (find-file-noselect journal)
          (goto-char (point-max))
          (unless (bolp) (insert "\n"))
          (insert (format-time-string "\n* %Y-%m-%d %A\n"))
          (insert note "\n")
          (save-buffer))
        (message "Journal entry saved"))))

   (init-dwim-make-action
    :title "Capture URL at point as note"
    :description "Fetch the page title and save as an Org link note"
    :category "Notes"
    :priority 70
    :predicate (lambda ()
                 (and (init-dwim--url-at-point)
                      (fboundp 'url-retrieve-synchronously)))
    :action
    (lambda ()
      (when-let ((url (init-dwim--url-at-point)))
        (let* ((buf (url-retrieve-synchronously url t t 5))
               (title (if buf
                          (with-current-buffer buf
                            (goto-char (point-min))
                            (if (re-search-forward
                                 "<title>\\([^<]+\\)</title>" nil t)
                                (decode-coding-string
                                 (match-string-no-properties 1)
                                 'utf-8)
                              url))
                        url))
               (link (format "[[%s][%s]]" url (string-trim title))))
          (when buf (kill-buffer buf))
          (init-dwim-extra--append-org-note title link)
          (message "Captured: %s" title)))))

   (init-dwim-make-action
    :title "List recent notes"
    :description "Browse headings in the quick-note inbox"
    :category "Notes"
    :priority 60
    :predicate (lambda ()
                 (and (fboundp 'consult-org-heading)
                      (file-exists-p init-dwim-extra-inbox-file)))
    :action
    (lambda ()
      (with-current-buffer
          (find-file-noselect init-dwim-extra-inbox-file)
        (consult-org-heading))))

   (init-dwim-make-action
    :title "Insert current date"
    :description "Insert today's date at point"
    :category "Notes"
    :priority 55
    :action
    (lambda ()
      (insert (format-time-string "%Y-%m-%d"))))))


;;; ── VC / built-in version control ─────────────────────────────────────────

(defun init-dwim-vc-provider ()
  "Return actions for Emacs' built-in VC system."
  (when (and (init-dwim--buffer-file-p)
             (fboundp 'vc-backend)
             (vc-backend (buffer-file-name)))
    (let ((file (buffer-file-name)))
      (list
       (init-dwim-make-action
        :title "VC diff current file"
        :description "Show a VC diff for the current file"
        :category "VC"
        :priority 72
        :predicate (lambda () (fboundp 'vc-diff))
        :action (lambda () (vc-diff nil)))
       (init-dwim-make-action
        :title "VC log current file"
        :description "Show VC history for the current file"
        :category "VC"
        :priority 70
        :predicate (lambda () (fboundp 'vc-print-log))
        :action (lambda () (vc-print-log)))
       (init-dwim-make-action
        :title "VC annotate current file"
        :description "Annotate the current file with VC blame information"
        :category "VC"
        :priority 68
        :predicate (lambda () (fboundp 'vc-annotate))
        :action (lambda () (vc-annotate file)))
       (init-dwim-make-action
        :title "VC revert current file"
        :description "Revert the current file from version control"
        :category "VC"
        :priority 45
        :predicate (lambda () (fboundp 'vc-revert))
        :action (lambda () (vc-revert)))
       (init-dwim-make-action
        :title "VC register current file"
        :description "Register the current file with VC"
        :category "VC"
        :priority 35
        :predicate (lambda () (fboundp 'vc-register))
        :action (lambda () (vc-register)))
       (init-dwim-make-action
        :title "VC next action"
        :description "Run VC's context-sensitive next action"
        :category "VC"
        :priority 65
        :predicate (lambda () (fboundp 'vc-next-action))
        :action (lambda () (vc-next-action nil)))))))

;;; ── Treesit ───────────────────────────────────────────────────────────────

(defun init-dwim-treesit-provider ()
  "Return actions for Emacs tree-sitter integration."
  (when (and (fboundp 'treesit-available-p)
             (treesit-available-p))
    (list
     (init-dwim-make-action
      :title "Treesit inspect node at point"
      :description "Inspect the tree-sitter node at point"
      :category "Treesit"
      :priority 64
      :predicate (lambda () (fboundp 'treesit-inspect-node-at-point))
      :action #'treesit-inspect-node-at-point)
     (init-dwim-make-action
      :title "Treesit copy node type"
      :description "Copy the type of the tree-sitter node at point"
      :category "Treesit"
      :priority 60
      :predicate (lambda () (fboundp 'treesit-node-at))
      :action (lambda ()
                (let ((node (treesit-node-at (point))))
                  (unless node (user-error "No tree-sitter node at point"))
                  (kill-new (treesit-node-type node))
                  (message "Copied node type: %s" (treesit-node-type node)))))
     (init-dwim-make-action
      :title "Treesit mark node at point"
      :description "Select the tree-sitter node at point"
      :category "Treesit"
      :priority 58
      :predicate (lambda () (fboundp 'treesit-node-at))
      :action (lambda ()
                (let ((node (treesit-node-at (point))))
                  (unless node (user-error "No tree-sitter node at point"))
                  (goto-char (treesit-node-start node))
                  (push-mark (treesit-node-end node) nil t))))
     (init-dwim-make-action
      :title "Treesit mark parent node"
      :description "Select the parent of the tree-sitter node at point"
      :category "Treesit"
      :priority 57
      :predicate (lambda () (fboundp 'treesit-node-parent))
      :action (lambda ()
                (let* ((node (treesit-node-at (point)))
                       (parent (and node (treesit-node-parent node))))
                  (unless parent (user-error "No parent tree-sitter node"))
                  (goto-char (treesit-node-start parent))
                  (push-mark (treesit-node-end parent) nil t))))
     (init-dwim-make-action
      :title "Treesit list parsers"
      :description "Show active tree-sitter parsers for this buffer"
      :category "Treesit"
      :priority 54
      :predicate (lambda () (fboundp 'treesit-parser-list))
      :action (lambda ()
                (message "%s" (mapconcat #'prin1-to-string
                                         (treesit-parser-list)
                                         ", ")))))))

;;; ── Context bookmarks ────────────────────────────────────────────────────

(defun init-dwim-bookmark-context-provider ()
  "Return context-aware bookmark actions."
  (list
   (init-dwim-make-action
    :title "Bookmark current project"
    :description "Create a bookmark at the current project root"
    :category "Bookmark"
    :priority 54
    :predicate #'init-dwim--in-project-p
    :action (lambda ()
              (let ((default-directory (init-dwim--project-root)))
                (bookmark-set (read-string "Project bookmark name: "
                                           (file-name-nondirectory
                                            (directory-file-name default-directory)))))))
   (init-dwim-make-action
    :title "Bookmark current directory"
    :description "Create a bookmark for default-directory"
    :category "Bookmark"
    :priority 52
    :action (lambda ()
              (let ((default-directory default-directory))
                (bookmark-set (read-string "Directory bookmark name: "
                                           (file-name-nondirectory
                                            (directory-file-name default-directory)))))))
   (init-dwim-make-action
    :title "Bookmark current Org heading"
    :description "Create a bookmark at the current Org heading"
    :category "Bookmark"
    :priority 58
    :predicate (lambda () (derived-mode-p 'org-mode))
    :action (lambda ()
              (require 'org)
              (org-back-to-heading t)
              (bookmark-set (read-string "Org heading bookmark name: "
                                         (nth 4 (org-heading-components))))))
   (init-dwim-make-action
    :title "Jump to project bookmark"
    :description "Jump to a bookmark, preferring project-style bookmarks by name"
    :category "Bookmark"
    :priority 50
    :predicate (lambda () (boundp 'bookmark-alist))
    :action (lambda ()
              (require 'bookmark)
              (bookmark-maybe-load-default-file)
              (bookmark-jump (completing-read "Jump to project bookmark: "
                                              (mapcar #'car bookmark-alist)
                                              nil t))))))

;;; ── Snippet maintenance ──────────────────────────────────────────────────

(defun init-dwim-yasnippet-maintenance-provider ()
  "Return actions for maintaining Yasnippet collections."
  (when (featurep 'yasnippet)
    (list
     (init-dwim-make-action
      :title "Visit Yasnippet directories"
      :description "Open the first configured snippet directory"
      :category "Snippet"
      :priority 46
      :action (lambda ()
                (let ((dir (car (if (listp yas-snippet-dirs)
                                    yas-snippet-dirs
                                  (list yas-snippet-dirs)))))
                  (unless dir (user-error "No yas-snippet-dirs configured"))
                  (dired dir))))
     (init-dwim-make-action
      :title "Reload Yasnippets"
      :description "Reload all Yasnippet definitions"
      :category "Snippet"
      :priority 45
      :predicate (lambda () (fboundp 'yas-reload-all))
      :action #'yas-reload-all)
     (init-dwim-make-action
      :title "Create mode snippet"
      :description "Create a new snippet for the current major mode"
      :category "Snippet"
      :priority 44
      :predicate (lambda () (fboundp 'yas-new-snippet))
      :action #'yas-new-snippet)
     (init-dwim-make-action
      :title "Create snippet from region"
      :description "Use the active region as the body of a new snippet"
      :category "Snippet"
      :priority 47
      :predicate #'use-region-p
      :action (lambda ()
                (let ((body (buffer-substring-no-properties
                             (region-beginning) (region-end))))
                  (yas-new-snippet)
                  (goto-char (point-max))
                  (insert body)))))))

;;; ── Transient ────────────────────────────────────────────────────────────

(defun init-dwim-transient-provider ()
  "Return actions for Transient sessions."
  (when (featurep 'transient)
    (list
     (init-dwim-make-action
      :title "Transient resume"
      :description "Resume the most recent transient, when available"
      :category "Transient"
      :priority 42
      :predicate (lambda () (fboundp 'transient-resume))
      :action #'transient-resume)
     (init-dwim-make-action
      :title "Transient quit one"
      :description "Quit the active transient popup"
      :category "Transient"
      :priority 41
      :predicate (lambda () (fboundp 'transient-quit-one))
      :action #'transient-quit-one)
     (init-dwim-make-action
      :title "Transient history next"
      :description "Cycle to the next transient history element"
      :category "Transient"
      :priority 40
      :predicate (lambda () (fboundp 'transient-history-next))
      :action #'transient-history-next)
     (init-dwim-make-action
      :title "Transient history previous"
      :description "Cycle to the previous transient history element"
      :category "Transient"
      :priority 40
      :predicate (lambda () (fboundp 'transient-history-prev))
      :action #'transient-history-prev))))

;;; ── File templates ───────────────────────────────────────────────────────

(defun init-dwim-file-template-provider ()
  "Return small file/template insertion actions."
  (list
   (init-dwim-make-action
    :title "Insert shebang"
    :description "Insert a shebang line chosen from common interpreters"
    :category "Template"
    :priority 48
    :action (lambda ()
              (goto-char (point-min))
              (insert (completing-read "Shebang: "
                                       '("#!/usr/bin/env bash"
                                         "#!/usr/bin/env python3"
                                         "#!/usr/bin/env node"
                                         "#!/usr/bin/env ruby")
                                       nil t)
                      "\n")))
   (init-dwim-make-action
    :title "Insert license header"
    :description "Insert a compact SPDX license header"
    :category "Template"
    :priority 44
    :action (lambda ()
              (insert (format "%s SPDX-License-Identifier: %s\n"
                              (or comment-start "#")
                              (completing-read "License: "
                                               '("MIT" "Apache-2.0" "GPL-3.0-or-later" "BSD-3-Clause")
                                               nil t "MIT")))))
   (init-dwim-make-action
    :title "Insert Emacs Lisp file header"
    :description "Insert a conventional Emacs Lisp file header"
    :category "Template"
    :priority 46
    :predicate (lambda () (derived-mode-p 'emacs-lisp-mode 'lisp-interaction-mode))
    :action (lambda ()
              (let ((name (or (file-name-nondirectory (or (buffer-file-name) ""))
                              "file.el")))
                (goto-char (point-min))
                (insert (format ";;; %s --- Summary -*- lexical-binding: t; -*-\n\n;;; Commentary:\n\n;;; Code:\n\n" name)))))
   (init-dwim-make-action
    :title "Insert Python script template"
    :description "Insert a small Python main-function template"
    :category "Template"
    :priority 46
    :predicate #'init-dwim--python-mode-p
    :action (lambda ()
              (insert "#!/usr/bin/env python3\n\n\ndef main() -> None:\n    pass\n\n\nif __name__ == \"__main__\":\n    main()\n")))
   (init-dwim-make-action
    :title "Insert README skeleton"
    :description "Insert a concise README.md structure"
    :category "Template"
    :priority 43
    :action (lambda ()
              (insert "# Project name\n\n## Overview\n\n## Installation\n\n## Usage\n\n## Development\n\n## License\n")))
   (init-dwim-make-action
    :title "Insert .gitignore template"
    :description "Insert a small language-aware .gitignore template"
    :category "Template"
    :priority 42
    :action (lambda ()
              (insert (pcase major-mode
                        ((or 'python-mode 'python-ts-mode)
                         "__pycache__/\n*.py[cod]\n.venv/\n.env\n.pytest_cache/\n.mypy_cache/\n")
                        ((or 'js-mode 'js-ts-mode 'typescript-mode 'typescript-ts-mode)
                         "node_modules/\ndist/\nbuild/\n.env\n*.log\n")
                        (_
                         ".DS_Store\n.env\n*.log\n/tmp/\n")))))))

;;; ── Security and file safety ─────────────────────────────────────────────

(defun init-dwim-security-provider ()
  "Return small security-oriented buffer and file actions."
  (let ((file (buffer-file-name)))
    (list
     (init-dwim-make-action
      :title "Show current file permissions"
      :description "Display the current file's permission bits"
      :category "Security"
      :priority 38
      :predicate (lambda () file)
      :action (lambda ()
                (let ((modes (file-modes file 'symbolic)))
                  (message "%s: %s" (file-name-nondirectory file) modes))))
     (init-dwim-make-action
      :title "Make current file read-only"
      :description "Remove write bits from the current file"
      :category "Security"
      :priority 36
      :predicate (lambda () file)
      :action (lambda ()
                (set-file-modes file #o444)
                (revert-buffer t t)
                (message "Made read-only: %s" file)))
     (init-dwim-make-action
      :title "Encrypt current file with epa"
      :description "Encrypt the current file using EasyPG"
      :category "Security"
      :priority 34
      :predicate (lambda () (and file (fboundp 'epa-encrypt-file)))
      :action (lambda ()
                (call-interactively #'epa-encrypt-file)))
     (init-dwim-make-action
      :title "Decrypt current file with epa"
      :description "Decrypt the current file using EasyPG"
      :category "Security"
      :priority 34
      :predicate (lambda () (and file (fboundp 'epa-decrypt-file)))
      :action (lambda ()
                (call-interactively #'epa-decrypt-file)))
     (init-dwim-make-action
      :title "Scan buffer for secret-looking strings"
      :description "Search for common token, key, and password patterns"
      :category "Security"
      :priority 40
      :action (lambda ()
                (occur "\\b\\(api[_-]?key\\|secret\\|token\\|password\\|passwd\\|private[_-]?key\\)\\b"))))))

;;;; New providers

;;; ── Clojure / CIDER ──────────────────────────────────────────────────────

(defun init-dwim-clojure-provider ()
  "Return actions for Clojure buffers via CIDER."
  (when (init-dwim--clojure-mode-p)
    (list
     (init-dwim-make-action
      :title "CIDER jack-in"
      :description "Start a Clojure REPL connected to this project"
      :category "Clojure"
      :priority 100
      :predicate (lambda () (fboundp 'cider-jack-in))
      :action (lambda () (cider-jack-in nil)))

     (init-dwim-make-action
      :title "CIDER jack-in ClojureScript"
      :description "Start a ClojureScript REPL"
      :category "Clojure"
      :priority 98
      :predicate (lambda () (fboundp 'cider-jack-in-cljs))
      :action (lambda () (cider-jack-in-cljs nil)))

     (init-dwim-make-action
      :title "Eval buffer"
      :description "Evaluate the entire Clojure buffer"
      :category "Clojure"
      :priority 85
      :predicate (lambda () (fboundp 'cider-eval-buffer))
      :action (lambda () (cider-eval-buffer)))

     (init-dwim-make-action
      :title "Eval defun at point"
      :description "Evaluate the top-level form at point"
      :category "Clojure"
      :priority 90
      :predicate (lambda () (fboundp 'cider-eval-defun-at-point))
      :action (lambda () (cider-eval-defun-at-point nil)))

     (init-dwim-make-action
      :title "Eval last sexp"
      :description "Evaluate the expression before point"
      :category "Clojure"
      :priority 88
      :predicate (lambda () (fboundp 'cider-eval-last-sexp))
      :action (lambda () (cider-eval-last-sexp nil)))

     (init-dwim-make-action
      :title "Load namespace"
      :description "Load the current namespace into the REPL"
      :category "Clojure"
      :priority 82
      :predicate (lambda () (fboundp 'cider-load-buffer))
      :action (lambda () (cider-load-buffer)))

     (init-dwim-make-action
      :title "Run tests in namespace"
      :description "Run all tests in the current namespace"
      :category "Clojure"
      :priority 80
      :predicate (lambda () (fboundp 'cider-test-run-ns-tests))
      :action (lambda () (cider-test-run-ns-tests nil)))

     (init-dwim-make-action
      :title "Run all project tests"
      :description "Run the full project test suite via CIDER"
      :category "Clojure"
      :priority 78
      :predicate (lambda () (fboundp 'cider-test-run-project-tests))
      :action (lambda () (cider-test-run-project-tests nil)))

     (init-dwim-make-action
      :title "Inspect last result"
      :description "Open the CIDER inspector on the last REPL result"
      :category "Clojure"
      :priority 70
      :predicate (lambda () (fboundp 'cider-inspect-last-result))
      :action (lambda () (cider-inspect-last-result)))

     (init-dwim-make-action
      :title "Interrupt evaluation"
      :description "Interrupt the currently running Clojure evaluation"
      :category "Clojure"
      :priority 60
      :predicate (lambda () (fboundp 'cider-interrupt))
      :action (lambda () (cider-interrupt))))))

;;; ── Common Lisp / SLY ────────────────────────────────────────────────────

(defun init-dwim-common-lisp-provider ()
  "Return actions for Common Lisp buffers via SLY."
  (when (init-dwim--common-lisp-mode-p)
    (list
     (init-dwim-make-action
      :title "Start SLY"
      :description "Start an inferior Common Lisp and connect SLY"
      :category "CommonLisp"
      :priority 100
      :predicate (lambda () (fboundp 'sly))
      :action (lambda () (sly)))

     (init-dwim-make-action
      :title "Eval defun"
      :description "Compile and load the top-level form at point"
      :category "CommonLisp"
      :priority 92
      :predicate (lambda () (fboundp 'sly-eval-defun))
      :action (lambda () (sly-eval-defun)))

     (init-dwim-make-action
      :title "Eval last expression"
      :description "Evaluate the expression before point"
      :category "CommonLisp"
      :priority 90
      :predicate (lambda () (fboundp 'sly-eval-last-expression))
      :action (lambda () (sly-eval-last-expression)))

     (init-dwim-make-action
      :title "Compile defun"
      :description "Compile the top-level form at point"
      :category "CommonLisp"
      :priority 88
      :predicate (lambda () (fboundp 'sly-compile-defun))
      :action (lambda () (sly-compile-defun)))

     (init-dwim-make-action
      :title "Load file"
      :description "Load the current file into the Lisp image"
      :category "CommonLisp"
      :priority 82
      :predicate (lambda () (fboundp 'sly-load-file))
      :action (lambda ()
                (when-let ((f (buffer-file-name)))
                  (sly-load-file f))))

     (init-dwim-make-action
      :title "Describe symbol"
      :description "Show documentation for the symbol at point"
      :category "CommonLisp"
      :priority 78
      :predicate (lambda () (fboundp 'sly-describe-symbol))
      :action (lambda () (sly-describe-symbol)))

     (init-dwim-make-action
      :title "Inspect value"
      :description "Open the SLY inspector on the expression at point"
      :category "CommonLisp"
      :priority 75
      :predicate (lambda () (fboundp 'sly-inspect))
      :action (lambda () (call-interactively #'sly-inspect)))

     (init-dwim-make-action
      :title "Macroexpand-1"
      :description "Expand the macro form at point once"
      :category "CommonLisp"
      :priority 70
      :predicate (lambda () (fboundp 'sly-macroexpand-1))
      :action (lambda () (sly-macroexpand-1)))

     (init-dwim-make-action
      :title "Quit SLY"
      :description "Disconnect SLY and quit the Lisp image"
      :category "CommonLisp"
      :priority 40
      :predicate (lambda () (fboundp 'sly-quit-lisp))
      :action (lambda () (sly-quit-lisp))))))

;;; ── Rust ─────────────────────────────────────────────────────────────────

(defun init-dwim-rust-provider ()
  "Return actions for Rust buffers."
  (when (init-dwim--rust-mode-p)
    (list
     (init-dwim-make-action
      :title "cargo run"
      :description "Build and run the current Cargo project"
      :category "Rust"
      :priority 95
      :predicate (lambda () (executable-find "cargo"))
      :action (lambda () (init-dwim--run-in-project "cargo run")))

     (init-dwim-make-action
      :title "cargo build"
      :description "Compile the current Cargo project"
      :category "Rust"
      :priority 90
      :predicate (lambda () (executable-find "cargo"))
      :action (lambda () (init-dwim--run-in-project "cargo build")))

     (init-dwim-make-action
      :title "cargo test"
      :description "Run the project's test suite"
      :category "Rust"
      :priority 88
      :predicate (lambda () (executable-find "cargo"))
      :action (lambda () (init-dwim--run-in-project "cargo test")))

     (init-dwim-make-action
      :title "cargo check"
      :description "Check for errors without producing an executable"
      :category "Rust"
      :priority 86
      :predicate (lambda () (executable-find "cargo"))
      :action (lambda () (init-dwim--run-in-project "cargo check")))

     (init-dwim-make-action
      :title "cargo clippy"
      :description "Run the Clippy linter"
      :category "Rust"
      :priority 82
      :predicate (lambda () (executable-find "cargo"))
      :action (lambda () (init-dwim--run-in-project "cargo clippy")))

     (init-dwim-make-action
      :title "cargo fmt"
      :description "Format Rust source with rustfmt"
      :category "Rust"
      :priority 80
      :predicate (lambda () (executable-find "cargo"))
      :action (lambda () (init-dwim--run-in-project "cargo fmt")))

     (init-dwim-make-action
      :title "cargo doc --open"
      :description "Build and open documentation in the browser"
      :category "Rust"
      :priority 70
      :predicate (lambda () (executable-find "cargo"))
      :action (lambda () (init-dwim--run-in-project "cargo doc --open" t)))

     (init-dwim-make-action
      :title "cargo add dependency"
      :description "Add a crate dependency via cargo add"
      :category "Rust"
      :priority 65
      :predicate (lambda () (executable-find "cargo"))
      :action (lambda ()
                (let ((crate (read-string "Crate name: ")))
                  (init-dwim--run-in-project
                   (format "cargo add %s" (shell-quote-argument crate))))))

     (init-dwim-make-action
      :title "cargo update"
      :description "Update all dependencies to latest compatible versions"
      :category "Rust"
      :priority 60
      :predicate (lambda () (executable-find "cargo"))
      :action (lambda () (init-dwim--run-in-project "cargo update"))))))

;;; ── Go ───────────────────────────────────────────────────────────────────

(defun init-dwim-go-provider ()
  "Return actions for Go buffers."
  (when (init-dwim--go-mode-p)
    (list
     (init-dwim-make-action
      :title "go run ."
      :description "Build and run the current Go package"
      :category "Go"
      :priority 95
      :predicate (lambda () (executable-find "go"))
      :action (lambda () (init-dwim--run-in-project "go run .")))

     (init-dwim-make-action
      :title "go build ."
      :description "Compile the current Go package"
      :category "Go"
      :priority 90
      :predicate (lambda () (executable-find "go"))
      :action (lambda () (init-dwim--run-in-project "go build .")))

     (init-dwim-make-action
      :title "go test ./..."
      :description "Run all tests in the project"
      :category "Go"
      :priority 88
      :predicate (lambda () (executable-find "go"))
      :action (lambda () (init-dwim--run-in-project "go test ./...")))

     (init-dwim-make-action
      :title "go vet ./..."
      :description "Run the Go vet static analyser"
      :category "Go"
      :priority 84
      :predicate (lambda () (executable-find "go"))
      :action (lambda () (init-dwim--run-in-project "go vet ./...")))

     (init-dwim-make-action
      :title "go mod tidy"
      :description "Add missing and remove unused Go module dependencies"
      :category "Go"
      :priority 80
      :predicate (lambda () (executable-find "go"))
      :action (lambda () (init-dwim--run-in-project "go mod tidy")))

     (init-dwim-make-action
      :title "go mod download"
      :description "Download all Go module dependencies"
      :category "Go"
      :priority 75
      :predicate (lambda () (executable-find "go"))
      :action (lambda () (init-dwim--run-in-project "go mod download")))

     (init-dwim-make-action
      :title "go generate ./..."
      :description "Run go generate across the entire project"
      :category "Go"
      :priority 70
      :predicate (lambda () (executable-find "go"))
      :action (lambda () (init-dwim--run-in-project "go generate ./...")))

     (init-dwim-make-action
      :title "Format buffer (gofmt)"
      :description "Format the current Go file using gofmt"
      :category "Go"
      :priority 82
      :predicate (lambda ()
                   (and (init-dwim--buffer-file-p)
                        (or (executable-find "gofmt")
                            (fboundp 'apheleia-format-buffer))))
      :action (lambda ()
                (cond
                 ((fboundp 'apheleia-format-buffer) (apheleia-format-buffer))
                 ((executable-find "gofmt")
                  (shell-command-on-region
                   (point-min) (point-max) "gofmt" nil t))))))))

;;; ── TypeScript ───────────────────────────────────────────────────────────

(defun init-dwim-typescript-provider ()
  "Return actions for TypeScript buffers."
  (when (init-dwim--typescript-mode-p)
    (list
     (init-dwim-make-action
      :title "Type-check (tsc --noEmit)"
      :description "Run the TypeScript compiler in check-only mode"
      :category "TypeScript"
      :priority 92
      :predicate (lambda () (executable-find "tsc"))
      :action (lambda () (init-dwim--run-in-project "tsc --noEmit")))

     (init-dwim-make-action
      :title "Run file with ts-node"
      :description "Execute the current TypeScript file with ts-node"
      :category "TypeScript"
      :priority 88
      :predicate (lambda ()
                   (and (executable-find "ts-node")
                        (init-dwim--buffer-file-p)))
      :action (lambda ()
                (compile (format "ts-node %s"
                                 (shell-quote-argument (buffer-file-name))))))

     (init-dwim-make-action
      :title "Run tests"
      :description "Run the project's test suite (jest or vitest)"
      :category "TypeScript"
      :priority 86
      :predicate (lambda ()
                   (or (executable-find "jest")
                       (executable-find "vitest")
                       (init-dwim-extra--project-has-file-p "package.json")))
      :action (lambda ()
                (cond
                 ((executable-find "vitest")
                  (init-dwim--run-in-project "npx vitest run"))
                 (t
                  (init-dwim--run-in-project "npx jest")))))

     (init-dwim-make-action
      :title "Format with prettier"
      :description "Format the current file using prettier"
      :category "TypeScript"
      :priority 82
      :predicate (lambda ()
                   (and (init-dwim--buffer-file-p)
                        (or (executable-find "prettier")
                            (fboundp 'apheleia-format-buffer))))
      :action (lambda ()
                (if (fboundp 'apheleia-format-buffer)
                    (apheleia-format-buffer)
                  (compile (format "prettier --write %s"
                                   (shell-quote-argument (buffer-file-name)))))))

     (init-dwim-make-action
      :title "Organize imports"
      :description "Ask the language server to organize imports"
      :category "TypeScript"
      :priority 80
      :predicate #'init-dwim--lsp-available-p
      :action (lambda ()
                (cond
                 ((and (fboundp 'eglot-code-actions)
                       (ignore-errors (eglot-current-server)))
                  (eglot-code-actions nil nil "source.organizeImports" t))
                 (t (user-error "No LSP server available")))))

     (init-dwim-make-action
      :title "Add type annotation"
      :description "Prompt for and insert a TypeScript type at point"
      :category "TypeScript"
      :priority 70
      :action (lambda ()
                (let ((type (read-string "Type annotation: ")))
                  (insert (format ": %s" type)))))

     (init-dwim-make-action
      :title "Add 'as const'"
      :description "Append 'as const' after the expression at point"
      :category "TypeScript"
      :priority 65
      :action (lambda () (insert " as const")))

     (init-dwim-make-action
      :title "Toggle strict null comment"
      :description "Insert or remove // @ts-strict-null comment"
      :category "TypeScript"
      :priority 60
      :action (lambda ()
                (save-excursion
                  (goto-char (point-min))
                  (if (re-search-forward "// @ts-strict-null" nil t)
                      (progn (beginning-of-line)
                             (kill-line 1)
                             (message "Removed @ts-strict-null"))
                    (goto-char (point-min))
                    (insert "// @ts-strict-null\n")
                    (message "Added @ts-strict-null"))))))))

;;; ── JavaScript ───────────────────────────────────────────────────────────

(defun init-dwim-javascript-provider ()
  "Return actions for JavaScript buffers."
  (when (init-dwim--javascript-mode-p)
    (list
     (init-dwim-make-action
      :title "Run file with node"
      :description "Execute the current JavaScript file with node"
      :category "JavaScript"
      :priority 92
      :predicate (lambda ()
                   (and (executable-find "node")
                        (init-dwim--buffer-file-p)))
      :action (lambda ()
                (compile (format "node %s"
                                 (shell-quote-argument (buffer-file-name))))))

     (init-dwim-make-action
      :title "ESLint fix"
      :description "Auto-fix ESLint issues in the current file"
      :category "JavaScript"
      :priority 88
      :predicate (lambda ()
                   (and (executable-find "eslint")
                        (init-dwim--buffer-file-p)))
      :action (lambda ()
                (compile (format "eslint --fix %s"
                                 (shell-quote-argument (buffer-file-name))))))

     (init-dwim-make-action
      :title "Format with prettier"
      :description "Format the current file using prettier"
      :category "JavaScript"
      :priority 84
      :predicate (lambda ()
                   (and (init-dwim--buffer-file-p)
                        (or (executable-find "prettier")
                            (fboundp 'apheleia-format-buffer))))
      :action (lambda ()
                (if (fboundp 'apheleia-format-buffer)
                    (apheleia-format-buffer)
                  (compile (format "prettier --write %s"
                                   (shell-quote-argument (buffer-file-name)))))))

     (init-dwim-make-action
      :title "Run jest tests"
      :description "Run jest tests for the current project"
      :category "JavaScript"
      :priority 82
      :predicate (lambda ()
                   (or (executable-find "jest")
                       (init-dwim-extra--project-has-file-p "package.json")))
      :action (lambda ()
                (init-dwim--run-in-project "npx jest")))

     (init-dwim-make-action
      :title "Insert console.log"
      :description "Insert a console.log for the symbol at point"
      :category "JavaScript"
      :priority 75
      :action (lambda ()
                (let ((sym (or (init-dwim--symbol-string) "")))
                  (end-of-line)
                  (newline-and-indent)
                  (insert (format "console.log('%s:', %s);" sym sym)))))

     (init-dwim-make-action
      :title "Insert debugger"
      :description "Insert a debugger statement at point"
      :category "JavaScript"
      :priority 70
      :action (lambda ()
                (end-of-line)
                (newline-and-indent)
                (insert "debugger;")))

     (init-dwim-make-action
      :title "Convert require → import"
      :description "Convert a CommonJS require on the current line to ESM import"
      :category "JavaScript"
      :priority 65
      :action (lambda ()
                (save-excursion
                  (beginning-of-line)
                  (when (re-search-forward
                         "const \\(\\w+\\) = require(\\(['\"]\\)\\([^'\"]+\\)\\2);"
                         (line-end-position) t)
                    (let ((name (match-string 1))
                          (path (match-string 3)))
                      (replace-match
                       (format "import %s from '%s';" name path))))))))))

;;; ── Org-table ─────────────────────────────────────────────────────────────

(defun init-dwim-org-table-provider ()
  "Return actions for Org tables."
  (when (and (derived-mode-p 'org-mode)
             (org-at-table-p))
    (list
     (init-dwim-make-action
      :title "Recalculate table"
      :description "Recompute all formula cells in this table"
      :category "OrgTable"
      :priority 95
      :predicate (lambda () (fboundp 'org-table-recalculate))
      :action (lambda () (org-table-recalculate t)))

     (init-dwim-make-action
      :title "Recalculate all tables"
      :description "Recompute all Org tables in the buffer"
      :category "OrgTable"
      :priority 80
      :predicate (lambda () (fboundp 'org-table-recalculate-buffer-tables))
      :action (lambda () (org-table-recalculate-buffer-tables)))

     (init-dwim-make-action
      :title "Sort column ascending"
      :description "Sort the table rows by the current column (A→Z / 0→9)"
      :category "OrgTable"
      :priority 85
      :predicate (lambda () (fboundp 'org-table-sort-lines))
      :action (lambda () (org-table-sort-lines nil ?a)))

     (init-dwim-make-action
      :title "Sort column descending"
      :description "Sort the table rows by the current column (Z→A / 9→0)"
      :category "OrgTable"
      :priority 83
      :predicate (lambda () (fboundp 'org-table-sort-lines))
      :action (lambda () (org-table-sort-lines nil ?A)))

     (init-dwim-make-action
      :title "Insert row"
      :description "Insert a new blank row at the current position"
      :category "OrgTable"
      :priority 78
      :predicate (lambda () (fboundp 'org-table-insert-row))
      :action (lambda () (org-table-insert-row)))

     (init-dwim-make-action
      :title "Insert column"
      :description "Insert a new blank column at the current position"
      :category "OrgTable"
      :priority 76
      :predicate (lambda () (fboundp 'org-table-insert-column))
      :action (lambda () (org-table-insert-column)))

     (init-dwim-make-action
      :title "Delete row"
      :description "Delete the current table row"
      :category "OrgTable"
      :priority 60
      :predicate (lambda () (fboundp 'org-table-kill-row))
      :action (lambda () (org-table-kill-row)))

     (init-dwim-make-action
      :title "Delete column"
      :description "Delete the current table column"
      :category "OrgTable"
      :priority 58
      :predicate (lambda () (fboundp 'org-table-delete-column))
      :action (lambda () (org-table-delete-column)))

     (init-dwim-make-action
      :title "Export table to CSV"
      :description "Save this Org table as a CSV file"
      :category "OrgTable"
      :priority 55
      :predicate (lambda () (fboundp 'org-table-export))
      :action (lambda ()
                (let ((file (read-file-name "Export CSV to: " nil nil nil
                                            "table.csv")))
                  (org-table-export file "orgtbl-to-csv")))))))

;;; ── Rectangle ────────────────────────────────────────────────────────────

(defun init-dwim-rectangle-provider ()
  "Return rectangle-editing actions."
  (list
   (init-dwim-make-action
    :title "Kill rectangle"
    :description "Cut the rectangle between point and mark"
    :category "Rectangle"
    :priority 88
    :predicate (lambda () (use-region-p))
    :action (lambda ()
              (call-interactively #'kill-rectangle)))

   (init-dwim-make-action
    :title "Copy rectangle"
    :description "Copy the rectangle between point and mark"
    :category "Rectangle"
    :priority 86
    :predicate (lambda () (use-region-p))
    :action (lambda ()
              (call-interactively #'copy-rectangle-as-kill)))

   (init-dwim-make-action
    :title "Yank rectangle"
    :description "Paste the last rectangle at point"
    :category "Rectangle"
    :priority 84
    :action (lambda () (call-interactively #'yank-rectangle)))

   (init-dwim-make-action
    :title "Open rectangle"
    :description "Insert spaces pushing text right in the rectangle region"
    :category "Rectangle"
    :priority 80
    :predicate (lambda () (use-region-p))
    :action (lambda ()
              (call-interactively #'open-rectangle)))

   (init-dwim-make-action
    :title "Clear rectangle"
    :description "Blank out the rectangle (replace with spaces)"
    :category "Rectangle"
    :priority 78
    :predicate (lambda () (use-region-p))
    :action (lambda ()
              (call-interactively #'clear-rectangle)))

   (init-dwim-make-action
    :title "Delete rectangle"
    :description "Delete the text in the rectangle region"
    :category "Rectangle"
    :priority 76
    :predicate (lambda () (use-region-p))
    :action (lambda ()
              (call-interactively #'delete-rectangle)))

   (init-dwim-make-action
    :title "String rectangle"
    :description "Replace each line in the rectangle with a string"
    :category "Rectangle"
    :priority 74
    :predicate (lambda () (use-region-p))
    :action (lambda ()
              (call-interactively #'string-rectangle)))

   (init-dwim-make-action
    :title "Number lines in rectangle"
    :description "Prefix each line in the rectangle with a line number"
    :category "Rectangle"
    :priority 70
    :predicate (lambda () (use-region-p))
    :action (lambda ()
              (call-interactively #'rectangle-number-lines)))

   (init-dwim-make-action
    :title "Copy rectangle to register"
    :description "Save the rectangle to a named register"
    :category "Rectangle"
    :priority 65
    :predicate (lambda () (use-region-p))
    :action (lambda ()
              (call-interactively #'copy-rectangle-to-register)))))

;;; ── Calc ─────────────────────────────────────────────────────────────────

(defun init-dwim-calc-provider ()
  "Return calculator and unit-conversion actions."
  (list
   (init-dwim-make-action
    :title "Open Calc"
    :description "Open the Emacs calculator"
    :category "Calc"
    :priority 75
    :action (lambda () (calc)))

   (init-dwim-make-action
    :title "Evaluate expression at point"
    :description "Compute the arithmetic expression at or around point"
    :category "Calc"
    :priority 85
    :action (lambda ()
              (let* ((expr (or (init-dwim--region-string)
                               (thing-at-point 'sexp t)
                               (read-string "Expression: ")))
                     (result (calc-eval expr)))
                (message "%s = %s" (string-trim expr) result))))

   (init-dwim-make-action
    :title "Insert calc result"
    :description "Evaluate an expression and insert the result at point"
    :category "Calc"
    :priority 80
    :action (lambda ()
              (let* ((expr (read-string "Expression: "))
                     (result (calc-eval expr)))
                (insert result))))

   (init-dwim-make-action
    :title "Quick-calc (minibuffer)"
    :description "Compute a quick arithmetic expression in the minibuffer"
    :category "Calc"
    :priority 78
    :predicate (lambda () (fboundp 'quick-calc))
    :action (lambda () (call-interactively #'quick-calc)))

   (init-dwim-make-action
    :title "Convert units"
    :description "Convert a value from one unit to another"
    :category "Calc"
    :priority 70
    :predicate (lambda () (fboundp 'calc-convert-units))
    :action (lambda ()
              (calc)
              (call-interactively #'calc-convert-units)))

   (init-dwim-make-action
    :title "Compute region as expression"
    :description "Treat the selected text as an expression and show the result"
    :category "Calc"
    :priority 82
    :predicate (lambda () (use-region-p))
    :action (lambda ()
              (let* ((text (buffer-substring-no-properties
                            (region-beginning) (region-end)))
                     (result (calc-eval (string-trim text))))
                (message "%s = %s" (string-trim text) result))))

   (init-dwim-make-action
    :title "Copy last Calc result"
    :description "Copy the last Calc stack result to the kill ring"
    :category "Calc"
    :priority 65
    :predicate (lambda () (fboundp 'calc-eval))
    :action (lambda ()
              (let ((result (calc-eval "$ 1" 'push)))
                (kill-new result)
                (message "Copied: %s" result))))))

;;; ── Org Agenda ───────────────────────────────────────────────────────────

(defun init-dwim-org-agenda-provider ()
  "Return actions specific to Org agenda buffers."
  (when (derived-mode-p 'org-agenda-mode)
    (list
     (init-dwim-make-action
      :title "Jump to original heading"
      :description "Visit the Org heading corresponding to this agenda entry"
      :category "OrgAgenda"
      :priority 100
      :predicate (lambda () (fboundp 'org-agenda-goto))
      :action (lambda () (org-agenda-goto)))

     (init-dwim-make-action
      :title "Mark done"
      :description "Cycle the TODO state of the entry at point to DONE"
      :category "OrgAgenda"
      :priority 95
      :predicate (lambda () (fboundp 'org-agenda-todo))
      :action (lambda () (org-agenda-todo 'done)))

     (init-dwim-make-action
      :title "Schedule"
      :description "Set or change the scheduled date for the entry"
      :category "OrgAgenda"
      :priority 90
      :predicate (lambda () (fboundp 'org-agenda-schedule))
      :action (lambda () (call-interactively #'org-agenda-schedule)))

     (init-dwim-make-action
      :title "Set deadline"
      :description "Set or change the deadline for the entry"
      :category "OrgAgenda"
      :priority 88
      :predicate (lambda () (fboundp 'org-agenda-deadline))
      :action (lambda () (call-interactively #'org-agenda-deadline)))

     (init-dwim-make-action
      :title "Refile"
      :description "Refile the entry to another Org heading"
      :category "OrgAgenda"
      :priority 85
      :predicate (lambda () (fboundp 'org-agenda-refile))
      :action (lambda () (org-agenda-refile)))

     (init-dwim-make-action
      :title "Archive"
      :description "Archive the entry at point"
      :category "OrgAgenda"
      :priority 80
      :predicate (lambda () (fboundp 'org-agenda-archive))
      :action (lambda () (org-agenda-archive)))

     (init-dwim-make-action
      :title "Clock in"
      :description "Start clocking the entry at point"
      :category "OrgAgenda"
      :priority 82
      :predicate (lambda () (fboundp 'org-agenda-clock-in))
      :action (lambda () (org-agenda-clock-in)))

     (init-dwim-make-action
      :title "Filter by tag"
      :description "Narrow the agenda view to a specific tag"
      :category "OrgAgenda"
      :priority 75
      :predicate (lambda () (fboundp 'org-agenda-filter-by-tag))
      :action (lambda () (call-interactively #'org-agenda-filter-by-tag)))

     (init-dwim-make-action
      :title "Toggle follow mode"
      :description "Auto-show the original heading when navigating the agenda"
      :category "OrgAgenda"
      :priority 70
      :predicate (lambda () (fboundp 'org-agenda-follow-mode))
      :action (lambda () (org-agenda-follow-mode))))))

;;; ── Outline ──────────────────────────────────────────────────────────────

(defun init-dwim-outline-provider ()
  "Return actions for outline-mode and outline-minor-mode."
  (when (or (derived-mode-p 'outline-mode)
            (bound-and-true-p outline-minor-mode))
    (list
     (init-dwim-make-action
      :title "Toggle subtree"
      :description "Fold or unfold the subtree at point"
      :category "Outline"
      :priority 90
      :predicate (lambda () (fboundp 'outline-toggle-children))
      :action (lambda () (outline-toggle-children)))

     (init-dwim-make-action
      :title "Show all"
      :description "Expand all headings in the buffer"
      :category "Outline"
      :priority 80
      :predicate (lambda () (fboundp 'outline-show-all))
      :action (lambda () (outline-show-all)))

     (init-dwim-make-action
      :title "Hide all"
      :description "Collapse all headings to just their first line"
      :category "Outline"
      :priority 78
      :predicate (lambda () (fboundp 'outline-hide-body))
      :action (lambda () (outline-hide-body)))

     (init-dwim-make-action
      :title "Promote heading"
      :description "Move heading one level up"
      :category "Outline"
      :priority 75
      :predicate (lambda () (fboundp 'outline-promote))
      :action (lambda () (outline-promote)))

     (init-dwim-make-action
      :title "Demote heading"
      :description "Move heading one level down"
      :category "Outline"
      :priority 73
      :predicate (lambda () (fboundp 'outline-demote))
      :action (lambda () (outline-demote)))

     (init-dwim-make-action
      :title "Move subtree up"
      :description "Move the subtree at point before the previous heading"
      :category "Outline"
      :priority 70
      :predicate (lambda () (fboundp 'outline-move-subtree-up))
      :action (lambda () (outline-move-subtree-up 1)))

     (init-dwim-make-action
      :title "Move subtree down"
      :description "Move the subtree at point after the next heading"
      :category "Outline"
      :priority 68
      :predicate (lambda () (fboundp 'outline-move-subtree-down))
      :action (lambda () (outline-move-subtree-down 1))))))

;;; ── Abbrev ───────────────────────────────────────────────────────────────

(defun init-dwim-abbrev-provider ()
  "Return abbrev-mode management actions."
  (list
   (init-dwim-make-action
    :title "Define global abbrev"
    :description "Define an abbreviation that expands in all modes"
    :category "Abbrev"
    :priority 75
    :action (lambda () (call-interactively #'define-global-abbrev)))

   (init-dwim-make-action
    :title "Define local (mode) abbrev"
    :description "Define an abbreviation for the current major mode"
    :category "Abbrev"
    :priority 73
    :action (lambda () (call-interactively #'define-mode-abbrev)))

   (init-dwim-make-action
    :title "Expand abbrev at point"
    :description "Expand the abbreviation preceding point"
    :category "Abbrev"
    :priority 80
    :action (lambda () (expand-abbrev)))

   (init-dwim-make-action
    :title "List all abbrevs"
    :description "Open a buffer listing all defined abbreviations"
    :category "Abbrev"
    :priority 60
    :action (lambda () (list-abbrevs t)))

   (init-dwim-make-action
    :title "Edit abbrevs"
    :description "Open the abbrev definition buffer for editing"
    :category "Abbrev"
    :priority 55
    :predicate (lambda () (fboundp 'edit-abbrevs))
    :action (lambda () (edit-abbrevs)))

   (init-dwim-make-action
    :title "Write abbrev file"
    :description "Save all abbreviations to the abbrev file"
    :category "Abbrev"
    :priority 50
    :predicate (lambda () (fboundp 'write-abbrev-file))
    :action (lambda () (call-interactively #'write-abbrev-file)))))

;;; ── wgrep ────────────────────────────────────────────────────────────────

(defun init-dwim-wgrep-provider ()
  "Return wgrep actions when in a grep or rg results buffer."
  (when (and (or (derived-mode-p 'grep-mode)
                 (derived-mode-p 'rg-mode))
             (fboundp 'wgrep-change-to-wgrep-mode))
    (list
     (init-dwim-make-action
      :title "Enable wgrep editing"
      :description "Make the grep results buffer editable"
      :category "Search"
      :priority 95
      :predicate (lambda ()
                   (not (bound-and-true-p wgrep-p)))
      :action (lambda () (wgrep-change-to-wgrep-mode)))

     (init-dwim-make-action
      :title "Save wgrep changes"
      :description "Apply all edits made in the wgrep buffer to the files"
      :category "Search"
      :priority 90
      :predicate (lambda ()
                   (and (bound-and-true-p wgrep-p)
                        (fboundp 'wgrep-save-all-buffers)))
      :action (lambda () (wgrep-save-all-buffers)))

     (init-dwim-make-action
      :title "Abort wgrep"
      :description "Discard all wgrep edits"
      :category "Search"
      :priority 85
      :predicate (lambda ()
                   (and (bound-and-true-p wgrep-p)
                        (fboundp 'wgrep-abort-changes)))
      :action (lambda () (wgrep-abort-changes)))

     (init-dwim-make-action
      :title "Mark all matches for replacement"
      :description "Use wgrep to mark all results for a query-replace"
      :category "Search"
      :priority 80
      :predicate (lambda () (fboundp 'wgrep-change-to-wgrep-mode))
      :action (lambda ()
                (wgrep-change-to-wgrep-mode)
                (call-interactively #'query-replace-regexp)))

     (init-dwim-make-action
      :title "Export to occur"
      :description "Open the grep results in an occur-mode buffer"
      :category "Search"
      :priority 70
      :predicate (lambda () (fboundp 'occur-mode-display-occurrence))
      :action (lambda ()
                (occur (read-regexp "Export occurrences of: ")))))))

;;; ── Corfu / completion ───────────────────────────────────────────────────

(defun init-dwim-corfu-provider ()
  "Return completion-UI actions when corfu is active."
  (when (bound-and-true-p corfu-mode)
    (list
     (init-dwim-make-action
      :title "Trigger completion"
      :description "Manually open the corfu completion popup"
      :category "Completion"
      :priority 85
      :predicate (lambda () (fboundp 'completion-at-point))
      :action (lambda () (completion-at-point)))

     (init-dwim-make-action
      :title "Toggle corfu auto-complete"
      :description "Enable or disable automatic completion popup"
      :category "Completion"
      :priority 70
      :predicate (lambda () (boundp 'corfu-auto))
      :action (lambda ()
                (setq corfu-auto (not corfu-auto))
                (message "corfu-auto: %s" (if corfu-auto "on" "off"))))

     (init-dwim-make-action
      :title "Toggle corfu popupinfo"
      :description "Show or hide inline documentation in the completion popup"
      :category "Completion"
      :priority 68
      :predicate (lambda () (fboundp 'corfu-popupinfo-mode))
      :action (lambda ()
                (corfu-popupinfo-mode 'toggle)
                (message "corfu-popupinfo: %s"
                         (if (bound-and-true-p corfu-popupinfo-mode)
                             "on" "off"))))

     (init-dwim-make-action
      :title "Cape: complete file path"
      :description "Trigger file path completion via Cape"
      :category "Completion"
      :priority 65
      :predicate (lambda () (fboundp 'cape-file))
      :action (lambda () (cape-file)))

     (init-dwim-make-action
      :title "Cape: complete from dabbrev"
      :description "Complete from dynamic abbreviations (all buffers)"
      :category "Completion"
      :priority 63
      :predicate (lambda () (fboundp 'cape-dabbrev))
      :action (lambda () (cape-dabbrev)))

     (init-dwim-make-action
      :title "Cape: complete Elisp symbol"
      :description "Trigger Elisp symbol completion"
      :category "Completion"
      :priority 60
      :predicate (lambda ()
                   (and (fboundp 'cape-elisp-symbol)
                        (derived-mode-p 'emacs-lisp-mode)))
      :action (lambda () (cape-elisp-symbol))))))

;;; ── Highlight ────────────────────────────────────────────────────────────

(defun init-dwim-highlight-provider ()
  "Return highlight actions for symbols and patterns."
  (when (derived-mode-p 'prog-mode 'text-mode)
    (list
     (init-dwim-make-action
      :title "Highlight symbol at point"
      :description "Add a persistent highlight for the current symbol"
      :category "Highlight"
      :priority 80
      :predicate (lambda ()
                   (or (fboundp 'hi-lock-face-phrase-buffer)
                       (fboundp 'highlight-symbol-at-point)))
      :action (lambda ()
                (cond
                 ((fboundp 'highlight-symbol-at-point)
                  (highlight-symbol-at-point))
                 ((fboundp 'hi-lock-face-phrase-buffer)
                  (hi-lock-face-phrase-buffer
                   (regexp-quote (or (init-dwim--symbol-string) "")))))))

     (init-dwim-make-action
      :title "Unhighlight symbol"
      :description "Remove the hi-lock highlight for the symbol at point"
      :category "Highlight"
      :priority 78
      :predicate (lambda ()
                   (and (or (fboundp 'hi-lock-unface-buffer)
                            (fboundp 'highlight-symbol-remove-all))
                        (init-dwim--symbol-string)))
      :action (lambda ()
                (cond
                 ((fboundp 'highlight-symbol-remove-all)
                  (highlight-symbol-remove-all))
                 ((fboundp 'hi-lock-unface-buffer)
                  (hi-lock-unface-buffer
                   (regexp-quote (or (init-dwim--symbol-string) "")))))))

     (init-dwim-make-action
      :title "Highlight regexp"
      :description "Highlight a custom regular expression"
      :category "Highlight"
      :priority 75
      :predicate (lambda () (fboundp 'highlight-regexp))
      :action (lambda () (call-interactively #'highlight-regexp)))

     (init-dwim-make-action
      :title "Unhighlight all"
      :description "Remove all hi-lock highlights from the buffer"
      :category "Highlight"
      :priority 73
      :predicate (lambda () (fboundp 'hi-lock-unface-buffer))
      :action (lambda () (hi-lock-unface-buffer t)))

     (init-dwim-make-action
      :title "Next highlighted occurrence"
      :description "Jump to the next occurrence of the highlighted symbol"
      :category "Highlight"
      :priority 70
      :predicate (lambda () (fboundp 'highlight-symbol-next))
      :action (lambda () (highlight-symbol-next)))

     (init-dwim-make-action
      :title "Previous highlighted occurrence"
      :description "Jump to the previous occurrence of the highlighted symbol"
      :category "Highlight"
      :priority 68
      :predicate (lambda () (fboundp 'highlight-symbol-prev))
      :action (lambda () (highlight-symbol-prev))))))

;;;; Provider registration

(setq init-dwim-providers
      '(;; Session, global navigation, and completion helpers.
        init-dwim-session-provider
        init-dwim-consult-provider
        init-dwim-embark-provider
        init-dwim-transient-provider

        ;; Selection, point context, and editing objects.
        init-dwim-region-provider
        init-dwim-expand-region-provider
        init-dwim-rectangle-provider
        init-dwim-url-provider
        init-dwim-file-utility-provider
        init-dwim-file-path-provider
        init-dwim-symbol-provider
        init-dwim-number-provider
        init-dwim-register-provider
        init-dwim-narrow-provider
        init-dwim-smartparens-provider
        init-dwim-highlight-provider

        ;; Notes, text, Org, Markdown, snippets, and templates.
        init-dwim-quick-note-provider
        init-dwim-org-provider
        init-dwim-org-table-provider
        init-dwim-org-agenda-provider
        init-dwim-org-clock-provider
        init-dwim-text-provider
        init-dwim-markdown-provider
        init-dwim-spelling-provider
        init-dwim-snippet-provider
        init-dwim-yasnippet-maintenance-provider
        init-dwim-abbrev-provider
        init-dwim-bookmark-provider
        init-dwim-bookmark-context-provider
        init-dwim-file-template-provider

        ;; Files, buffers, windows, tabs, and sessions.
        init-dwim-buffer-provider
        init-dwim-window-provider
        init-dwim-tab-bar-provider
        init-dwim-dired-provider
        init-dwim-history-provider
        init-dwim-focus-provider
        init-dwim-security-provider
        init-dwim-calc-provider

        ;; Projects, version control, diffs, and tasks.
        init-dwim-project-provider
        init-dwim-project-task-provider
        init-dwim-vc-provider
        init-dwim-magit-provider
        init-dwim-git-gutter-provider
        init-dwim-smerge-provider
        init-dwim-diff-provider
        init-dwim-ediff-provider
        init-dwim-wgrep-provider

        ;; Programming, diagnostics, languages, and structured data.
        init-dwim-programming-provider
        init-dwim-eglot-workspace-provider
        init-dwim-diagnostics-provider        ; includes flymake (merged)
        init-dwim-treesit-provider
        init-dwim-outline-provider
        init-dwim-xref-provider
        init-dwim-elisp-provider
        init-dwim-python-provider
        init-dwim-clojure-provider
        init-dwim-common-lisp-provider
        init-dwim-rust-provider
        init-dwim-go-provider
        init-dwim-typescript-provider
        init-dwim-javascript-provider
        init-dwim-json-yaml-provider
        init-dwim-restclient-provider
        init-dwim-docker-provider

        ;; Shells, terminals, output buffers, and search state.
        init-dwim-output-buffer-provider
        init-dwim-comint-provider
        init-dwim-shell-provider
        init-dwim-eat-provider
        init-dwim-isearch-provider
        init-dwim-corfu-provider

        ;; AI integrations.
        init-dwim-ai-provider
        init-dwim-gptel-provider

        ;; Emacs meta/help/package operations.
        init-dwim-help-provider
        init-dwim-evil-provider
        init-dwim-macro-provider
        init-dwim-package-provider
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

;; Path for journal entries created by init-dwim-quick-note-provider.
;; Defaults to journal.org inside org-directory when set, else user-emacs-directory.
(defvar init-dwim-journal-file
  (expand-file-name "journal.org"
                    (or (bound-and-true-p org-directory)
                        user-emacs-directory))
  "File used for timestamped journal entries by `init-dwim-quick-note-provider'.")

;; The one custom keybinding in this setup.
;; M-RET is a good default because it is mnemonic, easy to press, works in GUI
;; and terminal Emacs on most systems, and is explicitly suggested by init-dwim.
(with-eval-after-load 'evil
  (evil-set-leader '(normal visual motion emacs) (kbd "SPC"))
  (evil-define-key '(normal visual motion emacs) 'global
    (kbd "<leader> SPC") #'init-dwim))

(provide 'init)
;;; init.el ends here
