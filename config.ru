require_relative 'lib/confg_file'
require_relative 'models/collections'
require 'roda'
require 'slim'


class App < Roda
  plugin :render, engine: 'slim'
  plugin :all_verbs


  route do |r|
    r.root do
      r.redirect '/collections'
    end
    @config = ConfigFile.read

    r.on 'collections' do 
      @collections = Collections.all
      #r.get do
        view :collections
      #end
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

run App.freeze.app
