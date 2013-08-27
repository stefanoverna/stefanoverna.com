---
layout: post
title: Ma tu testi le migrations "down"?
date: 2013-08-27 09:06
tags:
---

Ieri sbirciando i dotfiles di Thoughtbot mi sono imbattuto in un [alias Zsh](https://github.com/thoughtbot/dotfiles/blob/master/aliases#L31)
interessante:

{% highlight bash %}
alias rdm="rake db:migrate && rake db:rollback && rake db:migrate && rake db:test:prepare"
{% endhighlight %}

In questo modo il pattern che si esegue durante le migrazioni è il seguente:

* Testo la migrazione *up*;
* Testo la migrazione *down*;
* Ri-applico la migrazione e aggiorno il db di testing;

Spesso e volentieri ci si dimentica delle migrazioni *down*, altre volte per
pigrizia si fa finta di niente... in questo si forza una good-practice al costo
di qualche secondo in più per eseguire la migrazione (`rake` viene eseguito due
volte).

