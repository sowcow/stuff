require_relative 'lib/config_file'
require_relative 'models/collections'
require 'roda'
require 'slim'


class App < Roda
  plugin :render, engine: 'slim'
  plugin :all_verbs
  #plugin :assets,
  #  css: 'semantic.min.css',
  #  js: ['jq.js', 'semantic.min.js']


  route do |r|
    #r.assets

    r.root do
      r.redirect '/collections'
    end
    @config = ConfigFile.read
    # not fixing to relative file name!
    # because config is a parameter!
    # hey but rackup seems like fixing, or not?

    r.on 'collections' do 
      @collections = Collections.all @config
      view :collections
    end

    # r.is 'artist/:id' do |artist_id|
    #   @artist = Artist[artist_id]
    #   check_access(@artist)

    #   r.get do
    #     view :artist
    #   end

    #   r.post do
    #     @artist.update(r['artist'])
    #     r.redirect
    #   end

    #   r.delete do
    #     @artist.destroy
    #     r.redirect '/'
    #   end
    # end
  end
end

use Rack::Static, urls: ['/assets'], root: 'public'

run App.freeze.app
