class BadgesModel < ActiveRecord::Migration
  def self.up
    create_table :badges do |t|
      t.string :name
      t.string :display_name
      t.text :description
      t.timestamps 
    end
  end

  def self.down
    drop_table :badges
  end
end
