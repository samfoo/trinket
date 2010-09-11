require 'sequel' 

module Trinket
  module Database
    def self.connect(uri) 
      # TODO: Configurinateify this, also, probably shouldn't be relative. 
      const_set("DB", Sequel.sqlite(uri))
      Sequel::Model.db = DB

      # Migrate the database if necessary.
      Sequel.extension :migration
      Sequel::Migrator.apply(Trinket::Database::DB, File.join(File.dirname(__FILE__), '../../db/migrations'))
    end
  end
end

