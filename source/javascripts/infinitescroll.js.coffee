$ ->

  $("section.page-content.index").each ->

    $(window).infinitescroll
      url: "/blog/page-{{page}}.html"
      triggerAt: 150
      appendTo: this

    $(this).bind "infinitescroll.finish", ->
      $.ajax(url: 'http://platform.twitter.com/widgets.js', dataType: 'script', cache: true)
      $.ajax(url: 'http://stefanoverna.disqus.com/count.js', dataType: 'script', cache: true)

