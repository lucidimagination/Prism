require 'sinatra/base'
require 'net/http'
require 'net/https'
require 'cgi'

require 'solr'
require 'velaro'
require 'lucid_works'
# require 'eurocon'

module Lucid  
  module Prism
    class Main < Sinatra::Base
      set :public_folder, './public'
      set :views, './views'

      SOLR_BASE_URL = ENV['PRISM_SOLR_BASE_URL'] || 'http://localhost:8983/solr' # TODO:unDRY alert:this is duplicated in lucid_works.rb - centralize.
      
      use Lucid::Prism::LucidWorks # TODO: inject this dynamically somehow rather than hardcoding - via Rack middleware config?
      # TODO:and how to automatically namespace-prefix these types of plugins?  e.g. /lucid/ + routes in Prism::LucidWorks

      # Solr direct pass-thru; response code, headers including content-type, and Solr response body all included
      # TODO: this needs to be made optional, and perhaps only default it on when in development mode
      get '/solr/?:core?/?:handler?' do
        solr_core = params[:core] ? ('/' + params[:core]) : ''
        solr_url = "#{SOLR_BASE_URL}#{solr_core}"
        http_response = solr(solr_url, params[:handler] ? "/#{params[:handler]}" : nil, params)

        [http_response.code.to_i, http_response.to_hash, http_response.body]
      end
      
      get '/prism/?:core?/?:handler?' do
        # TODO:centralize this Solr calling pattern as used above also
        solr_core = params[:core] ? ('/' + params[:core]) : ''
        solr_url = "#{SOLR_BASE_URL}#{solr_core}"

        solr_params = {}
        params.each {|key,value| solr_params[key] = value unless %w{splat captures core template handler}.include?(key) }

        http_response = solr(solr_url, params[:handler] ? "/#{params[:handler]}" : nil, solr_params.merge(:wt=>:ruby))
        solr_response = eval(http_response.body) rescue ""
        
        velaro params[:template] || params[:handler] || :prism,
          :locals => {
            :solr => {
              # TODO: string keys required for now, but symbols should be made to work
              'response' => solr_response['response'], 
              'header' => solr_response['responseHeader'], 
              'raw_response' => http_response.body, 
              'url' => solr_url,
              'params' => solr_params,
            },
            :params => params,
          },

          # Velocity engine parameters
          :velocity => {
            # TODO:fix situation with this template_path (and generalized issue),
            # TODO:of making "plugin" be able to load in a "prism" with this kind of thing specified
            :'file.resource.loader.path' => "./views/lucid_works,./views/solr",
            :'resource.loader' => "file"
          }
      end
      
      post '/update' do
        "not supported"
        # TODO: process multiparts, case them into /update, /update/csv, /update/extract, etc
      end
    end
  end
end

# TODO: launch Prism outside of here
Lucid::Prism::Main.run!

