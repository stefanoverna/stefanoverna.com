---
date: 2012/01/09
title: TDD è meglio che fare Unit Testing a posteriori
---

Forse non ce n'era il bisogno, ma se vi dovesse servire una ulteriore
prova inconfutabile che scrivere i test **mentre** stai scrivendo il
codice sia meglio che testare il codice a latere, eccola.

Questo è il codice del controller che avevo scritto per gestire una autenticazione
OAuth verso Twitter in un precedente progetto:

    [@language="ruby"]
    [@caption="oauth_controller.rb"]
    class OauthController < ApplicationController

      def twitter_oauth
        oauth_consumer = TwitterUser.oauth_consumer
        request_token = oauth_consumer.get_request_token(:oauth_callback => team_twitter_callback_url(@team))
        session['request_token'] = request_token.token
        session['request_secret'] = request_token.secret
        redirect_to request_token.authorize_url
      end

      def twitter_oauth_callback
        oauth_consumer = TwitterUser.oauth_consumer
        request_token = OAuth::RequestToken.new(oauth_consumer, session['request_token'], session['request_secret'])
        access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])

        client = TwitterUser.client(access_token.token, access_token.secret)
        user = TwitterUser.initialize_with_twitter_data(client.verify_credentials)
        user.team = @team
        user.access_token = access_token.token
        user.access_secret = access_token.secret
        user.save

        flash_message :notice, "A new Twitter account has been successfully added."
        redirect_to profile_path(@team)
      end

    end

Codice che funziona, a prima vista. Ma un po' troppo complicato per essere un controller, o no?
E cosa succede se per caso qualcosa va come non dovrebbe? Il codice è pronto a gestire tutti i casi?

Questo è il medesimo codice, ma riscritto in TDD:

    [@language="ruby"]
    [@caption="oauth_controller.rb"]
    class OauthController < ApplicationController

      def twitter_oauth
        request = TwitterProfile.oauth_authorization_request(twitter_callback_url)
        session['request_token'] = request.token
        session['request_secret'] = request.secret
        redirect_to request.authorize_url
      end

      def twitter_oauth_callback
        profile = TwitterProfile.new_from_oauth_authorization_response(session['request_token'], session['request_secret'], params[:oauth_verifier])
        profile.user = current_user
        if profile.save
          redirect_to profile_path(profile), notice: "A new Twitter account has been successfully added."
        else
          redirect_to new_profile_path, alert: "We were no able to add the Twitter account: #{formatted_record_errors(profile)}"
        end
      rescue OAuth::Unauthorized => e
        redirect_to new_profile_path, alert: "We were no able to add the Twitter account (#{e.message})"
      end

    end

La differenza si nota, o sbaglio? Controller più snello, più comprensibile,
modulare, e questo nonostante sia più complesso, dato che gestisce anche possibili errori
durante l'autenticazione che il primo codice ignorava con disprezzo.

La cosa divertente del TDD è che la forma che prende il codice non viene
decisa a priori, ma emerge in modo naturale durante la scrittura del test.

L'unica regola da seguire è: "se il test è troppo complicato da
scrivere, spezza e modularizza". Il resto viene da se'.
