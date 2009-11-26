class AddUniqueIndexToUsersEmail < ActiveRecord::Migration
  def self.up
    add_index :users, :email, :name => :email_unique, :unique => true
  end

  def self.down
    remove_index :users, :email_unique
  end
end
