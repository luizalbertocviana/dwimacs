# dwimacs

A modern, single-file Emacs configuration centered around a context-aware **Do What I Mean** command named `init-dwim`.

This setup keeps the base Emacs configuration compact while pushing most day-to-day actions into one discoverable command. Instead of memorizing many keybindings, press the DWIM key and choose an action that is relevant to the current buffer, region, project, symbol, URL, file, Org heading, Magit status buffer, Dired buffer, shell buffer, or programming context.

## Requirements

- Emacs **30.1** or newer
- Git
- Internet access on first launch, so `straight.el` can bootstrap and install packages
- Recommended command-line tools:
  - `rg` / ripgrep for fast project search
  - language servers for the languages you use with Eglot
  - formatters used by Apheleia or Format All
  - `black` and `isort` if you work in Python
  - spell-checking tools supported by your Ispell setup
  - Java and LanguageTool if you want grammar checking through `langtool`

## Installation

1. Back up your current Emacs configuration if you already have one:

   ```sh
   mv ~/.emacs.d ~/.emacs.d.backup
   ```

2. Create a new Emacs config directory:

   ```sh
   mkdir -p ~/.emacs.d
   ```

3. Copy the config file into place as `init.el`:

   ```sh
   cp init.el ~/.emacs.d/init.el
   ```

4. Start Emacs.

On the first launch, `straight.el` will bootstrap itself and install the configured packages. This can take a little while depending on your connection and machine.

## Main Keybinding

The main entry point is:

```text
SPC SPC  →  init-dwim
```

This keybinding is active through Evil in normal, visual, motion, and emacs states. The Evil leader key is set to `SPC`.

## What `init-dwim` Does

`init-dwim` collects actions from many providers, filters them by the current context, sorts them by priority, and displays them through completion. With Vertico, Orderless, Marginalia, and Consult enabled, this gives you a fast searchable action menu where every candidate shows its category and a short description annotation.

Examples of context-aware actions include:

- **Region** — copy, kill, indent, format, comment, sort, deduplicate, search, evaluate, or send to AI
- **URL** — open, copy, insert Markdown or Org links, fetch title, open in EWW, or download
- **File path** — open, copy, reveal in Dired, open externally, link, delete, copy, or diff
- **Symbol** — jump to definition, find references, rename, search, describe, highlight, or query-replace
- **Number** — increment, decrement, multiply, or replace with a computed value
- **isearch** — extend or refine an active incremental search
- **Org** — TODO state, scheduling, deadlines, refiling, archiving, clocking, links, export, tags, capture, agenda, and table helpers
- **Org clock** — clock in, clock out, clock report, and recent-task switching
- **Programming** — tests, formatting, diagnostics, REPLs, evaluation, related files, Imenu, Eglot actions, and compilation
- **Python** — run with pytest, type-check with mypy, format with black, sort imports with isort, insert a breakpoint
- **Elisp** — evaluate expression, defun, buffer, load file, macroexpand, describe function/variable, byte-compile
- **Diagnostics** — list Flymake errors, jump next/previous, describe, or copy the message at point
- **JSON / YAML** — pretty-print, minify, validate, or convert between formats
- **Text and Markdown** — preview, links, word count, export, folding, search, and table of contents
- **Dired** — open, rename, copy, delete, compress, external open, Git status, mark by extension, and search contents
- **Magit** — stage, unstage, commit, push, pull, diff, branch, checkout, stash, blame, log, and status
- **git-gutter** — stage hunk, revert hunk, jump next/previous, and popup diff
- **smerge** — keep upper/lower/all, navigate conflicts, combine, and resolve
- **diff** — apply hunk, reverse, jump next/previous, and copy
- **ediff** — launch ediff on buffer, region, files, or revisions
- **Comint** — send input, clear buffer, interrupt, navigate history, and copy last output
- **restclient** — send request, narrow to block, copy as curl, and prettify response
- **Project** — search, files, switch project, commands, notes, Git status, Dired, shell, and terminal
- **Buffer and window** — save, revert, rename, kill, clone, copy, split, delete, balance, rotate, and maximize
- **Bookmark** — set, jump, delete, list, and rename
- **Snippet** — expand, insert by name, new, edit, and list
- **Smartparens** — slurp, barf, splice, raise, split, join, wrap, and unwrap
- **expand-region** — expand or contract selection by semantic unit
- **Focus / writing** — toggle writeroom or olivetti mode, adjust body width, and center text
- **eat terminal** — send line, send region, clear, and rename buffer
- **Shell** — open shell, send region, and cd to project root
- **AI** — send region or buffer to gptel, open a chat buffer, and switch model
- **gptel buffer** — send input, change model, edit system prompt, copy last response, clear, or save chat to a dated log file
- **Help** — describe key, function, variable, mode, package, or open the manual
- **Evil** — record macro, toggle insert/normal, switch to visual line, and common state transitions
- **Tab bar** — new tab, rename, close, switch, and list
- **Register** — save, insert, jump, list, and clear
- **Spelling** — check word, correct, add to dictionary, toggle flyspell, and next error
- **Macro** — start, stop, execute, name, and insert
- **Narrow** — narrow to region, defun, page; widen; and clone indirect buffer
- **History** — browse minibuffer history, search command history, and consult recent files
- **Package / straight.el** — list packages, install, pull all, rebuild all, fetch updates, freeze lockfile, and thaw lockfile
- **Session / Emacs admin** — restart Emacs, load/save desktop, open init file, eval init buffer, garbage collect, and display startup stats
- **Consult** — search buffer, line, outline, imenu, recent files, and ripgrep via the Consult integration
- **xref** — find definitions, references, and go back

