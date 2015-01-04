---
layout: post
title: Ottimizzare la leggibilità del proprio sito con Compass /3
---

Bene, dopo una sfarinatura su come mantenere un ritmo verticale tramite
Compass, su come impostare una scala tipografica, su come gestire in
maniera ottimale i font-size mediante `em`, arriviamo all'ultimo
passaggio: come scegliere in maniera ottimale `line-height` e `font-size`
per il tag `<body>`, ovvero le dimensioni che saranno di riferimento per l'intero sito?

La soluzione non è ovviamente farina del mio sacco, ma si
rifà al concetto di [Golden Ratio
Typography](http://www.pearsonified.com/2011/12/golden-ratio-typography.php),
ideato da Chris Pearson.

L'impianto della trattazione si basa su due evidenze provabili empiricamente da chiunque:

* Le proprietà `font-size` e `line-height` sono legate
  linearmente: per mantenere un testo leggibile, se una aumenta l'altra
  dovrà aumentare proporzionalmente;
* Similmente, larghezza del corpo del testo (da qui in poi `line-width`) e `line-height` sono legate
  linearmente: più la larghezza aumenta, più difficile diventa per
  l'occhio umano seguire le linee di testo, e dunque diventa necessario
  aumentare anche l'interlinea.

Chris Pearson si è spinto oltre, cercando di legare numericamente queste
grandezze, facendo uso del famoso rapporto aureo:

![Line height](/images/blog/vertical_rythm/optimal-line-height.gif)
![Line width](/images/blog/vertical_rythm/optimal-line-width.gif)

Quindi, è sufficiente scegliere il `font-size` di riferimento, per
esempio `16px`, e `line-height` e `line-width` verranno da sè:

```sass
$phi-const: 1.61803399
$base-font-size: 15px
$base-line-height: $base-font-size * $phi-const
$base-line-width: $base-line-height * $base-line-height
```

In linea teorica, il concetto termina qui. Dal punto di vista pratico
però, i nostri schermi lavorano su un'unità di misura non
"spezzabile": il pixel. Il calcolo riportato
porterebbe ad una interlinea di `24.27px`, ovviamente non realizzabile.
Occorrerebbe portarlo a `24px`, ma non sarebbe l'arrotondamento
ottimale.

Matematicamente parlando, ciò che bisogna realizzare è un
"minimizzatore" di errore, in grado di ricercare il minimo locale.
Trovare dunque la combinazione di pixel "interi" per `font-size`,
`line-height` e `line-width` che globalmente più si avvicinano ai valori aurei.

Non si tratta di calcoli piacevolissimi, e fortunatamente Chris Pearson
ha creato il [Golden Ratio Typography Calculator](http://www.pearsonified.com/typography/),
che fa tutto il lavoro sporco per noi. Possiamo fissare sul calcolatore il `font-size`
prescelto, o piuttosto la larghezza del contenuto, o entrambi. Il buon
calcolatore ci restituirà il `line-height` ottimale, oltre a suggerirci
eventuali cambiamenti di dimensioni che potrebbero ulteriormente
migliorare la resa.

Niente. Dovrei aver finito, siete pronti per rendere i vostri blog
super-leggibili. La mia parentesi tipografica si chiude temporaneamente.

Per un po' ritornerò a parlare di codice, tante cose bollono in
pentola!
