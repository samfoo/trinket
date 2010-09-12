require 'sequel'

class Event < Sequel::Model
  many_to_one :player

  def before_create
    self.created_at ||= Time.now
    super
  end
end
