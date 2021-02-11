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

;; Define a hierarquia estrutural
(defvar hierarquia '(:ementa :título :capítulo :seção :subseção))
(defun descendente (e1 e2)
  (>= (position e1 hierarquia) (position e2 hierarquia)))
(defun coerção (texto)
  (cond
    ((str:starts-with? "Constituição da República Federativa do Brasil" texto) :ementa)
    ((str:starts-with? "Título" texto) :título)
    ((str:starts-with? "Capítulo" texto) :capítulo)
    ((str:starts-with? "Seção" texto) :seção)
    ((str:starts-with? "Seção" texto) :seção)
    ((str:starts-with? "Subseção" texto) :subseção)
    (t nil)))

;; Demarca e separa as estruturas
(defvar estrutura '(:ementa))
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (cond
      ((coerção (plump:text nó))
        (loop while (not (descendente (coerção (plump:text nó)) (first estrutura))) do
          (pop estrutura))
        (setf (plump:text nó) (concatenate 'string
          '(#\Newline) "## " (plump:text nó) '(#\Newline))))
      (t nil)))
    :test #'plump:text-node-p))

;; Remove linhas em branco que restaram
(defvar linhas (coerce (lquery:$ elementos (text)) 'list))
(defvar conteúdo (format nil "~{~A~%~^~}"
  (remove-if (lambda (s) (string= "" s)) linhas)))

(with-open-file (saída "texto_promulgado.md"
    :direction :output
    :if-exists :supersede
    :if-does-not-exist :create)
  (write-sequence conteúdo saída))
