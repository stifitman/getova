module GeToVaLogger
  attr_accessor :log

  def init_logger
    @log = Logger.new(STDOUT)
  end
end

