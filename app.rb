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

  SUPER_OPTIMIZED = ['-filter Triangle', '-define filter:support=2',
                     '-unsharp 0.25x0.08+8.3+0.045', '-dither None',
                     '-posterize 136', '-quality 82',
                     '-define jpeg:fancy-upsampling=off',
                     '-define png:compression-filter=5',
                     '-define png:compression-level=9',
                     '-define png:compression-strategy=1',
                     '-define png:exclude-chunk=all', '-interlace none',
                     '-colorspace sRGB']

  Size = Struct.new(:original) do
    def to_geometry_s
      !!original.match(/\A\d+x\d+\z/) ? original + '#' : original
    end

    def valid?
      !!original.match(/\A\d*x\d*\z/) && !!original.match(/\d+/)
    end
  end

  get '/opt/:size/*' do
    size = Size.new(params['size'])
    return 404 unless size.valid?

    begin
      first_wildcard = params.fetch('splat', [])[0]
      Dragonfly.app.fetch_url("#{ENV['URL_BASE']}/#{first_wildcard}")
                   .convert(SUPER_OPTIMIZED * ' ')
                   .thumb(size.to_geometry_s)
                   .to_response(env)
    rescue ErrorResponse, CannotHandle, TooManyRedirects, BadURI
      return 404
    end
  end

  get '/:size/*' do
    size = Size.new(params['size'])
    return 404 unless size.valid?

    begin
      first_wildcard = params.fetch('splat', [])[0]
      Dragonfly.app.fetch_url("#{ENV['URL_BASE']}/#{first_wildcard}")
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
