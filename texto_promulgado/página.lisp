#!/usr/bin/env -S sbcl --script
(load "~/.sbclrc")
(ql:quickload :dexador)

;; https://web.archive.org/web/20201204151049/https://www.senado.leg.br/atividade/const/con1988/CON1988_05.10.1988/CON1988.asp
(defvar url "http://www.senado.leg.br/atividade/const/con1988/CON1988_05.10.1988/CON1988.asp")
(defvar request (dex:get url))

(with-open-file (saída "página.html"
    :direction :output
    :if-exists :supersede
    :if-does-not-exist :create)
  (write-sequence request saída))
