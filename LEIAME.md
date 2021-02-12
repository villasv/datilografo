# O Datilógrafo

## Objetivos

## Decisões

### Formato .md
O texto compilado da constituição deverá ser armazenado em um arquivo de texto
legível por pessoas que não tenham familiaridade com tecnologia. Por isso, deve
apresentar o mínimo de marcação textual possível para indicar a estrutura do
documento de forma intuitiva. Por esse critério, estão eliminadas as linguagens
de marcação oferecidas pelo HTML, reStructuredText e AsciiDoc. As possibilidades
restantes são: a) [Markdown (.md)][markdown] b) [Sem padrão (.txt)][texto]

A vantagem de se utilizar o formato .md no lugar de .txt é a ampla
disponibilidade de ferramentas específicas. Por exemplo, ao visitar o arquivo
[diretamente no repositório][arquivo] é apresentada uma visualização mais
confortável do que a [original][original]. A interpretação de Markdown nos
navegadores permite o uso de âncoras: links que apontam diretamente para uma
seção do documento ([exemplo][seção]).

A desvantagem é ser obrigado a seguir as regras de formatação do Markdown. Essas
regras limitam as escolhas de organização do texto no arquivo. Por isso os
incisos e artigos precisam ser separados por linhas em branco. Além disso, mesmo
que a marcação seja simples, pode ser estranho o primeiro contato com as
notações de `*negrito*`, `_itálico_` e os níveis de `# título`, `# subtítulo`,
`### subsubtítulo` etc.

Mesmo que fosse evitado o uso de Markdown, alguma marcação seria necessária para
indicar a estrutura do documento; portanto, algum nível de estranheza é
inevitável. Enfim, foi decidido que os ganhos da adoção de Markdown superam os
custos.

[markdown]: https://pt.wikipedia.org/wiki/Markdown
[texto]: https://pt.wikipedia.org/wiki/Arquivo_de_texto
[arquivo]: https://github.com/villasv/datilografo/blob/main/texto_promulgado/texto_promulgado.md
[original]: https://raw.githubusercontent.com/villasv/datilografo/main/texto_promulgado/texto_promulgado.md
[seção]: https://github.com/villasv/datilografo/blob/main/texto_promulgado/texto_promulgado.md#cap%C3%ADtulo-iii


# Referências

https://github.com/abjur/constituicao

https://www.senado.leg.br/atividade/const/constituicao-federal.asp
