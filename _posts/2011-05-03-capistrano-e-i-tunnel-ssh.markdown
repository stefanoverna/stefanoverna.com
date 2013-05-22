---
layout: post
date: 2011/05/03
title: Capistrano e i tunnel SSH
---

Piccola scoperta involontaria di ieri: se avete un'accesso SSH al server di produzione ristretto su un solo IP pubblico, l'iter che fino a ieri seguivo per i deploy Capistrano era quello di creare un tunnel SSH tra me ed il server "gateway" via terminale tramite il comando:

{% highlight bash %}
ssh -f -N -L 12345:server-di-produzione.com:22 server-gateway.com
{% endhighlight %}

A questo punto era possibile connettersi alla porta `22` di `server-di-produzione.com` tramite la porta `12345` di `localhost`. Capistrano però ha già tutto predisposto: è sufficiente aggiungere la seguente variabile al proprio script di deploy:

{% highlight ruby %}
# deploy.rb
set :gateway, "utente@server-gateway.com"
{% endhighlight %}

E in automatico creerà il tunnel al vostro posto. Urrà per il comando in meno da digitare!