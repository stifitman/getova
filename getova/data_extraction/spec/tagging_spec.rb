require 'spec_helper'

describe "tagging" do

  it 'should be includable into a class' do
     class A
       include Tagger
     end
     a = A.new
     expect {a.init_tags}.to_not raise_error
  end

end
