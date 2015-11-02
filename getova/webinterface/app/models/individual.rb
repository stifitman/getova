class Individual < ActiveRecord::Base
  has_many :representations
  validates_uniqueness_of :name
end
