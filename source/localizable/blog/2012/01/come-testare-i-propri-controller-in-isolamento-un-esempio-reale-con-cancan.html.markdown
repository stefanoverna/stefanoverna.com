---
title: "Come testare i propri controller in isolamento: un esempio reale con CanCan"
date: 2012/01/29
---

<div class="note">
<strong>TL;DR</strong> Questo è un post per sviluppatori Rails di media esperienza.
L'obiettivo di questo (lungo) tutorial è quello di guidare il lettore
passo passo verso le possibili tecniche per testare i propri controller,
evidenziandone problematiche e vantaggi. Arriveremo al termine del
tutorial ad un soluzione rapida e mantenibile, che testi in completo
isolamento il controller e che farà uso di strumenti come <em>stubs</em> e <em>mocks</em>.
</div>

Nella stragrande maggioranza dei progetti ci si ritrova a dover
gestire autorizzazioni e ruoli per gli utenti. La gemma più popolare per
questo compito è senza dubbio [CanCan](https://github.com/ryanb/cancan). Mi sembra
questo un ottimo esempio concreto da sfruttare per la trattazione.

Nella [Wiki del progetto su Github](https://github.com/ryanb/cancan/wiki/Testing-Abilities), il buon Ryan Bates elenca un paio di
possibili suggerimenti per approcciarsi al problema dei test funzionali.
Nei passati progetti ho cercato di seguirli diligentemente, ma la verità
è che sono esempi pessimi se seguiti nel mondo reale.

Partiamo con l'analizzare meglio i problemi.

CUT

## Un esempio concreto

Prendiamo come esempio una azione classica azione custom che fa uso di
CanCan:

    [@language="ruby"]
    [@caption="items_controller.rb"]
    class ItemsController < ApplicationController
      load_and_authorize_resource :project
      load_and_authorize_resource :item, :through => :project

      # /projects/:project_id/items/:id/add_tag?tag_id=XXX
      def add_tag
        @tag = Tag.find(params[:tag_id])
        authorize! :read, @tag
        @item.tags << @tag

        respond_with @item
      end
    end

Il modello `Item` appartiene ad un `Project`. L'azione `add_tag` prevede
un parametro aggiuntivo in `GET`, `:tag_id`. Cosa fa il metodo? Aggiunge
il tag alla collezione dei tag dell'item stesso. Semplice ed
indolore.

Le autorizzazioni più o meno implicite che CanCan esegue nel corso di questa
azione sono le seguenti:

    [@language="ruby"]
    can? :show, @profile
    can? :add_tag, @item
    can? :read, @tag

Definiamo dunque nella classe `Ability` le seguenti regole:

    [@language="ruby"]
    [@caption="ability.rb"]
    def initialize(user)
      if user.present?
        can :show, Project, user_id: user
        can :add_tag, Item, project_id: user.projects
        can :read, Tag, public: true
      end
    end

In pratica, stiamo dicendo a CanCan che:

* un utente può accedere solo ai suoi progetti;
* che può aggiungere tag ad un item solo se 1) ne è il proprietario e 2) se il tag stesso è pubblico.

Ora proviamo a scrivere il test secondo i suggerimenti nella Wiki.

## Testare l'azione, Integration-style

La prima soluzione suggerita da CanCan per testare il controller è la seguente:

    [@language="ruby"]
    [@caption="items_controller_spec.rb"]
    describe ItemsController do
      describe "#add_tag" do

        before do
          @user = Factory.create(:user)
          controller.stubs(:current_user).returns(@user)
        end

        context "if the user passes all the authorizations" do
          it "adds the specified tag to the item if authorizatio" do
            @project = Factory.create(:project, user: @user)
            @item = Factory.create(:item, project: @project)
            @tag = Factory.create(:tag, public: true)

            get :add_tag, project_id: @project, id: @item, tag_id: @tag

            @item.tags.should include @tag
            response.should be_success
          end
        end

      end
    end

In pratica, ci comportiamo come nel più classico degli integration
tests: prima creiamo tutti i modelli necessari per far funzionare
l'azione, dopodichè la eseguiamo, e al termine controlliamo il risultato
finale, sia in termini di modello modificato che di status code della
risposta generata.

