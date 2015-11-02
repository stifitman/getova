require "spec_helper"
require "dbconnector_helper"
require 'json'
require 'json-schema'
require 'json-generator'

describe Converter do

  before(:each) do
    @db = TestDBConnector.setUpDB
    efh = EuropassFormatHandler.new(@db,"http://fitman.sti2.at/base/")
    @converter = Converter.new(@db,efh)

    ep2resumefile = "EP2Resume.sparql"
    ep2resume = File.open(ep2resumefile, "r")
    ep2resumeConstruct = ep2resume.read
    ep2resume.close

    resume2epfile = "Resume2EP.sparql"
    resume2ep = File.open(resume2epfile, "r")
    resume2epConstruct = resume2ep.read
    resume2ep.close
    resume = ConverterFormatTransformation.new("resume",ep2resumeConstruct,resume2epConstruct)
    @converter.addFormat(resume)
  end

  it "should create resume out of base" do
    @converter.get(0,"resume")
    @converter.get(0,"resume").class.should eq(String)
    @converter.get(0,"resume").length.should > 100
  end

  it "should create json out of resume" do
    @converter.get(0,"resume")
    @db.removeFormat(0,"rdf")
    @db.removeFormat(0,"json")
    @db.removeFormat(0,"jsonld")

    @converter.get(0,"json").class.should eq(String)
    @converter.get(0,"json").length.should > 100
  end

  it "should work for generated resume of the data extractor" do
    puts  "resume:  #{@converter.get(5,"resume")}"
    puts  "rdf:  #{@converter.get(5,"rdf")}"
  end

  it "should create base out of resume" do
    @converter.get(0,"resume").class.should eq(String)
    @converter.get(0,"resume").length.should > 100

    @db.removeFormat(0,"rdf")
    @db.removeFormat(0,"json")
    @db.removeFormat(0,"jsonld")

    @converter.get(0,"rdf").class.should eq(String)
    @converter.get(0,"rdf").length.should > 100

    puts "USING GENERATED PERSONS!"
    resume = @converter.get(1,"resume")
    puts "RESUME #{resume}"
    @converter.get(1,"resume").class.should eq(String)
    @converter.get(1,"resume").length.should > 100

    @db.removeFormat(1,"rdf")
    @db.removeFormat(1,"json")
    @db.removeFormat(1,"jsonld")

    base = @converter.get(1,'rdf')
    puts "base: #{base}"
    @converter.get(1,"rdf").class.should eq(String)
    @converter.get(1,"rdf").length.should > 100
  end
end
