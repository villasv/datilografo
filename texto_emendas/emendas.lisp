#!/usr/bin/env -S sbcl --script
(load "~/.sbclrc")
(ql:quickload '(:dexador :jonathan :str))

;; https://web.archive.org/web/20210212215756/https://www.senado.leg.br/atividade/const/emendas_a.txt
(defvar url "https://www.senado.leg.br/atividade/const/emendas_a.txt")
(defvar resultado (dex:get url))

(with-open-file (saída "emendas.json"
    :direction :output
    :if-exists :supersede
    :if-does-not-exist :create)
  (write-sequence resultado saída))

;; Gera os links da constituição compilada em cada data
(defvar emendas (jonathan:parse resultado))
(loop for emenda in (getf emendas :|normas|) do
  (let ((prefixo "https://www.senado.leg.br/atividade/const/con1988/con1988_")
        (sufixo "/CON1988.asp")
        (norma (getf emenda :|norma|))
        (data (getf emenda :|data|)))
    (cond
      ((str:starts-with? "EMC" norma)
        (let ((url (str:concat prefixo (str:join "." (reverse (str:split "-" data))) sufixo)))
          (with-open-file (saída (str:concat "./compilados/" norma ".html")
              :direction :output
              :if-exists :supersede
              :if-does-not-exist :create)
            (write-sequence (dex:get url) saída))))
      (t nil))))
