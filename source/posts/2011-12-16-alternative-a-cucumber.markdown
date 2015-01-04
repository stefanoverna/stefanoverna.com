---
layout: post
title: "Spinach e Turnip: alternative a Cucumber"
---

Negli ultimi tempi sembra esserci stata una presa di coscienza collettiva nel mondo Rails/BDD. Se fino a sei mesi fa eravamo in piena [Cucumber](http://cukes.info)-mania, la situazione pare essersi quantomeno ribilanciata. Bello Cucumber? No, il contrario. E' terribile, con quella miriade di steps globali ed espressioni regolari da dover domare evitando conflitti e ambiguità.

Ho avuto modo di provare Cucumber su un solo progetto di media grandezza (71 classi, ~5000 LOC), scontrandomi in prima persona con questi problemi. La gestione ed il mantenimento della suite di test è stata snervante al punto da portarmi ad utilizzare sui progetti successivi soluzioni più "leggere" come [Steak](https://github.com/cavalle/steak).

Eppure l'idea di un "contratto" sempre aggiornato, testato e comprensibile per tutti i soggetti coinvolti nel progetto è incredibilmente allettante. Così come l'idea di poter descrivere le varie feature in maniera astratta, focalizzandosi unicamente sul business value che queste portano. Il linguaggio scelto da Cucumber per questo scopo si chiama [Gherkin](https://github.com/cucumber/gherkin), ed il tempo ha confermato tutta la sua validità.

Dunque eccoci di fronte ad una seconda ondata di gemme, che cercano di raddrizzare il tiro di Cucumber, mantenendo ciò che di buono c'è -- Gherkin appunto -- e migliorando il rimanente.

CUT

## Spinach

Ad Ottobre è uscito [Spinach](http://codegram.github.com/spinach/), frutto del lavoro della piccola realtà spagnola [Codegram](http://codegram.com/). Con Spinach:

* Alla feature Gherkin `Feature: Test how spinach works` corrisponde una classe Ruby chiamata `TestHowSpinachWorks`;
* Ad ogni step contenuto nella feature corrisponde un metodo nella classe `TestHowSpinachWorks`;
* L'implementazione degli step non prevede l'uso di espressioni regolari per matchare più step in un solo colpo: uno step, una definizione;
* E' possibile generare automaticamente lo scheletro di `TestHowSpinachWorks` tramite un generatore `spinach --generate`;

Molto leggero e totalmente privo di ambiguità. Non esistono step globali: se si vuole riutilizzare degli steps, è sufficiente estrapolare i relativi metodi di classe in un apposito modulo Ruby, da includere dove se ne vuole fare uso. Ma sembra evidente che Spinach porti ad un basso riutilizzo degli step definitions, e dunque ad una maggiore astrazione degli step, cosa buona e giusta.

## Turnip

Un mese più tardi, il buon [Jonas Nicklas](http://elabs.se/blog) -- autore di [Carrierwave](https://github.com/jnicklas/carrierwave) e [Capybara](https://github.com/jnicklas/capybara) -- ha ufficializzato la sua proposta: [Turnip](https://github.com/jnicklas/turnip). Si tratta di un approccio sicuramente meno drastico:

* Le espressioni regolari sono state eliminate, ma è possibile comunque "parametrizzare" le step definitions mediante placeholders, con maggiore comprensibilità e minori possibilità di degenero (i.e. `step "there is/are :count monster(s)" do |count|`);
* Gli step globali continuano a poter esistere, ma è possibile anche raggrupparli in "scopes" e richiamarli sono nelle features che li necessitano (attraverso direttive `@nome_scope` presenti nella feature Gherkin);

## Cosa ne pensate?

Sono sinceramente interessato a questi due nuovi tentativi. Sicuramente la direzione è quella giusta, ma mi domando se anche questi strumenti non nascondano delle problematiche. Siamo sicuri che Spinach non sia troppo rigido, non permettendo di parametrizzare del tutto gli step? D'altra parte, lo stesso Jonas in un suo [celebre post passato](http://elabs.se/blog/15-you-re-cuking-it-wrong), recitava come un mantra:

> A step description should never contain regexen, CSS or XPath selectors, any kind of code or data structure. It should be easily understood just by reading the description.

Ma allora perchè lui stesso ha permesso di parametrizzare gli step descriptions, dando il via a possibili nuovi [Pickle](https://github.com/ianwhite/pickle)? Forse per permettere ai duri e puri di scrivere alà-Spinach, mantenendo però un ponte col passato?

Avete già avuto modo di provarli sul campo? Che idea vi siete fatti?
