require 'sequel'

class Event < Sequel::Model
  many_to_one :player

  set_schema do
    primary_key :id
    String :name, :null => false
    Integer :value, :null => false
    Time :created_at, :null => false

    foreign_key :player_id, :players

    index :name
    index :player_id
  end

  create_table unless table_exists?

  def before_create
    self.created_at ||= Time.now
    super
  end
end
