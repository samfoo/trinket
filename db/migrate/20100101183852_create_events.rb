class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events, :id => false do |t|
      t.string :name, :null => false
      t.string :value
      t.string :entity_id
      t.integer :user_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
