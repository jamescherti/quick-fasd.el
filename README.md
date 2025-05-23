# quick-fasd.el - Easily navigate your file system directly within Emacs by using Fasd
![Build Status](https://github.com/jamescherti/quick-fasd.el/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/github/license/jamescherti/quick-fasd.el)
![](https://raw.githubusercontent.com/jamescherti/quick-fasd.el/main/.images/made-for-gnu-emacs.svg)

The **quick-fasd** Emacs package integrates the Fasd tool within the Emacs environment. Fasd, a command-line utility, enhances the productivity of users by providing fast access to frequently used files and directories.

After installing the **quick-fasd** Emacs package, you can easily navigate your file system directly within Emacs by using Fasd’s fast-access capabilities. For example, you can open recently accessed files or quickly jump to frequently used directories without leaving the Emacs environment.

Here’s how the package works:
- `quick-fasd-mode` adds a hook to `find-file-hook` and `dired-mode-hook` to automatically add all visited files and directories to Fasd's database.
- The user can invoke the `quick-fasd-find-file` function, which prompts for input and display available candidates from the Fasd index, enabling rapid and efficient file navigation.

## Requirements

- The [fasd](https://github.com/clvv/fasd) command line tool.

## Installation

### Emacs: Install with straight (Emacs version < 30)

To install *quick-fasd* with `straight.el`:

1. It if hasn't already been done, [add the straight.el bootstrap code](https://github.com/radian-software/straight.el?tab=readme-ov-file#getting-started) to your init file.
2. Add the following code to the Emacs init file:
```emacs-lisp
(use-package quick-fasd
  :ensure t
  :straight (quick-fasd
             :type git
             :host github
             :repo "jamescherti/quick-fasd.el")
  :config
  (quick-fasd-mode))
```

### Alternative installation: Emacs: Installing with use-package and :vc (Built-in feature in Emacs version >= 30)

To install *quick-fasd* with `use-package` and `:vc` (Emacs >= 30):

``` emacs-lisp
(use-package quick-fasd
  :ensure t
  :vc (:url "https://github.com/jamescherti/quick-fasd.el"
       :rev :newest)
  :config
  (quick-fasd-mode))
```

### Alternative installation: Doom Emacs

Here is how to install *quick-fasd* on Doom Emacs:

1. Add to the `~/.doom.d/packages.el` file:
```elisp
(package! quick-fasd
  :recipe
  (:host github :repo "jamescherti/quick-fasd.el"))
```

2. Add to `~/.doom.d/config.el`:
```elisp
(after! quick-fasd
  (quick-fasd-mode))
```

3. Run the `doom sync` command:
```
doom sync
```

## Usage

### Key binding

Add a shortcut key for `quick-fasd-find-file`:

```elisp
(global-set-key (kbd "C-h C-/") 'quick-fasd-find-file)
```

### Customizations

You can configure `quick-fasd` using Emacs' customization system:

```elisp
M-x customize-group RET fasd RET
```

### Initial Prompt

By default, `fasd` prompts for an initial query. To disable this and display all results immediately, set:

```elisp
(setq quick-fasd-enable-initial-prompt nil)
```

### Completion Function

`quick-fasd-find-file` uses the standard `completing-read-function`, which may be backed by `helm`, `ido`, or any other completion framework you have configured.

### Standard Search Behavior

By default, `fasd` searches for both files and directories using the `-a` parameter. You can customize this behavior by setting the `quick-fasd-standard-search` option to refine the search criteria.

## Author and License

The *quick-fasd* Emacs package has been written by steckerhalter and [James Cherti](https://www.jamescherti.com/) and is distributed under terms of the GNU General Public License version 3, or, at your choice, any later version.

Copyright (C) 2024-2025 James Cherti

Copyright (C) 2013-2021 steckerhalter

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

## Links

- [quick-fasd.el @GitHub](https://github.com/jamescherti/quick-fasd.el)

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
