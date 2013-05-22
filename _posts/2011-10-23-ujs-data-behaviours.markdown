---
layout: post
date: 2011/10/23
title: "Tabs UJS con i data-behaviour"
---

Ho scoperto l'UJS in concomitanza della sua introduzione massiccia su Rails: ne sono rimasto immediatamente affascinato. Un coupling ancora meno stretto tra contenuto e comportamenti dinamici della pagina, utilizzando come strumento di comunicazione gli attributi HTML5 `data-*`? Fantastico! :)

Ho cercato da quel momento di impegnarmi a generare codice JS quanto più unobtrusive possibile; il vantaggio è evidente dopo i primi tentativi: nel tempo, arrivi a comporre una comoda libreria di comportamenti riutilizzabili in altri contesti senza nessun codice JS custom da introdurre.

## Esempio: una tabbed interface

Quante volte vi sarà capitato di dover impostare una vista a tab? Io sono arrivato a questa soluzione, che considero difficilmente battibile, sia per chiarezza che per brevità:

{% highlight coffeescript %}
$ ->
  $tab_scope_contents = {}
  $("[data-behaviour=tab]").each ->
    $tab = $(this)
    $tab_content = $($tab.attr("href") || $tab.find("a").attr("href")).hide()
    scope = $tab.data("tab-scope")
    $related_tabs = $("[data-tab-scope=#{scope}]")
    $tab_scope_contents[scope] = ($tab_scope_contents[scope] || $()).add $tab_content
    $tab.click ->
      $related_tabs.removeClass("selected-tab")
      $tab.addClass("selected-tab")
      $tab_scope_contents[scope].hide()
      $tab_content.show()
      false
    $related_tabs.eq(0).click()
{% endhighlight %}

Come si utilizza? Semplice: supponiamo di avere un HTML del genere:

{% highlight html %}
<ul>
  <li><a href="#primo">Primo tab</a></li>
  <li><a href="#secondo">Secondo tab</a></li>
  <li><a href="#terzo">Terzo tab</a></li>
</ul>
<div id="primo">Primo contenuto!</div>
<div id="secondo">Secondo contenuto!</div>
<div id="terzo">Terzo contenuto!</div>
{% endhighlight %}

E' sufficiente aggiungere, per ogni tab handle, un attributo `data-behaviour="tab"` per specificare che vogliamo da quel link un comportamento di tipo "tab", e un attributo `data-tab-scope="nome-dello-scope"` per specificare a quale gruppo di tab appartenga:

{% highlight html %}
<ul>
  <li><a href="#primo"   data-behaviour="tab" data-tab-scope="tabset1">Primo tab</a></li>
  <li><a href="#secondo" data-behaviour="tab" data-tab-scope="tabset1">Secondo tab</a></li>
  <li><a href="#terzo"   data-behaviour="tab" data-tab-scope="tabset1">Terzo tab</a></li>
</ul>
{% endhighlight %}

Boom. Il gioco è fatto. Ora, ovunque tu voglia tab, basta aggiungere due attributi all'HTML.

Cosa ne pensate?