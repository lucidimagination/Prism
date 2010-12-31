# -=-=-=-=-=-=-=-=-=-=-=-=-=-
#   Generic Solr access code, perhaps split this off to Lucid::Solr as a separate project
# -=-=-=-=-=-=-=-=-=-=-=-=-=-

# pass nil for handler to use the standard /select with no qt set.
# TODO: maybe pass full Solr base URL instead of just core name?
def solr(core, handler, params={})
  url = URI.parse("http://localhost:8888/solr/#{core}") # TODO: parameterize Solr URL and handle nil core
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
