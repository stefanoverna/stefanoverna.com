---
layout: post
title: "Ottimizzare la leggibilità del proprio sito con Compass /2"
date: 2012/01/12
---

Al termine del post precedente, abbiamo visto come mantenere
tutte le interlinee multiple tra di loro permetta una maggiore
leggibilità del testo. Per essere più chiari, ecco [un esempio](http://24ways.org/examples/compose-to-a-vertical-rhythm/example.html)
di ciò di cui stiamo parlando.

Nel mondo web, l'unità base di spazio verticale è rappresentata dalla regola CSS
`line-height`.

![Line height](/data/vertical_rythm/font-size-line-height.png)

Una `line-height` rimane costante nella pagina fino a quando non
intervengono cambi di `font-size`, `margin`, `padding` o `border`.
A questo punto tipicamente il flusso si spezza producendo interlinee
non multiple.

Riuscire a impostare dimensioni di `margin`, `padding` e `border` tali
da preservare il flusso verticale in tutta la pagina richiede una serie
di calcoli non particolarmente complessi, ma sicuramente poco divertenti.

Fortunatamente Compass include un modulo poco documentato ma ottimo in grado di
alleviare di molto questo problema.

## Vertical Rythm con Compass

Una volta importato il modulo tramite la direttiva

{% highlight sass %}
@import "compass/typography/vertical_rhythm"
{% endhighlight %}

siamo pronti a partire specificando il `font-size` e la `line-height` che abbiamo scelto
per il corpo principale del testo:

{% highlight sass %}
$base-line-height: 25px
$base-font-size: 15px
+establish-baseline
{% endhighlight %}

Il mixin `+establish-baseline` si occupa proprio di impostare questi due valori
sul selettore `body` (utilizzando come unità di misura l'*em* per
evitare problemi di resize su browser legacy).

<div class="important" markdown="1">
Una volta proceduti col seguente setup del modulo, l'unica regola da ricordare
è questa: le proprietà `font-size`, `line-height`, `margin`, `padding` e `border` non vanno mai
toccate manualmente, perchè spezzerebbero il ritmo. Per modificarle è necessario passare
attraverso appositi mixin di Compass.
</div>

Supponiamo di voler stilizzare il tag `h1`, portando il `font-size` a 24px,
e aggiungendo del margine in basso. Non possiamo più fare:

{% highlight sass %}
h1
  font-size: 24px
  margin-bottom: 15px
{% endhighlight %}

Ma dovremo invece scrivere qualcosa come:

{% highlight sass %}
h1
  +adjust-font-size-to(24px, 2)
  +padding-trailer(3, 24px)
{% endhighlight %}

Il primo mixin utilizzato, `+adjust-font-size-to`, oltre ad impostare il nuovo `font-size`,
modificherà la line-height dell'elemento in modo tale da preservare l'interlinea originaria
di `25px`, od un suo multiplo. Il secondo parametro, impostato nell'esempio a 2,
imposterà un line-height effettivo di `25px * 2 = 50px`.

Il mixin `+padding-trailer`, similmente, imposterà un `padding-bottom` in *em* pari
esattamente a `26px * 3 = 75px`. Esistono ovviamente tutta una serie di mixin analoghi
per gestire allo stesso modo margini, padding e bordi superiori e inferiori.

E' importante ricordare di utilizzare numeri interi come parametri per
tali mixin, a meno che la somma totale non risulti comunque essere un
intero:

{% highlight sass %}
h1
  +adjust-font-size-to(24px, 1.5)
  +padding-leader(0.5, 24px)
  +padding-trailer(1, 24px)
{% endhighlight %}

Questo esempio è comunque valido in quanto `1.5 + 0.5 + 1 = 3`, che
continua ad essere un numero intero.

## Ci fermiamo anche oggi

Nel prossimo post andremo ad analizzare l'ultima questione fondamentale
per la leggibilità: in base a quali parametri dovremo andare a scegliere
il `$base-line-height` e `$base-line-height` ottimale per la nostra pagina.

## Referenze

* [Compose to a Vertical Rhythm](http://24ways.org/2006/compose-to-a-vertical-rhythm), Richard Rutter
* [Scale & Rhythm](http://lamb.cc/typograph/), Iain Lamb
* [Vertical Rythm Module](http://compass-style.org/reference/compass/typography/vertical_rhythm/), Compass Documentation

