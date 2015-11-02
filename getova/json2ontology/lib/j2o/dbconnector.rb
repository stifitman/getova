class DBConnector

  def initialize()
    @data = Array.new
  end

  def data
    @data
  end

  def addNew(data,format)
    if format=="json"
      data = JSON.parse(data)
      data = JSON.pretty_generate(data)
    end
    newEntry = Hash.new
    newEntry[format] = data.to_s
    @data.push(newEntry)
    @data.length-1 #return "id"
  end

  def addFormat(id,data,format)
    @data[id][format] = data
  end

  def removeFormat(id,format)
    @data[id].delete(format)
  end

  def remove(id)
    @data[id].delete
  end

  def update(id,data,format)
    @data[id][format]=data
  end

  def get(id,format)
    if id<0
      return nil
    end
    if @data[id]==nil
      return nil
    end
    @data[id][format]
  end

end
