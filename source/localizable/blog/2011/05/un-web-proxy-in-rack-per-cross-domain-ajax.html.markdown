---
date: 2011/05/07
title: Un web proxy in Rack per cross-domain Ajax
---

In weLaika stiamo lavorando allo sviluppo di un social-network con un'architettura logica a due livelli: da una parte uno storage ultra-performante su Google App Engine, dall'altra una serie di differenti frontend per l'utente finale. Il primo frontend è quello web -- al quale weLaika sta lavorando. Il secondo, e per ora ultimo, sarà realizzato con tecnologia Flash.

Tutti i frontend sono in grado di comunicare col backend tramite API. I metodi API sono stati suddivisi in  "pubblici" e "privati". Quelli pubblici sono in grado di rispondere con formato JSONP e possono dunque essere utilizzati da applicazioni di terze parti, le API private sono invece pensate solo ed esclusivamente per i frontend "ufficiali" ed è possibile accedervi solo mediante richieste Ajax pure, quindi da pagine all'interno dello stesso dominio del backend (per maggiori info, date un'occhio alla [same-origin policy](http://en.wikipedia.org/wiki/Same_origin_policy)).

Tutto bellissimo e sensato, ma come lavorare sul frontend web in locale, con la possibilità effettuare richieste Ajax verso il backend? I browsers non ce lo permettono (se non mediante hack vari, e non sempre comunque)!

### Cross-domain Ajax con Rack e Net::HTTP

[Così come suggerito anche da Yahoo](http://developer.yahoo.com/javascript/howto-proxy.html), la soluzione è semplice: il server locale deve poter intercettare tutte le richieste Ajax, capire quali sono quelle da inoltrare verso un server remoto, fingersi client con quest'ultimo passando i medesimi parametri ricevuti dal browser (cookie compresi), ricevere la risposta (header compresi) e inoltrare il tutto al browser. Phew.

Tutto ciò in realtà è moderatamente semplice da fare. Ecco qui un middleware Rack in grado di comportarsi esattamente in questo modo, sfruttando la libreria standard `Net::HTTP`:

    [@language="ruby"]
    [@caption="rack_proxy.rb"]

    require "net/http"

    class Rack::Proxy
      def initialize(app, &block)
        self.class.send(:define_method, :uri_for, &block)
        @app = app
      end

      def call(env)
        req = Rack::Request.new(env)
        method = req.request_method.downcase
        method[0..0] = method[0..0].upcase

        return @app.call(env) unless uri = uri_for(req)

        sub_request = Net::HTTP.const_get(method).new("#{uri.path}#{"?" if uri.query}#{uri.query}")

        if sub_request.request_body_permitted? and req.body
          sub_request.body_stream = req.body
          sub_request.content_length = req.content_length
          sub_request.content_type = req.content_type
        end

        sub_request["Cookie"] = req.env["HTTP_COOKIE"]
        sub_request["Accept-Encoding"] = req.accept_encoding
        sub_request["Referer"] = req.referer
        sub_request.basic_auth *uri.userinfo.split(':') if (uri.userinfo && uri.userinfo.index(':'))

        http = Net::HTTP.new(uri.host, uri.port)

        sub_response = http.start { |http| http.request(sub_request) }

        headers = {}
        sub_response.each_header do |k,v|
          headers[k] = v unless k.to_s =~ /content-length|transfer-encoding/i
        end

        [sub_response.code.to_i, headers, [sub_response.read_body]]
      end
    end

Il suo utilizzo è molto semplice, un esempio pratico (da lanciare per esempio con `thin  -R config.ru start`):

    [@language="ruby"]
    [@caption="config.ru"]

    use Rack::Proxy do |req|
      if req.path =~ /api/
        URI.parse("http://www.api-server.com#{req.path}#{"?" if req.query_string}#{req.query_string}")
      end
    end

    run Rack::Directory.new(".")

In questo caso, facciamo partire un server Rack che normalmente serve tutti i files contenuti nella directory corrente (mediante il fantastico `Rack::Directory`), ma il middleware Rack creato, prima di passare la palla a `Rack::Directory`, controlla se l'URL non contiene la stringa `"api"`. In caso affermativo, si comporta da proxy, forwardando la richiesta HTTP ricevuta al server `www.api-server.com`, sul medesimo path.
