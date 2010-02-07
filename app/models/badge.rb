class Badge < ActiveRecord::Base
  has_and_belongs_to_many :users
  validates_uniqueness_of :name
  validates_presence_of :name, :display_name

  def image_url
    APP_CONFIG["badge_images_url_root"] + name.underscore + ".jpg"
  end
end
