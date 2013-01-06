---
title: "Ruby: variabili di classe ereditarie e class_inheritable_accessor"
date: 2011/4/16
---

Oggi sono capitato di fronte ad un pattern interessante, immagino molto frequente nel caso di scrittura di plugin per Rails.

Immaginiamo, a scopo esemplificativo, di voler scrivere un semplice plugin Rails in grado di permettere questo tipo di chiamata all'interno dei tuoi modelli:

    [@language="ruby"]
    [@caption="app/models/document.rb"]

    class Document < ActiveRecord::Base
      special_attribute :title
      special_attribute :description
    end

La chiamata a `special_attribute` supponiamo faccia miracoli ai due attributi `:title` e `:description` del modello, ma andiamo oltre. Supponiamo che plugin debba anche essere in grado di restituire tutti gli attributi "speciali" tramite un metodo `special_attributes`:

    [@language="ruby"]

    Document.special_attributes
    # => [ :title, :description ]

Come lo implementereste? Io farei qualcosa del genere:

    [@language="ruby"]
    [@caption="config/initializers/special_attributes.rb"]

    module SpecialAttributesPlugin

      def special_attribute(attribute)
        @@special_attributes ||= []
        @@special_attributes << attribute
      end

      def special_attributes
        @@special_attributes ||= []
      end

    end

    # aggiungo il modulo ad ActiveRecord::Base
    module ActiveRecord
      class Base
        extend SpecialAttributesPlugin::ActiveRecordAdapter
      end
    end

In questo modo il risultato effettivamente è quello sperato! Cosa abbiamo fatto? Si è usata una variabile di classe chiamata `@@special_attributes` per memorizzare i vari campi.

Attenzione però, se complichiamo un po' il caso d'uso, ci troviamo di fronte ad comportamento inaspettato. Supponiamo che ci siano delle sottoclassi di `Document`, per esempio `SpreadsheetDocument` e `TextDocument`. Saremmo in questo caso davanti ad una STI (Single Table Inheritance) --- caso tutt'altro che raro nella realtà. Vediamo se tutto funziona ancora come ci aspettiamo:


    [@language="ruby"]
    [@caption="app/models/spreadsheet_document.rb"]
    class SpreadsheetDocument < Document
      special_attribute :author
    end

    SpreadsheetDocument.special_attributes
    # => [ :title, :description, :author ]

Fin qui tutto bene! Aggiungiamo `TextDocument` ora:

    [@language="ruby"]
    [@caption="app/models/spreadsheet_document.rb"]
    class TextDocument < Document
      special_attribute :page_count
    end

    SpreadsheetDocument.special_attributes
    # => [ :title, :description, :author, :page_count ]

Ahia, ecco il problema: `:page_count` è ovviamente l'inaspettato intruso, non è un attributo di `SpreadsheetDocument`. La spiegazione è semplice: una variabile di classe come `@@special_attributes` viene condivisa tra la classe padre e *tutte* le classi figlie. Non fa quindi al caso nostro. Proviamo con un'altra feature di Ruby: le *variabili di istanza di classe*.

Ruby è un linguaggio totalmente OOP, dunque tutto è un'oggetto, le classi non fanno eccezione. Possiamo fare in modo di aggiungere una variabile di istanza all'oggetto classe!

    [@language="ruby"]
    [@caption="config/initializers/special_attributes.rb"]

    module SpecialAttributesPlugin

      def special_attribute(attribute)
        @special_attributes ||= []
        @special_attributes << attribute
      end

      def special_attributes
        @special_attributes ||= []
      end

    end

    # aggiungo il modulo ad ActiveRecord::Base
    module ActiveRecord
      class Base
        extend SpecialAttributesPlugin::ActiveRecordAdapter
      end
    end

Come si può notare, abbiamo fatto diventare `@special_attributes` una variabile dell'istanza. Ora riproviamo a testarne il funzionamento.

    [@language="ruby"]

    Document.special_attributes
    # => [ :title, :description ] --> corretto!

    SpreadsheetDocument.special_attributes
    # => [ :author ] --> errato...

    TextDocument.special_attributes
    # => [ :page_count ] --> errato...

Ora effettivamente ognuna delle classi ha la sua variabile, differente da quella delle altre classi, ma le classi figlie non partono col valore della variabile della classe padre, `Document`! Sfortunatamente Ruby non possiede nulla semplice per ovviare a questo problema.. ma in qualche modo è comunque possibile arrivare al comportamento desiderato, in poche righe di codice:

    [@language="ruby"]
    [@caption="config/initializers/special_attributes.rb"]

    module SpecialAttributesPlugin

      def special_attribute(attribute)
        @special_attributes ||= []
        @special_attributes << attribute
      end

      def special_attributes
        @special_attributes ||= []
      end

      def inherited(subclass)
        subclass.instance_variable_set "@special_attributes", special_attributes.dup
      end

    end

    # aggiungo il modulo ad ActiveRecord::Base
    module ActiveRecord
      class Base
        extend SpecialAttributesPlugin::ActiveRecordAdapter
      end
    end

Il giochetto è sfruttare la callback `inherited(subclass)`, che viene chiamata quando viene generata una classe figlia. Agganciandoci a quest'evento, siamo in grado di inizializzare la variabile di istanza della classe figlia con quella della classe padre. Attezione però a non passare la medesima variabile al figlio, ma una copia, altrimenti padre e figli condivideranno il medesimo oggetto, con risultati non attesi.

Spero siate riusciti a seguirmi. Ora, per sentirci tutti meglio, arriviamo allo shortcut.. `ActiveSupport` estende di default l'oggetto `Class` per supportare il metodo `class_inheritable_accessor`. Possiamo riscrivere il plugin in questo modo, ottenendo il medesimo risultato:

    [@language="ruby"]
    [@caption="config/initializers/special_attributes.rb"]

    module SpecialAttributesPlugin

      def special_attribute(attribute)
        class_inheritable_accessor :special_attributes
        self.special_attributes ||= []
        self.special_attributes << attribute
      end

    end

    # aggiungo il modulo ad ActiveRecord::Base
    module ActiveRecord
      class Base
        extend SpecialAttributesPlugin::ActiveRecordAdapter
      end
    end

Meglio, no?
