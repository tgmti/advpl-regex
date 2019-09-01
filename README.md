# AdvPl RegEx

Implementação de RegEx em AdvPl

Projeto criado por [Thiago Oliveira Santos](https://github.com/Farenheith) em Setembro de 2013 e disponibilizado no [Google Code](https://code.google.com/archive/p/advpl-regex/).

***

# As seguintes funcionalidades estão disponíveis até o momento:

## Classes de caracteres:

As classes de caracteres podem ser tanto as padrões (`\w`, `\d`, etc...) como personalizadas

## Quantificadores: 

`?, +, *, {m,n}, {,m}, {m,}`

## Boundaries:

`^ `: Somente como marcador de início de texto

`$ `: Somente como marcador de final de texto

## Agrupamentos:

`( ) `: Suporta captura de grupo que pode ser omitida por "`?:`"

## Captura de grupos:

Quando utilizadas recursivamente dentro do regexp, deve-se usar \1 e \2 Em expressões de output para substituição, pode-se adicionalmente usar a expressão (m,n), que servirá para pegar a ocorrência n do grupo m.

## Grupos nomeados:

Um agrupamento pode ser nomeado com o seguinte termo no início do grupo: `?<nome> `

Igualmente, para fazer referência a um grupo pelo nome em operações de Transform e Replace, deve-se utilizar a seguinte sintaxe: `\<nome>`

Também é possível referenciar a ocorrência, da seguinte forma: `\<nome,numerodaocorrencia>`

Dois grupos podem ter o mesmo nome e, se for o caso, serão tratados como o mesmo agrupamento em operações de captura, inclusive o índice será o mesmo, isto é, se eu tiver apenas dois grupos, os dois terem o mesmo nome e eu usar a referência \1, esta referência retornará informação que pode ter sido capturada por qualquer um dos grupos. A não ser no caso de grupos com mesmo nome, o índice não é alterado.

## Pattern "OU" ( | pipe)

O "ou" consiste em determina duas ou mais patterns aceitáveis para um texto procurado Exemplo: \w+on|\w+re|\w+la|\w+go

A Pattern acima procura por sequências de texto e número que terminem com on, re, la e go. Palavras como thiago e sala seriam encontradas com este pattern. No caso, sala poderia ser encontrada até dentro de salada, já que não há nenhum padrão que defina que o caracter seguinte ao texto encontrado não pode ser uma letra.

## Exemplos de utilização:

RegEx para captura ou validação de e-mail `[\w-\._\+%]+@(?:[\w-]+\.)+[\w]{2,6}`

RegEx para captura ou validação de IPv4 `(?:(2(?:[0-4]\d|5[0-5])|[01]?\d?\d)\.){3}(?:(2(?:[0-4]\d|5[0-5])|[01]?\d?\d))`

RegEx para captura de campos de um texto CSV, delimitado por , e com qualificador de texto " `(?:("(?:[^"]|"")+"|[^",\n\r]++)[,\n\r]?)+`
