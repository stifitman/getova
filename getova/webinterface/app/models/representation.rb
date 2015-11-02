class Representation < ActiveRecord::Base
  belongs_to :individual
  validates :individual_id, presence: true
  validates :format_id , presence: true
end
