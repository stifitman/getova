module AerospaceExtraction
  class CompanyExtractor < Tagger::DataExtractor

    def extract_sidebar(text)
      name = @doc.xpath('///h4[@class="balken '+text+'"]/../ul/li').each do |name|
        yield name.content
      end
    end

    def extract_data
      company_name = clean_html @doc.xpath('//*[@id="leftContentColumn"]/h2')
      puts company_name

      basic_data  = @doc.xpath('//*[@id="leftContentColumn"]/div[2]/table/tr/td')

      @log.info "basic_data #{basic_data}"

      mail = clean_html basic_data[9]

      @log.info "MAIL9 #{mail}"
      mail = mail.gsub(/\s+/, "") unless mail.nil?

      phone = clean_html basic_data[7]

      if not is_a_valid_email?(mail)
        mail = clean_html basic_data[7]
      @log.info "MAIL7 #{mail}"
        phone = clean_html basic_data[5]
      end

      website = clean_html basic_data.last

      products_and_services = @doc.xpath('//*[@id="leftContentColumn"]/div[4]/text()')
      @log.info "Product & Services #{products_and_services}"

      address_line = @doc.xpath('//*[@id="leftContentColumn"]/div[1]/text()')
      address_text = address_line.to_s.split(',')

      i = 0
      address_text.each do |d|
        @log.info "#{i}: address: #{d}"
        i += 1
      end

      postal = address_text.last
      streetAddress = address_text.first + address_text[1]
      country = "Wales"
      locality = address_text[3]
      region = address_text[2]

      categories = @doc.xpath('//*[@id="leftContentColumn"]/div[@class="memberdiv"]')
      categories = categories.xpath(".//li")

      set_company
      add_name company_name

      add_locality locality unless locality.nil?
      add_country_name country
      add_postal_code postal
      add_website website
      add_mail mail.gsub(/\s+/, "") if is_a_valid_email?(mail)
      add_region region unless region.nil?
      add_street_address streetAddress
      add_phone phone
      add_extra "tanet"

      categories.each do |c|
        add_category(clean_html c)
      end

      company_name.gsub('/','_')
    end
  end
end
