require 'sequel'

class Player < Sequel::Model
  many_to_many :badges
  one_to_many :events
  plugin :validation_helpers

  def validate
    super
    validates_presence :name
    validates_unique :name
  end

  def _add_badge(badge)
    values = {:player_id => id, :badge_id => badge.id, :created_at => Time.now}
    db[:badges_players].insert(values)
  end
end
