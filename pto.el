;;; pto.el --- oject Templates Organizer           -*- lexical-binding: t; -*-

;; Copyright (C) 2025  Matthias Pfeifer

;; Author: Matthias Pfeifer <matthias@kamino.local>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(defgroup pto nil "Customization options for the Project Templates Organizer." :group 'convenience)

(defcustom pto/project-parameters nil
  "Parameters for projects."
  :type 'plist
  :group 'pto)

(defcustom pto/templates-directory nil "Directory of project templates."
  :type 'string
  :group 'pto)

(defcustom pto/default-repo nil "This value tells pto where to store projects by default."
  :type 'string
  :group 'pto)

(defcustom pto/after-copy-script "after-copy.el"
  "Emacs-lisp file to run when new project is started.")

(defun replace-in-file (file from to)
  "Replace text FROM to TO in FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (while (search-forward from nil t)
      (replace-match to t t))
    (write-region (point-min) (point-max) file)))

(defun pto/process-parameters (project-directory project-template-name)
  "Replace parameters in PROJECT-DIRECTORY.
Assuming project is copied from PROJECT-TEMPLATE-NAME."
  (let ((parameters (plist-get pto/project-parameters (intern (concat ":" project-template-name)))))
    (dolist (param parameters)
      (cond
       ((eq (nth 0 param) :replacement)
        (let* ((param (cdr param))
               (placeholder (nth 0 param))
               (prompt (nth 1 param))
               (type (nth 2 param))
               ;;             (description (nth 3 param))
               )
          (cond ((eq type :string)
                 (let ((replacement (read-string prompt)))
                   (dolist (file (directory-files-recursively project-directory ".*"))
                     (replace-in-file file placeholder replacement))))
                ((eq type :list)
                 (progn
                   (let* ((options (nth 3 param))
                          (replacement (completing-read prompt options)))
                     (dolist (file (directory-files-recursively project-directory ".*"))
                       (replace-in-file file placeholder replacement))))))))))))

(defun pto/start-new-project (project-template project-repo installed-name)
  "Start a new project from PROJECT-TEMPLATE.  Start project in PROJECT-REPO.
Project will be installed as INSTALLED-NAME."
  (interactive (list
                (expand-file-name
                 (read-directory-name "Select template: "
                                      (file-name-as-directory pto/templates-directory)
                                      (file-name-as-directory pto/templates-directory) t))
                (expand-file-name
                 (read-directory-name "Select projects repo: "
                                      (file-name-as-directory pto/default-repo)
                                      (file-name-as-directory pto/default-repo) t))
                (read-string "Directory name for the new project? ")))
  (copy-directory project-template (concat project-repo installed-name))
  
  (pto/process-parameters (concat project-repo "/" installed-name)
                          (nth 1 (reverse (file-name-split project-template))))
  (let ((default-directory (concat project-repo "/" installed-name)))
    (when (file-exists-p pto/after-copy-script)
      (load-file pto/after-copy-script)
      (delete-file pto/after-copy-script)
      (delete-file (concat pto/after-copy-script "c" )))))

(provide 'pto)

;;; pto.el ends here