### Fantastico! Anzi, no.

Certo, questo è un possibile metodo per testare l'azione del controller. Il vantaggio
è l'estrema semplicità di scrittura. Il grosso contro è che in realtà non stiamo testando
solo il controller, ma implicitamente anche una marea di altre cose:

* I modelli dati in pasto all'azione vengono salvati su DB: se per caso il DB
  non fosse stato migrato correttamente, il test fallirebbe, a prescindere
  dalla non colpevolezza del codice del controller;

* Se tra qualche giorno dovessimo aggiungere al modello `Project` un nuovo
  attributo `:title` con presenza obbligatoria (`validates :title, presence: true`),
  il test fallirebbe perchè non riuscirebbe più a creare un oggetto `Project`, ma, di
  nuovo, l'azione `add_tag` sarebbe totalmente innocente;

* Se in futuro dovessero cambiare i meccanismi all'interno di `Ability` secondo i
  quali l'autorizzazione viene concessa, il test fallirebbe, e di nuovo non sarebbe colpa del
  controller.

Quindi, in altre parole, **stiamo creando un test di difficile
mantenibilità futura**, in quanto troppo dipendente e legato a fattori
ed oggetti esterni.

Un test del genere poi da solo non sarebbe sufficiente: in questo modo **stiamo testando unicamente
l'esecuzione con successo dell'azione**, ma a questo punto dovremmo anche preoccuparci
di testare il comportamento del controller nel caso in cui l'utente
provi a lanciare l'azione senza avere uno dei permessi sopra citati,
per assicurarci che venga adeguatamente bloccato. **I test diventerebbero
allora quattro, per una sola azione!**

    [@language="ruby"]
    context "if the user passes all the authorizations" do
      it "adds the specified tag to the item" do
        # ...
      end
    end

    context "if the user cannot :show the Project" do
      it "raises a CanCan::AccessDenied exception" do
        # ...
      end
    end

    context "if the user cannot :add_tag to the Item" do
      it "raises a CanCan::AccessDenied exception" do
        # ...
      end
    end

    context "if the user cannot :read the Tag" do
      it "raises a CanCan::AccessDenied exception" do
        # ...
      end
    end

Consideriamo ora anche il fattore velocità. I test di integrazione
sono lenti per loro stessa natura: il loro compito è quello di riprodurre per filo e per segno
quello che è il flusso normale di utilizzo dell'applicazione, con tutte le innumerevoli
interazioni con la base dati e gli altri oggetti che compongono la logica dell'applicazione.

**I quattro test del genere impiegano circa un secondo per venire eseguiti!** Se consideriamo una applicazione
semplice con una media di 4-5 azioni per 10 controller, arriviamo tranquillamente al minuto.

Se il tempo non sembra poi così alto, ricordiamoci che stiamo parlando di controller, la componente
dell'applicazione che dovrebbe essere più snella in assoluto! Dev'esserci qualcosa di meglio per testare le *quattro dannatissime* righe di codice dell'azione!

## Isolarsi da `Ability`: un primo passo verso la speranza

