---
layout: post
title: Pattern in Rails
date: 2013-01-06 13:02 +01:00
tags:
---

Negli ultimi mesi sembrano essersi finalmente smosse le acque nel panorama delle pratiche per rendere le proprie applicazioni Rails più mantenibili e modulari. [Avevamo già parlato della questione qualche tempo fa](http://stefanoverna.com/blog/2012/06/oo-rails-e-thin-models-quando-rails-non-basta.html), dunque ci torniamo volentieri.

Tradizione vuole che le opinioni nel mondo Ruby vengano spesso [espresse piuttosto vivacemente dai sui principali esponenti](http://rubydramas.com), ed anche questa volta non ci sono state eccezioni. 

Ecco solo una piccola parte della valanga di articoli usciti:

* [Put chubby models on a diet with concerns](http://37signals.com/svn/posts/3372-put-chubby-models-on-a-diet-with-concerns)
* [Why I Don't Use ActiveSupport::Concern](http://bit.ly/TKdHj3)
* [Where the logic hides in Rails apps](http://grantammons.me/architecture/2012/12/22/where-the-logic-hides/)
* [Clean Ruby](http://bit.ly/V07hf5)
* [DCI in Ruby](http://bit.ly/UcWfCf)
* [Rails Developers Should Take DCI Seriously](http://feedly.com/k/TIbbKd)
* [Models, Roles, Decorators, and Interactions](https://gist.github.com/4341122)
* [Why DCI Contexts?](http://bit.ly/Zj36ke)
* [DCI in Ruby is completely broken](http://bit.ly/TK5viZ)
* [King of Nothing, the DCI paradigm is a scam](http://feedly.com/k/VVpqJT)
* [DCI: The Right Idea for the Wrong Paradigm](http://decomplecting.org/blog/2013/01/03/dci-the-right-idea-for-the-wrong-paradigm/)
* [Crazy, Heretical, and Awesome: The Way I Write Rails App](http://jamesgolick.com/2010/3/14/crazy-heretical-and-awesome-the-way-i-write-rails-apps.html)
* [Does My Rails App Need a Service Layer?](http://blog.carbonfive.com/2012/01/10/does-my-rails-app-need-a-service-layer/)

A prescindere dalle diatribe integraliste sul Miglior Pattern®, credo che la cosa più giusta sia quella di provare ad interiorizzare quante più metodologie di decoupling possibile, in modo sfruttarle al meglio nei modi e luoghi più indicati.

## Concern

Un *Concern* Rails non è altro che un [*mixin*](http://rubysource.com/ruby-mixins-2/) evoluto. Il *mixin* è uno dei capisaldi della programmazione in Ruby ed è utile per raggruppare all'interno di un modulo unitario tutti i metodi necessari a realizzare uno specifico comportamento. Lo scopo ovviamente è il riutilizzo del modulo stesso in più di un contesto.

Le classiche macro `act_as_*` che ci vengono messe a disposizione dalle varie gemme `ActiveRecord` utilizzano al loro interno questo pattern, ed il modulo `ActiveSupport::Concern` permette di sfruttare lo stesso meccanismo anche all'interno della nostra applicazione, per parti di codice che vogliamo utilizzare in più modelli/controller:

{% highlight ruby %}
module Taggable
  extend ActiveSupport::Concern
  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings 
  end
  def tag_names
    tags.map(&:name)
  end
end

class Post < ActiveRecord::Base
  # ...
  include Taggable
end
{% endhighlight %}

Il *Concern* è il pattern "anti Fat Model" ufficialmente riconosciuto e supportato dal Rails core team: pare che Rails 4 potrebbe includere di default due nuove directory (`app/controllers/concerns` e `app/models/concerns`) nelle quali aggiungere i propri *Concern*, ed il medesimo concetto verrà sicuramente proposto anche [a livello di routes](https://github.com/rails/routing_concerns).

## Presenter/Decorator/Exhibit

Un [oggetto *Decorator*](http://www.dofactory.com/Patterns/PatternDecorator.aspx) prevede l'estensione di comportamento di un singolo oggetto attraverso il [concetto di composition](http://andrzejonsoftware.blogspot.it/2011/01/code-reuse-in-ruby-why-composition-is.html), senza influenzare le altre istanze della medesima classe presenti nel sistema.

Il pattern *Presenter* è un caso speciale del pattern *Decorator* nel quale i metodi aggiunti all'oggetto sono utili a fini di presentazione dell'oggetto stesso (tipicamente all'interno di una vista).

Sono dunque un'alternativa più object-oriented all'utilizzo dei classici helper Rails. Per capirci, il metodo [`.to_json`](http://apidock.com/rails/ActiveRecord/Serialization/to_json) presente nei modelli `ActiveRecord` sarebbe un candidato ideale a spostarsi all'interno di un *Presenter*, in quanto responsabile della generazione di una rappresentazione JSON del modello.

In Ruby è possibile implementare una classe *Presenter* attraverso l'utilizzo  della classe standard [`SimpleDelegator`](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/delegate/rdoc/SimpleDelegator.html):

{% highlight ruby %}
class User < Struct.new(:first_name, :email)
  # ...
end

require 'delegate'

class UserDecorator < SimpleDelegator
  def class
    __getobj__.class
  end
  def avatar_url
    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png"
  end
end

user = User.new("Stefano", "stefano.verna@welaika.com")
user_decorator = UserDecorator.new(user)
puts user_decorator.class # => User
puts user_decorator.first_name # => "Stefano"
puts user_decorator.avatar_url # => "http://gravatar.com/avatar/b731002ef4fa2ee7423e4b15e177f5b3.png"
{% endhighlight %}

Il decoratore garantisce un comportamento in tutto e per tutto identico all'oggetto decorato, con l'aggiunta di uno o più metodi di tipo presentational da utilizzare all'interno delle nostre viste.

Per un utilizzo più avanzato di decoratori, date un'occhiata alla gemma [Draper](https://github.com/drapergem/draper), potrebbe fare al caso vostro.

## Domain Service Objects

Quando esistono logiche all'interno dell'applicazione che coinvolgono più di un modello, la responsabilità di esecuzione spesso non può essere affidata a nessuno dei singoli modelli, ne' tanto meno al controller — il cui ruolo dovrebbe essere semplicemente quello di instradare le richieste HTTP verso una particolare vista/template; Ecco che in questi casi può far comodo un *Service Object*, il cui compito è quello di coordinare due o più oggetti, al fine di realizzare un particolare *Use Case*.

Supponiamo di dover mandare una mail contestualmente alla creazione di un nuovo post:

{% highlight ruby %}
class PostsController < ApplicationController
  respond_to :html
  
  def create
    @post = PostCreationService.run(current_user, params)
    respond_with @post
  end
end

class PostCreationService
  def self.run(user, post_params)
    post = Post.new(post_params.merge(user: user))
    PostMailer.post_created(post).deliver if post.save
    post
  end
end
{% endhighlight %}

Certo, si potrebbe risolvere la medesima questione attraverso un hook `after_create` nel modello `Post`, ma non è compito del modello inviare una mail: se creassimo un nuovo `Post` all'interno della console o in un test, probabilmente non gradiremmo ricevere una mail di conferma :)

Con l'utilizzo di *Service Objects* i controller possono essere ultra-concisi ed è possibile testare tutte le possibili condizioni di comportamento dell'applicazione **fuori** da un controller, migliorando il design complessivo, il decoupling degli oggetti e i tempi di esecuzione dei test.

Il *Domain Service Objects* non è l'unica tipologia di service disponibile: esistono anche *Application Services* ed *Infrastructure Services*. [Questo articolo di Jared Carrol](http://blog.carbonfive.com/2012/01/10/does-my-rails-app-need-a-service-layer/) esplora con maggior dettaglio la tematica.

## DCI

Il [*DCI*](http://en.wikipedia.org/wiki/Data,_context_and_interaction) è il pattern più "complesso" che tratteremo (se così si può dire) ed è anche il più recente in ordine temporale ad essere stato suggerito dalla comunità all'interno di applicazioni Rails. Gim Gay, con il suo libro in-progress [Clean Ruby](http://clean-ruby.com), è il principale esponente di questa tecnica.

Grossolamente possiamo considerare il *DCI* come una unione più strutturata dei pattern *Concern* e *Service Object*, finalizzata alla descrizione di uno o più *Use Cases* espressi in termini di dominio del problema.

Il *DCI* è composto da 3 differenti "parti" interagenti:

* **Data**: possiamo tranquillamente figurarceli come modelli Active Record "stupidi", senza logica aggiuntiva, concentrati unicamente sull'aspetto "persistenza dei dati";
* **Interaction/Roles**: sono molto simili a *Concern*, dunque blocchi di logica applicabili a più di un modello differente. C'è un'unica differenza: vengono applicati a run-time ad un modello solo nel momento in cui questo deve assumere un determinato ruolo, e come un *Presenter*, non intaccano altre istanze del medesimo modello presenti nel sistema;
* **Context**: è simile per molti versi ad un *Service Object*: dopo aver applicato un *Role* ad uno più più modelli, si occupa di definire le interazioni tra di loro atte ad implementare un caso d'uso.

Vediamo un classico esempio *DCI*:

{% highlight ruby %}
class Account < Struct.new(:owner, :amount)
end

class MoneyTransferContext < Struct.new(:source, :destination)
  def transfer(amount)
    # applico i ruoli ai modelli "stupidi"
    source.extend SourceRole
    destination.extend DestinationRole
    # definisco le interazioni tra i ruoli
    source.draw_money(amount)
    destination.deposit(amount)
  end

  module SourceRole
     def draw_money(amount)
       self.amount -= amount
     end
  end

  module DestinationRole
    def deposit(amount)
      self.amount += amount
    end
  end
end

my_account = Account.new("Stefano", 100.0)
other_account = Account.new("Matteo", 50.0)
MoneyTransferContext.new(my_account, other_account).transfer(10.0)
puts my_account.amount    # => 90.0
puts other_account.amount # => 60.0
{% endhighlight %}

Quali vantaggi otteniamo rispetto ai precedenti pattern?

* **I *Concern* "sporcano" i modelli** aggiungendo logica a ciascuna delle sue istanze, con potenziali conflitti tra differenti Concern. Dal punto di vista tecnico, i modelli continuano a rimanere "fat models". I ruoli *DCI* vengono invece applicati a run-time sui modelli, solo quando necessario.
* **Il *Concern* non spiega il "perchè":** è difficile capire quando e come un certo *Concern* viene utilizzato all'interno dell'applicazione: i suoi metodi possono venire richiamati in ogni parte del codebase. Nel *DCI*, l'utilizzo di un determinato *Role* è circoscritto all'interno del suo *Context*, rendendo banale la comprensione del suo utilizzo.

## Per concludere…

A prescindere da inutili guerre di religione, ritengo estremamente positiva la proposta a livello di framework di una soluzione ufficiale al problema dei "Fat Models". 

Rails è dichiaratamente ottimizzato per la fase di prototipazione iniziale di un'app e preferisce da sempre soluzioni semplici ai problemi (vedi la guerra tra *Test Unit* ed *RSpec*). Era dunque praticamente scontata la scelta del pattern più "lightweight" a disposizione, quello dei *Concern*. E probabilmente, è anche giusto così.

*Concern* e *Presenters* sono i primi, semplicissimi strumenti da utilizzare come primo livello di modularizzazione della logica.

Ho utilizzato spesso con successo e soddisfazione la tecnica dei *Service Objects* per "spostare" logiche complesse al di fuori di controller e modelli: anch'essi sono molto semplici da introdurre nei progetti Rails, e facilitano la "testabilità" del proprio dominio del problema.

Sto iniziando a sperimentare a piccoli passi il *DCI* in un paio di progetti, e l'impressione è quella di un pattern bene adattabile al mondo Rails, facilmente inseribile in un progetto anche di medie dimensioni.

Buon divertimento!

