$ ->

  $("section.page-content.archivio").each ->

    $container = $(this)

    results_template = Hogan.compile '
      <div class="right">
        <h1>Risultati per "{{query}}"</h1>
        <ul>
          {{#results}}
            <li>
              <a href="{{link}}">{{title}}</a>
            </li>
          {{/results}}
        </ul>
      </div>
    '

    $original_content = $container.find(".right")

    $("#query").change ->

      query = $(this).val()

      if query == ""

        $container.find(".right").remove()
        $container.append($original_content)

      else

        $.getJSON("http://www.tapirgo.com/api/1/search.json?callback=?", token: '4dc912b43f61b01c710001c1', query: query)
          .success (data) ->
            html = results_template.render
              query: query
              results: data

            $container.find(".right").remove()
            $container.append(html)
