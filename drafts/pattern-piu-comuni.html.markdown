---
title: Pattern più comuni
date: 2012-12-30 19:28 +01:00
tags:
---

## Value Objects

Examples of value objects are things like numbers, dates, monies and strings. Usually, they are small objects which are used quite widely. Their identity is based on their state rather than on their object identity. This way, you can have multiple copies of the same conceptual value object.

Value Objects are simple objects whose equality is dependent on their value rather than an identity. They are usually immutable. Date, URI, and Pathname are examples from Ruby’s standard library, but your application can (and almost certainly should) define domain-specific Value Objects as well. Extracting them from ActiveRecords is low hanging refactoring fruit.

In Rails, Value Objects are great when you have an attribute or small group of attributes that have logic associated with them. Anything more than basic text fields and counters are candidates for Value Object extraction.


## Service Objects/Policy Objects

Some actions in a system warrant a Service Object to encapsulate their operation. I reach for Service Objects when an action meets one or more of these criteria:

* The action is complex (e.g. closing the books at the end of an accounting period)
* The action reaches across multiple models (e.g. an e-commerce purchase using Order, CreditCard and Customer objects)
* The action interacts with an external service (e.g. posting to social networks)
* The action is not a core concern of the underlying model (e.g. sweeping up outdated data after a certain time period).
* There are multiple ways of performing the action (e.g. authenticating with an access token or password). This is the Gang of Four Strategy pattern.

Policy Objects are similar to Service Objects, but I use the term “Service Object” for write operations and “Policy Object” for reads. They are also similar to Query Objects, but Query Objects focus on executing SQL to return a result set, whereas Policy Objects operate on domain models already loaded into memory.

A service object is typically used to coordinate two or more objects; usually, the service object doesn't have any logic of its own (simplified definition). We're also going to use Dependency Injection so that we can mock everything out and make our tests awesomely fast (seconds not minutes). The implementation is simple:


## Form Objects

When multiple ActiveRecord models might be updated by a single form submission, a Form Object can encapsulate the aggregation. This is far cleaner than using accepts_nested_attributes_for, which, in my humble opinion, should be deprecated. A common example would be a signup form that results in the creation of both a Company and a User:

## Query Objects

Alternativa a scopes/metodi di classe


## Decorators


Decorators let you layer on functionality to existing operations, and therefore serve a similar purpose to callbacks. For cases where callback logic only needs to run in some circumstances or including it in the model would give the model too many responsibilities, a Decorator is useful.

Posting a comment on a blog post might trigger a post to someone’s Facebook wall, but that doesn’t mean the logic should be hard wired into the Comment class. One sign you’ve added too many responsibilities in callbacks is slow and brittle tests or an urge to stub out side effects in wholly unrelated test cases.

Decorators differ from Service Objects because they layer on responsibilities to existing interfaces. Once decorated, collaborators just treat the FacebookCommentNotifier instance as if it were a Comment.


## View Objects/Presenters

If logic is needed purely for display purposes, it does not belong in the model. Ask yourself, “If I was implementing an alternative interface to this application, like a voice-activated UI, would I need this?”. If not, consider putting it in a helper or (often better) a View object.

Presenters are a specific kind of decorator, used to add presentational logic.

