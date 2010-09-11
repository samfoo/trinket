Sequel.migration do
  up do
    create_table(:badges) do
      primary_key :id
      String :name, :null => false

      index :name
    end

    create_table(:players) do
      primary_key :id
      String :name, :null => false

      index :name
    end

    create_table(:badges_players) do
      foreign_key :badge_id, :badges
      foreign_key :player_id, :players
    end
  end

  down do 
    drop_table(:badges_players)
    drop_table(:players)
    drop_table(:badges)
  end
end
