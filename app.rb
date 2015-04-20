require 'rubygems'
require 'sinatra/base'
require 'dragonfly'

if ENV['RACK_ENV'] != 'production'
  require 'dotenv'
  Dotenv.load
end

class App < Sinatra::Base
  Dragonfly.app.configure do
    plugin      :imagemagick
    verify_urls false
  end

  Size = Struct.new(:original) do
    def to_geometry_s
      !!original.match(/\A\d+x\d+\z/) ? original + '#' : original
    end

    def valid?
      !!original.match(/\A\d*x\d*\z/) && !!original.match(/\d+/)
    end
  end

  get '/:size/*' do
    size = Size.new(params['size'])
    return 404 unless size.valid?

    begin
      Dragonfly.app.fetch_url("#{ENV['URL_BASE']}/#{params['splat'].first}")
                   .thumb(size.to_geometry_s)
                   .to_response(env)
    rescue ErrorResponse, CannotHandle, TooManyRedirects, BadURI
      return 404
    end
  end

  get '/' do
    'Alive: ' + ENV['URL_BASE']
  end
end
