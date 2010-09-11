require 'sequel'

class Badge < Sequel::Model
  many_to_many :players, :uniq => true

  set_schema do
    primary_key :id
    String :name, :null => false

    unique :name
    index :name
  end

  create_table unless table_exists?

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
