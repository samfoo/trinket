class Badge < ActiveRecord::Base
  has_and_belongs_to_many :users
  validates_uniqueness_of :name
  validates_presence_of :name, :display_name
end
