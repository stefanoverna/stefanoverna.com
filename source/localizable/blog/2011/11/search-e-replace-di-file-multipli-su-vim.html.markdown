---
date: 2011/11/14
title: Search e replace di file multipli su Vim
---

Questo era l'ultimo pezzo che mi mancava da Textmate, direi. La sostituzione becera su più file in contemporanea. Io l'ho risolta con [`greplace`](https://github.com/vim-scripts/greplace.vim), un simpatico plugin.

Se usi [Janus](https://github.com/carlhuda/janus) (lo usi, vero?), aggiungi questa riga in `~/.janus.rake`:

    [@language="ruby"]
    [@caption="~/.janus.rake"]
    vim_plugin_task "greplace", "git://github.com/vim-scripts/greplace.vim.git"

Perfetto, ora lancia un `rake` dalla cartella `~/.vim` per installare automaticamente il plugin, e aggiungi quest'ultima riga in `~/.gvimrc.local`:

    [@language="vim"]
    [@caption="~/.gvimrc.local"]
    " Command-Shift-R for greplace
    map <D-R> :Gqfopen<CR>:ccl<CR>

Da questo momento, potrai continuare a ricercare utilizzando Ack con lo shortcut `Cmd+Shift+F`. Ma se, con il pannello dei risultati ancora aperto, provi a digitare `Cmd+Shift+R`, il pannello si trasformerà in un buffer con i medesimi risultati, ma modificabile. Effettua le tue sostituzioni tranquillamente su quel file con i metodi classici. Una volta terminato il lavoro, lancia il comando `:Greplace` -- così come suggerito in un commento nel buffer stesso -- e le modifiche effettuate sul buffer si rifletteranno sui vari file.

Già che ci sono, ti consiglio anche [`indentguides`](http://github.com/mutewinter/vim-indent-guides), io lo trovo fantastico.

E voi? Usate qualcosa di particolarmente fico? Fatemi sapere, son
curioso :)
