---
layout: post
title: "OO Rails e Thin models: quando Rails non basta"
---

Un paio di settimane fa ho acquistato una copia di [Objects on Rails](http://objectsonrails.com/):
la lettura è stata molto interessante, e ha chiarito alcuni dei dubbi "architetturali"
sorti negli ultimi progetti Rails più complessi che ho incrociato.

Rails, nella sua forma base, è ottimo per bootstrappare un progetto, ma al crescere
della sua complessità alcune "scelte" di default iniziano a risultare
strette: la mancata separazione tra fra domain layer ed ActiveRecord, la
commistione tra logica e template e la proceduralità degli helpers prima
di tutte.

Questo ovviamente non vuol dire che Rails fa schifo. E' perfettamente
normale partire "agili", ed aggiungere livelli "logici" object-oriented aggiuntivi
sopra le normali convenzioni Rails.

Qui in fondo una buona lista di referenze per approfondire questo
discorso:

* [Ruby DataMapper status](http://solnic.eu/2012/01/10/ruby-datamapper-status.html)
* [Making ActiveRecord models thin](http://solnic.eu/2011/08/01/making-activerecord-models-thin.html)
* [DDD for Rails developers: layered architecture](http://rubysource.com/ddd-for-rails-developers-part-1-layered-architecture/)
* [The secret to Rails OO design](http://blog.steveklabnik.com/posts/2011-09-06-the-secret-to-rails-oo-design)
* [ActiveRecord (and Rails) considered harmful](http://blog.steveklabnik.com/posts/2011-12-30-active-record-considered-harmful)
* [Let Them Code Cake!](http://www.engineyard.com/blog/2010/let-them-code-cake/)
* [Rails is still cool](http://andrzejonsoftware.blogspot.it/2011/12/rails-is-still-cool.html)
* [Rails is not your application](http://blog.firsthand.ca/2011/10/rails-is-not-your-application.html)
* [Blow up your views](http://jumpstartlab.com/news/archives/2011/12/01/blow-up-your-views/)
* [Hexagonal Rails](http://confreaks.com/videos/977-goruco2012-hexagonal-rails)
