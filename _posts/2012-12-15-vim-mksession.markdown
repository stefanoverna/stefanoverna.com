---
layout: post
title: "Persistere sessioni di lavoro con Vim"
date: 2012/12/15
---

Vim continua a stupirmi. Spesso e volentieri mi sono ritrovato a chiedermi se 
esistesse un modo per ripristinare lo stato delle viste così come lasciate prima
dell'ultima chiusura.

Esce fuori l'esistenza del comando `:mksession` che permette di salvare su file
lo stato corrente dell'editor sotto forma di Vimscript. 

Con l'opzione `sessionoptions` è anche possibile specificare con un buon livello 
di granularità cosa salvare su file e cosa ignorare. Ovviamente è possibile 
caricare in un secondo momento il Vimscript con un `:source session.vim`.

[`vim-session`](https://github.com/xolox/vim-session) è un plugin che estende
il comportamento base di `:mksession` e rende più comodo gestire una serie di 
sessioni. 

{% highlight bash %}
let g:session_directory = "."
let g:session_autoload = 'yes'
let g:session_autosave = 'yes'
set sessionoptions-=buffers
{% endhighlight %}

Configurato in questo modo, permette di dare vita ad un workflow comodissimo:
per ogni progetto, è sufficiente richiamare il comando `:SaveSession` la prima 
volta. Verrà salvato un file `default.vim` all'interno della directory del progetto,
che verrà automaticamente aggiornato ad ogni chiusura dell'editor, e ripristinato
lo stato precedente ad ogni apertura dell'editor nella medesima cartella.

L'opzione `set sessionoptions-=buffers` specifica la volontà di non ripristinare
lo stato dei buffer nascosti.