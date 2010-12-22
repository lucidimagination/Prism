require 'sinatra'
require 'net/http'
require 'cgi'

get '/search' do
  # hmmm... seems like &fq=one&fq=two comes out in params[:fq] as just "two"... TODO!
  solr('/lucid', params).body
end

def solr(qt, params={})
  url = URI.parse("http://localhost:8888/solr/collection1")
  connection = Net::HTTP.new(url.host, url.port)
  connection.use_ssl = true if url.scheme == "https"
  
  connection.get(url.path + '/select?qt=' + CGI.escape(qt) + '&' + hash_to_query_string(params))
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
