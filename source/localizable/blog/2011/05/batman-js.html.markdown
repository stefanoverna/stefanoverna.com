---
date: 2011/05/21
title: Batman.js
external_link: http://batmanjs.org/alfred.html
---

Una interessante alternativa agli MVC lato client. Opzionalmente è in grado di occuparsi anche del lato server, in Node.js, con possibilità di condividere il codice e le validazioni dei modelli.
Mi piace molto il binding automatico di comportamenti tramite attributi HTML5 `data-`:

    [@language="html"]

    <ul id="items">
        <li data-foreach-todo="Todo.all" data-mixin="animation">
            <input type="checkbox" data-bind="todo.isDone" />
            <label data-bind="todo.body" data-class-done="todo.isDone" data-mixin="editable"></label>
            <a data-event-click="todo.destroy">delete</a>
        </li>
    </ul>

Se c'è una cosa che Backbone.js non sa fare, è farti essere rapido nelle cose banali. Qui mi sembra ci siano invece degli ottimi spunti.
