require_relative 'lib/j2o'

puts "Running fitman sample program"

root = File.dirname(__FILE__)
DBCONNECTOR = DBConnector.new

files = Array.new
files.push(root+"/spec/fixtures/cvexample1.json")
#files.push(root+"/spec/fixtures/cvexample2.json")
#files.push(root+"/spec/fixtures/cvexample3.json")
#files.push(root+"/spec/fixtures/cvexample4.json")
#files.push(root+"/spec/fixtures/cvexample5.json")

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
#efh.getAsRDF(1)
#efh.getAsRDF(2)
#efh.getAsRDF(3)
#efh.getAsRDF(4)


running = true

while (running) do

 # puts "Enter id or -1 to exit"
 # count = 0
 # files.each do |f|
 #   puts "id: #{count} -> #{f}"
 #   count += 1
 # end
 # id = gets.chomp.to_i

 # if id<= -1
 #   puts "Entered #{id.to_s} --> Exit program"
 #   running = false
 #   break
 # end
id = 0
  puts "Choose format \n1: json,\n2: rdf,\n3: resume,\n4: jsonld"
  format = gets.chomp

   if format.to_i == 1 then
     puts converter.get(id,'json')
   elsif format.to_i == 2 then
     puts converter.get(id,'rdf')
   elsif format.to_i == 3 then
     puts converter.get(id,"resume")
   elsif format.to_i == 4 then
     puts JSON.pretty_generate(converter.get(id,'jsonld'))
   elsif format.to_i == 5 then
     puts converter.get(id, 'xml')
   else
     puts "Format not know"
   end
end

puts "Sample program exiting..."
