---
layout: post
title: "CoffeeBeans: AJAX con CoffeeScript su Rails"
external_link: https://github.com/markbates/coffeebeans
---

Il pezzo che ancora mancava a Rails 3.1: scrivere anche le risposte AJAX in CoffeeScript. Con questo plugin è sufficiente creare viste con suffisso `.coffee`, e verranno automaticamente convertite in Javascript al momento del rendering.

```ruby
# app/views/users/index.js.coffee
alert "Hello world!"
```

L'unico svantaggio da verificare è la lentezza per processare questa compilazione live.
