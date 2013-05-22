---
layout: post
date: 2011/04/21
title: "Sinatra: un repository viewer web-based in.. 50 righe"
---

Sinatra, per piccole webapp, è un progetto semplicemente incredibile. Riesce a condensare dentro ad un DSL composto da pochissimi comandi gran parte delle features presenti in web framework ben più complessi e pesanti.

In [weLaika](http://www.welaika.com) stiamo lavorando ad una Intranet scritta in Ruby per una celebre università inglese: tra le specifiche compare anche una sezione nella quale sia possibile per i dipendenti poter navigare tra i vari commit di un repository SVN e, per ogni commit, poter visualizzare l'alberatura delle directory, ovviamente con la possibilità di poter scaricare i file presenti nelle varie loro versioni. Un repo viewer web-based, insomma. Il primo pensiero è stato: non dovremmo metterci ad integrare Ruby con WebSVN, vero?

Dopo una veloce ricerca, ho avuto la conferma di quanto SVN non sia esattamente il revision-system preferito dal popolo rubista. Poche gemme, poco utilizzate e documentate. Alchè mi sono ricordato di una interessante feature di Git (mai utilizzata dal sottoscritto fino ad ora): la possibilità di gestire localmente un repository SVN, via Git. E' infatti sufficiente effettuare un `git clone` leggermente diverso:

```
git svn clone http://ie7-js.googlecode.com/svn ie7-js
```

Per poter avere in locale un repo Git, in grado di committare (`git dcommit`) e updatare dal repository SVN originario (`git rebase`), in maniera del tutto trasparente. Non male! Ma a questo punto le possibilità di implementazione per il nostro repo-viewer si allargano incredibilmente. Siamo infatti in grado di poter usare una delle tante gemme in grado di interfacciarsi con repository Git: `Grit`, per esempio, [usata attualmente su Github](https://github.com/schacon/grit).

Ecco allora la sfida: siamo in grado di scrivere un clone di WebSVN in Sinatra, in meno di 50 righe di codice (viste comprese)? Ovvio che sì! Qui in basso avete un applicazione funzionante, in grado di soddisfare tutti i requisiti sopra elencati.

{% highlight ruby %}
# app.rb
%w(sinatra grit).each { |gem| require gem }
mime_type :binary, 'binary/octet-stream'
set :repo, Grit::Repo.new('/Users/steffoz/dev/richcomments')
before %r{^/(\w+)} do
  commit_id = params[:captures].first[0..10]
  @commit = settings.repo.commits(commit_id).first
  halt "No commit exists with id #{commit_id}" if @commit.nil?
end
get "/" do
  @commits = settings.repo.commits
  haml :index
end
get "/:commit_id" do |commit_id|
  @tree = @commit.tree
  @path = ""
  haml :dir
end
get "/:commit_id/*" do |commit_id, path|
  @object = @commit.tree / path
  halt "No object exists with path #{path}" if @object.nil?
  if @object.is_a? Grit::Blob
    content_type :binary
    @object.data
  else
    @tree = @object
    @path = path + "/"
    haml :dir
  end
end
__END__
@@ index
%ul
  - @commits.each do |commit|
    %li
      %a{ :href => "/#{commit.id[0..10]}" }= "#{commit.id[0..10]} (by #{commit.author}, #{commit.committed_date})"
@@ dir
%h1= "Commit #{@commit.id[0..10]} - Path: #{@path}"
%ul
  - @tree.contents.each do |obj|
    %li
      %a{ :href => "/#{@commit.id}/#{@path}#{obj.name}" }= obj.name
{% endhighlight %}

Se poi consideriamo [Almost Sinatra](https://github.com/rkh/almost-sinatra), che riesce a riscrivere le 5700 righe di Sinatra in 8 righe (!!!).. capite che la cosa inizia a diventare piuttosto esilarante. Se aveste problemi a comprendere lo script, son qui.