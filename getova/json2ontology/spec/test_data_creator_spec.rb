require "spec_helper"


describe TestDataCreator do

  it "should create resume and a a related json" do
    creator = TestDataCreator.new
    10.times do
    creator.generate
    puts creator.resume
    puts creator.json
    creator.json.should_not eq(nil)
    creator.resume.should_not eq(nil)
    end
  end

end
