# quick-fasd.el - Integrate Fasd for fast file and directory navigation in Emacs
![Build Status](https://github.com/jamescherti/quick-fasd.el/actions/workflows/melpazoid.yml/badge.svg)
[![MELPA](https://melpa.org/packages/quick-fasd-badge.svg)](https://melpa.org/#/quick-fasd)
[![MELPA Stable](https://stable.melpa.org/packages/quick-fasd-badge.svg)](https://stable.melpa.org/#/quick-fasd)
![License](https://img.shields.io/github/license/jamescherti/quick-fasd.el)
![](https://jamescherti.com/misc/made-for-gnu-emacs.svg)

The [quick-fasd](https://github.com/jamescherti/quick-fasd.el) Emacs package integrates the Fasd tool into the Emacs environment. Fasd is a command-line utility that provides fast access to frequently used files and directories.

After installing **quick-fasd** and enabling `quick-fasd-mode`:

- All visited files and directories are automatically added to the Fasd database.
- The `quick-fasd-find-path` function prompts for input and presents candidates from the Fasd index. *(For example, recently accessed files can be opened, and frequently used directories can be visited without leaving Emacs.)*
- When invoked from the minibuffer, `quick-fasd-find-path` appends the selected path, simplifying completion.

If this package improves the workflow, consider supporting the project by **⭐ starring quick-fasd.el on GitHub** so that more Emacs users can benefit from it.

## Requirements

- The [fasd](https://github.com/clvv/fasd) command line tool.

## Installation

1. If you haven't already done so, [add MELPA repository to your Emacs configuration](https://melpa.org/#/getting-started).

2. Add the following code to your Emacs init file to install **easysession** from MELPA:

```emacs-lisp
(use-package quick-fasd
  :bind (("C-x C-d" . quick-fasd-find-path)
         :map minibuffer-local-completion-map
         ("C-x C-d" . quick-fasd-find-path))
  :init
  (quick-fasd-mode 1))
```

## Usage

### Key binding

Add a shortcut key for `quick-fasd-find-path`:

```elisp
(global-set-key (kbd "C-x C-d") 'quick-fasd-find-path)

;; When `quick-fasd-find-path' is invoked from the minibuffer, it appends
;; the selected path, simplifying completion.
;; Path insertion can be disabled by setting `quick-fasd-minibuffer-insert-path' to nil.
(define-key minibuffer-local-completion-map (kbd "C-x C-d") 'quick-fasd-find-path)
```

### Customizations

You can configure `quick-fasd` using Emacs' customization system:

```elisp
M-x customize-group RET quick-fasd RET
```

### Passing custom arguments to Fasd

The `quick-fasd` package allows customizing the types of results returned by Fasd using `quick-fasd-standard-search`:

```emacs-lisp
;; Display directories only
(setq quick-fasd-standard-search '("-d"))

;; Display files only
(setq quick-fasd-standard-search '("-f"))

;; Display both files and directories
(setq quick-fasd-standard-search '("-a"))
```

### Initial Prompt

By default, *quick-fasd* prompts for an initial query. To bypass the prompt and display all results immediately, set:

```elisp
(setq quick-fasd-enable-initial-prompt nil)
```

Setting this to nil is useful when using completion frameworks such as Consult, Vertico, or Orderless, allowing them to handle filtering instead of fasd. However, fetching all paths from fasd can be slower for large file databases and may produce an overwhelming number of candidates.

### Completion Function

The `M-x quick-fasd-find-path` command uses the standard `completing-read-function`, which may be backed by *Consult*, *helm*, *ido*, or any other completion framework you have configured.

### Standard Search Behavior

By default, *quick-fasd* searches for both files and directories using the `-a` parameter. You can customize this behavior by setting the `quick-fasd-standard-search` option to refine the search criteria.

### Automatically adding paths on buffer or window change

Quick-Fasd can optionally add the current file or directory to the Fasd database whenever the buffer or window changes. This behavior is controlled by the `quick-fasd-auto-add-on-buffer-change` option.

To enable automatic path addition, set the option to `t`:

```elisp
(setq quick-fasd-auto-add-on-buffer-change t)
```

When enabled, Quick-Fasd will track every file or directory visited in Emacs, including those accessed through buffers and Dired windows, without requiring manual addition.

Benefits:

- **Seamless tracking**: Ensures that all relevant files and directories are added to Fasd automatically.
- **Improved workflow**: Facilitates faster navigation through frequently accessed paths using Quick-Fasd commands, without the need to manually update the database.

Drawbacks:

- **Increased background activity:** Each buffer or window change spawns a background process to update the Fasd database. While this does not block Emacs, it can generate extra system activity if buffers are switched frequently.
- **Database growth**: Continuous automatic additions may increase the size of the Fasd database over time, potentially including entries that are rarely used.

Use this option when the convenience of automatic tracking outweighs the potential performance and database size considerations.

## Frequently asked questions

### What is the difference between quick-fasd and the fasd Emacs package?

The *quick-fasd* Emacs package is a fork of the unmaintained *fasd* Emacs package. It supersedes *fasd* by providing additional features and bug fixes.

Key differences and improvements in *quick-fasd* include:

- When `quick-fasd-find-path` is invoked from the minibuffer, it appends the selected path, simplifying completion. (This can be disabled by setting `quick-fasd-minibuffer-insert-path` to nil)
- Adds support for indirect Dired buffers.
- Enhances `dired-mode` detection to append paths using the `fasd` command, increasing their priority for subsequent `fasd` usage.
- Fixes an issue in `quick-fasd-add-path` to ensure it respects `quick-fasd-executable-path`.
- Caches the path to the `fasd` executable for efficiency.
- Enhances modularity and readability of `quick-fasd` functions.
- Fixes all Emacs warnings.
- Renames `global-quick-fasd-mode` to `quick-fasd-mode`.
- Refines overall code readability and structure.
- Removes Ivy support, delegating it to a possible third-party package.
- Allows customizing the Lighter
- Removes the trailing slash from directories before adding them to Fasd ensures consistent path entries and prevents duplicates.
- Normalizes the path before adding it to Fasd by expanding it (e.g., replacing `~/` with the home directory).
- Provides a function to remove a specified path from the Fasd database (`quick-fasd-delete-path`).
- Can optionally add the current file or directory to the Fasd database whenever the buffer or window changes. This behavior is controlled by the `quick-fasd-auto-add-on-buffer-change` option.

## Author and License

The *quick-fasd* Emacs package [James Cherti](https://www.jamescherti.com/) and is distributed under terms of the GNU General Public License version 3, or, at your choice, any later version. It is based on the fasd package, originally written by Steckerhalter.

Copyright (C) 2024-2026 James Cherti

Copyright (C) 2013-2021 Steckerhalter

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

## Links

- [quick-fasd.el @GitHub](https://github.com/jamescherti/quick-fasd.el)
- [quick-fasd.el @MELPA](https://melpa.org/#/quick-fasd)

Other Emacs packages by the same author:

- [compile-angel.el](https://github.com/jamescherti/compile-angel.el): **Speed up Emacs!** This package guarantees that all .el files are both byte-compiled and native-compiled, which significantly speeds up Emacs.
- [outline-indent.el](https://github.com/jamescherti/outline-indent.el): An Emacs package that provides a minor mode that enables code folding and outlining based on indentation levels for various indentation-based text files, such as YAML, Python, and other indented text files.
- [easysession.el](https://github.com/jamescherti/easysession.el): Easysession is lightweight Emacs session manager that can persist and restore file editing buffers, indirect buffers/clones, Dired buffers, the tab-bar, and the Emacs frames (with or without the Emacs frames size, width, and height).
- [vim-tab-bar.el](https://github.com/jamescherti/vim-tab-bar.el): Make the Emacs tab-bar Look Like Vim's Tab Bar.
- [elispcomp](https://github.com/jamescherti/elispcomp): A command line tool that allows compiling Elisp code directly from the terminal or from a shell script. It facilitates the generation of optimized .elc (byte-compiled) and .eln (native-compiled) files.
- [tomorrow-night-deepblue-theme.el](https://github.com/jamescherti/tomorrow-night-deepblue-theme.el): The Tomorrow Night Deepblue Emacs theme is a beautiful deep blue variant of the Tomorrow Night theme, which is renowned for its elegant color palette that is pleasing to the eyes. It features a deep blue background color that creates a calming atmosphere. The theme is also a great choice for those who miss the blue themes that were trendy a few years ago.
- [Ultyas](https://github.com/jamescherti/ultyas/): A command-line tool designed to simplify the process of converting code snippets from UltiSnips to YASnippet format.
- [dir-config.el](https://github.com/jamescherti/dir-config.el): Automatically find and evaluate .dir-config.el Elisp files to configure directory-specific settings.
- [flymake-bashate.el](https://github.com/jamescherti/flymake-bashate.el): A package that provides a Flymake backend for the bashate Bash script style checker.
- [flymake-ansible-lint.el](https://github.com/jamescherti/flymake-ansible-lint.el): An Emacs package that offers a Flymake backend for ansible-lint.
- [inhibit-mouse.el](https://github.com/jamescherti/inhibit-mouse.el): A package that disables mouse input in Emacs, offering a simpler and faster alternative to the disable-mouse package.
- [quick-sdcv.el](https://github.com/jamescherti/quick-sdcv.el): This package enables Emacs to function as an offline dictionary by using the sdcv command-line tool directly within Emacs.
- [enhanced-evil-paredit.el](https://github.com/jamescherti/enhanced-evil-paredit.el): An Emacs package that prevents parenthesis imbalance when using *evil-mode* with *paredit*. It intercepts *evil-mode* commands such as delete, change, and paste, blocking their execution if they would break the parenthetical structure.
- [stripspace.el](https://github.com/jamescherti/stripspace.el): Ensure Emacs Automatically removes trailing whitespace before saving a buffer, with an option to preserve the cursor column.
- [persist-text-scale.el](https://github.com/jamescherti/persist-text-scale.el): Ensure that all adjustments made with text-scale-increase and text-scale-decrease are persisted and restored across sessions.
- [pathaction.el](https://github.com/jamescherti/pathaction.el): Execute the pathaction command-line tool from Emacs. The pathaction command-line tool enables the execution of specific commands on targeted files or directories. Its key advantage lies in its flexibility, allowing users to handle various types of files simply by passing the file or directory as an argument to the pathaction tool. The tool uses a .pathaction.yaml rule-set file to determine which command to execute. Additionally, Jinja2 templating can be employed in the rule-set file to further customize the commands.
- [kirigami.el](https://github.com/jamescherti/kirigami.el): The *kirigami* Emacs package offers a unified interface for opening and closing folds across a diverse set of major and minor modes in Emacs, including `outline-mode`, `outline-minor-mode`, `outline-indent-minor-mode`, `org-mode`, `markdown-mode`, `vdiff-mode`, `vdiff-3way-mode`, `hs-minor-mode`, `hide-ifdef-mode`, `origami-mode`, `yafolding-mode`, `folding-mode`, and `treesit-fold-mode`. With Kirigami, folding key bindings only need to be configured **once**. After that, the same keys work consistently across all supported major and minor modes, providing a unified and predictable folding experience.
- [buffer-guardian.el](https://github.com/jamescherti/buffer-guardian.el): Automatically saves Emacs buffers without requiring manual intervention. By default, it triggers a save when the user switches to another buffer, switches to another window or frame, Emacs loses focus, or the minibuffer is opened. Beyond standard file buffers, *buffer-guardian* also manages specialized editing buffers such as *org-src* and *edit-indirect*. Additional features, disabled by default, include periodic or idle-time saving of all buffers, automatic exclusion of remote, nonexistent, or large files, and support for custom exclusion rules via regular expressions or predicate functions.
