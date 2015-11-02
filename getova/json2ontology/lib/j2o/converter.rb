require 'net/http'
require 'rubygems'
require 'json-schema'
require 'sparql'


#exception thrown if there are errors during conversions
class ConverterException < StandardError
end

class ConverterFormatTransformation
  include Logging

  def initialize(name,baseToFormat,formatToBase)
    @name = name
    @baseToFormat = baseToFormat
    @formatToBase = formatToBase
  end

  def name
    @name
  end

  def baseToFormat
    @baseToFormat
  end

  def formatToBase
    @formatToBase
  end

end

class  Converter
  include Logging

  def initialize(dbconnector,europassformathandler)
    @dbconnector = dbconnector
    @efh = europassformathandler
    @formats = Hash.new
    efh_formats.each do |f|
      @formats[f] = ""
    end
  end

  def addFormat(format)
    @formats[format.name] = format
  end

  def formats
    @formats.keys
  end

  def efh_formats
    ['xml','rdf','json','jsonld']
  end

  def useEuropassFormatHandler?(format)
    efh_formats.include? format
  end

  def transform_format(id,format,toBase)
    logger.info "Converter tries to create #{format} out of the base" unless toBase
    logger.info "Converter tries to transform #{format} to base" if toBase

    data = StringIO.new(@dbconnector.get(id,"rdf")) unless toBase
    data = StringIO.new(@dbconnector.get(id, format)) if toBase
    reader = RDF::Reader.for(:ntriples).new(data)
    repo = RDF::Repository.new

    reader.each do |i|
      repo.insert(i)
    end

    unless toBase
      query = SPARQL.parse(@formats[format].baseToFormat)
    else
      query = SPARQL.parse(@formats[format].formatToBase)
    end

    result = query.execute(repo).dump(:ntriples)
    logger.info "RESULT IS #{result.class} with #{result.length} chars"
    @dbconnector.addFormat(id,result,format) unless toBase
    @dbconnector.addFormat(id,result,"rdf") if toBase
    result
  end

  def get(id,format)
    logger.info"id: #{id} format: #{format}"


    unless @dbconnector.get(id,format).nil?
      logger.info "Converter found the format already"
      return @dbconnector.get(id,format)
    end

    if @formats[format].nil?
      logger.info 'Converter does not know the format"'
      return nil
    end

    if useEuropassFormatHandler? format
      logger.info "using europasshandler to obtain the format"
      res = @efh.get(id,format)
      unless res.nil?
        return res
      end
    end

    unless @efh.get(id,"rdf").nil?
      if useEuropassFormatHandler? format
        return @efh.get(id,format)
      end
      return transform_format(id,format, false)
    end

    storedformat = nil
    formats.each do |f|
      unless @dbconnector.get(id,f).nil?
        puts "FORMAT: #{f}"
        storedformat = f unless useEuropassFormatHandler? f
        puts "CHOOSEN  #{storedformat}"
      end
    end

    if storedformat==nil
      logger.info 'Converter did not find any suitable formats to create the wanted format'
      return nil
    else
      logger.info "Converter is creating the #{format} out of #{storedformat}"
    end

    logger.info "Converter creating #{format} out of #{storedformat}"
    transform_format(id,storedformat,true )
    get(id,format)
  end


  def getFormat(name)
    @formats[name]
  end

  def removeFormat()
    @formats[format.name].delete
  end

end
