;;; pto.el --- Project Templates Organizer           -*- lexical-binding: t; -*-

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

(defun replace-in-file (file from to)
  "Replace text FROM to TO in FILE."
  (with-current-buffer (find-file-noselect file)
    (goto-char (point-min))
    (while (search-forward from (point-max) t)
      (replace-match to t))
    (when (buffer-modified-p)
      (write-file (buffer-file-name)))
    (kill-buffer)))

(defun pto/replace-parameters (project-directory project-template-name)
  "Replace parameters in PROJECT-DIRECTORY.
Assuming project is copied from PROJECT-TEMPLATE-NAME."
  (let ((parameters (cdr (plist-get pto/project-parameters (intern project-template-name)))))
    (dolist (param parameters)
      (let* ((placeholder (nth 0 param))
	     (prompt (nth 1 param))
	     (type (nth 2 param))
	     (description (nth 3 param))
	     (replacement (read-string prompt)))
	(dolist (file (directory-files-recursively project-directory ".*"))
	  (replace-in-file file placeholder replacement))))))

(defgroup pto nil "Customization options for the Project Templates Organizer." :group 'convenience)

(defcustom pto/project-parameters
  '(thunderbird-add-on (list
			 ("%NAME%" "What will the name of the add-on be? " 'string "Name of the add-on.")
			 ("%DESCRIPTION%" "Describe the new add-on: " 'string "Description of the add-on.")
			 ("%AUTHOR%" "Who is the author of the new add-on? " 'string "Author of the add-on.")))
  "Parameters for projects in form of a ."
  :type 'plist
  :group 'pto)

(defcustom pto/templates-directory nil "Directory of project templates."
  :type 'string
  :group 'pto)

(defcustom pto/default-repo nil "This value tells pto where to store projects by default."
  :type 'string
  :group 'pto)

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
		(read-string "Name of the installed project (directory name)? ")))
  (copy-directory project-template (concat project-repo installed-name))
  (pto/replace-parameters (concat project-repo "/" installed-name) (nth 1 (reverse (file-name-split project-template)))))

(provide 'pto)

;;; pto.el ends here
