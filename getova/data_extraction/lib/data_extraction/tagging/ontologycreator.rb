require 'rdf'
require 'rdf/ntriples'
require 'sparql'
require 'json'
require 'json/ld'

module OntologyCreator
  include GeToVaLogger

  def init_ontology_creator
    @log.info "intializing OntologyCreator"
    @graph = RDF::Graph.new
    @graph_usdl = RDF::Graph.new

    set_up_namespaces
  end

  def set_up_namespaces
    @resume_cv = RDF::Vocabulary.new("http://fitman.sti2.at/company/")
    @gr = RDF::Vocabulary.new("http://purl.org/goodrelations/v1#")
    @s = RDF::Vocabulary.new("http://schema.org/address")
    @v = RDF::Vocabulary.new("http://www.w3.org/2006/vcard/ns#")
    @l = RDF::Vocabulary.new("http://www.linked-usdl.org/ns/usdl-core#")
  end

  #adds triples to the rdf graph
  def add_triple(subject,predicat,object)
    @log.debug "Add triple #{subject} #{predicat} #{object}"
    if subject != nil and predicat != nil and object != nil
      @graph << [ subject, predicat, object]
    else
      @log.debug "Tried to add nil tuple (but cancelled) : " + subject.to_s + " " + predicat.to_s + " " + object.to_s
    end
  end

  #adds triple to the rdf graph
  def add_usdl(subject,predicat,object)
    if subject != nil and predicat != nil and object != nil
      @graph_usdl << [ subject, predicat, object]
    else
      @log.debug "Tried to add nil tuple to USDL (but cancelled) : " + subject.to_s + " " + predicat.to_s + " " + object.to_s
    end
  end

  def return_triples
    return @graph.dump(:ntriples)
  end

  def return_usdl
    return @graph_usdl.dump(:ntriples)
  end

  def return_json(second=nil)
    jsonld = get_jsonld(@graph.dump(:ntriples))
    json = jsonld2json jsonld
    json.to_json
  end

  def return_jsonld
    get_jsonld(@graph.dump(:ntriples))
  end

  def self.included(klass)
    klass.send :prepend, OntologyCreator
  end


  def get_jsonld(rdf)
    input = RDF::Graph.new << RDF::Reader.for(:ntriples).new(rdf)
    context = JSON.parse %({
  "@context": {
      "gr": "http://purl.org/goodrelations/v1#",
      "s": "http://schema.org/address",
      "v": "http://www.w3.org/2006/vcard/ns#",
      "l": "http://www.linked-usdl.org/ns/usdl-core#",
      "foaf": "http://xmlns.com/foaf/0.1/",
      "c": "http://fitman.sti2.at/company/"
 }
 })


 compacted = nil
 JSON::LD::API::fromRdf(input) do |expanded|
   compacted = JSON::LD::API.compact(expanded, context['@context'])
 end

 compacted
  end

  def jsonld2json(jsonld)

    if jsonld.class == String
      @log.info "jsonld was a string"
      jsonld = JSON.parse(jsonld)
      @log.info jsonld
    end

    jsonld.delete '@context'
    @log.info "remove context:"
    @log.info jsonld

    @log.info "Merging all graphs together"
    if jsonld['@graph']
      final_json = Hash.new
      graph = jsonld['@graph']
      graph.each do |g|
        g.each do |k,v|
          @log.info "#{k} #{v}"
          final_json[k] = v
        end
      end
      jsonld = final_json
    else
      @log.error "There was no graph for #{jsonld}"
    end

    @log.info "Created the following plain json: #{jsonld}"
    return jsonld

    plain = Hash.new
    jsonld.each do |k,v|
      key = k
      match_result = k.match('(:)(\w+)')
      @log.info "matchresult: #{match_result}"
      key = match_result[2].to_s unless match_result.nil?

      plain[key] = v.strip if v.class == String
    end
    return plain
  end
end
