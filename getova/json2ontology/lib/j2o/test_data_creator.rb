require 'net/http'
require 'rubygems'
require 'json-schema'
require 'faker'

class  TestDataCreator

  def initialize()
    @json = nil
    @resume = nil
  end

  def json
    @json.to_json
  end

  def resume
    @graph
  end

  def generate()
    @json = Hash.new

    firstname = Faker::Name.first_name
    setJSONField(["SkillsPassport","LearnerInfo","Identification","PersonName","FirstName"],firstname )
    surname = Faker::Name.last_name
    setJSONField(["SkillsPassport","LearnerInfo","Identification","PersonName","Surname"],surname )

    addressLine = Faker::Address.street_address
    setJSONField(["SkillsPassport","LearnerInfo","Identification","ContactInfo","Address", "Contact","AddressLine"],addressLine )
    postalCode = Faker::Address.postcode
    setJSONField(["SkillsPassport","LearnerInfo","Identification","ContactInfo","Address", "Contact","PostalCode"],postalCode )
    municipality = Faker::Address.city
    setJSONField(["SkillsPassport","LearnerInfo","Identification","ContactInfo","Address", "Contact","Municipality"],municipality )
    countryCode = Faker::Address.country_code
    setJSONField(["SkillsPassport","LearnerInfo","Identification","ContactInfo","Address", "Contact","Country","Code"],countryCode )
    countryLabel = Faker::Address.country
    setJSONField(["SkillsPassport","LearnerInfo","Identification","ContactInfo","Address", "Contact","Country","Label"],countryLabel )
    birthYear = Faker::Date.birthday(25,50).year
    setJSONField(["SkillsPassport","LearnerInfo","Identification","Demographics", "Birthdate","Year"],birthYear )
    birthMonth = Faker::Date.birthday(25,50).month
    setJSONField(["SkillsPassport","LearnerInfo","Identification","Demographics", "Birthdate","Month"],birthMonth )
    birthDay = Faker::Date.birthday(25,50).day
    setJSONField(["SkillsPassport","LearnerInfo","Identification","Demographics", "Birthdate","Day"],birthDay )

    gender = rand(10) > 5 ? 'male' : 'female'
    setJSONField(["SkillsPassport","LearnerInfo","Identification","Demographics", "Gender","Label"],gender )

    resume_cv = RDF::Vocabulary.new("http://kaste.lv/~captsolo/semweb/resume/cv.rdfs#")
    resume_base = RDF::Vocabulary.new("http://kaste.lv/~captsolo/semweb/resume/base.rdfs#")

    @graph = RDF::Graph.new

    cv = RDF::URI.new(@namespace)
    addTriple(  cv, RDF.type, resume_cv.CV)

    workexperiences = Array.new

    (rand(4) + 2).times do |e|

          w = Hash.new
          fromYear = Faker::Date.birthday(25,50).year
          setJSONField2(["Period","From","Year"],w,fromYear)

          fromMonth = Faker::Date.birthday(25,50).month
          setJSONField2(["Period","From","Month"],w,fromMonth )

          toYear = Faker::Date.birthday(25,50).year
          setJSONField2(["Period","To","Year"],w,toYear )
          toMonth = Faker::Date.birthday(25,50).month
          setJSONField2(["Period","To","Month"],w,toMonth )

          current = 'false'
          setJSONField2(["Period","Current"],w,current )

          position = Faker::Name.title
          setJSONField2(["Position","Label"],w,position )

          activity = Faker::Company.bs
          setJSONField2(["Activities"],w,activity )
          sector = Faker::Commerce.department
          setJSONField2(["Sector"],w,sector )

          employerName = Faker::Company.name
          setJSONField2(["Employer","Name"],w,employerName )

          employerContactAddressLine = Faker::Address.street_address
          setJSONField2(["Employer","ContactInfo","Address","Contact","AddressLine"],w,employerContactAddressLine )

          employerContactPostalCode = Faker::Address.postcode
          setJSONField2(["Employer","ContactInfo","Address","Contact","PostalCode"],w,employerContactPostalCode )

          employerContactMunicipality = Faker::Address.city
          setJSONField2(["Employer","ContactInfo","Address","Contact","Municipality"],w,employerContactMunicipality )

          employerContactCountry = Faker::Address.country
          setJSONField2(["Employer","ContactInfo","Address","Contact","Country","Label"],w,employerContactCountry )

          workhistory = RDF::Node.new
          addTriple( workhistory , RDF.type, resume_cv.WorkHistory)
          addTriple(cv, resume_cv.hasWorkHistory, workhistory)

          company = RDF::Node.new
          addTriple(company, RDF.type, resume_cv.Company)
          addTriple(company, resume_cv.Name, employerName)
          addTriple(company, resume_cv.Country, employerContactCountry)
          addTriple(company, resume_cv.Locality, employerContactMunicipality)

          addTriple(workhistory, resume_cv.employedIn, company)
          addTriple(workhistory, resume_cv.startDate, fromMonth.to_s + " " + fromYear.to_s) #TODO: formating?
          addTriple(workhistory, resume_cv.endData, toMonth.to_s + " " + toYear.to_s ) #

          addTriple(workhistory, resume_cv.isCurrent, current.to_s=="true")

          addTriple(workhistory, resume_cv.jobType, position)
          addTriple(workhistory, resume_cv.jobDescription , activity)
          workexperiences << w
        end


    setJSONField(["SkillsPassport","LearnerInfo","WorkExperience"],workexperiences)
    #    educations = setJSONField(["SkillsPassport","LearnerInfo","Education"],educations )
    #
    #    educations.each do |w|
    #
    #      education = RDF::Node.new
    #      addTriple(education, RDF.type, resume_cv.Education)
    #      addTriple(cv, resume_cv.hasEducation, education)
    #
    #      fromYear = setJSONField2(["Period","From","Year"],w,fromYear )
    #      fromMonth = setJSONField2(["Period","From","Month"],w,fromMonth )
    #      toYear = setJSONField2(["Period","To","Year"],w,toYear )
    #      toMonth = setJSONField2(["Period","To","Month"],w,toMonth )
    #
    #      organisationName = setJSONField2(["Organisation","Name"],w,organisationName )
    #      organisationContactAddressLine = setJSONField2(["Organisation","ContactInfo","Address","Contact","AddressLine"],w,organisationContactAddressLine )
    #      organisationContactPostalCode = setJSONField2(["Organisation","ContactInfo","Address","Contact","PostalCode"],w,organisationContactPostalCode )
    #      organisationContactMunicipality = setJSONField2(["Organisation","ContactInfo","Address","Contact","Municipality"],w,organisationContactMunicipality )
    #      organisationContactCountry = setJSONField2(["Organisation","ContactInfo","Address","Contact","Country","Label"],w,organisationContactCountry )
    #
    #      title = setJSONField2(["Title"],w,title )
    #      activity = setJSONField2(["Activities"],w,activity )
    #
    #      addTriple(education, resume_cv.eduStartDate, fromMonth.to_s + " " + fromYear.to_s) #TODO: formating?
    #      addTriple(education, resume_cv.eduGradDate, toMonth.to_s + " " + toYear.to_s ) #TODO: eduGradDate not correct here
    #      addTriple(education, resume_cv.degreeType, title)
    #      addTriple(education, resume_cv.eduDescription, activity)
    #
    #      organisation = RDF::Node.new
    #      addTriple(organisation, RDF.type, resume_cv.EducationalOrg)
    #      addTriple(education, resume_cv.studiedIn, organisation)
    #
    #      addTriple(organisation, resume_cv.Name, organisationName)
    #      addTriple(organisation, resume_cv.Country, organisationContactCountry)
    #      addTriple(organisation, resume_cv.Locality, organisationContactMunicipality)
    #
    #    end
    #
    #    skills = setJSONField(["SkillsPassport", "LearnerInfo", "Skills"],skills )
    #
    #    linguistic = setJSONField2(["Linguistic"],skills,linguistic )
    #
    #    mothertongues = setJSONField2(["MotherTongue"],linguistic,mothertongues )
    #
    #    mothertongues.each do |m|
    #      mothertongue = RDF::Node.new
    #      addTriple(mothertongue, RDF.TYPE,resume_cv.LanguageSkill)
    #      addTriple(cv, resume_cv.hasSkill, mothertongue)
    #
    #      skillName = setJSONField2(["Description","Label"], m,skillName )
    #      addTriple(mothertongue, resume_cv.skillName, skillName)
    #      addTriple(mothertongue, resume_cv.skillLevel, "Mothertongue")
    #    end
    #
    #    foreignlanguages = setJSONField2(["ForeignLanguage"],linguistic,foreignlanguages )
    #
    #    foreignlanguages.each do |f|
    #      foreignlanguage = RDF::Node.new
    #      addTriple(foreignlanguage, RDF.TYPE,resume_cv.LanguageSkill)
    #      addTriple(cv, resume_cv.hasSkill, foreignlanguage)
    #
    #      skillName = setJSONField2(["Description","Label"], f,skillName )
    #      addTriple(foreignlanguage, resume_cv.skillName, skillName)
    #
    #      proficiencylevel = setJSONField2(["ProficiencyLevel"],f,proficiencylevel )
    #      addTriple(foreignlanguage, resume_cv.skillLevel,proficiencylevel.to_s ) #TODO not realy supported in resumee...
    #    end
    #
    #    skills.each do |k,v|
    #      if k!="Linguistic"
    #        otherInfo = RDF::Node.new
    #        addTriple(otherInfo, RDF.TYPE,resume_cv.OtherInfo)
    #        addTriple(cv, resume_cv.otherInfoType, otherInfo)
    #
    #        description = setJSONField2(["Description"], v,description )
    #
    #        addTriple(otherInfo, resume_cv.otherInfoDescription, k.to_s + " "+ description.to_s)
    #      end
    #    end


    person = RDF::Node.new
    addTriple( person , RDF.type, resume_cv.Person)
    addTriple( cv , resume_cv.aboutPerson, person)
    addTriple( person , RDF::FOAF.firstName, firstname)
    addTriple( person , RDF::FOAF.lastName, surname)
    addTriple( person , resume_base.SexProperty, gender) #todo what is resume_base?
    addTriple( person, resume_cv.hasDriversLicense , false) #todo
  end


  def setJSONField(accessorList, insert)
    setJSONField2(accessorList,nil,insert)
  end

  def setJSONField2(accessorList,json, insert)

    if json.nil?
      json = @json
    end

    lastkey = accessorList.last

    unless accessorList.length == 1
      accessorList.delete_at(accessorList.length-1)

      accessorList.each do |k|
        if json[k].nil?
          json[k] = Hash.new
        end
        json = json[k]
      end
    end
    json[lastkey] = insert
  end

  def addTriple(subject,predicat,object)
    if subject != nil and predicat != nil and object != nil
      @graph << [ subject, predicat, object]
    else
      puts "Tried to add nil tuple (but cancelled) : " + subject.to_s + " " + predicat.to_s + " " + object.to_s
    end
  end

end
