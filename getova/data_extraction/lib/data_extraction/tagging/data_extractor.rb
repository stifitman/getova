module Tagger
  class DataExtractor
    include Tagger
    include CompanyOntology

    attr_accessor :element_name
    attr_accessor :xpath_splitter
    attr_accessor :data

    #
    # prepares everything for a run
    #
    def set_up
      @tag_server_ip = ENV['elastic_search_ip']
      init_logger
      init_company_ontology

      @log.info "Parsing file\n\n"
      @log.info "Using xpath to split the document: #{@xpath_splitter}" if @xpath_splitter

      init_tags
    end

    #
    # main run method of the extractor
    #
    def perform_run( send_data_to_server)
      @log.info "Running company extractor"
      begin
        @element_name = extract_data
      rescue Exception => e
        @log.error "Extraction failed for company"
        @log.error e
        @element_name = "failed"
        return "failed"
      end
      @log.info return_usdl
      store_wordlists if (ENV['elastic_search_ip'] && send_data_to_server)
    end

    #
    # check wether some text is a valid email
    #
    def is_a_valid_email?(email)
      (email =~ /^(([A-Za-z0-9]*\.+*_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\+)|([A-Za-z0-9]+\+))*[A-Z‌​a-z0-9]+@{1}((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,4}$/i)
    end

    #
    # Cleans text from html tags
    #
    def clean_html(html)
      return "" if html.nil?

      if html.respond_to? ('text') #is a nokogiri node
        html.text.chomp.gsub(/\s+/, " ")
      else
        html.gsub(%r{</?[^>]+?>}, '') # assume plain text
      end
    end

    #
    # the main methods used to extract data from
    # the doc
    #
    def extract_data
      raise "Method not implemented"
    end

    #
    # Loads a document using Nokogiri
    #
    def load_doc file_name

      file = File.open(file_name, "r")
      data = file.read
      file.close

      @log.info "Nokogiri tries to load the file"
      @doc = Nokogiri::HTML data if file_name.end_with? "html"
      @doc = Nokogiri::XML data if file_name.end_with? "xml"

      if @doc.nil?
        raise 'Nokogiri could not handle the format (xml / html) ?'
      end
    end

    #
    # Store the data locally for the given file name and the
    # specified results_folder
    #
    def store_extraction_locally file_name
      @log.info "saving to result/#{file_name}"
      @log.info "file #{file_name}"
      File.open( ENV['results_folder'] + "/" + file_name + ".rdf", 'w') { |file| file.write(return_triples) }
      File.open( ENV['results_folder'] + "/" + file_name + ".usdl", 'w') { |file| file.write(return_usdl) }
      File.open( ENV['results_folder'] + "/" + file_name + ".json", 'w') { |file| file.write(return_json) }
    end

    #
    # Send the extracted data to a specified rails server
    #
    def send_extraction_to_server
      @log.info "Sending data to #{ENV['rails_server_ip']}"

      begin
        response =  RestClient.post "#{ENV['rails_server_ip']}/companies", {'company' =>
          {'name' => @element_name,
            'content' => "#{return_triples}",
            'usdl' => "#{return_usdl}"}}, :accept => :json
      rescue Exception => e
        @log.error e
      end
      @log.info response.inspect
    end

    #
    # Extract the data of a single file
    #
    def run_extraction(file_name, send_data_to_server)
      @log.info "Extracting data from #{file_name}"

      set_up
      load_doc file_name unless @xpath_splitter
      perform_run(send_data_to_server)

      file_name = @element_name

      results = Hash.new
      results['usdl'] = return_usdl
      results['rdf'] = return_triples
      results['json'] = return_json
      @data[file_name] = results

      if ENV['results_folder'] and @store_extraction_locally
        store_extraction_locally file_name
      else
        @log.info "Do not store results"
      end

      if ENV['rails_server_ip'] && send_data_to_server
        send_extraction_to_server
      else
        @log.info "Do not send data to server!"
      end

      @log.info "Finished extracting: #{file_name}"
    end

    #
    # starts the extraction of the data extractor
    # the name of the extractor is optional and for debugging reasons
    #
    def start(extractor_name: nil, command_line: false, files: [], send_data_to_server: true, store_data_locally: false)
      init_logger

      extractor_name = self.class if extractor_name.nil?
      files = ARGV if command_line == true

      @log.info "Using Commandline arguments: #{command_line}"
      @log.info "Received arguments: #{files} files"
      @log.info "Extractor name:  for #{extractor_name}" unless extractor_name.nil?
      @log.info "Rails server detected at #{ENV['rails_server_ip']}" unless ENV['rails_server_ip'].nil?
      @log.info "ElasticSearch server detected at #{ENV['elastic_search_ip']}" unless ENV['elastic_search_ip'].nil?
      @log.info "Store results locally: #{store_data_locally}, Send data to server: #{send_data_to_server}"

      @store_data_locally = store_data_locally

      @data = Hash.new
      @doc = nil
      files.each do |file_name|
        @log.info "Extracting for #{file_name}"
        unless @xpath_splitter
          run_extraction(file_name, send_data_to_server)
        else
          @log.info "Using xpath to split the document #{@xpath_splitter}"
          load_doc file_name
          splits = @doc.xpath(@xpath_splitter)
          @log.info "File contains #{splits.size} document"
          splits.each do |file|
            @doc = file
            run_extraction(file_name, send_data_to_server)
          end
        end
      end
    end
  end
end
