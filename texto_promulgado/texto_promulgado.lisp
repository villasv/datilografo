#!/usr/bin/env -S sbcl --script
(load "~/.sbclrc")
(ql:quickload :lquery)

(defvar página (uiop:read-file-string "página.html"))
(defvar documento (lquery:$ (initialize página) "#conteudoConst"))


(defvar conteúdo (format nil "~{~A~^~%~}" (coerce (lquery:$ documento (text)) 'list)))
(with-open-file (saída "texto_promulgado.txt"
    :direction :output
    :if-exists :supersede
    :if-does-not-exist :create)
  (write-sequence conteúdo saída))
