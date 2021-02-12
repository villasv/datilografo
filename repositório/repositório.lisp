#!/usr/bin/env -S sbcl --script
(load "~/.sbclrc")
(ql:quickload :legit)

;; Limpeza do ambiente
(ensure-directories-exist "./cartamagna/")
(defvar diretório (first (directory "./cartamagna/")))
(uiop:delete-directory-tree diretório :validate t)

;; Criação do repositório
(ensure-directories-exist diretório)
(legit:with-chdir (diretório)
  (legit:git-init)
  (legit:git-checkout
    :branch "-B" :new-branch "main")
  (legit:git-remote
    :add
    :name "origin"
    :url "git@github.com:villasv/cartamagna.git"))

;; Inicialização com o texto promulgado
(defvar data "1988-10-5T15:30:00-3")
(uiop:copy-file
  "../texto_promulgado/texto_promulgado.md"
  "./cartamagna/CONSTITUIÇÃO.md")
(legit:with-chdir (diretório)
  (legit:git-add
    :all t)
  (setf (uiop:getenv "GIT_COMMITTER_DATE") data)
  (setf (uiop:getenv "GIT_AUTHOR_DATE") data)
  (legit:git-commit
    :message "Constituição da República Federativa do Brasil")
  (legit:git-push
    :set-upstream t
    :repository "origin"
    :refspecs "main"
    :force t))
