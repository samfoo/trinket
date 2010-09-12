require 'sequel' 

module Trinket
  module Database
    DB = Sequel.sqlite(":memory:")
    Sequel::Model.db = DB
    Sequel::Model.plugin :validation_helpers

    def self.connect(path) 
      remove_const("DB")
      const_set("DB", Sequel.sqlite(path))
      Sequel::Model.db = DB
      self.init
    end

    def self.init
      DB.create_table :players do
        primary_key :id
        String :name, :null => false

        unique :name
        index :name
      end unless DB.table_exists?(:players)

      DB.create_table :badges do
        primary_key :id
        String :name, :null => false

        unique :name
        index :name
      end unless DB.table_exists?(:badges)

      DB.create_table :events do
        primary_key :id
        String :name, :null => false
        Integer :value, :null => false
        Time :created_at, :null => false

        foreign_key :player_id, :players

        index :name
        index :player_id
      end unless DB.table_exists?(:events)

      DB.create_table :badges_players do
        foreign_key :badge_id, :badges, :null => false
        foreign_key :player_id, :players, :null => false
        Time :created_at, :null => false
      end unless DB.table_exists?(:badges_players)
    end

    init

    models = File.join(File.dirname(__FILE__), 'models')
    Dir[File.join(models, '*.rb')].each do |model| 
      require File.join(models, File.basename(model))
    end

  end
end

