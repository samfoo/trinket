require 'sequel'

class Badge < Sequel::Model
  many_to_many :players, :left_key => :badge_id, :right_key => :player_id
end
