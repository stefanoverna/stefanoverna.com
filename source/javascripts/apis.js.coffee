$ ->

  # Disqus
  window.disqus_shortname = 'stefanoverna'

  # SimpleReach Slide
  window.__spr_config =
    pid: "4f070745396cef0b3f0001fb"
    slide_logo: false
    loc: '.article-content'
    header: 'FORSE POTREBBE INTERESSARTI'
    # mostra solo nella pagina dettaglio
    no_slide: !$("section.page-content").is(".page-single-article")

  # Analytics
  window._gaq = [ ['_setAccount', 'UA-5105763-1'], ['_trackPageview'] ]

  # Load everything
  $.each([
    'http://platform.twitter.com/widgets.js',
    'http://stefanoverna.disqus.com/embed.js',
    'http://stefanoverna.disqus.com/count.js',
    'http://www.google-analytics.com/ga.js'
  ], (i, script) ->
    $.ajax(url: script, dataType: 'script', cache:true)
  )
