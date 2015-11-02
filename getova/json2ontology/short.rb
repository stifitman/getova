
require_relative 'lib/j2o'

puts "Running fitman sample program"

root = File.dirname(__FILE__)
DBCONNECTOR = DBConnector.new

files = Array.new
files.push(root+"/spec/fixtures/cvexample1.json")

files.each do |f|
  openfile = File.open(f, "r")
  puts "Loading #{f}"
  fcontent = openfile.read
  DBCONNECTOR.addNew(fcontent,"json")
  openfile.close
end

efh = EuropassFormatHandler.new(DBCONNECTOR,"http://fitman.sti2.at/base/")
converter = Converter.new(DBCONNECTOR, efh)

ep2resumefile = "EP2Resume.sparql"
ep2resume = File.open(ep2resumefile, "r")
ep2resumeConstruct = ep2resume.read
ep2resume.close

resume2epfile = "Resume2EP.sparql"
resume2ep = File.open(resume2epfile, "r")
resume2epConstruct = resume2ep.read
resume2ep.close

resume = ConverterFormatTransformation.new("resume",ep2resumeConstruct,resume2epConstruct)
converter.addFormat(resume)
efh.getAsRDF(0)

puts converter.get(0,'json')
puts converter.get(0,'rdf')
puts converter.get(0,"resume")
puts JSON.pretty_generate(converter.get(0,'jsonld'))
puts "Sample program exiting..."
