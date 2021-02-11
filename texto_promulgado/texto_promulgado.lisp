#!/usr/bin/env -S sbcl --script
(load "~/.sbclrc")
(ql:quickload '(:lquery :plump :cl-ppcre))

(defvar página (uiop:read-file-string "página.html"))
(defvar elementos (lquery:$ (initialize página) "#conteudoConst p"))

;; Remove espaçamento excessivo
(loop for p across elementos do
  (plump:strip p))
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (setf (plump:text nó)
      (cl-ppcre:regex-replace-all "\\s+" (plump:text nó) " ")))
    :test #'plump:text-node-p))

(defvar linhas (coerce (lquery:$ elementos (text)) 'list))
(defvar conteúdo (format nil "~{~A~%~^~}"
  (remove-if (lambda (s) (string= "" s)) linhas)))

(with-open-file (saída "texto_promulgado.txt"
    :direction :output
    :if-exists :supersede
    :if-does-not-exist :create)
  (write-sequence conteúdo saída))
