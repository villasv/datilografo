#!/usr/bin/env -S sbcl --script
(load "~/.sbclrc")
(ql:quickload :legit)

;; Limpeza do ambiente
(ensure-directories-exist "./cartamagna/")
(defvar diretório (first (directory "./cartamagna/")))
(uiop:delete-directory-tree diretório :validate t)

;; Criação do repositório
(ensure-directories-exist diretório)
(legit:git-init :directory diretório)
(defvar repositório (make-instance 'legit:repository :location diretório))
(push (list "origin" "git@github.com:villasv/cartamagna.git") (legit:remotes repositório))

;; Configuração de submódulo

;; Inicialização com o texto promulgado
(uiop:copy-file
  "../texto_promulgado/texto_promulgado.md"
  "./cartamagna/CONSTITUIÇÃO.md")
(legit:add repositório ".")
(legit:commit repositório
  "Constituição da República Federativa do Brasil")
(legit:push repositório)
