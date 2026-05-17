# dwimacs

A modern, single-file Emacs configuration centred around a **Do What I Mean** command dispatcher. One key press surfaces every relevant action for the current context — no prefix maps to memorise, no mode-specific muscle memory required.

**→ [github.com/luizalbertocviana/dwimacs](https://github.com/luizalbertocviana/dwimacs)**

---

## How it works

Pressing `SPC SPC` invokes `init-dwim`. It polls every registered *provider* function, each of which inspects the current buffer, point, region, and active modes to decide which actions are relevant right now. The resulting list is filtered, sorted by priority, and presented through a completing-read UI. Pick an action; it runs.

```
SPC SPC  →  init-dwim  →  collect from 79 providers  →  sort & filter  →  execute
```

Providers are ordinary Elisp functions. They return a list of action plists created with `init-dwim-make-action` and are completely independent of the engine. Adding a new action is as simple as adding a `init-dwim-make-action` call inside the right provider function.

### Action anatomy

```elisp
(init-dwim-make-action
  :title       "Cargo test"                          ; shown in the picker
  :description "Run the project's test suite"        ; shown as annotation
  :category    "Rust"                                ; used for grouping/filtering
  :priority    88                                    ; higher = floats to the top
  :predicate   (lambda () (executable-find "cargo")) ; nil = always show
  :confidence  'high                                 ; high / medium / low
  :action      (lambda () (compile "cargo test")))   ; what runs on selection
```

### Debugging

`M-x init-dwim-explain` shows a debug buffer explaining exactly which providers fired, which actions they proposed, and why any were filtered out. Useful when a provider seems to be missing.

---

## Requirements

- Emacs **30.1** or later
- Internet access on first launch (straight.el bootstraps itself and installs packages)
- Optionally: `cargo`, `go`, `node`/`tsc`, `mix`, `mvn`/`gradle`, `bundle`, `docker`, `rg` in `PATH` for the relevant language and tooling providers

---

## Installation

```bash
# Back up any existing config first
mv ~/.emacs.d ~/.emacs.d.bak

# Clone
git clone https://github.com/luizalbertocviana/dwimacs ~/.emacs.d

# Start Emacs — straight.el installs everything on the first run
emacs
```

That's it. There is no compilation step and no `make` target. On the first launch Emacs will be slower than usual while packages are cloned and compiled; subsequent starts are fast.

---

## Package stack

| Layer | Packages |
|---|---|
| Package manager | `straight.el` + `use-package` |
| Completion UI | `vertico`, `orderless`, `marginalia`, `consult`, `embark` |
| In-buffer completion | `corfu`, `cape` |
| Editing | `evil`, `evil-collection`, `smartparens`, `expand-region` |
| Snippets | `yasnippet`, `yasnippet-snippets` |
| Projects | `projectile` |
| Git | `magit`, `git-gutter` |
| Search | `ripgrep`, `rg` |
| LSP | `eglot` (built-in) |
| Diagnostics | `flymake` (built-in) |
| Formatting | `apheleia`, `format-all` |
| Tree-sitter | `tree-sitter-langs` |
| Languages | `cider`, `sly`, `rust-mode`, `go-mode`, `typescript-mode`, `clojure-mode`, `json-mode`, `yaml-mode`, `dockerfile-mode` |
| Testing | `pytest`, `jest-test-mode` |
| AI / LLM | `gptel`, `ellama` |
| Notes & prose | `org-modern`, `olivetti`, `writeroom-mode`, `markdown-mode`, `markdown-toc`, `grip-mode`, `langtool` |
| HTTP | `restclient` |
| Terminal | `eat` |
| Spelling | `ispell` (built-in), `langtool` |
| Wgrep | `wgrep`, `wgrep-ag` |
| Undo | `vundo` |
| Debug | `dap-mode` |
| UI | `doom-themes`, `doom-modeline`, `which-key`, `highlight-symbol`, `no-littering` |

---

## Providers

79 provider functions cover the full editing surface. They activate only when their context is present — a Rust provider never pollutes a Markdown buffer's action list.

| Domain | Providers | Example actions |
|---|---|---|
| **Selection & editing** | region, expand-region, rectangle, symbol, number, smartparens, text | HTML-escape, ROT13, SHA-256 hash, titlecase, string rectangle, number increment |
| **Files & buffers** | file-path, file-utility, file-template, buffer, dired, narrow | hexl view, chmod, add to .gitignore, bury buffer, toggle word-wrap |
| **Navigation & search** | consult, isearch, xref, history, embark, wgrep | visual undo tree, repeat command history, enable wgrep editing |
| **Windows & workspace** | window, tab-bar, focus, session | winner-undo/redo, dedicate window, save desktop session |
| **Notes & writing** | org, org-table, org-agenda, org-clock, quick-note, markdown, spelling, abbrev | cut/copy/paste subtree, sparse tree by tag, journal entry, add to personal dictionary |
| **Snippets & templates** | snippet, yasnippet-maintenance, file-template | list snippets for mode, try snippet in temp buffer |
| **Bookmarks & registers** | bookmark, bookmark-context, register | — |
| **Version control** | magit, git-gutter, vc, smerge, diff, ediff | worktree, bisect, submodule, tag |
| **Projects & tasks** | project, project-task | find TODO/FIXME, open changelog, run Cargo/Go/Mix/Maven/Gradle/Bundler tasks |
| **LSP & diagnostics** | eglot-workspace, diagnostics (flymake merged) | next/prev error, project diagnostics, toggle checker |
| **Languages** | elisp, python, clojure, common-lisp, rust, go, typescript, javascript, json-yaml | jack-in CIDER/SLY, cargo clippy, go mod tidy, tsc --noEmit, ESLint fix, convert require→import |
| **REPL & terminals** | comint, shell, eat | open eat terminal, open ansi-term, change default directory |
| **AI & LLM** | ai, gptel | explain in plain English, suggest better name, refactor for readability |
| **Completion** | corfu | trigger completion, toggle corfu-auto, Cape file/dabbrev completions |
| **Highlighting** | highlight | highlight symbol, highlight regexp, next/prev occurrence |
| **Tooling** | package, restclient, docker, treesit, security, outline, transient | docker exec shell, docker system prune, promote/demote heading |
| **Emacs meta** | emacs, evil, help | toggle debug-on-quit, open \*Backtrace\*, list all keybindings |

---

## The single keybinding

```elisp
SPC SPC  →  init-dwim
```

`SPC` is the Evil leader key. That is the only custom global binding in the entire configuration. Everything else is reached through the DWIM dispatcher.

---

## Customisation

All knobs live at the bottom of `init.el` under the `;;;; init-dwim user configuration` heading:

```elisp
(setq init-dwim-max-candidates           nil      ; nil = no limit
      init-dwim-include-low-confidence-actions t
      init-dwim-completion-backend       'consult-if-available
      init-dwim-project-notes-file       "NOTES.org"
      init-dwim-ai-system-prompt         "You are a senior engineer…")

(defvar init-dwim-journal-file           "~/org/journal.org")
```

Providers can be individually disabled without touching their code:

```elisp
(setq init-dwim-disabled-providers
      '(init-dwim-docker-provider
        init-dwim-ai-provider))
```

Category-based invocation is also available for narrowed workflows:

```elisp
M-x init-dwim-for-category RET Git RET
```

---

## Extending

Adding a new action to an existing provider:

```elisp
;; Inside init-dwim-org-provider, after the existing actions:
(init-dwim-make-action
  :title    "Export to LaTeX"
  :category "Org"
  :priority 50
  :predicate (lambda () (fboundp 'org-latex-export-to-pdf))
  :action   (lambda () (org-latex-export-to-pdf)))
```

Adding a new provider:

```elisp
(defun init-dwim-my-provider ()
  "Return actions for my custom workflow."
  (when (my-condition-p)
    (list
     (init-dwim-make-action
       :title  "My action"
       :action (lambda () (do-something))))))

;; Register it:
(add-to-list 'init-dwim-providers 'init-dwim-my-provider)
```

The engine is never modified — it is the stable contract between providers and the UI.

---

## License

MIT
