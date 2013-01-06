---
date: 2011/04/29
title: "ScottBot: a \"that's what she said\" bot"
external_link: https://github.com/jsocol/scottbot
---

> To get scottbot started, I put it into an otherwise empty IRC channel and just fed it a few "funny" and "notfunny" messages, giving it feedback on each one. Within a few dozen it was getting pretty good at this. Which, coincidentally, is what she said.

Semplicemente geniale. Per un utilizzo più generico, senza necessità di training, affidatevi invece al filtro bayesiano [TWSS](https://github.com/bvandenbos/twss):

    [@language="ruby"]
    > TWSS("you're not going fast enough")
    true
