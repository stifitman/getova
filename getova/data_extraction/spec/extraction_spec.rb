require'spec_helper'

describe "data_extractors" do
  describe "COMPLUS" do
    it 'should extract data correctly' do
      extractor = LEDExtraction::CompanyExtractor.new

      lumitronix = file_absolute_location("/data/complus/led/lumitronixR-led-technik-gmbh.html")

      extractor.start(
        extractor_name: "Complus LED Extractor",
        files: [lumitronix],
        send_data_to_server: false
      )

        expect(extractor.return_triples).not_to be_empty
        expect(extractor.return_usdl).not_to be_empty
    end
  end

  describe "LinkedIn" do
    describe "Companies"
    it 'should extract data correctly' do
      extractor = LinkedInExtraction::CompanyExtractor.new

      audi = file_absolute_location(
        "/data/linkedin/companies/html/AUDI AG  Overview   LinkedIn.html")

        extractor.start(files: [audi])

        expect(extractor.return_triples).not_to be_empty
        expect(extractor.return_usdl).not_to be_empty
    end
  end
end


describe "Tanet" do
  describe "Aerospace" do
    it 'should extract data correctly' do
      extractor = AerospaceExtraction::CompanyExtractor.new
      metal = file_absolute_location(
        "/data/tanet/aerospace/metal.html")

        extractor.start(files: [metal])
        expect(extractor.return_triples).not_to be_empty
        expect(extractor.return_usdl).not_to be_empty
    end
  end

  describe "WAF1" do
    it 'should extract data correctly' do
      extractor = WAFExtraction1::CompanyExtractor.new
      waf1 = file_absolute_location(
        "/data/tanet/waf1/WAFData.xml")

        extractor.start(files: [waf1])
        expect(extractor.data.keys.size).to be >10
        expect(extractor.return_triples).not_to be_empty
        expect(extractor.return_usdl).not_to be_empty
    end
  end

  describe "WAF2" do
    it 'should extract data correctly' do
      extractor = WAFExtraction2::CompanyExtractor.new
      waf1 = file_absolute_location(
        "/data/tanet/waf2/GetXml.xml")

        extractor.start(files: [waf1])
        expect(extractor.return_triples).not_to be_empty
        expect(extractor.data["Yamada"]).not_to be_empty
        expect(extractor.return_usdl).not_to be_empty
    end
  end
end
