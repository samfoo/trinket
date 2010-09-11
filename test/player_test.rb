require 'helper'

require 'trinket/models/player'

class PlayerTest < Test::Unit::TestCase
  def test_cant_create_null_nmaed_player
    assert_raise Sequel::ValidationFailed do
      Player.create
    end
  end

  def test_cant_create_duplicated_named_player
    Player.create(:name => "ultraman")

    assert_raise Sequel::ValidationFailed do
      Player.create(:name => "ultraman")
    end
  end

  def test_add_badge
    player = Player.create(:name => "James Bond")
    double_o = Badge.create(:name => "Double-O")

    player.add_badge(double_o)

    assert Player.first(:name => "James Bond").badges.include?(double_o)
  end

  def test_add_lots_of_badges_to_one_player_is_fine
    player = Player.create(:name => "James Bond")
    confirmed_kill = Badge.create(:name => "Confirmed Kill")

    player.add_badge(confirmed_kill)
    player.add_badge(confirmed_kill)
    player.add_badge(confirmed_kill)
    player.add_badge(confirmed_kill)

    assert Player.first(:name => "James Bond").badges.include?(confirmed_kill)
    assert Player.first(:name => "James Bond").badges.size == 4
  end
end
