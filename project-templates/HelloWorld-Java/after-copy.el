;; This file is run by pto.el after a new project is copied into the project-directory

(let* ((package-name "%PACKAGE%")
       (package-path (string-replace "." "/" "%PACKAGE%"))
       (src-dir (concat "src/main/java/" package-path))
       (tst-dir (concat "src/test/java/" package-path)))
  (make-directory src-dir t)
  (copy-file "src/main/java/App.java" (concat src-dir "/App.java"))
  (delete-file "src/main/java/App.java")
  (make-directory tst-dir t)
  (copy-file "src/test/java/TestApp.java" (concat tst-dir "/TestApp.java"))
  (delete-file "src/test/java/App.java"))
  
  
