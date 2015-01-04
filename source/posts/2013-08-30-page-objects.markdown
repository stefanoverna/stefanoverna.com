---
layout: post
title: "La mia esperienza con i Page Objects"
tags:
---

Il pattern *Page object* ha come obiettivo quello di mettere a disposizione
del sistema oggetti che rappresentino mapping 1:1 con una specifica
pagina (o collezioni di pagine) presenti nella nostra UI.

È un pattern che presenta diverse similitudini con il ben più conosciuto
*Active record*; Così come con oggetti *Active record* centralizziamo
tutte le operazioni di persistenza relative ad una riga del nostro DB,
in un *page object* accentriamo tutte le possibili interazioni eseguibili
all'interno di una vista del nostro sistema, permettendoci di astrarre da
fragili dettagli di presentazione all'interno dei nostri test.

Come si può presentare un *page object*?

```ruby
class SignInPage < Struct.new(:browser)
  def visit
    browser.visit "/profile/sign_in"
  end

  def login(user, password)
    browser.fill_in :user, user
    browser.fill_in :password, password
    browser.click 'Sign in now!'
  end
end
```

Si ritorna dunque al principio *DRY*, tanto caro al mondo Rails. Se disponiamo
di oggetti di questo tipo, i nostri test saranno più semplici da modificare se
si dovesse presentare una modifica nella strutturazione dell'HTML o delle 
routes (cosa piuttosto frequente, di solito).

Con gemme come [SitePrism](https://github.com/natritmeyer/site_prism) si può accedere
ad una serie di funzionalità aggiuntive come una maggiore integrazione con
Capybara, le solite DSL comode per rendere più dichiarative e meno verbose 
le definizioni di classe, ma soprattutto la possibilità di definire "Sezioni" 
riutilizzabili in più page objects (pensiamo a menù di navigazione o footer, 
per esempio).

```ruby
feature "As a visitor, in order to use the platform" do
  let!(:admin) { create(:user, :admin) }
  let(:sign_up_page) { SignUpPage.new }

  scenario 'I want to sign in with email/password' do
    user = create(:user)
    sign_in_page.load
    sign_in_page.sign_in_as(user)
    expect(sign_in_page.flashes).to have_notice
  end
end

class SignInPage < SitePrism::Page
  section :flashes, FlashesSection, "#flashes"

  set_url '/profile/sign_in'
  set_url_matcher %r{/profile/sign_in}

  element :email,    "[name$='[email]']"
  element :password, "[name$='[password]']"
  element :button,   "[type='submit']"

  def sign_in_as(user)
    email.set user.email
    password.set "changeme"
    button.click
  end
end

class FlashesSection < SitePrism::Section
  element :notice, ".flash.notice"
  element :alert, ".flash.alert"
end
```

Ovviamente nulla vieta di usare banalissimi moduli Ruby per ricreare ex-novo 
il concetto di sezioni illustrato qui sopra.

Prima di introdurre un nuovo layer di astrazione e complessità nel nostro codice
è sempre bene pensarci. Detto questo, quando si inizia a sentire "attrito"
durante la gestione e il mantenimento dei nostri test di integrazione, i page
objects sono ottimi per:

* Rendere più leggibili i test;
* Promuovere il riuso di codice;
* Centralizzare il *coupling* con l'UI;

#### Riferimenti esterni

* [Page Object Pattern](http://blog.josephwilk.net/cucumber/page-object-pattern.html)
* [Awesome Page Objects In Testing](http://itreallymatters.net/post/12242886944/awesome-page-objects-in-testing#.UiAgsGSPg0M)
* [SitePrism: Capybara Page Objects](http://www.natontesting.com/2012/05/02/siteprism-capybara-page-objects/)

