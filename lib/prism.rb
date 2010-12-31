require 'sinatra/base'
require 'net/http'
require 'cgi'

require 'solr'
require 'velaro'
require 'lwe'

module Lucid  
  module Prism
    class Main < Sinatra::Base
      set :public, './public'
      set :views, './views'
      
      use Lucid::Prism::LWE # TODO: inject this dynamically somehow rather than hardcoding - via Rack middleware config?

      # Solr direct pass-thru; response code, headers including content-type, and Solr response body all included
      # TODO: this needs to be made optional, and perhaps only default it on when in development mode
      get '/solr/?:core?' do
        solr_response = solr(params[:core], nil, params)

        [solr_response.code.to_i, solr_response.to_hash, solr_response.body]
      end
    end
  end
end

# TODO: launch Prism outside of here
Lucid::Prism::Main.run!

