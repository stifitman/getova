require "spec_helper"

module TestDBConnector

  def TestDBConnector.setUpDB
    root = File.dirname(__FILE__)
    dbconnector = DBConnector.new
    files = Array.new
    files.push(root+"/fixtures/cvexample1.json")

    resume_triples = Array.new
    resume_triples.push(root+"/fixtures/person_resume.ntriple")

    files.each do |f|
      openfile = File.open(f, "r")
      fcontent = openfile.read
      dbconnector.addNew(fcontent,"json")
      openfile.close
    end


    creator = TestDataCreator.new

    4.times do
      creator.generate
      dbconnector.addNew(creator.json, 'json')
    end

    resume_triples.each do |f|
      openfile = File.open(f, "r")
      fcontent = openfile.read
      dbconnector.addNew(fcontent,"resume")
      openfile.close
    end

    dbconnector
  end
end
