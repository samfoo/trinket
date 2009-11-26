class AddUniqueIndexToBadgesName < ActiveRecord::Migration
  def self.up
    add_index :badges, :name, :name => :name_unique, :unique => true
    add_index :badges, :display_name, :name => :display_name_unique, :unique => true
  end

  def self.down
    remove_index :badges, :name_unique
  end
end
