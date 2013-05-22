---
layout: post
date: 2011/10/23
title: "Linear gradients su IE: Sinatra alla riscossa"
---

Con strumenti come Sass e Compass il CSS sta vivendo il suo primo vero rinascimento: la possibilità di astrarre, modularizzare e parametrizzare i fogli di stile ci permette di rendere più stimolante, rapido e mantenibile un lavoro altrimenti devastante a causa dei vari rendering engines da dover gestire.

E' ancora recente la scelta di Compass di introdurre nel suo core l'ormai fu Lemonade, estensione in grado di generare automaticamente immagini sprites attraverso comodi mixins. Non tutti sono particolarmente favorevoli ad arrivare un simile livello di automazione: non sono uno di questi. Personalmente, condivido ogni strada che possa essere prese per rendere meno tedioso un lavoro banale. :)

Un altro esempio di tedio, per esempio, arriva dalla direttiva `linear-gradient`, non supportata nativamente dall'amato Explorer, se non a mezzo di astrusi filtri di questo tipo:

{% highlight sass %}
=ie-linear-gradient($from, $to)
  :filter progid:DXImageTransform.Microsoft.Gradient(GradientType=0, startColorstr='#{$from}', endColorstr='#{$to}') // IE6 & IE7
  :-ms-filter quote(progid:DXImageTransform.Microsoft.gradient(startColorstr='#{$from}', endColorstr='#{$to}')) // IE8 & IE9
  :background-image -ms-linear-gradient(top, #{$from}, #{$to}) // IE10
=cross-browser-linear-gradient($from, $to)
  +ie-linear-gradient($from, $to)
  +background(linear-gradient($from, $to))
{% endhighlight %}

Purtroppo la renderizzazione di gradienti realizzati con questa tecnica è orribile, dunque non c'è altro rimedio se non tornare nei mitici '90s, e utilizzare a mo' di gradiente la famosa immagine larga 1xNpx. E qui entra in gioco Sinatra.

Prima il codice:

{% highlight sass %}
=ie-linear-gradient($from, $to, $height)
  background: mix($from, $to) image-url("/images/ie_gradients/#{red($from)}-#{green($from)}-#{blue($from)}-#{red($to)}-#{green($to)}-#{blue($to)}-#{$height}.png")
{% endhighlight %}

Questo mixin cosa fa? Prende come parametri i due colori limite del gradiente e l'altezza del gradiente stesso, e assume la presenza di una immagine che segua una nomenclatura predefinita, dipendente proprio dai 3 parametri di cui sopra. Imposta inoltre un colore solido di fallback, pari al mix *fifty-fifty* tra i due colori.

Ottimo, ormai siamo a cavallo, è sufficiente chiedere a Sinatra di completare il lavoro:

{% highlight rb %}
get '/images/ie_gradients/:r1-:g1-:b1-:r2-:g2-:b2-:height.png' do |r1, g1, b1, r2, g2, b2, height|
  # il path ricomposto dell'immagine
  path = File.join(File.dirname(__FILE__), 'public/images/ie_gradients',"#{r1}-#{g1}-#{b1}-#{r2}-#{g2}-#{b2}-#{height}.png")
  unless File.exists? path
    # ricompongo i colori esadecimali
    from = "#%02x%02x%02x" % [r1.to_i, g1.to_i, b1.to_i]
    to = "#%02x%02x%02x" % [r2.to_i, g2.to_i, b2.to_i]
    # assicuriamoci che l'altezza sia un intero
    height = height.to_i
    # ImageMagick, pensaci tu!
    `convert -size 1x#{height} gradient:#{from}-#{to} #{path}`
  end
  # passo l'immagine
  send_file path
end
{% endhighlight %}

Come potete vedere, Sinatra intercetta la richiesta del file, controlla se effettivamente il file esiste, e in caso di test negativo, la genera in automatico utilizzando brutalmente ImageMagick, estrapolando i vari parametri dal nome del file stesso.

La tecnica è ancora grezza, ma vedete il potenziale? Una volta che i file sono stati generati da Sinatra, magari in fase di prototipazione iniziale del layout -- continua a funzionare anche senza Sinatra.

Ovviamente, per la massima comodità, si potrebbe trasformare tutto ciò in estensione Compass. Non ne ho mai fatta una, dunque ho evitato di perdere tempo in questa fase. Ma cosa ne pensate?