## Package Stack

The setup uses `straight.el` with `use-package` and installs packages automatically.

### Completion and Discovery

- `vertico` — vertical completion UI with cycling and resize
- `orderless` — space-separated fuzzy matching
- `marginalia` — annotations in the minibuffer
- `consult` — enhanced search and navigation commands
- `embark` — act on minibuffer candidates
- `which-key` — popup showing available keybindings (0.5 s delay)

### Editing

- `evil` with undo-redo and C-u scroll
- `evil-collection` — Evil bindings for many modes
- `corfu` — in-buffer auto-completion popup
- `cape` — completion-at-point extensions (file, dabbrev)
- `yasnippet` + `yasnippet-snippets`
- `smartparens` — structured pair editing in prog, markdown, and org modes
- `expand-region`

### Projects, Search, and Version Control

- `projectile` — project detection and commands
- `magit` — full Git interface
- `git-gutter` — live hunk indicators in the fringe
- `ripgrep` + `rg`

### Programming

- Built-in `eglot` — LSP client (autoshutdown enabled)
- Built-in `flymake` — on-the-fly diagnostics for prog and elisp modes
- `apheleia` — format-on-save (global mode)
- `format-all` — fallback formatter
- `highlight-symbol` — highlight symbol occurrences in prog buffers
- `tree-sitter-langs` — tree-sitter highlighting (when available)
- `cider`, `sly` — Clojure and Common Lisp REPLs
- `pytest`, `jest-test-mode` — test runners
- `go-mode`, `rust-mode`, `typescript-mode`
- `json-mode`, `yaml-mode`, `dockerfile-mode`

### Writing, Org, and Markdown

- Built-in `org` with capture templates for tasks and notes
- `org-modern` — prettier Org headings and bullets
- `markdown-mode` (GFM mode for README files)
- `markdown-toc`
- `grip-mode` — live GitHub-flavored Markdown preview
- `langtool` — grammar checking (requires Java and LanguageTool)
- `writeroom-mode` — distraction-free writing

### Files, Shells, REST, and UI

- Built-in `dired` with `diredfl` colours
- Built-in `diff-mode` and `smerge-mode`
- `eat` — fast terminal emulator inside Emacs
- `restclient` — interactive HTTP client (`.http` files)
- `olivetti` — centred writing layout (body width 88)
- `doom-themes` — Doom One theme
- `doom-modeline` — modeline with icons, VCS info, and word count
- `no-littering` — keep `~/.emacs.d` tidy

### AI

- `gptel` — multi-backend LLM chat (defaults to org-mode buffers)
- `ellama` — local model integration

### Development Utilities

- `package-lint` — lint packages before publishing

## UI Defaults

The config starts with a clean, modern UI:

- Startup screen disabled
- Menu bar, tool bar, and scroll bar disabled
- Global line numbers and column number mode enabled
- Save place, save history, recent files, and auto-revert enabled
- Doom One theme loaded
- Doom Modeline enabled (height 28, word count, project-aware VCS)
- Tab bar disabled by default

## Editing Defaults

- Spaces instead of tabs
- Tab width: `4`
- Fill column: `88`
- Backups disabled
- Auto-save enabled
- Lockfiles disabled
- Short answers (`y`/`n`) enabled
- `sentence-end-double-space` disabled
- Bell silenced

## Startup Performance

