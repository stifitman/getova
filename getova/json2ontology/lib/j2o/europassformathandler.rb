require 'net/http'
require 'rubygems'
require 'json-schema'
require 'openssl'

class EuropassFormatHandlerException < StandardError
end

class EuropassFormatHandler
  include Logging

  def initialize(dbconnector,namespace)
    @dbconnector = dbconnector
    @jsonToRdfconverter = JsonToRdfConverter.new
    @jsonToRdfconverter.setNamespace(namespace)
  end

  def JSONSchema
    @schema
  end

  def setJSONSchema(schema)
    @schema = JSON.parse(File.read(schema))
  end

  def setNamespace(namespace)
    @namespace = namespace
  end

  def namespace
    @namespace
  end

  def isValid(id)
    if @schema == nil
      raise EuropassFormatHandlerException
    else
      puts JSON::Validator.fully_validate(@schema, json, :errors_as_objects => true)
      puts JSON::Validator.validate(@schema, getAsJSON(id), :strict => true)
    end
  end

  def get(id,format)
    logger.info "returning #{format} for #{id}"
    if format == "rdf"
      logger.info "loading rdf"
      return getAsRDF(id)
    elsif format == "xml"
      logger.info "loading xml"
      return getAsXML(id)
    elsif format == "json"
      logger.info "loading json"
      return getAsJSON(id)
    elsif format == "jsonld"
      logger.info "loading jsonld"
      return getAsJSONLD(id)
    end
  end

  private

  def getAsXML(id)
    if (@dbconnector.get(id,"xml")!=nil)
      @dbconnector.get(id,"xml")
    else
      logger.info "calling europass webservice to create xml out of json"
      uri = URI.parse('https://europass.cedefop.europa.eu/rest/v1/document/to/xml-cv')
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      data = JSON.parse(getAsJSON(id)).to_json
      req.body = data
      res = https.request(req)
      @dbconnector.addFormat(id,res.body,"xml")
      return res.body
    end
  end

  def getAsJSON(id)
    unless @dbconnector.get(id,"json").nil?
      return @dbconnector.get(id,"json")
    end
    unless @dbconnector.get(id,"jsonld").nil?
      logger.info "create json out of jsonld"
      jsonld = JSON.parse(@dbconnector.get(id, "jsonld").to_json)
      jsonld.delete("@context")
      @dbconnector.addFormat(id, jsonld,'json')
      return jsonld.to_json
    end
    unless @dbconnector.get(id,"xml").nil?
      logger.info "call europass ws to create json out of xml"
      uri = URI.parse('https://europass.cedefop.europa.eu/rest/v1/document/to/json')
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/xml'})
      data = @dbconnector.get(id, 'xml')
      req.body = data
      res = https.request(req)
      @dbconnector.addFormat(id,res.body,"json")
      return res.body
    end
    #TODO: JSONLD seems to be oddly formated...
    unless @dbconnector.get(id,"rdf").nil?
      logger.info "create jsonld out of rdf to create json"
      jsonld = @jsonToRdfconverter.getJsonld(@dbconnector.get(id,'rdf'))
      @dbconnector.addFormat(id,"jsonld", jsonld)
      logger.info "create json out of jsonld (use jsonld as json)"
      @dbconnector.addFormat(id, jsonld,'json')
      return jsonld.to_json
    end

    nil
  end

  def exists?(id,format)
    not  @dbconnector.get(id,format).nil?
  end

  def getAsRDF(id)
    if exists?(id,'rdf')
      logger.info "Returning existing RDF"
      return @dbconnector.get(id,"rdf")
    end
    if exists?(id,"jsonld")
      logger.info "Returning RDF created out of jsonld"
      jsonld = @dbconnector.get(id,"jsonld")
      rdf = @jsonToRdfconverter.getRdf(jsonld)
      @dbconnector.addFormat(id,rdf,"rdf")
      return rdf
    end
    if exists?(id,"json")
      logger.info "Returning RDF created out of jsonld created out of json"
      json = @dbconnector.get(id,"json")
      jsonld = @jsonToRdfconverter.createJSONLD(json)
      @dbconnector.addFormat(id,jsonld,"jsonld")
      rdf = @jsonToRdfconverter.getRdf(jsonld)
      @dbconnector.addFormat(id,rdf,"rdf")
      return rdf
    end
    if exists?(id,"xml")
      logger.info "Create JSON out of XML to create RDF"
      getAsJSON(id)
      return getAsRDF(id)
    end
  end

  def getAsJSONLD(id)
    if @dbconnector.get(id,"jsonld")!=nil
      return @dbconnector.get(id,"jsonld")
    end
    if @dbconnector.get(id, "json")!=nil
      logger.info "create jsonld out of json"
      json = @dbconnector.get(id,"json")
      jsonld = @jsonToRdfconverter.createJSONLD(json)
      @dbconnector.addFormat(id,jsonld,"jsonld")
      return jsonld
    end
    if @dbconnector.get(id, "xml")!=nil
      logger.info "create json out xml to create jsonld"
      getAsJSON(id)
      return getAsJSONLD(id)
    end
    unless @dbconnector.get(id, "rdf").nil?
      logger.info "create jsonld out of rdf"
      jsonld = @jsonToRdfconverter.getJsonld(@dbconnector.get(id,'rdf'))
      @dbconnector.addFormat(id,"jsonld", jsonld)
      return jsonld
    end
  end
end
