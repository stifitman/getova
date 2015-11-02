module Tagger
  include GeToVaLogger

  def init_tags
    init_logger
    begin
      @log.info "Loading annotations from elasticsearch db"
      @annotations =  @es_client.search index: 'tags', id: 'led_tags'
      @annotations = @annotations['hits']['hits'].first['_source']
      @log.info "LOADED ####################################################################################################"
      @log.info "Loaded #{@annotations}"
      @log.info "LOADED ####################################################################################################"
    rescue
      @log.error "Could not load annotations from database"
      begin
        @annotations  = JSON.parse( IO.read("annotations.json") )
        remove_annotation_duplicates
      rescue
        @annotations = Hash.new
      end
    end
  end

  def add_annotation(annotation, text)
    @annotations[annotation] = Array.new unless @annotations.has_key? annotation
    @annotations[annotation] << text.strip
  end

  def store_wordlists
    remove_annotation_duplicates

    if ENV['results_folder']
      File.open("annotations.json","w") do |f|
        f.write(JSON.pretty_generate(@annotations))
      end
    end

    @log.info "Loading tags from #{@tag_server_ip}"
    begin
      @es_client = Elasticsearch::Client.new host: @tag_server_ip
      @es_client.index  index: 'tags',id: 'led_tags', type: 'tag', body: @annotations
      @log.info "Stored tags onto the server: #{@annotations}"
    rescue Exception => e
      @log.error "Could not sore tags into database!"
      @log.error e
    end

    if ENV['results_folder']
      @annotations.each do |k, v|
        File.open(k,"w") do |f|
          v.each do |word|
            f.write(word.strip+"\n")
          end
        end
      end
    end
  end

  def remove_annotation_duplicates
    @annotations.select do |k,v|
      v.uniq!
    end
  end
end
