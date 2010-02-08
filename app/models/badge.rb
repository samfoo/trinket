class Badge < ActiveRecord::Base
  has_and_belongs_to_many :users
  validates_uniqueness_of :name
  validates_presence_of :name, :display_name

  def requirements_in_words 
    Trinket::Badges::Rules.const_get(name.camelize).requirements_in_words
  end

  def image_url
    # TODO: Different sizes
    APP_CONFIG["badge_images_url_root"] + name.underscore + ".jpg"
  end
end
