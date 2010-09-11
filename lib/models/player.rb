require 'sequel'

class Player < Sequel::Model
  many_to_many :badges, :left_key => :player_id, :right_key => :badge_id
end
