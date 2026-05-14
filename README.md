# DWIM Emacs Setup

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
  - spell-checking tools supported by your Emacs/Ispell setup
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

This keybinding is active through Evil in normal, visual, motion, and emacs states.

The config also sets the Evil leader key to:

```text
SPC
```

## What `init-dwim` Does

`init-dwim` collects actions from many providers, filters them by the current context, sorts them by priority, and displays them through completion. With Vertico, Orderless, Marginalia, and Consult enabled, this gives you a fast searchable action menu.

Examples of context-aware actions include:

- Region actions: copy, kill, indent, format, comment, sort, deduplicate, search, evaluate, or send to AI
- URL actions: open, copy, insert Markdown or Org links, fetch title, open in EWW, or download
- File path actions: open, copy, reveal in Dired, open externally, link, delete, copy, or diff
- Symbol actions: jump to definition, find references, rename, search, describe, highlight, or query-replace
- Org actions: TODO state, scheduling, deadlines, refiling, archiving, clocking, links, export, tags, capture, agenda, and table helpers
- Programming actions: tests, formatting, diagnostics, REPLs, evaluation, related files, Imenu, Eglot actions, and compilation
- Text and Markdown actions: preview, links, word count, export, folding, search, and table of contents
- Dired actions: open, rename, copy, delete, compress, external open, Git status, mark by extension, and search contents
- Magit actions: stage, unstage, commit, push, pull, diff, branch, checkout, stash, blame, log, and status
- Project actions: search, files, switch project, commands, notes, Git status, Dired, shell, and terminal
- Buffer and window actions: save, revert, rename, kill, clone, copy, split, delete, balance, rotate, and maximize
- Help, Evil, AI, output buffer, tab, register, spelling, macro, narrowing, shell, and Emacs administration actions

## Package Stack

The setup uses `straight.el` with `use-package` and installs packages automatically.

### Completion and Discovery

- `vertico`
- `orderless`
- `marginalia`
- `consult`
- `embark`
- `which-key`

### Editing

- `evil`
- `evil-collection`
- `corfu`
- `cape`
- `yasnippet`
- `yasnippet-snippets`
- `smartparens`
- `expand-region`

### Projects, Search, and Version Control

- `projectile`
- `magit`
- `git-gutter`
- `ripgrep`
- `rg`

### Programming

- Built-in `eglot`
- `flycheck`
- `apheleia`
- `format-all`
- `highlight-symbol`
- `tree-sitter-langs`
- `cider`
- `sly`
- `pytest`
- `jest-test-mode`
- `go-mode`
- `rust-mode`
- `typescript-mode`
- `json-mode`
- `yaml-mode`
- `dockerfile-mode`

### Writing, Org, and Markdown

- Built-in `org`
- `org-modern`
- `markdown-mode`
- `markdown-toc`
- `grip-mode`
- `langtool`
- `writeroom-mode`

### Files, Shells, and UI

- Built-in `dired`, `diff-mode`, and `smerge-mode`
- `diredfl`
- `eat`
- `doom-themes`
- `doom-modeline`
- `no-littering`

### AI

- `gptel`
- `ellama`

## UI Defaults

The config starts with a clean, modern UI:

- Startup screen disabled
- Menu bar, tool bar, and scroll bar disabled
- Global line numbers enabled
- Column number mode enabled
- Save place, save history, recent files, and auto-revert enabled
- Doom One theme loaded
- Doom Modeline enabled
- Tabs disabled by default

## Editing Defaults

- Spaces instead of tabs
- Tab width: `4`
- Fill column: `88`
- Backups disabled
- Auto-save enabled
- Lockfiles disabled
- Short answers enabled, so Emacs asks `y`/`n` instead of `yes`/`no`

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

### Formatting does not work

Install the formatter expected for the current major mode, or customize Apheleia/Format All for your preferred formatter.

### Grammar checking does not work

`langtool` usually requires LanguageTool and Java. Install both, then configure `langtool` as needed for your system.

## File Layout

This is intentionally a single-file setup:

```text
~/.emacs.d/init.el
```

The DWIM implementation is included directly in the init file. It is not loaded as an external package.

## License

MIT
