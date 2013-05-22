---
layout: post
title: Prime Impressioni su Sphinx
date: 2011/4/9
---

Per la prima volta ho avuto modo di testare funzionamento di [Sphinx](http://sphinxsearch.com/), uno dei più popolari motori di ricerca full-text in circolazione. L'ho preferito a [Lucene](http://lucene.apache.org/) per evitare il disagio di Java, e a  [Ferret](http://ferret.davebalmain.com/) per la maggiore affidabilità che mi sembrava dare dal punto di vista del supporto e della stabilità.

### Installazione

L'installazione è stata incredibilmente semplice e rapida con `homebrew`:

```
brew install sphinx
```

In realtà mi sono reso presto conto che la ricetta homebrew non
prevedeva il supporto per `libstemmer` (vedremo dopo a cosa serve),
quindi ho modificato leggermente la ricetta in questo modo (`sudo brew
edit sphinx`):

{% highlight ruby %}
require 'formula'
class Sphinx < Formula
  url 'http://sphinxsearch.com/downloads/sphinx-0.9.9.tar.gz'
  homepage 'http://www.sphinxsearch.com'
  md5 '7b9b618cb9b378f949bb1b91ddcc4f54'
  head 'http://sphinxsearch.googlecode.com/svn/trunk/'
  fails_with_llvm "fails with: ld: rel32 out of range in _GetPrivateProfileString from /usr/lib/libodbc.a(SQLGetPrivateProfileString.o)"
  def install
    system "curl -O http://snowball.tartarus.org/dist/libstemmer_c.tgz"
    system "tar zxvf libstemmer_c.tgz"
    args = ["--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking", "--with-libstemmer"]
    # configure script won't auto-select PostgreSQL
    args << "--with-pgsql" if `/usr/bin/which pg_config`.size > 0
    args << "--without-mysql" if `/usr/bin/which mysql`.size <= 0
    system "./configure", *args
    system "make install"
  end
  def caveats
    <<-EOS.undent
    Sphinx depends on either MySQL or PostreSQL as a datasource.
    You can install these with Homebrew with:
      brew install mysql
        For MySQL server.
      brew install mysql-connector-c
        For MySQL client libraries only.
      brew install postgresql
        For PostgreSQL server.
    We don't install these for you when you install this formula, as
    we don't know which datasource you intend to use.
    EOS
  end
end
{% endhighlight %}


### Configurazione

A questo punto, il peggio è passato. [Thinking
Sphinx](http://freelancing-god.github.com/) è una gemma ottimamente
documentata e seguita dal suo sviluppatore, e ti permette di impostare
degli indici di ricerca per i tuoi modelli Rails direttamente al loro
interno, grazie ad un semplice DSL di questo tipo:

{% highlight ruby %}
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  define_index do
    indexes first_name
    indexes last_name, :sortable => true
    indexes email
    indexes company
    indexes company_role
    indexes city
    indexes website
    indexes notes
    set_property :enable_star => true
    set_property :min_infix_len => 1
  end
end
{% endhighlight %}

### Avviare Sphinx

Una volta impostati gli indici (per maggiori info su come funziona
Sphinx rifatevi a [questa
pagina](http://freelancing-god.github.com/ts/en/sphinx_basics.html), per
esempio), basta semplicemente far partire un rake task per convertire il
DSL in file di configurazione Sphinx: `thinking_sphinx:configure`.
Potete poi far partire il server Sphinx con `thinking_sphinx:start`.
Giuro che è stato *veramente* così semplice.

Thinking Sphinx dispone di una serie di rake task aggiuntivi per coprire
tutti i vostri bisogni:

```
rake thinking_sphinx:configure      # Generate the Sphinx configuration file using Thinking Sphinx's settings
rake thinking_sphinx:index          # Index data for Sphinx using Thinking Sphinx's settings
rake thinking_sphinx:rebuild        # Stop Sphinx (if it's running), rebuild the indexes, and start Sphinx
rake thinking_sphinx:reindex        # Reindex Sphinx without regenerating the configuration file
rake thinking_sphinx:restart        # Restart Sphinx
rake thinking_sphinx:running_start  # Stop if running, then start a Sphinx searchd daemon using Thinking Sphinx's settings
rake thinking_sphinx:start          # Start a Sphinx searchd daemon using Thinking Sphinx's settings
rake thinking_sphinx:stop           # Stop Sphinx using  Thinking Sphinx's settings
rake thinking_sphinx:version        # Output the current Thinking Sphinx version
```

Per ricercare facendo uso di Sphinx, rifatevi all'ottima guida, ma fondamentalmente si parla di fare cose come:

{% highlight ruby %}
User.search(params[:search], :star => true, :order => :last_name).page(params[:page]).per(10)
{% endhighlight %}

E come forse vi state chiedendo sì, è già compatibile con
will_paginate e Kaminari (dalla versione `~> 2.0.3`).

### Word stemming

Se avete installato Sphinx con il flag `--with-libstemmer` da me suggerito qualche riga più in alto, allora avrete anche la possibilità di configurare il [word stemming](http://freelancing-god.github.com/ts/en/advanced_config.html) italiano. Questo significa che Sphinx sarà in grado di gestire correttamente le forme singolari/plurali delle ricerche, fornendo risultati più rilevanti.


### Conclusioni

Quello che abbiamo visto è la base. Sphinx è incredibilmente potente e permette, ad esempio:

* La ricerca anche sulle relazioni delle entità;
* Ordinare i risultati per peso raggruppandoli in slot temporali (utile per ricerche real-time);
* Ricercare mediante più sintassi (da quella per operatori logici, a quella con wildcards);
* Effettuare ricerche geospaziali;

L'unico svantaggio di Sphinx rispetto ad altri motori di ricerca full-text è che gli indici devono essere totalmente rigenerati quando anche solo un'elemento della tabella cambia. In realtà anche questo aspetto è stato pressochè risolto mediante [delta indexes](http://freelancing-god.github.com/ts/en/deltas.html), praticamente trasparenti all'utente.

Insomma. Sphinx mi ha convinto.