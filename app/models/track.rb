class Track < ActiveRecord::Base
  has_and_belongs_to_many :mixtapes
end
