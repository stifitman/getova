#this script creates linked usdl and rdf out of a provided xml by DITF
module WAFExtraction2
  class CompanyExtractor < Tagger::DataExtractor

    def start extractor_name
      @xpath_splitter = '/Companies/Company'
      super extractor_name
    end

    def extract_data
      set_company
      company = @doc#.xpath("//Company").first

      company_name = company.attribute('nodeName').text

      website =  company.xpath("website").text
      category = company.xpath("mainCategory").text unless company.xpath("mainCategory").nil?

      address_complete  = ""
      address = company.xpath("address1/text()").text.strip
      locality = company.xpath("townCity").text.strip
      postal_code = company.xpath("postCode").text.strip
      phone = company.xpath("contact/TextstringArray/values/value").text.strip

      address_complete += address + ", " + locality + " " + postal_code

      prod_services = company.xpath("productServices/text()").text.strip
      prod_services = prod_services.split(/[.,'•]/)

      add_name company_name

      add_website website
      add_extra "tanet"
      add_address address_complete
      add_category category if category

      prod_services.each do |c|
        add_subcategory c.strip
      end

      return @company_name = company_name.tr("/","_")
    end
  end
end
