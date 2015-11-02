class AboutController < ActionController::Base
   layout 'application'

  def index
    creator = TestDataCreator.new
    creator.generate
    @example_file = creator.json
    render :index
  end


end
