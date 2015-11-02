require 'net/http'
require 'rubygems'
require 'json-schema'

class JsonToRdfConverterException < StandardError
end

class JsonToRdfConverter

  #  @@jsonld_to_rdf_ws = 'http://rdf-translator.appspot.com/convert/json-ld/rdf-json/content'

  def setNamespace(namespace)
    @namespace = namespace
  end

  def namespace
    @namespace
  end

  def prettyLD
    @jsonld_pretty
  end

  def deleteFromHashIfExists(hash,key)
    hash[key] = []
    hash.delete(key)
  end

  def createJSONLD(json)
    context_accu = Hash.new
    jsonld = JSON.parse(json)
    context = addToContext jsonld, @namespace ,context_accu
    jsonld["@context"]=  context
    @jsonld_pretty = JSON.pretty_generate(jsonld)
    jsonld
  end

  def addToContext(hash, ns, hash_accu)
    hash.each do |k, v|
      hash_accu[k] = ns + k
      if v.is_a? Hash
        addToContext(v,ns,hash_accu)
      elsif v.is_a? Array
        v.each do |e|
          if e.is_a? Hash
            addToContext(e,ns,hash_accu)
          end
        end
      end
    end

    hash_accu
  end

  def getRdf(jsonld)
    graph = RDF::Graph.new << JSON::LD::API.toRdf(jsonld)
    graph.dump(:ntriples)
  end

  def getJsonld(rdf)
    input = RDF::Graph.new << RDF::Reader.for(:ntriples).new(rdf)
    JSON::LD::API::fromRdf(input).to_s
  end

end
