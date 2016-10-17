;;; dired-icon.el --- A minor mode to display a list of associated icons in dired buffers. -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Hong Xu <hong@topbug.net>

;; Author: Hong Xu <hong@topbug.net>
;; URL: https://gitlab.com/xuhdev/dired-icon
;; Version: 0.1
;; Keywords: dired, files
;; Package-Requires: ((cl-lib "0.5"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This package provides a minor mode `dired-icon-mode' to display an icon for
;; each file type in dired buffers.  Currently systems which runs GTK, such as
;; GNU/Linux and FreeBSD, are fully supported.

;; To report bugs and make feature requests, please open a new ticket at the
;; issue tracker <https://gitlab.com/xuhdev/dired-icon/issues>.  To contribute,
;; please create a merge request at
;; <https://gitlab.com/xuhdev/dired-icon/merge_requests>.

;;; Code:

(require 'cl-lib)
(require 'dired)
(require 'ezimage)

(defgroup dired-icon nil
  "Display icons for files in dired buffers."
  :group 'dired
  :prefix 'dired-icon)

(defcustom dired-icon-file-executable "file"
  "The path of the executable of the \"file\" executable."
  :type 'string)

(defcustom dired-icon-python2-executable "python2"
  "The path of the executable of the \"python2\" executable (Python 2.x is required)."
  :type 'string)

(defvar dired-icon--script-directory
  (if load-file-name
      (file-name-directory load-file-name)
    default-directory)
  "The directory of this script.")

(defvar dired-icon--image-hash (make-hash-table :test 'equal)
  "A hash table that maps image path to the image object by \"create-image\".")

(defun dired-icon--get-icons (file-names)
  "Create an alist, which maps the files FILE-NAMES to image objects."
  (cond
   ;; GTK2
   ((and (executable-find dired-icon-file-executable)
         (executable-find dired-icon-python2-executable)
         (= 0 (call-process dired-icon-python2-executable nil nil nil
                            (expand-file-name
                             "get-icon-path-gtk2.py"
                             dired-icon--script-directory) "test")))
    (with-temp-buffer
      ;; insert the list of mimetypes into the temp buffer
      (dolist (fn file-names)
        (goto-char (point-min)) ;; reverse the file name insertion order
        (call-process dired-icon-file-executable nil t nil
                      "-b" "--mime-type" fn))
      ;; replace the current buffer with an icon file name in each line
      (call-process-region (point-min) (point-max)
                           dired-icon-python2-executable
                           t t nil
                           (expand-file-name
                            "get-icon-path-gtk2.py"
                            dired-icon--script-directory))
      ;; create an image object for each icon
      (let ((icon-images nil))
        (dolist (icon-fname (split-string (buffer-string) "\n" nil))
          (if (string= icon-fname "")
              (push nil icon-images)
            (let ((image (gethash icon-fname dired-icon--image-hash)))
              (unless image
                (setq image (create-image icon-fname))
                (puthash icon-fname image dired-icon--image-hash))
              (push image icon-images))))
        ;; The first element is an nil caused by the file end \n. Remove
        ;; it.
        (pop icon-images)
        (cl-pairlis file-names icon-images))))
   (t  ;; other unsupported systems
    (cl-pairlis file-names
                (make-list (length file-names) nil)))))

(defun dired-icon-display ()
  "Display the icons."
  (interactive)
  ;; always clear the overlays from last readin
  (when (boundp 'dired-icon--overlays)
    (dolist (o dired-icon--overlays)
      (delete-overlay o)))
  (setq-local dired-icon--overlays nil)

  (let* ((files (directory-files default-directory t))
         (file-icons (dired-icon--get-icons files)))
    (save-excursion
      (cl-loop for (fn . icon) in file-icons
               count
               (when (dired-goto-file fn)
                 (let ((image
                        (if (file-directory-p fn)
                            ezimage-directory
                          icon)))
                   (when image
                     (dired-move-to-filename)
                     (push (put-image image (point))
                           dired-icon--overlays))))))))

(define-minor-mode dired-icon-mode
  "Display icons according to the file types in dired buffers."
  :lighter "dired-icon"
  (add-hook 'dired-after-readin-hook 'dired-icon-display))

(provide 'dired-icon)

;;; dired-icon.el ends here

;; Local Variables:
;; coding: utf-8
;; fill-column: 80
;; indent-tabs-mode: nil
;; sentence-end-double-space: t
;; End:
