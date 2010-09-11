require 'sequel'

class Player < Sequel::Model
  many_to_many :badges
end
