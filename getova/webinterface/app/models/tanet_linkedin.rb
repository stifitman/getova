class TanetLinkedin < ActiveRecord::Base
  validate :data, uniqueness: true
end
