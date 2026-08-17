;;; quick-fasd.el --- Integration for the command-line tool `fasd' -*- lexical-binding: t; -*-

;; Copyright (C) 2024-2026 James Cherti
;; Copyright (C) 2013-2021 steckerhalter

;; Maintainer: James Cherti
;; Original Author: steckerhalter
;; Version: 1.0.2
;; URL: https://github.com/jamescherti/quick-fasd.el
;; Keywords: convenience
;; Package-Requires: ((emacs "26.1"))
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; The quick-fasd Emacs package integrates the Fasd tool within the Emacs
;; environment. Fasd, a command-line utility, enhances the productivity of users
;; by providing fast access to frequently used files and directories. Inspired
;; by tools such as autojump, z, and v, Fasd functions by maintaining a dynamic
;; index of files and directories you access, allowing you to reference them
;; quickly from the command line.
;;
;; After installing quick-fasd in Emacs, you can easily navigate your file
;; system directly within Emacs by using Fasd's fast-access capabilities. For
;; example, you can open recently accessed files or quickly jump to frequently
;; used directories without leaving the Emacs environment.
;;
;; Here's how the package works:
;; - `quick-fasd-mode' adds a hook to `find-file-hook' and `dired-mode-hook' to
;;   automatically add all visited files and directories to Fasd's database.
;; - The user can invoke the `quick-fasd-find-path' function, which prompts for
;;   input and display available candidates from the Fasd index, enabling rapid
;;   and efficient file navigation.

;;; Code:

;;; Variables

(defgroup quick-fasd nil
  "Quickly accessing previously-visited files and directories using Fasd."
  :group 'quick-fasd
  :prefix "quick-fasd-")

