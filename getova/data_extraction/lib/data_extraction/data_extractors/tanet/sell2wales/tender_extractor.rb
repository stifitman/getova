module Sell2WalesExtractor
  class TenderExtractor < Tagger::DataExtractor

    attr_accessor :categories

    def fetch_categories
      @categories = Set.new
      if ENV['rails_server_ip']
        @log.info "fetching categories from #{ENV['rails_server_ip']}"
        data = RestClient.get ENV['rails_server_ip']+"/tanet", :accept => :json
        data = JSON.parse data
        @log.debug "Received #{data} consisting of #{data.size} files"

        data.each do |d|
          d = JSON.parse d['data']
          @log.debug "Element #{d}"
          @log.info "Adding categories for #{d['c:hasLegalName']}"
          @log.info "Adding categories for #{d['c:name']}"

          if d['c:category'].class == Array
          @log.debug "CATS ARRAY:  #{d['c:category']}"
            @categories.merge d['c:category']
          else
          @log.debug "CATS SINGLE:  #{d['c:category']}"
            @categories.add d['c:category'] unless d['c:category'].nil?
          end

          if d['c:subcategories'].class == Array
          @log.debug "SUBCATS ARRAY:  #{d['c:subcategories']}"
            @categories.merge d['c:subcategories']
          else
          @log.debug "SUBCATS SINGLE:  #{d['c:subcategories']}"
            @categories.add d['c:subcategories'] unless d['c:subcategories'].nil?
          end
        end
      else
        @log.info "No rails server set. No categories are fetched"
      end

      @categories.delete ""
      @categories.delete_if { |e| e.length < 3}
      @categories
    end

    def start name
      init_logger
      fetch_categories
      @log.info "Categories #{@categories.inspect}"
      super
    end

    def extract_data
      tender = RDF::Node.new
      add_triple( tender , RDF.type, @resume_cv.Tender)

      #word_list = open("wordlist.txt")
      word_list = @categories
      notes =  @doc.xpath('//*[@id="ctl00_ContentPlaceHolder1_tab_StandardNoticeView1_notice_introduction1_lblAbstract"]/text()[1]').text
      name = @doc.xpath('//*[@id="ctl00_ContentPlaceHolder1_tab_StandardNoticeView1_notice_introduction1_lblTitle"]').text
      provider = @doc.xpath('//*[@id="ctl00_ContentPlaceHolder1_tab_StandardNoticeView1_notice_introduction1_lblAuth"]/a').text
      publication_date = @doc.xpath('//*[@id="ctl00_ContentPlaceHolder1_tab_StandardNoticeView1_notice_introduction1_lblPubDate"]').text
      deadline_date = @doc.xpath('//*[@id="ctl00_ContentPlaceHolder1_tab_StandardNoticeView1_notice_introduction1_lblDeadlineDate"]').text
      deadline_time = @doc.xpath('//*[@id="ctl00_ContentPlaceHolder1_tab_StandardNoticeView1_notice_introduction1_lblDeadlineTime"]').text

      word_list.each do |w|
        w = w.strip
        if notes.downcase.include? w.downcase
          add_triple(tender, @resume_cv.category, w)
        end
      end

      add_triple(tender , @resume_cv.notes, notes)
      add_triple(tender , @resume_cv.name, name)
      add_triple(tender , @resume_cv.provider, provider)
      add_triple(tender, @resume_cv.publication_date, publication_date)
      add_triple(tender, @resume_cv.deadline_date, deadline_date)
      add_triple(tender, @resume_cv.deadline_time, deadline_time)

      if  ENV['rails_server_ip']
        @log.info "Sending data to #{ENV['rails_server_ip']}"

        begin
          puts "TENDER:"
          json = {'tender' => {'data' => "#{return_json()}"}}
          puts json
          puts "end tender"

          response =  RestClient.post "#{ENV['rails_server_ip']}/tenders", json, :accept => :json
        rescue Exception => e
          @log.error e
        end
        @log.info response.inspect
      else
        @log.info "Do not send data to server!"
      end

      name.gsub('/','_')
    end
  end
end
