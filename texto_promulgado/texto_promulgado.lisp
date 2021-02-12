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
(defvar hierarquia-estrutural '(:ementa :título :capítulo :seção :subseção))
(defun descendente (e1 e2)
  (or (equal e2 nil) (> (position e1 hierarquia-estrutural) (position e2 hierarquia-estrutural))))
(defun marcador-estrutural (texto)
  (cond
    ((str:starts-with? "Constituição da República Federativa do Brasil" texto) :ementa)
    ((str:starts-with? "Título" texto) :título)
    ((str:starts-with? "Capítulo" texto) :capítulo)
    ((str:starts-with? "Seção" texto) :seção)
    ((str:starts-with? "Seção" texto) :seção)
    ((str:starts-with? "Subseção" texto) :subseção)
    (t nil)))

;; Demarca e separa as estruturas
(defvar estrutura '())
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (cond
      ((marcador-estrutural (plump:text nó))
        (loop while (not (descendente (marcador-estrutural (plump:text nó)) (first estrutura))) do
          (pop estrutura))
        (push (marcador-estrutural (plump:text nó)) estrutura)
        (setf (plump:text nó) (concatenate 'string
          '(#\Newline)
          (make-string (length estrutura) :initial-element #\#) " " (plump:text nó)
          '(#\Newline))))
      (t nil)))
    :test #'plump:text-node-p))

;; Define a hierarquia dispositiva
(defun marcador-dispositivo (texto)
  (cond
    ((str:starts-with? "Art. " texto) :artigo)
    ((str:starts-with? "§ " texto) :parágrafo)
    ((str:starts-with? "Parágrafo único." texto) :parágrafo)
    (t nil)))

;; Demarca e separa os dispositivos
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (cond
      ((marcador-dispositivo (plump:text nó))
        (setf (plump:text nó) (concatenate 'string
          '(#\Newline)
          "**" (plump:text nó) "**"
          '(#\Newline))))
      (t nil)))
    :test #'plump:text-node-p))

;; Demarca e separa os incisos
(defvar primeiro-inciso t)
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (cond
      ((cl-ppcre:scan "[IVXL]+ -" (plump:text nó))
        (setf (plump:text nó) (concatenate 'string
          '(#\Newline)
          "    " (plump:text nó)))
        (setf primeiro-inciso nil))
      ((string= (plump:attribute (plump:parent nó) "class") "alinea")
        (setf primeiro-inciso nil))
      (t (setf primeiro-inciso t))))
    :test #'plump:text-node-p))

;; Demarca e separa as alíneas
(defvar pós-alínea nil)
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (cond
      ((cl-ppcre:scan "[a-z]\\)" (plump:text nó))
        (setf (plump:text nó) (concatenate 'string
          "        " (plump:text nó) " "))
        (setf pós-alínea t))
      ((string= (plump:attribute (plump:parent nó) "class") "alinea")
        (setf (plump:text nó) (concatenate 'string
          (plump:text nó) "  "))
        (setf pós-alínea nil))
      (t (setf pós-alínea nil))))
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
