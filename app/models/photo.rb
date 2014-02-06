class Photo < ActiveRecord::Base
  
  validates :image_url, presence: true

  belongs_to :user
  
end
