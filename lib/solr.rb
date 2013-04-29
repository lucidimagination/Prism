require 'net/http'
require 'net/https'
require 'cgi'

# TODO: should requests to Solr be wrapped in blocks/yields to allow auto/safe connection closing?

def solr(url, handler, params={})
  connection, solr_url = connection(url)
  req_url = solr_url.path + '/select?' + hash_to_query_string(params.merge(:qt => handler))
  # puts "*** requesting to Solr: #{req_url}"
  connection.get(req_url)
end

def solr_cores(url)
  connection, solr_url = connection(url)
  connection.get(solr_url.path + '/admin/cores?wt=ruby')
end

def connection(url)
  url = URI.parse(url)
  connection = Net::HTTP.new(url.host, url.port)
  connection.use_ssl = true if url.scheme == "https"
  return connection, url
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
