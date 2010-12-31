require 'sinatra/base'
require 'net/http'
require 'cgi'

require 'solr'
require 'velaro'
require 'lwe'

module Lucid  
  module Prism
    class Base < Sinatra::Base
      use Lucid::Prism::LWE # TODO: inject this dynamically somehow rather than hardcoding - maybe via Rack middleware config?

      # Solr direct pass-thru; response code, headers including content-type, and Solr response body all included
      # TODO: perhaps extract this out to its own Sinatra::Base subclass to make it optional via config
      get '/solr' do
        solr_response = solr('collection1', nil, params)

        [solr_response.code.to_i, solr_response.to_hash, solr_response.body]
      end
    end
  end
end

# TODO: launch Prism outside of here
Lucid::Prism::Base.run!

