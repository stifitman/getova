require "spec_helper"

describe DBConnector do

  before(:each) do
    @db = DBConnector.new
  end

  it "db should be empty at initialisitation" do
    @db.data.length.should eq(0)
  end

  it "should return nil for non exsiting data" do
    @db.get(-1,"something").should eq(nil)
  end

  it "should return stored data formats" do
    id1 = @db.addNew("somedata","rdf")
    id2 = @db.addNew("otherdata","xml")
    id3 = @db.addNew("test","rdf")


    @db.get(id1,"rdf").should eq("somedata")
    @db.get(id1,"xml").should eq(nil)

    @db.addFormat(id1,"otherdata","xml")
    @db.get(id1,"xml").should eq("otherdata")
    @db.get(id2,"xml").should eq("otherdata")
    @db.get(id3,"rdf").should eq("test")
  end

  it "should update data"

  it "should remove stored data formats"

  it "should remove stored data"

  it "should add formats to existing data"

end
