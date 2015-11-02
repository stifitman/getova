require "spec_helper"
require "dbconnector_helper"

describe EuropassFormatHandler do
  before(:each) do
    @db = TestDBConnector.setUpDB
    @efh = EuropassFormatHandler.new(@db,"http://fitman.sti2.at/base/")
    #  @efh.setJSONSchema()
    @root = File.dirname(__FILE__)
  end

  it "should create xml out of json" do
    @efh.get(0,'xml').should_not eq(nil)
  end

  it "should return a cv as json" do
    @efh.get(0,'json').should_not eq(nil)
    @efh.get(5,'json').should eq(nil)
    @efh.get(-1,'json').should eq(nil)
  end

  it "should assure that the json and the rdf contains the same informaion"

  it "should create jsonld out of json" do
    @efh.get(0,'jsonld').should_not eq(nil)
  end


  it "should create json out of xml" do
    @efh.get(0,'json').should_not eq(nil)
    @efh.get(0,'xml').should_not eq(nil)
    @db.removeFormat(0,'json')
    @efh.get(0,'json').should_not eq(nil)


    @efh.get(1,'json').should_not eq(nil)
    @efh.get(1,'xml').should_not eq(nil)
    @db.removeFormat(1,'json')
    @efh.get(1,'json').should_not eq(nil)
  end

  it "should create json out of jsonld" do
    @efh.get(0,'json').should_not eq(nil)
    @efh.get(0,'jsonld').should_not eq(nil)
    @db.removeFormat(0,"json")
    @efh.get(0,'json').should_not eq(nil)

    @efh.get(1,'json').should_not eq(nil)
    @efh.get(1,'jsonld').should_not eq(nil)
    @db.removeFormat(1,"json")
    @efh.get(1,'json').should_not eq(nil)
  end

  it "should create xml out of jsonld" do
    @efh.get(0,'jsonld').should_not eq(nil)
    @db.removeFormat(0,'json')
    xml = @efh.get(0,'xml')
    xml.should_not eq(nil)


    @efh.get(1,'jsonld').should_not eq(nil)
    @db.removeFormat(1,'json')
    xml = @efh.get(1,'xml')
    xml.should_not eq(nil)
  end

  it "should create xml out of json" do
    @efh.get(0,'xml').should_not eq(nil)
  end

  it "should create json out of rdf" do
    @efh.get(0,'json').should_not eq(nil)
    @efh.get(0,'rdf').should_not eq(nil)
    @db.removeFormat(0,"json")
    @db.removeFormat(0,"jsonld")
    @efh.get(0,'json').should_not eq(nil)

    @efh.get(1,'json').should_not eq(nil)
    @efh.get(1,'rdf').should_not eq(nil)
    @db.removeFormat(1,"json")
    @db.removeFormat(1,"jsonld")
    @efh.get(1,'json').should_not eq(nil)
  end


  it "should create rdf out of json" do
    @efh.get(0,'rdf').should_not eq(nil)
    @efh.get(1,'rdf').should_not eq(nil)
    @efh.get(2,'rdf').should_not eq(nil)
    @efh.get(3,'rdf').should_not eq(nil)
    @efh.get(5,'rdf').should eq(nil)
    @efh.get(-1,'rdf').should eq(nil)
  end

  it "should create rdf out of jsonld" do
    @efh.get(0,'json').should_not eq(nil)
    @efh.get(0,'jsonld').should_not eq(nil)
    @db.removeFormat(0,"json")
    @efh.get(0,'rdf').should_not eq(nil)

    @efh.get(1,'json').should_not eq(nil)
    @efh.get(1,'jsonld').should_not eq(nil)
    @db.removeFormat(1,"json")
    @efh.get(1,'rdf').should_not eq(nil)
  end

  it "should create rdf out of xml" do
    @efh.get(0,'json').should_not eq(nil)
    @efh.get(0,'xml').should_not eq(nil)
    @db.removeFormat(0,"json")
    @db.removeFormat(0,"jsonld")
    @efh.get(0,'rdf').should_not eq(nil)

    @efh.get(1,'json').should_not eq(nil)
    @efh.get(1,'xml').should_not eq(nil)
    @db.removeFormat(1,"json")
    @db.removeFormat(1,"jsonld")
    @efh.get(1,'rdf').should_not eq(nil)
  end


  it "should create xml out of rdf" do
    @efh.get(0,'json').should_not eq(nil)
    @efh.get(0,'rdf').should_not eq(nil)
    @db.removeFormat(0,"json")
    @db.removeFormat(0,"jsonld")
    @efh.get(0,'xml').should_not eq(nil)

    @efh.get(1,'json').should_not eq(nil)
    @efh.get(1,'rdf').should_not eq(nil)
    @db.removeFormat(1,"json")
    @db.removeFormat(1,"jsonld")
    @efh.get(1,'xml').should_not eq(nil)
  end

  it "should create jsonld out of rdf" do
    @efh.get(0,'json').should_not eq(nil)
    @efh.get(0,'rdf').should_not eq(nil)
    @db.removeFormat(0,"json")
    @db.removeFormat(0,"jsonld")
    @efh.get(0,'jsonld').should_not eq(nil)

    @efh.get(1,'json').should_not eq(nil)
    @efh.get(1,'rdf').should_not eq(nil)
    @db.removeFormat(1,"json")
    @db.removeFormat(1,"jsonld")
    @efh.get(1,'jsonld').should_not eq(nil)
  end

  it "should create jsonld out of xml" do
    @efh.get(0,'xml').should_not eq(nil)
    @db.removeFormat(0,'json')
    @efh.get(0,'jsonld').should_not eq(nil)

    @efh.get(1,'xml').should_not eq(nil)
    @db.removeFormat(1,'json')
    @efh.get(1,'jsonld').should_not eq(nil)
  end

  it "should validate json with the jsonschema"

end
