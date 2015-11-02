module Fitman
  class DBConnector

    def initialize()
    end

    def addNew(content,format)
      cv = Individuals.create()
      format_id = IndividualFormat.find_by(name: format).id
      Representation.create(content: content, format_id: format_id, individual_id: cv.id)
    end

    def addFormat(id,content,format)
      format_id = IndividualFormat.find_by(name: format).id
      Representation.create(content: content.to_s, format_id: format_id, individual_id: id)
    end

    def removeFormat(id,format_id)
      raise IOError
    end

    def remove(id)
      raise IOError
    end

    def update(id,content,format)
      cvrep = Representation.find_by format_id: format_id, individual_id: id
      format_id = IndividualFormat.find_by(name: format).id
      Representation.update(content: content, format_id: format_id)
    end

    def get(id,format)
      puts "DBCONNECTOR: get id: #{id} format: #{format}"
      format_id = IndividualFormat.find_by(name: format.to_s).id
      if id<0
        return nil
      end
      cvrep = Representation.find_by(format_id: format_id, individual_id: id )
      unless cvrep.nil?
        puts "cv rep: #{cvrep.content.to_s[0,50]} ..."
      end
      if cvrep == nil
        puts "was not found"
        return nil
      end

      return cvrep.content
    end
  end
end
