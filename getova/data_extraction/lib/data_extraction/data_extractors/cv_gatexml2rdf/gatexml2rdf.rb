require 'nokogiri'
require 'open-uri'
require 'rdf'
require 'rdf/ntriples'

# This script extracts data out of a gate xml
# annotated using the tags: desc, edu, skill and work

#adds triples to the rdf graph
def addTriple(subject,predicat,object)
  puts "Adding "  + subject.to_s + " " + predicat.to_s + " " + object.to_s
  if subject != nil and predicat != nil and object != nil
    @graph << [ subject, predicat, object]
  else
    puts "Tried to add nil tuple (but cancelled) : " + subject.to_s + " " + predicat.to_s + " " + object.to_s
  end
end

#############################################################
# Extract the person data
#############################################################
def extractPersonData()
  persons = @doc.xpath('//Annotation[@Type="Person"]/@StartNode')
  min = +1.0/0.0
  persons.each do |p|
    if p!=nil
      puts "person: #{p.content}"
      p = p.content.to_i
      if p < min
        min = p
        puts "#{min}"
      end
    end
  end

  person = @doc.xpath("//Annotation[@Type='Person' and @StartNode='#{min}']/Feature")

  firstname = person.xpath('Name[text()="firstName"]/../Value[text()]').first.content
  puts "firstname (#{firstname})"

  surname = person.xpath('Name[text()="surname"]/../Value[text()]').first.content
  puts "surname (#{surname})"

  gender = person.xpath('Name[text()="gender"]/../Value[text()]').first.content
  puts "gender (#{gender})"

  person = RDF::Node.new
  addTriple( person , RDF.type, @resume_cv.Person)
  addTriple( @cv , @resume_cv.aboutPerson, person)
  addTriple( person , RDF::FOAF.firstName, firstname)
  addTriple( person , RDF::FOAF.lastName, surname)
  addTriple( person , @resume_base.gender, gender)

end
#############################################################
# Parse command line
#############################################################
#TODO

def init()
  puts "parsing file\n\n"
  puts "Loading file: (#{ARGV[0]})"
  @doc = Nokogiri::XML(open(ARGV[0]))
  cvuri = "TEST_CV"
  @namespace = "htttp://sti2.at/test/"

  @resume_cv = RDF::Vocabulary.new("http://kaste.lv/~captsolo/semweb/resume/cv.rdfs#")
  @resume_base = RDF::Vocabulary.new("http://kaste.lv/~captsolo/semweb/resume/base.rdfs#")

  @graph = RDF::Graph.new
  @cv = RDF::URI.new(@namespace + cvuri)
  addTriple(@cv, RDF.type, @resume_cv.CV)
end

def extractSkillData()
  nodes = @doc.xpath('//Annotation[@Type="skill"]')
  #  puts "skill #{nodes}"
  nodes.each do |node|
    startNode = node.xpath('@StartNode')
    endNode = node.xpath('@EndNode')
    skillName = ""
    for i in startNode.first.content..endNode.first.content
      @doc.xpath("//Node[@id='#{i}']").each do |curNode|
        skillName += curNode.next
      end
    end
    skill = RDF::Node.new
    addTriple(skill, RDF.type, @resume_cv.Skill)
    addTriple(@cv,@resume_cv.hasSkill, skill)
    addTriple(skill,@resume_cv.skillName, skillName )
  end
end
#############################################################
# Extract the other info related data
#############################################################
def getNodesInRange(type,startPos,endPos)
  nodes = Array.new
  puts "get nodes in #{startPos} - - #{endPos} of #{type}"
  #get all related nodes inbetween
  potentialInbetweenNodes = @doc.xpath("//Annotation[@Type='#{type}']")

  potentialInbetweenNodes.each do |node|
    startNode = node.xpath('@StartNode').first.content
    endNode = node.xpath('@EndNode').first.content

    if startNode >= startPos and endNode <= endPos
      content = ""
      for i in startNode..endNode
        @doc.xpath("//Node[@id=#{i}]").each do |curNode|
          content += curNode.next unless curNode.next.nil?
        end
      end
      nodes.push(content)
    end

  end
  nodes
end
#
#############################################################
# Extract the  education  related data
#############################################################
def extractEducation()

  type = "edu"

  nodes = @doc.xpath("//Annotation[@Type='#{type}']")
  nodes.each do |node|
    startNode = node.xpath('@StartNode').first.content
    endNode = node.xpath('@EndNode').first.content

    eduDesc = getNodesInRange("desc",startNode,endNode).first
    orgName = getNodesInRange("Organization",startNode,endNode).first

    eduName = ""
    for i in startNode..endNode
      @doc.xpath("//Node[@id='#{i}']").each do |curNode|
        eduName += curNode.next unless curNode.next.nil?
      end
    end

    education = RDF::Node.new
    addTriple( education , RDF.type, @resume_cv.Education)
    addTriple(@cv, @resume_cv.hasEducation, education)
    organisation = RDF::Node.new
    addTriple(@cv, @resume_cv.studiedIn, organisation)
    addTriple(organisation, @resume_cv.Name, orgName)
    addTriple(organisation, RDF.type, @resume_cv.EducationalOrg)
    addTriple(education, @resume_cv.Notes, eduDesc)
  end
end
#############################################################
# Extract the workhistory or education  related data
#############################################################
def extractWorkHistory()
  type = "work"

  nodes = @doc.xpath("//Annotation[@Type='#{type}']")
  nodes.each do |node|
    startNode = node.xpath('@StartNode').first.content
    endNode = node.xpath('@EndNode').first.content

    eduDesc = getNodesInRange("desc",startNode,endNode).first
    orgName = getNodesInRange("Organization",startNode,endNode).first

    eduName = ""
    for i in startNode..endNode
      @doc.xpath("//Node[@id='#{i}']").each do |curNode|
        eduName += curNode.next
      end
    end

    workhistory = RDF::Node.new
    addTriple( workhistory , RDF.type, @resume_cv.WorkHistory)
    addTriple(@cv, @resume_cv.hasWorkHistory, workhistory)
    company = RDF::Node.new
    addTriple(@cv, @resume_cv.employedIn, company)
    addTriple(company, @resume_cv.Name, orgName)
    addTriple(company, RDF.type, @resume_cv.Company)
    addTriple(workhistory, @resume_cv.jobDescription, eduDesc)
    addTriple(workhistory, @resume_cv.jobDescription, eduDesc)
  end
end
#############################################################
# Save the created triples inside a file
#############################################################
def storeTriplesToFile()
  puts @graph.dump(:ntriples)
  puts "finished parsing ###############\n\n\n"
end

#############################################################
# Run the program to
#############################################################
init()
extractPersonData()
extractSkillData()
extractEducation()
extractWorkHistory()
storeTriplesToFile()
