require 'sequel' 

module Trinket
  module Database
    def self.connect(uri) 
      const_set("DB", Sequel.sqlite(uri))
      Sequel::Model.db = DB
      Sequel::Model.plugin :validation_helpers 
      Sequel::Model.plugin :schema

      models = File.join(File.dirname(__FILE__), 'models')
      Dir[File.join(models, '*.rb')].each do |model| 
        require File.join(models, File.basename(model))
      end

      if !DB.table_exists?(:badges_players)
        DB.create_table :badges_players do
          foreign_key :badge_id, :badges, :null => false
          foreign_key :player_id, :players, :null => false
          Time :created_at, :null => false
        end
      end
    end
  end
end

