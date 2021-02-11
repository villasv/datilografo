#!/usr/bin/env -S sbcl --script
(load "~/.sbclrc")
(ql:quickload '(:lquery :plump :cl-ppcre :str))

(defvar página (uiop:read-file-string "página.html"))
(defvar documento (lquery:$ (initialize página)))
(defvar elementos (lquery:$ documento "#conteudoConst p"))

;; Remove espaçamento excessivo
(loop for p across elementos do
  (plump:strip p))
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (setf (plump:text nó)
      (cl-ppcre:regex-replace-all "\\s+" (plump:text nó) " ")))
    :test #'plump:text-node-p))

;; Adiciona marcadores estruturais
(defun abaixo (e1 e2)
  (cond
    ((equal e1 :título) (or
      (equal e2 :título)))
    (t nil)))

(defvar estrutura '())
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (cond
      ((string= (plump:attribute p "class") "ementa")
        (push :ementa estrutura)
        (setf (plump:text nó) (concatenate 'string "# " (plump:text nó) '(#\Newline))))
      ((str:starts-with? "Título" (plump:text nó))
        (loop while (abaixo :título (first estrutura)) do
          (pop estrutura))
        (push :título estrutura)
        (print estrutura)
        (setf (plump:text nó) (concatenate 'string
          '(#\Newline) "## " (plump:text nó) '(#\Newline))))
      (t nil)))
    :test #'plump:text-node-p))

;; Remove linhas em branco que restaram
(defvar linhas (coerce (lquery:$ elementos (text)) 'list))
(defvar conteúdo (format nil "~{~A~%~^~}"
  (remove-if (lambda (s) (string= "" s)) linhas)))

(with-open-file (saída "texto_promulgado.txt"
    :direction :output
    :if-exists :supersede
    :if-does-not-exist :create)
  (write-sequence conteúdo saída))
