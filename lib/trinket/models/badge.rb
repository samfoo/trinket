require 'sequel'

class Badge < Sequel::Model
  many_to_many :players, :uniq => true

  def validate
    super
    validates_presence :name
    validates_unique :name
  end

  def _add_player(player)
    values = {:player_id => player.id, :badge_id => id, :created_at => Time.now}
    db[:badges_players].insert(values)
  end
end
