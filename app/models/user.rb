class User < ActiveRecord::Base
  acts_as_authentic 

  has_and_belongs_to_many :badges
  has_many :events
  validates_uniqueness_of :email
  validates_presence_of :first_name, :last_name

  def full_name
    first_name + " " + last_name
  end

  def has_achieved?(badge, options={})
    Trinket::Badges.has_achieved?(self, badge, options)
  end
end
