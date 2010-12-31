module Lucid
  module Prism
    class LWE < Sinatra::Base
      get '/lwe' do
        # This is where we split off this /lwe method into a pluggable module to Prism, which will then also handle looking up roles for the user logged in, etc
        solr_params = params.merge(:wt => :ruby, :role => 'DEFAULT')
        raw = solr('collection1','/lucid', solr_params).body
        velaro :browse, :response => eval(raw), :raw => raw, :params => solr_params
      end

      get '/lwe_erb' do
        # copy of '/lwe' to demonstrate erb
        solr_params = params.merge(:wt => :ruby, :role => 'DEFAULT')
        raw = solr('collection1','/lucid', solr_params).body
        erb :browse, :locals => {:response => eval(raw), :raw => raw, :params => solr_params}
      end
    end  
  end
end
