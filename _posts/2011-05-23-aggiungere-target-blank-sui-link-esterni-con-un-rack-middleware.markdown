---
layout: post
date: 2011/05/23
title: Aggiungere target="blank" sui link esterni con un Rack middleware
---

Quante volte avete sentito, magari a termine dei lavori, la richiesta "tutti i link verso l'esterno dovrebbero aprirsi in un tab separato"? Questo è un tipico esempio di lavoro tremendamente noioso da fare per vie canoniche -- perchè richiederebbe un editing di tutti i link presenti in tutte le viste -- ma banale da realizzare passando per un middleware Rack.

In basso il codice. Il middleware usa [Nokogiri](http://nokogiri.org) per parsare tutte le pagine HTML (quelle con `Content-Type` impostato a `text/html`), e per ogni link trovato controlla il dominio: se non coincide con quello del server, aggiunge il fatidico attributo `target` al link.

{% highlight ruby %}
# target_blank.rb
require 'nokogiri'
module Rack
  class TargetBlank
    include Rack::Utils
    def initialize(app)
      @app = app
    end
    def call(env)
      @request = Rack::Request.new(env)
      status, @headers, @body = @app.call(env)
      @headers = HeaderHash.new(@headers)
      if is_html_content?
        body = edit_external_links(body_to_string)
        update_response_body(body)
        update_content_length
      end
      [status, @headers, @body]
    end
    private
    def edit_external_links(body)
      doc = Nokogiri::HTML(body)
      found_links = false
      doc.css('a[href]').each do |link|
        uri = URI(link['href'])
        if uri.absolute? and uri.host != @request.host
          link['target'] = 'blank'
          found_links = true
        end
      end
      found_links ? doc.to_html : body
    end
    def body_to_string
      s = ""
      @body.each { |x| s << x }
      s
    end
    def update_content_length
      length = 0
      @body.each { |s| length += Rack::Utils.bytesize(s) }
      @headers['Content-Length'] = length.to_s
    end
    def update_response_body(body)
      if @body.class.name == "ActionController::Response"
        @body.body = body
      else
        @body = [body]
      end
    end
    def is_html_content?
      @headers.key?('Content-Type') && @headers['Content-Type'].include?('text/html')
    end
  end
end
{% endhighlight %}