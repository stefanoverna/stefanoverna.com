---
layout: post
title: Get me torrents
date: 2013-05-23 09:06
tags:
---

Sebbene la stasi di questo posto, diverse cose divertenti sono successe da
gennaio, tra cui il side-project [Get me torrents!](http://www.getmetorrents.com),
che dopo 3 ore dalla messa in onda si è ritrovato sulla front page di Reddit:

![Reddit](/data/getmetorrents-reddit.png)

Con conseguente bombing di visitatori contemporanei:

![Analytics](/data/getmetorrents-analytics.png)

E' stata una giornata interessante. Non ero ovviamente preparare a gestire un
carico del genere (l'intero sito era hostato su una VPS da 7$/mese) ma in qualche 
modo siamo riusciti a scalare bene le richieste delegando a macchine secondarie
improvvisate la valanga di job in arrivo.

Avevo promesso di condividere il codice sorgente del progetto, dunque ecco
[`nanny`](https://github.com/stefanoverna/nanny), il core che esegue scraping
per ottenere URL diretti a torrent (completo di CLI), ed il [semplice sito Sinatra di
contorno](https://github.com/stefanoverna/getmetorrents-ruby), che sfrutta
[Resque][] e [Socky][] per offrire una interfaccia in grado di mostrare lo stato
in-progress delle ricerche.

Ora il sito si è trasformato in una estensione Chrome, che ha il duplice
vantaggio di evitare blocchi IP ed esternalizzare direttamente sui client 
il lavoro di scraping. Lo scraping dei siti di terze parti avviene attraverso 
delle semplici chiamate AJAX (che all'interno di estensioni non hanno limiti 
cross-site). A posteriori, sicuramente sarebbe stato meglio a lavorare alla
versione client-side da subito, ma l'intuizione è arrivata troppo tardi.

Tra non molto spero di trovare il tempo di pubblicare anche il sorgente
dell'estensione, nel frattempo è sufficiente scaricarla e fare un po' di
inspection del pacchetto :)

[resque]: https://github.com/defunkt/resque
[socky]: https://github.com/socky

