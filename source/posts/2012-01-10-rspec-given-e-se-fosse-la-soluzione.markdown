---
layout: post
title: 'rspec-given: e se fosse la soluzione?'
external_link: https://github.com/jimweirich/rspec-given
---

Tornando a bomba [sui miei interrogativi passati](/blog/2011/12/alternative-a-cucumber.html),
potrei aver trovato una soluzione in grado di permettere una maggiore
descrittività ai test -- in stile Gherkin -- ma al tempo stesso "sicura" (ovvero che
non utilizzi librerie TDD ancora in stato alpha).

La soluzione si chiama [rspec-given](https://github.com/jimweirich/rspec-given) è non è altro
che una leggera DSL sopra ad RSpec, che permette di utilizzare dei
blocchi `Given`, `When` e `Then`.

Esempio d'ordinanza:

```ruby
describe Stack do
  def stack_with(initial_contents)
    stack = Stack.new
    initial_contents.each { |item| stack.push(item) }
    stack
  end
  Given(:stack) { stack_with(initial_contents) }
  context "when empty" do
    Given(:initial_contents) { [] }
    Then { stack.depth.should == 0 }
    context "when pushing" do
      When { stack.push(:an_item) }
      Then { stack.depth.should == 1 }
      Then { stack.top.should == :an_item }
    end
  end
end
```

Direi che la cosa migliore è provarlo per trovarne eventuali lati
negativi o brutture. Vi faccio sapere.
