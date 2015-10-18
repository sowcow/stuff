require_relative 'lib/config_file'
require_relative 'lib/code_getter'
require_relative 'lib/state'
require_relative 'models/collections'
require 'roda'
require 'slim'

require 'better_errors'
use BetterErrors::Middleware
BetterErrors.application_root = __dir__


class App < Roda
  plugin :render, engine: 'slim'
  plugin :assets, css: %w[
    normalize.css
    skeleton.css
    app.sass
  ]
  compile_assets


  route do |r|
    r.assets
    @config = ConfigFile.read

    r.root do
      r.redirect '/collections'
    end

    r.on 'collections' do 
      @collections = Collections.all @config
      @title = 'Коллекции'

      r.is do
        r.get do
          view :collections
        end
      end

      r.on ':slug' do |slug|
        @collection = @collections.find { |x|
          x.slug == slug
        }
        @title = @collection.name

        r.get do
          view :collection
        end

        r.post do
          getter = CodeGetter.for @collection
          getter.get
          r.redirect to(@collection)
        end
      end
    end

  end


  # url helpers

  # guards gem if more types needed to handle
  def to collection
    "/collections/#{collection.slug}"
  end

  # view helpers


  def ui_item_menu count
    count = READS.fetch count.to_s
    "ui item menu #{count}"
  end
  READS = {
    '1' => 'one',
    '2' => 'two',
    '3' => 'three',
    '4' => 'four',
    '5' => 'five',
    '6' => 'six',
    '7' => 'seven',
    '8' => 'eight',
    '9' => 'nine',
  }

  def nest_url url
    "/collections/#{url}"
  end
end

#use Rack::Static, urls: ['/assets'], root: 'public'

run App.freeze.app
