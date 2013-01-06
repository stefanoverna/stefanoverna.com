$ ->
  $('.page-single-article article').each ->
    $article = $(this)
    $article.find("sidebar").portamento(wrapper: $article, gap: 24)
