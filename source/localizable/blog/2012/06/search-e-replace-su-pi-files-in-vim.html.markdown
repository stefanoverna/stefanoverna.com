---
title: "Search e replace su più files in Vim"
date: 2012/06/22
---

Ritorno su un argomento a me caro, già [affrontato in passato][old]: la ricerca
e sostituzione di stringhe su più files. Sebbene [greplace.vim][greplace]
finora abbia funzionato piuttosto bene, fa sempre comodo essere a conoscenza di
possibili alternative, soprattutto se non richiedono l'uso di plugin
aggiuntivi.

In Vim, la modalità generica per gestire operazioni contemporanee su più
file si basa sul concetto di argument list:

    [@language="bash"]
    :help argument-list

L'argument list è una variabile globale che rappresenta un insieme di path
su cui è possibile effettuare un determinato comando.

E' possibile vedere in ogni momento il valore della propria argument list
attraverso il comando `:ar[gs]`, aggiungere nuovi path col comando `:arga[dd]`,
e così via.

La cosa si fa interessante quando si scopre che è possibile anche impostare
l'argument list pari a tutti i files con una determinata estensione con questo
comando:

    [@language="bash"]
    :args **/*.rb

O utilizzare un comando esterno attraverso l'uso di backticks:

    [@language="bash"]
    :args `ack --ruby foobar`

Una volta impostata la lista di files da utilizzare, è possibile
lanciare un comando in "batch mode" su tutti i files specificati col
comando `:argdo`. Nel caso di search e replace, il comando sarà
ovviamente un `:s[ubstitute]`:

    [@language="bash"]
    :argdo %s/foobar/barfoo/e

Il flag `e` evita di lanciare un errore nel caso in cui in un certo
file non dovesse venire trovata nessuna occorrenza della regular
expression. Il comando in questo modo non salverà il risultato finale su file.
Per ottenere questo effetto è sufficiente aggiungere il comando `:update`:

    [@language="bash"]
    :argdo %s/foobar/barfoo/e | update

Per rendere l'operazione di ricerca più "sicura", possiamo sempre
contare sul flag `c`, che richiederà una conferma esplicita di ogni
sostituzione:

    [@language="bash"]
    :argdo %s/foobar/barfoo/ec

Sarebbe brutto terminare senza un oneliner, vero? Questo ad esempio reindenta
tutti i file ruby presenti nel progetto:

    [@language="bash"]
    :args **/*.rb | argdo execute "normal gg=G" | update

[old]: http://stefanoverna.com/blog/2011/11/search-e-replace-di-file-multipli-su-vim.html
[greplace]: http://www.vim.org/scripts/script.php?script_id=1813

