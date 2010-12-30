require 'sinatra'
require 'net/http'
require 'cgi'

# Solr direct pass-thru; response code, headers including content-type, and Solr response body all included
get '/solr' do
  solr_response = solr(nil, params)
    
  [solr_response.code.to_i, solr_response.to_hash, solr_response.body]
end

get '/lwe' do
  # This is where we split off this /lwe method into a pluggable module to Prism, which will then also handle looking up roles for the user logged in, etc
  solr_params = params.merge(:wt => :ruby, :role => 'DEFAULT')
  raw = solr('/lucid', solr_params).body
  velaro :browse, :response => eval(raw), :raw => raw, :request => solr_params
end

# pass nil for handler to use the standard /select with no qt set.
def solr(handler, params={})
  url = URI.parse("http://localhost:8888/solr/collection1") # TODO: parameterize Solr URL
  connection = Net::HTTP.new(url.host, url.port)
  connection.use_ssl = true if url.scheme == "https"
  
  connection.get(url.path + '/select?' + hash_to_query_string(params.merge(:qt => handler)))
end

def hash_to_query_string(hash)
  hash.delete_if{|k,v| v==nil}.collect {|key,value|
    if value.respond_to?(:each) && !value.is_a?(String)
      value.delete_if{|v| v==nil}.collect { |v| "#{key}=#{CGI.escape(v.to_s)}"}.join('&')    
    else
      "#{key}=#{CGI.escape(value.to_s)}"
    end
  }.join('&')   
end

# -=-=-=-=-=-=-=-=-=-=-=-=-=-
#   Velaro - The code below will be extracted back into erikhatcher's Velaro github project
# -=-=-=-=-=-=-=-=-=-=-=-=-=-

if RUBY_PLATFORM == "java"
  include Java

  require "./lib/velocity-1.6.4-dep.jar"

  java_import 'org.apache.velocity.Template'
  java_import 'org.apache.velocity.VelocityContext'
  java_import 'org.apache.velocity.app.VelocityEngine'
  
  java_import 'java.io.StringWriter'
else
  raise "Velaro requires JRuby"
end # if java

def velaro(template_name, parameters)
  engine = VelocityEngine.new
  engine.setProperty(VelocityEngine::FILE_RESOURCE_LOADER_PATH, "./views")
  engine.setProperty(VelocityEngine::RESOURCE_LOADER, "file")
  template = engine.getTemplate("#{template_name}.vel")
  
  context = VelocityContext.new

  parameters.each do |k,v|
    context.put(k, v)
  end

  writer = StringWriter.new
  template.merge(context, writer)
  return writer.getBuffer.to_s
end
