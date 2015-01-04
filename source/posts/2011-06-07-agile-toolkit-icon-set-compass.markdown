---
layout: post
title: "atk_icons: Agile Toolkit Icon Set su Compass"
external_link: https://github.com/welaika/atk_icons
---

Da un paio di progetti a questa parte sto facendo un uso massiccio di un iconset non particolarmente conosciuto: [Agile Toolkit Icon Set](http://www.agiletech.ie/blog/128x16x16). Trattasi di 128 iconcine 16x16 da poter utilizzare in un sacco di contesti, e che con uno sforzo minimo rendono immediatamente più attraente, usabile e caratterizzante un sito.

Con la solita logica DRY, ieri sera ho creato una piccola gemma che permette di sfruttare questo iconset su Compass con maggiore semplicità:

```sass
# screen.sass
@import "atk_icons"
.button.delete
  /* this will add an :after pseudo-selector with the specified icon
  @include atk-icon-pseudo("basic-ex")
.button.add span.icon
  /* you can also set the icon to a sub-element
  @include atk-icon("basic-plus")
```

Per maggiori informazioni su come installare questa estensione Compass, consultate il [`README`](https://github.com/welaika/atk_icons). Spero vi possa essere utile!