(defcustom quick-fasd-enable-initial-prompt t
  "When non-nil, prompt the user for a query first.

When nil, return all fasd paths immediately for completion.

Setting this to nil is useful when using completion frameworks such as Consult,
Vertico, or Orderless, allowing them to handle filtering instead of fasd.
However, fetching all paths from fasd can be slower for large file databases and
may produce an overwhelming number of candidates."
  :type 'boolean
  :group 'quick-fasd)

;; TODO make this type function
(defcustom quick-fasd-file-manager 'find-file
  "Default file manager used by `quick-fasd-find-path-action'."
  :type '(radio
          (const
           :tag "find-file, the built-in function to edit files and directories"
           find-file)
          (const :tag "Dired, the default Emacs file manager" dired)
          (const :tag "Deer, Ranger's file manager" deer)
          (function :tag "Custom file manager function"))
  :group 'quick-fasd)

(defcustom quick-fasd-command-args '("-a")
  "List of flags passed to the fasd command.
This controls which types of entries are returned.

Available options:
  - `-a': Match files and directories
  - `-d': Match directories only
  - `-f': Match files only
  - `-r': Match by rank only
  - `-t': Match by recent access only

Multiple flags can be combined by adding them to the list. This allows
customizing the default behavior of `quick-fasd' searches."
  :type '(repeat string)
  :group 'quick-fasd)

(defcustom quick-fasd-executable-path "fasd"
  "Path to the Fasd executable or its command name (e.g., fasd)."
  :type 'string
  :group 'quick-fasd)

(defcustom quick-fasd-minibuffer-insert-path t
  "Control how `quick-fasd-find-path' behaves in the minibuffer.

If non-nil, the selected path is inserted directly into the minibuffer.
If nil, `quick-fasd-find-path' opens the directory instead of inserting the
path."
  :type 'boolean
  :group 'quick-fasd)

(defcustom quick-fasd-auto-add-on-buffer-change nil
  "If non-nil, add the current path to Fasd when the buffer changes."
  :type 'boolean
  :group 'quick-fasd)

(defcustom quick-fasd-debug nil
  "When non-nil, display debug messages in the echo area for operations."
  :type 'boolean
  :group 'quick-fasd)

(defcustom quick-fasd-ignore-temporary-directories t
  "If non-nil, ignore files in standard Emacs temporary directories.
This checks against the variable `temporary-file-directory' and the TMPDIR
environment variable."
  :type 'boolean
  :group 'quick-fasd)

(defvar quick-fasd-mode-lighter " QFasd"
  "Default lighter string for `quick-fasd-mode'.")

(defcustom quick-fasd-ignore-directories
  '("\\`/run/")
  "List of regular expressions matching directories to ignore."
  :type '(repeat string)
  :group 'quick-fasd)

(defcustom quick-fasd-ignore-files
  '("\\.elc\\'")
  "List of regular expressions matching file names/extensions to ignore."
  :type '(repeat string)
  :group 'quick-fasd)

;;; Internal functions

(defvar quick-fasd--internal-executable nil)

(defvar quick-fasd--last-file nil
  "Tracks the most recently added file to prevent redundant fasd updates.")

(defvar quick-fasd--last-dir nil
  "Tracks the most recently added directory to prevent redundant fasd updates.")

(defmacro quick-fasd--debug (format-str &rest args)
  "Display message using FORMAT-STR and ARGS if `quick-fasd-debug' is non-nil."
  `(when quick-fasd-debug
     (message (concat "[quick-fasd] " ,format-str) ,@args)))

(defun quick-fasd--get-fasd-executable-path ()
  "Return the path to the `fasd` executable or signal an error if not found."
  (unless quick-fasd--internal-executable
    (setq quick-fasd--internal-executable
          (let ((result (executable-find quick-fasd-executable-path)))
            (when (or (not result)
                      (not (file-regular-p result))
                      (not (file-executable-p result)))
              (user-error "Fasd executable not found: %s"
                          quick-fasd-executable-path))
            result)))
  quick-fasd--internal-executable)

(defun quick-fasd-find-path-action (file)
  "Open FILE with appropriate file manager or prompt if unreadable."
  (if (file-readable-p file)
      (if (file-directory-p file)
          (funcall quick-fasd-file-manager file)
        (find-file file))
    (user-error "[quick-fasd] No such file or directory %s" file)))

(defun quick-fasd--get-file (prefix query)
  "Use fasd to open a file or directory and return the selected path.
Return nil if no results are found.
Optionally pass QUERY to avoid prompt.
PREFIX is the same prefix as `quick-fasd-find-path'."
  (let* ((fasd-executable (quick-fasd--get-fasd-executable-path))
         (prefix-value (prefix-numeric-value prefix))
         (fasd-args (cond
                     ((= prefix-value -1) '("-f"))
                     ((= prefix-value 0) '("-d"))
                     (t quick-fasd-command-args))))
    (unless query
      (setq query (if quick-fasd-enable-initial-prompt
                      (read-from-minibuffer "Fasd: ")
                    "")))
    (let* ((prompt "Fasd: ")
           (process-args (append '("-l" "-R")
                                 fasd-args
                                 (unless (string= query "")
                                   (list query))))
           (results
            (let ((default-directory temporary-file-directory))
              (condition-case nil
                  (apply #'process-lines fasd-executable process-args)
                (error nil))))
           (file (when results
                   (setq this-command 'quick-fasd-find-path)
                   (completing-read prompt results nil t))))
      (if file
          file
        (user-error "[quick-fasd] Fasd found nothing for: %S" query)))))

(defun quick-fasd--hook-add-path-to-db ()
  "Add current file or directory to the Fasd database."
  (let* ((raw-path (if (derived-mode-p 'dired-mode)
                       dired-directory
                     (buffer-file-name (buffer-base-buffer))))
         ;; In Emacs, the buffer-local variable dired-directory does not always
         ;; evaluate to a plain string. Depending on how the Dired buffer was
         ;; created, it can take two formats: a string or a cons cell.
         (path (if (stringp raw-path)
                   raw-path
                 (car raw-path))))
    (when (and path
               (stringp path)
               (not (file-remote-p path)))
      ;; Standardize the path and ensure it is absolute
      (setq path (expand-file-name path))

      (if (quick-fasd--should-ignore-p path)
          (quick-fasd--debug "Ignored: %s" path)
        (if (file-directory-p path)
            ;; Directory logic
            (progn
              ;; Ensure trailing slash for perfect equality checks
              (setq path (file-name-as-directory path))
              (setq quick-fasd--last-file nil)
              (unless (equal path quick-fasd--last-dir)
                (setq quick-fasd--last-dir path)
                (quick-fasd-add-path path t)))
          ;; File logic
          (when (file-regular-p path)
            (unless (equal path quick-fasd--last-file)
              (setq quick-fasd--last-file path)
              (quick-fasd-add-path path)
              ;; Update the parent directory asynchronously, BUT only if it
              ;; changed
              (let ((dir (file-name-directory path)))
                (when (and dir (not (equal dir quick-fasd--last-dir)))
                  (setq quick-fasd--last-dir dir)
                  (quick-fasd-add-path dir t))))))))))

(defun quick-fasd--maybe-add-path-on-buffer-change (&optional object)
  "Add current buffer's file or directory to Fasd if enabled.
OBJECT can be a frame or a window."
  (when quick-fasd-auto-add-on-buffer-change
    (let* ((is-frame (frame-live-p object))
           (frame (if is-frame
                      object
                    (selected-frame)))
           (window (cond
                    ;; Frame
                    (is-frame
                     (with-selected-frame object
                       (selected-window)))
                    ;; Window
                    ((window-live-p object)
                     object)
                    ;; Current window
                    (t
                     (selected-window)))))
      (when (and frame window)
        (with-selected-frame frame
          (with-selected-window window
            (quick-fasd--hook-add-path-to-db)))))))

(defun quick-fasd--should-ignore-p (path)
  "Return non-nil if PATH should be ignored based on ignore lists."
  (if (and quick-fasd-ignore-temporary-directories
           (or (and temporary-file-directory
                    (file-in-directory-p path temporary-file-directory))
               (and (not (memq system-type '(windows-nt ms-dos)))
                    (or (file-in-directory-p path "/tmp/")
                        (file-in-directory-p path "/var/tmp/")
                        (let ((tmpdir (getenv "TMPDIR")))
                          (and tmpdir
                               (not (string= tmpdir ""))
                               (file-in-directory-p path tmpdir)))))))
      t
    (catch 'found
      (dolist (regexp quick-fasd-ignore-directories)
        (when (string-match-p regexp path)
          (throw 'found t)))
      (unless (file-directory-p path)
        (let ((file-name (file-name-nondirectory path)))
          (dolist (regexp quick-fasd-ignore-files)
            (when (string-match-p regexp file-name)
              (throw 'found t)))))
      nil)))

;;; Functions

;;;###autoload
(defun quick-fasd-find-path (prefix &optional query)
  "Use fasd to open a file or directory.
Optionally pass QUERY to avoid prompt.
If PREFIX is 0 consider only directories.
If PREFIX is -1 consider only files.
Otherwise, use `quick-fasd-command-args', which by default lists both files and
directories."
  (interactive "P")
  (if (and quick-fasd-minibuffer-insert-path
           (minibufferp))
      (let* ((enable-recursive-minibuffers t)
             (file (quick-fasd--get-file prefix query)))
        (when file
          (setq file (file-name-as-directory file))
          (insert file)))
    (let ((file (quick-fasd--get-file prefix query)))
      (when file
        (quick-fasd-find-path-action file)))))

(define-obsolete-function-alias
  'quick-fasd-find-file
  #'quick-fasd-find-path
  "1.0.2")

;;;###autoload
(defun quick-fasd-delete-path (path)
  "Delete PATH from the Fasd database."
  (when (and path
             (stringp path)
             (not (file-remote-p path)))
    (let ((expanded-path (expand-file-name path))
          (fasd-executable (quick-fasd--get-fasd-executable-path))
          (default-directory temporary-file-directory))
      (let ((exit-code (call-process fasd-executable nil nil nil "-D" expanded-path)))
        (when (zerop exit-code)
          (quick-fasd--debug "Deleted path: %s" expanded-path))))))

;;;###autoload
(defun quick-fasd-add-path (path &optional async)
  "Add PATH to the Fasd database.
If ASYNC is non-nil, add the path in the background."
  (when (and path
             (stringp path)
             (file-readable-p path))
    (let* ((expanded-path (expand-file-name path))
           (fasd-executable (quick-fasd--get-fasd-executable-path))
           (default-directory temporary-file-directory))
      (if async
          ;; Asynchronous execution
          (set-process-sentinel
           (start-process "*fasd*" nil fasd-executable "--add" expanded-path)
           (lambda (proc _event)
             (when (and (eq (process-status proc) 'exit)
                        (zerop (process-exit-status proc)))
               (quick-fasd--debug "Added path (async): %s" expanded-path))))
        ;; Synchronous execution
        (let ((exit-code (call-process fasd-executable nil nil nil "--add" expanded-path)))
          (when (zerop exit-code)
            (quick-fasd--debug "Added path (sync): %s" expanded-path)))))))

;;;###autoload
(define-minor-mode quick-fasd-mode
  "Integration for the command-line tool `fasd'."
  :global t
  :group 'quick-fasd
  :lighter quick-fasd-mode-lighter
  (if quick-fasd-mode
      (progn
        (add-hook 'find-file-hook #'quick-fasd--hook-add-path-to-db)
        (add-hook 'dired-mode-hook #'quick-fasd--hook-add-path-to-db)
        (add-hook 'window-buffer-change-functions
                  #'quick-fasd--maybe-add-path-on-buffer-change))
    (remove-hook 'find-file-hook #'quick-fasd--hook-add-path-to-db)
    (remove-hook 'dired-mode-hook #'quick-fasd--hook-add-path-to-db)
    (remove-hook 'window-buffer-change-functions
                 #'quick-fasd--maybe-add-path-on-buffer-change)))

;;; Provide

(provide 'quick-fasd)

;;; quick-fasd.el ends here