Early startup sets `gc-cons-threshold` to `most-positive-fixnum` during load, then resets it to 64 MB afterward. `read-process-output-max` is set to 1 MB to improve LSP throughput. Startup time and GC count are reported in the `*Messages*` buffer.

## Project Defaults

Projectile searches these directories for projects:

```elisp
("~/src" "~/work" "~/projects" "~/git")
```

You can change this in the `projectile-project-search-path` setting.

Project notes default to:

```text
NOTES.org
```

relative to the project root.

## Org Defaults

```elisp
(org-directory "~/.emacs.d/org")
(org-default-notes-file "~/.emacs.d/org/inbox.org")
(org-log-done 'time)
(org-startup-indented t)
(org-hide-emphasis-markers t)
```

Two capture templates are included: `t` for tasks and `n` for notes, both filed under `inbox.org`.

## Customization

The main DWIM options are configured near the end of the file:

```elisp
(setq init-dwim-max-candidates nil
      init-dwim-include-low-confidence-actions t
      init-dwim-completion-backend 'consult-if-available
      init-dwim-project-notes-file "NOTES.org"
      init-dwim-ai-system-prompt
      "You are a senior engineer helping inside Emacs. Be concise and actionable.")
```

### Limit the number of candidates

```elisp
(setq init-dwim-max-candidates 30)
```

### Hide low-confidence fallback actions

```elisp
(setq init-dwim-include-low-confidence-actions nil)
```

### Use plain `completing-read`

```elisp
(setq init-dwim-completion-backend 'completing-read)
```

### Disable a provider

Add provider symbols to `init-dwim-disabled-providers`:

```elisp
(setq init-dwim-disabled-providers
      '(init-dwim-ai-provider
        init-dwim-spelling-provider))
```

### Register your own provider

A provider is a function that returns a list of actions created with `init-dwim-make-action`:

```elisp
(defun my-dwim-provider ()
  (list
   (init-dwim-make-action
    :title "Say hello"
    :description "Show a friendly message"
    :category "Personal"
    :priority 10
    :action (lambda () (message "Hello from DWIM")))))

(init-dwim-register-provider #'my-dwim-provider t)
```

The `:predicate` key is optional. When present it must be a zero-argument function that returns non-nil only when the action is applicable. The `:confidence` key accepts `high`, `medium`, or `low`; low-confidence actions are hidden when `init-dwim-include-low-confidence-actions` is nil.

## Debugging DWIM Actions

Use:

```text
M-x init-dwim-explain
```

This opens a debug buffer showing which providers ran, which actions were returned, and why some actions were rejected.

You can also run DWIM for a specific category:

```text
M-x init-dwim-for-category
```

Or toggle debug logging interactively:

```text
M-x init-dwim-debug-mode
```

## Notes About AI Backends

The config installs `gptel` and `ellama`, but you still need to configure whichever backend, model, API key, or local model setup you intend to use. Without that extra backend configuration, AI actions may appear but may not be useful yet.

## Troubleshooting

### Package installation fails on first launch

Check that Emacs can access GitHub and that Git is installed. Then restart Emacs.

### `SPC SPC` does not open DWIM

Make sure Evil loaded successfully. You can still run the command manually with:

```text
M-x init-dwim
```

### Search actions do not work

Install ripgrep:

```sh
# macOS
brew install ripgrep

# Debian/Ubuntu
sudo apt install ripgrep

# Fedora
sudo dnf install ripgrep
```

### Eglot does not start for a language

Install the language server for that language and make sure it is available on your `PATH`.

### Flymake shows no diagnostics

Flymake is configured to start automatically in `prog-mode` and `emacs-lisp-mode` buffers. If it appears inactive, check that the relevant checker (e.g. a language server via Eglot) is running with `M-x flymake-running-backends`.

### Formatting does not work

Install the formatter expected for the current major mode, or customize Apheleia for your preferred formatter. Python buffers also expose `black` and `isort` directly through DWIM.

### restclient actions do not appear

Open a file with a `.http` extension or switch to `restclient-mode` manually with `M-x restclient-mode`.

### Grammar checking does not work

`langtool` requires LanguageTool and Java. Install both, then configure `langtool-default-language` and the path to your LanguageTool installation as needed for your system.

## File Layout

This is intentionally a single-file setup:

```text
~/.emacs.d/init.el
```

The `init-dwim` implementation is included directly in the init file. It is not loaded as an external package. Customizations placed in Emacs's `custom.el` (written by `M-x customize`) are loaded automatically if the file exists.

## License

MIT
