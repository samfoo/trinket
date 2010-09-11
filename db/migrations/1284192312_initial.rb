Sequel.migration do
  up do
    create_table(:badges) do
      primary_key :id
      String :name, :null => false

      unique :name
      index :name
    end

    create_table(:players) do
      primary_key :id
      String :name, :null => false

      unique :name
      index :name
    end

    create_table(:badges_players) do
      foreign_key :badge_id, :badges
      foreign_key :player_id, :players
      #Time :created_at, :null => false
    end

    create_table(:events) do
      primary_key :id
      String :type, :null => false
      Time :created_at, :null => false

      foreign_key :player_id, :players

      index :type
      index :player_id
    end
  end

  down do 
    drop_table(:events)
    drop_table(:achievements)
    drop_table(:players)
    drop_table(:badges)
  end
end
