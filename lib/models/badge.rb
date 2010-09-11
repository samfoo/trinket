require 'sequel'

class Badge < Sequel::Model
  many_to_many :players
end
