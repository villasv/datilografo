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

;; Prepara o preâmbulo
(defvar preâmbulo (lquery:$ documento "#conteudoConst p.preambulo"))
(loop for p across preâmbulo do
  (plump:traverse p
    (lambda (nó) (setf (plump:text nó) (concatenate 'string
      (if (string= (plump:text nó) "Preâmbulo")
        "> **"
        (concatenate 'string '(#\Newline) ">" '(#\Newline) "> _"))
      (plump:text nó)
      (if (string= (plump:text nó) "Preâmbulo") "**" "_"))))
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

;; Demarca e separa os artigos
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (cond
      ((str:starts-with? "Art. " (plump:text nó))
        (setf (plump:text nó) (concatenate 'string
          '(#\Newline)
          "**" (plump:text nó) "**"
          '(#\Newline))))
      (t nil)))
    :test #'plump:text-node-p))

;; Demarca e separa os parágrafos
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (cond
      ((or (str:starts-with? "§ " (plump:text nó))
           (str:starts-with? "Parágrafo único." (plump:text nó)))
        (setf (plump:text nó) (concatenate 'string
          '(#\Newline)
          "  **" (plump:text nó) "**"
          '(#\Newline))))
      (t nil)))
    :test #'plump:text-node-p))

;; Demarca e separa os incisos
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (cond
      ((cl-ppcre:scan "[IVXL]+ -" (plump:text nó))
        (setf (plump:text nó) (concatenate 'string
          '(#\Newline)
          "        " (plump:text nó))))
      (t nil)))
    :test #'plump:text-node-p))

;; Demarca e separa as alíneas
(loop for p across elementos do
  (plump:traverse p
    (lambda (nó) (cond
      ((cl-ppcre:scan "[a-z]\\)" (plump:text nó))
        (setf (plump:text nó) (concatenate 'string
          '(#\Newline)
          "          " (plump:text nó) " ")))
      (t nil)))
    :test #'plump:text-node-p))

;; Separa a parte final
(defvar final (lquery:$ documento "#conteudoConst p.parteFinal"))
(loop for p across final do
  (plump:traverse p
    (lambda (nó) (setf (plump:text nó) (concatenate 'string
      '(#\Newline)
      (plump:text nó))))
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
