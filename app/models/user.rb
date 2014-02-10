class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  has_one :mixtape
  has_many :photos
  has_many :sent_messages, :class_name => "Message", :foreign_key => "author_id"
  has_many :received_messages, :class_name => "Message", :foreign_key => "recipient_id"


  def self.find_for_facebook_oauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      unless user.persisted?
        new_user = user.profile_assignment(auth)
        new_user.save!
        new_user.profile_photo_assignment
        new_user.recent_photo_assignment
      end
    end
  end

  def profile_assignment(auth)
    self.provider = auth.provider
    self.uid = auth.uid
    self.email = auth.info.email
    self.password = Devise.friendly_token[0,20]
    self.name = auth.info.name
    self.birthday = auth.extra.raw_info.birthday
    self.location = auth.info.location
    self.auth_token = auth.credentials.token
    self.male = (auth.extra.raw_info.gender == 'male' ? true : false)
    self
  end

  def profile_photo_assignment
    profile_pictures.each_with_index do |profile_photo, index|
      new_photo = self.photos.create
      new_photo.image_url = profile_photo
      index < 5 ? new_photo.profile_picture = true : nil
      new_photo.save!
    end
  end

  def recent_photo_assignment
    tagged_pictures.each do |tagged_picture|
      new_photo = self.photos.create
      new_photo.image_url = tagged_picture
      new_photo.save!
    end
  end

  def profile_pictures
    # raise self.inspect
    graph = Koala::Facebook::API.new(self.auth_token)
    profile_album = []
    graph.get_connections("me", "albums").each do |album|
      album['name'] == 'Profile Pictures' ?  (profile_album << album) : nil
     end
    profile_photos = graph.get_connections("#{profile_album[0]['id']}", 'photos')
    profile_photos.map { |photo| photo['images'][0]['source']}
  end

  def tagged_pictures
    graph = Koala::Facebook::API.new(self.auth_token)
    albums = graph.get_connections("me", "photos")
    albums.map {|image| image['source']}
  end

  def age
    dob = self.birthday
    day, month, year = dob.slice(3,2), dob.slice(0,2), dob.slice(6,4)
    dob = Time.new( year, month, day )
    ((Time.now - dob)/(60*60*24*365)).floor
  end 

  def music_likes
    graph = Koala::Facebook::API.new(self.auth_token)
    music_profile = graph.get_connections("me", "music")
    music_profile.each do |musician|
      puts musician['name']
    end
  end


  def update_with_password(params, *options)
    update_attributes(params, *options)
  end

end
