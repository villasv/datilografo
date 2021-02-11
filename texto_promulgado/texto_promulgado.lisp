#!/usr/bin/env -S sbcl --script
(load "~/.sbclrc")
(ql:quickload '(:lquery :plump :cl-ppcre))

(defvar página (uiop:read-file-string "página.html"))
(defvar documento (lquery:$ (initialize página) "#conteudoConst p"))

;; Remove espaçamento excessivo
(loop for p across documento do
  (plump:strip p))
(loop for p across documento do
  (plump:traverse p
    (lambda (nó) (setf (plump:text nó)
      (cl-ppcre:regex-replace-all "\\s+" (plump:text nó) " ")))
    :test #'plump:text-node-p))

(defvar conteúdo (format nil "~{~A~^~%~}" (coerce (lquery:$ documento (text)) 'list)))
(with-open-file (saída "texto_promulgado.txt"
    :direction :output
    :if-exists :supersede
    :if-does-not-exist :create)
  (write-sequence conteúdo saída))
