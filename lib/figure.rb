require 'nokogiri'

module Rack

  class PreFigure
    include Rack::Utils

    def initialize(app)
      @app = app
    end

    def call(env)
      @request = Rack::Request.new(env)

      status, @headers, @body = @app.call(env)
      @headers = HeaderHash.new(@headers)

      if is_html_content?
        body = edit_code_captions(body_to_string)
        update_response_body(body)
        update_content_length
      end

      [status, @headers, @body]
    end

    private

    def edit_code_captions(body)
      html = Nokogiri::HTML.fragment(body)
      html.css("pre > code").each do |code|
        process_caption_tag(code)
      end
      html.to_html
    end

    def process_caption_tag(element)
      pre = element.parent
      if result = element.content.match(/\[\s*@caption\s*=\s*"([^"]+)"\s*\]/)

        filename = result[1]
        element.content = element.content.gsub(/\[\s*@caption\s*=\s*"([^"]+)"\s*\]/, '')

        # Wrap in a <figure>.
        figure = Nokogiri::XML::Node.new("figure", element.document)
        pre.add_next_sibling(figure)
        pre.parent = figure

        # Add a <figcaption>.
        figcaption = Nokogiri::XML::Node.new("figcaption", element.document)
        figcaption.content = $1

        pre.add_previous_sibling(figcaption)

      end
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
