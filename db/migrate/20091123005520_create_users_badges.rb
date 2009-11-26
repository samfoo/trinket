class CreateUsersBadges < ActiveRecord::Migration
  def self.up
    create_table :badges_users, :id => false do |t|
      t.integer :user_id
      t.integer :badge_id
      t.timestamps
    end
  end

  def self.down
    drop_table :badges_users
  end
end
