---
layout: post
date: 2012/01/11
title: Ottimizzare la leggibilità del proprio sito con Compass /1
---

Nel recente restyling di questo blog mi sono concentrato sul rendere
la lettura di ogni pagina il più piacevole possibile.
Era un campo inesplorato per me, e sono talmente eccitato delle scoperte
fatte e del risultato ottenuto che non posso non riassumervi qualcosa.

Innanzitutto, non stiamo parlando di tematiche specifiche per il web.
I tipografi si occupano di questa materia da centinaia d'anni, ed è
proprio dalle loro regole d'oro che bisogna partire.

In questa prima parte inizierò col descrivere le regole teoriche, nel
prossimo post vedremo come applicarle in assoluta semplicità grazie ai
vari mixin di Compass.

## Non comporre mai una pagina senza una scala tipografica

Una delle regole fondamentali è questa: ogni variazione di `font-size`
che si desidera introdurre nella pagina deve seguire una scala
predefinita e regolare.

Non esiste una sola scala possibile; esistono differenti scale celebri
e riconosciute come "naturali e piacevoli alla vista" in campo tipografico:

* Le [successioni di Fibonacci](http://it.wikipedia.org/wiki/Successione_di_Fibonacci);
* Il celebre [Modulor](http://it.wikipedia.org/wiki/Modulor) di Le Corbusier;
* Il [rapporto aureo](http://it.wikipedia.org/wiki/Sezione_aurea);
* La storica e tradizionale ["scala tipografica"](http://retinart.net/typography/typographicscale/);

La scelta di una di queste scale va fatta a seconda del contesto e del
proprio gusto personale. Per quanto mi riguarda, ho deciso di utilizzare
la scala tipografica, con un'unica differenza, ovvero quella di scegliere
un `font-size` di 15px (invece che 16px come consigliato) per il contenuto
principale della pagina (il corpo del post). Sul perchè di questa scelta
ci torneremo nel prossimo post.

![La scala tipografica](/data/vertical_rythm/typographicscale.gif)

Tutti gli altri `font-size` seguono la medesima scala: nel mio
caso ho scelto 18px per gli `h3`, 21px per gli `h2` e gli 24px per gli `h1`.

## Mantieni un unico ritmo verticale nella pagina

Il concetto astratto di leggibilità si posa in gran parte sul concetto
ben più materiale di *interlinea* (in inglese, *leading*): è lo spazio
fra la linea di base di una riga e quella della successiva.

Conservare l'interlinea immutata nel flusso dell'intera pagina aiuta
immensamente a renderla più piacevole e coerente.

<div class="important">
Progettare una pagina con ritmo verticale significa scegliere una interlinea di
riferimento e fare in modo che tutte le interlinee presenti nella pagina
presenti siano un suo multiplo.
</div>

### Piccola digressione sull'*em*

L'*em* è una unità di misura relativa: il suo valore in pixel dipende
direttamente dal `font-size` assegnato all'elemento stesso.

{% highlight sass %}
body
  font-size: 16px
  line-height: 1.5em
{% endhighlight %}

Nell'esempio, l'interlinea varrà `16px * 1.5 = 24px`, e mi permetterà
quindi di ottenere uno spazio vuoto tra le righe di testo pari a `24px -
16px = 8px`.

Altra cosa fondamentale da ricordare è che la direttiva `line-height` viene
ereditata dagli elementi del DOM sottostanti:

{% highlight sass %}
  body
    font-size: 16px
    line-height: 1.5em
    h1
      font-size: 18px
{% endhighlight %}

In questo caso, il tag `h1` avrà anch'esso un `line-height` pari a
`1.5em`, ma questa si tradurrà in una interlinea pari a `18px * 1.5 =
27px`.

Ultima cosa da ricordare riguardo all'*em*:

{% highlight sass %}
body
  font-size: 16px
  line-height: 1.5em
  h1
    font-size: 1.5em
{% endhighlight %}

Se è proprio la direttiva `font-size` ad avere una misura espressa in
*em*, allora questa sarà una misura relativa al `font-size`
dell'elemento padre. Nel nostro caso, il `font-size` per l'elemento `h1`
sarà di `16px * 1.5 = 24px`, con una interlinea pari a `24px * 1.5 = 36px`.

Impostare tutte le grandezze in *em* ci permette dunque di far
discendere tutte le proporzioni direttamente da un'unico parametro, il
`font-size` che si stabilisce per il `body`.

## Per oggi basta

Nel prossimo post vedremo:

* come arrivare matematicamente al un valore di interlinea ottimale per
  la propria pagina;
* come ruscire ad ottenere un ritmo verticale facendo uso degli *em*;
* come applicare tutta questa teoria ai nostri fogli di stile Sass con
  dei semplici mixin.

Aspetto i vostri commenti!