La [solita Wiki](https://github.com/ryanb/cancan/wiki/Testing-Abilities) ci suggerisce che è possibile testare il comportamento
del controller indipendentemente da ciò che viene specificato dal file
`Ability`. Vediamo come:

    [@language="ruby"]
    describe "#add_tag" do

      before do
        @ability = Object.new
        @ability.extend(CanCan::Ability)
        controller.stubs(:current_ability).returns(@ability)
      end

      context "if the user passes all the authorizations" do
        it "adds the specified tag to the item" do
          @ability.can(:show, Project)
          @ability.can(:add_tag, Item)
          @ability.can(:read, Tag)

          project = Factory.create(:project)
          item = Factory.create(:item)
          tag = Factory.create(:tag)

          get :add_tag, project_id: project, id: item, tag_id: tag

          item.tags.should include tag
          response.should be_success
        end
      end

    end

Il test si basa sulla consapevolezza che CanCan fa uso del metodo `current_ability`
del controller per sapere quale dev'essere l'oggetto con modulo `CanCan::Ability`
da utilizzare per i test di autorizzazione.

Il comportamento standard del metodo `current_ability` è quello di restituire un'istanza
della classe `Ability`, ma nel blocco `before` del test **sostituiamo l'oggetto che
l'applicazione normalmente restituirebbe con un suo alter-ego**, che possiamo però
modificare a piacimento a seconda dei test. Questa è una delle tecniche
fondamentali di testing: viene chiamata [*stubbing*](http://yarorb.wordpress.com/2007/11/26/mocks-and-stubs-in-ruby-on-rails-the-mocha-solution/).

Notate come nelle righe `15-17` non abbiamo più bisogno di specificare le relazioni
tra progetto, item e tag, perchè prima dell'esecuzione del test, nelle righe `11-13`
**stiamo forzando un successo nell'autenticazione**.

In altre parole, abbiamo a tutti gli effetti isolato il test sul controller dalla classe
`Ability` dell'app. Sarà compito dei test sulla classe `Ability` controllare
che esso autorizzi solo nel caso in cui i modelli sono legati tra loro
in maniera corretta. Tutti i test sulle azioni dei controller danno
per assodato questo fatto, bypassano la classe `Activity` e dunque
eviteranno di spaccarsi nel caso di suoi cambiamenti futuri.

<div class="important">
Non è compito del test su un controller assicurarsi che con determinati modelli
venga fornita una certa autorizzazione. Il suo compito è quello di
verificare il comportamento del controller a seconda delle possibili risposte
di autorizzazione che gli vengono fornite da CanCan.
</div>

Attenzione: **continuiamo ad aver bisogno di quattro differenti test per controllare
il diverso comportamento del controller** nelle varie casistiche di permesso
autorizzato/non autorizzato — e i test continuano ad essere lenti
perchè stiamo ancora scrivendo su DB — ma quantomeno abbiamo ottenuto
qualcosa di più mantenibile!

## Avanti tutta! Isoliamoci dai modelli!

Iniziamo ad intravedere la via del successo. Proviamo ad applicare il
medesimo approccio di isolamento e *stubbing* anche ai modelli coinvolti.

    [@language="ruby"]
    describe "#add_tag" do
      before do
        @ability = Object.new
        @ability.extend(CanCan::Ability)
        controller.stubs(:current_ability).returns(@ability)
      end

      context "if the user passes all the authorizations" do
        it "adds the specified tag to the item" do
          @ability.can(:show, Project)
          @ability.can(:add_tag, Item)
          @ability.can(:read, Tag)

          project = stub_model(Project)
          item = stub_model(Item)
          tag = stub_model(Tag)

          Project.stubs(:find).with(project.to_param).returns(project)
          project.stubs(:items).returns(stub('Association', name: 'items', find: item))
          Tag.stubs(:find).with(tag.to_param).returns(tag)

          get :add_tag, project_id: project, id: item, tag_id: tag

          item.tags.should include tag
          response.should be_success
        end
      end
    end

Nelle righe `14-16` invece che salvare su DB dei modelli veri, creiamo
dei *model stub*: oggetti che hanno sembianze di modelli `ActiveRecord` correttamente
salvati su DB — hanno per esempio `id` incrementali, fingono di essere
istanze del modello specificato e rispondono a metodi `ActiveRecord` classici
quali `errors` o `to_param` — ma che sono **totalmente sintetici e non
persistenti**.

A questo punto, per portare a buon fine il test
è necessario sapere come si comporta CanCan nella fase
di caricamento delle risorse per questa azione (i comportamenti
ben documentati nella Wiki):

    [@language="ruby"]
    @project = Project.find(params[:project_id])
    @item = project.items.find(params[:id])

Nelle righe `18-20` ora siamo in grado di eseguire lo *stubbing*
delle medesime chiamate, inducendo CanCan a ritornarci invece che modelli veri
i nostri modelli farlocchi.

Di nuovo, **abbiamo a tutti gli effetti isolato il test sul controller dai veri modelli
dell'app, e da ActiveRecord in generale**: se tra qualche giorno dovessimo
aggiungere al modello `Project` un nuovo attributo obbligatorio, il test questa
volta non fallirebbe più.

<div class="important">
Il controller di per sé si aspetta che esistano dei modelli salvati su DB. Non è compito del test
su un controller inizializzare e salvare modelli. E' sufficiente assicurarsi che il controller
effettivamente effettui delle chiamate per fetcharli.
</div>

## L'ultimo passaggio: un test che ne vale quattro (WHOA!)

Anche nell'ultima versione del test, continuiamo a forzare il successo
dell'autenticazione mediante *stubbing*  del metodo `current_ability`. Questo significa che se in un
test forziamo il successo, dovremo automaticamente avere altri test per forzare anche
l'insuccesso, di modo da poter verificare che l'azione effettivamente
faccia uso delle `Ability`, e che dunque blocchi l'utente.

La soluzione per ridurre i test ad uno, e uno solo, è questa:

    [@language="ruby"]
    describe "#add_tag" do
      context "if the user passes all the authorizations" do
        it "adds the specified tag to the item" do
          project = stub_model(Project)
          item = stub_model(Item)
          tag = stub_model(Tag)

          should_authorize(:show, project)
          should_authorize(:add_tag, item)
          should_authorize(:read, tag)

          Project.stubs(:find).with(project.to_param).returns(project)
          project.stubs(:items).returns(stub('Association', name: 'items', find: item))

          Tag.stubs(:find).with(tag.to_param).returns(tag)

          get :add_tag, project_id: project, id: item, tag_id: tag

          item.tags.should include tag
          response.should be_success
        end
      end
    end

E' cambiato poco, in superficie: il blocco `before` che *stubbava* il metodo
`current_ability` del controller se ne è andato, e le tre chiamate
ad `@ability.can` sono state sostituite da un fantomatico metodo,
che ho chiamato `should_authorize`, con una semantica molto simile.

Cosa sta succedendo? Succede che andiamo ancora più alla fonte. CanCan, dopo aver
caricato i modelli, fa subito uso del metodo `authorize!` del controller per
testare l'autorizzazione da parte dell'utente. E' `authorize!` che fa uso del metodo
`current_ability` finora simulato.

Andiamo a vedere il codice dell'helper RSpec `should_authorize`:

    [@language="ruby"]
    def should_authorize(action, subject)
      controller.expects(:authorize!).with(action, subject).returns('passed!')
    end

Invece che *stubbare* `current_ability`, ora stiamo *stubbando* direttamente
`authorize!`, facendolo passare sempre e comunque, ma non solo: utilizziamo il metodo
`expects` invece che `stubs`. La differenza è piccola ma fondamentale.
Il metodo `expects` **non solo modifica la risposta, ma fa fallire il
test se quel dato metodo, con quei dati parametri, non verrà effettivamente
chiamato durante il corso dell'azione del controller.** Questa variante di
*stubbing* viene comunemente chiamata *mocking*, e ci permette di essere
tranquilli sull'effettiva protezione implementata dal controller.

<div class="important">
Non è compito del test su un controller assicurarsi che CanCan faccia
uso della classe <code>Ability</code> per far passare o meno l'autorizzazione ad una
azione. Ne tantomeno che il metodo <code>authorize!</code> lasci passare l'utente o
lanci un'eccezione. Questo tipo di testing è già stato fatto a livello
di gemma. Il controller deve semplicemente assicurarsi che il metodo
<code>authorize!</code> messogli a disposizione dalla gemma stessa venga
effettivamente chiamato.
</div>



## Abbiamo finito? SRSLY?!

A questo punto possiamo — *se solo Dio volesse* — dirci soddisfatti.
Abbiamo un solo test per il controller. Un test che totalmente isolato
dal resto dell'app, che non si spaccherà se non per motivi reali e
dipendenti dall'azione stessa, e che — non facendo uso del livello
database — verrà eseguito in pochi millisecondi.

Scusate per il disagio del post. Spero che possa essere utile a
qualcuno!




