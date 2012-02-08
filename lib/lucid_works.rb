module Lucid
  module Prism

    # TODO: Add actions here that hit LucidWorks backend to save/retrieve settings somehow
    class LucidWorks < Sinatra::Base
      # TODO:Make it so I can mount a /prism here with some defaults overridden (like template path)


      # TODO:figure out the Right place for these environment configuration basics
      SOLR_BASE_URL = 'http://localhost:8888/solr'

      # For now this is a simple way to compare/contrast the results from N (2 to start with) different /select requests
      # (including dynamic qt) to the same Solr core.  Request parameters (excepting _core_) will be used as the controls
      # for each juxtaposed view, and the values will be the default
      get '/juxtapose/?:core?' do # TODO: "collection" or "core"??

        # get cores - /admin/cores?wt=ruby&indent=on
        http_response = solr_cores(SOLR_BASE_URL)
        solr_response = eval(http_response.body)
        core = solr_response['status'][params[:core]]   # TODO:perhaps evolve to allowing various cores (at various base URLs) be selectable

        #http_response = solr("#{SOLR_BASE_URL}/",'/lucid', solr_params)
        #solr_response = eval(http_response.body)

        #solr_params = params.merge(:wt => :ruby, :role => 'DEFAULT')
        #http_response = solr("#{SOLR_BASE_URL}/collection1",'/lucid', solr_params)
        #solr_response = eval(http_response.body)

        solr_params = {}
        params.each {|key,value| solr_params[key] = value unless %w{splat captures core}.include?(key) }

        velaro :juxtapose,
            # Velocity context parameters
           :locals => {
            :core => core,
            :params => params,
            :solr_params => solr_params,
             #:solr => {
             #  # TODO: string keys required for now, but symbols should be made to work
             #  'response' => solr_response['response'],
             #  'header' => solr_response['responseHeader'],
             #  'raw_response' => http_response.body,
             #  'params' => solr_params
             #}
           },

           # Velocity engine parameters
           :velocity => {
             :'file.resource.loader.path' => "./views/lucid_works,./views/solr",
             :'resource.loader' => "file"
           },
           
           :layout => nil
      end
      
      get '/timeline' do
        [200, {'Content-Type' => "application/xml"}, '<data wiki-url="http://simile.mit.edu/shelf/" wiki-section="Simile Monet Timeline"><event start="Nov 14 2010 00:00:00 GMT" title="Birth" image="monet.png" link="http://en.wikipedia.org/wiki/Monet">Claude Monet</event></data>']
      end
    end  
  end
end


# Example browse.erb that can work with the following action:

# get '/lwe_erb' do # same as /lucid_works except renders via ERb for example purposes
#   solr_params = params.merge(:wt => :ruby, :role => 'DEFAULT')
#   raw = solr('collection1','/lucid', solr_params)
#   erb :browse, :locals => {:response => eval(raw.body), :raw => raw.body, :params => solr_params}
# end

# <html>
#   <head>
#     <title>Lucid Prism - search results for <%=params[:q]%></title>
#     <link rel="stylesheet" type="text/css" href="/main.css"/>
#   </head>
#   
#   <body>
#     Found <%=response['response']['numFound']%> docs in <%=response['responseHeader']['QTime']%>ms
# 
#     <% response['response']['docs'].each do |doc| %>
#       <div>
#         <%=doc['id']%>
#       </div>
#     <% end %>
# 
#   </body>
# </html>
