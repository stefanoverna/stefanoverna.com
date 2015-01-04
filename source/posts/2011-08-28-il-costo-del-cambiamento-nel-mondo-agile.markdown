---
layout: post
title: Il costo del cambiamento nel mondo Agile
---

Una delle assunzioni universali dell’ingegneria del software è quella che vede il costo necessario per modificare un programma crescere esponenzialmente nel tempo. Chi di noi non ha mai visto qualcosa di simile su un manualone di programmazione?

![Il costo esponenziale del cambiamento](http://dl.dropbox.com/u/8835321/stefanoverna.com/9u.png "Il costo esponenziale del cambiamento")

Ovviamente, un grafico del genere ci spinge a premunirci. Per evitare l’insorgere di costi inimmaginabili nel futuro, si tenta di prevedere ogni problematica con il più largo anticipo, stimando ogni futura evoluzione del progetto già dall’inizio dei tempi. Questo in effetti è ciò che tutti noi — ad un certo punto della nostra crescita professionale — abbiamo imparato volenti o nolenti a fare, pur sapendo quanto a tratti sia impossibile.

Durante gli ultimi decenni, enormi sforzi sono stati compiuti nella costruzione di nuovi linguaggi, paradigmi, strumenti e metodologie di lavoro in grado di alleviare il costo delle modifiche in corso d’opera.
La lettura del libro “Extreme Programming Explained” di Kent Beck è stata illuminante. Si parte da una domanda: ma se per caso tutti questi sforzi avessero veramente portato a qualcosa? Se per caso, applicando i risultati ottenuti in questo senso, il costo di una modifica ad un software non crescesse in modo esponenziale nel tempo, ma seguisse una curva molto più lenta, tendente quasi ad un asintoto?

![Il costo asintotico del cambiamento](http://dl.dropbox.com/u/8835321/stefanoverna.com/9v.png "Il costo asintotico del cambiamento")

È questa la premessa tecnica fondamentale dell’Extreme Programming (e di tutte le metodologie agili in generale): se i costi crescessero in questo modo, lo sviluppo SW procederebbe con modalità totalmente differenti.

Le “grandi decisioni” verrebbero prese quanto più tardi possibile, per posticiparne il costo e per attendere di avere in mano il massimo quantitativo recuperabile di informazioni a convalidare l'investimento. Si implementerebbe solo il minimo indispensabile, e si introdurrebbero nuovi elementi al design complessivo solo quando questi semplificassero il codice già esistente, o rendessero il prossimo pezzo di codice più semplice da scrivere.

Non si spenderebbero più giornate o settimane a decidere in fase di specifica iniziale se investire o meno in una componente “rischiosa”, solo per la paura che eseguire la medesima modifica in un secondo tempo possa essere enormemente più costoso; si implementerebbe solo ciò che si rivela utile all’oggi, con la fiducia e la tranquillità di sapere che un domani sarà possibile estendere l'esistente senza aumenti di prezzo degni di preoccupazione.

Con questo cambiamento radicale di prospettiva ci sono le basi per impostare un processo di sviluppo del software nel quale — invece che attuare le grandi decisioni al “tempo zero” e limitarsi a piccole virate in seguito — siamo in grado, in ogni momento, di prendere decisioni strategiche e vederle realizzate tempi rapidi.
