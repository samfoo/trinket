class Event < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id
  validates_inclusion_of :name, 
    :in => %w(create status priority), 
    :message => "Unknown event name '{{value}}'"

  def email=(email)
    self.user = User.find_by_email(email)
  end
end
