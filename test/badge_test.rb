require 'helper'

require 'trinket/models/badge'

class BadgeTest < Test::Unit::TestCase
  def test_cant_create_null_named_badge
    assert_raise Sequel::ValidationFailed do
      Badge.create
    end
  end

  def test_cant_create_duplicated_named_badge
    Badge.create(:name => "robot logic")

    assert_raise Sequel::ValidationFailed do
      Badge.create(:name => "robot logic")
    end
  end

  def test_add_player_adds_player_to_players
    badge = Badge.create(:name => "kill all humans")
    bender = Player.create(:name => "bender")

    badge.add_player(bender)

    assert Badge.first(:name => "kill all humans").players.include?(bender)
  end

  def test_add_player_more_than_once_is_acceptable
    badge = Badge.create(:name => "kill all humans")
    bender = Player.create(:name => "bender")

    badge.add_player(bender)
    badge.add_player(bender)
    badge.add_player(bender)

    assert Badge.first(:name => "kill all humans").players.include?(bender)
    assert Badge.first(:name => "kill all humans").players.size == 1
  end
end
