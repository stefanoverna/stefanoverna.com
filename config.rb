activate :i18n, langs: [ :it ], :mount_at_root => :it

set :slim, :disable_escape => true
set :markdown_engine, :redcarpet
# set :markdown_engine_prefix, ::Tilt
# set :markdown, smartypants: true

activate :blog do |blog|
  blog.prefix = "blog"
  blog.summary_separator = /(<p>CUT<\/p>)/
  blog.summary_generator = Proc.new do |resource, source|
    if source =~ /CUT/
      resource.define_singleton_method(:cut?) { true }
      source.split(/CUT/).first
    else
      resource.define_singleton_method(:cut?) { false }
      source
    end
  end
  blog.sources = ":year/:month/:title.html"
  blog.permalink = ":year/:month/:title.html"
  blog.layout = "article"
end

page "/feed.xml", :layout => false

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

use Rack::Codehighlighter,
  :pygments,
  :element => "pre>code",
  :pattern => /\[@language="([^"]+)"\]/,
  :options => { :encoding => 'utf-8', :outencoding => 'utf-8', :linenos => 'inline' },
  :markdown => true

require 'lib/figure'
use Rack::PreFigure

activate :deploy do |deploy|
  deploy.method = :rsync
  deploy.host = "mt2.s.welaika.com"
  deploy.user = "mt2.s.welaika.com"
  deploy.path = "/home/128423/users/.home/domains/stefanoverna.com/html"
end
