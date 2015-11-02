
module LEDExtraction
  class CompanyExtractor < Tagger::DataExtractor
    def extract_sidebar(text)
      @doc.xpath('///h4[@class="balken ' + text + '"]/../ul/li').each do |name|
        yield name.content
      end
    end

    def extract_data
      content = @doc.css('div').select { |document|
        document['id'] == "inhalt"
      }[0]
      company_name = clean_html content.css('h1')

      description = @doc.css('div').select { |description|
        description['id'] == "text"
      }[0]

      address = @doc.css('div').select { |address| address['class'] == 'adresse' }.first
      website = @doc.css('a').select { |website| website['class'] == 'out' }[0]['href']
      address_lines = address.to_s.lines

      cleaned_address_lines = Array.new
      address_lines[3, address_lines.size].each do |l|
        l = clean_html(l)
        cleaned_address_lines << l
      end

      streetaddress = cleaned_address_lines[0]
      postal = cleaned_address_lines[1].split[0]
      locality = cleaned_address_lines[1].split[1]
      country = cleaned_address_lines[2]
      phone = cleaned_address_lines[4]
      mail = cleaned_address_lines[5]
      region = country

      set_company
      add_name company_name
      add_extra 'complus'

      add_locality locality
      add_country_name country
      add_postal_code postal
      add_website website
      add_mail mail.gsub(/\s+/, '')
      add_region region
      add_street_address streetaddress
      add_phone phone

      extract_sidebar('prodcat') { |i|
        @log.debug "prodcat : #{i}"
        add_produces i
      }

      extract_sidebar('prodcat2') { |i|
        @log.debug "prodcat2 : #{i}"
        add_sells_product i
      }

      extract_sidebar('distcat') { |i|
        @log.debug "distcat : #{i}"
        add_distribution_category i
      }

      extract_sidebar('distfor') { |i|
        @log.debug "distfor : #{i}"
        add_distributes_for i
      }

      extract_sidebar('provcat') { |i|
        @log.debug "provcat : #{i}"
        add_provides i
      }

      extract_sidebar('distby') { |i|
        @log.debug "distfor : #{i}"
        add_distributed_by i
      }

      company_name
    end
  end
end
