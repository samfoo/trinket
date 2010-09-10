require 'test_helper'
require 'lib/badges'

class BadgesTest < ActiveSupport::TestCase
  teardown_badge_definitions

  test "hasn't achieved must have achieved constraint" do
    module Trinket::Badges
      badge :winnar_is_you do
        must_have_achieved :elected_president
      end
    end

    user = users(:sarah)
    Trinket::Badges.award_if_qualified(user, :winnar_is_you)

    assert !Badge.find_by_name("winnar_is_you").users.include?(user)
    assert user.badges.size == 0
  end

  test "document must have achieved constraint" do
    module Trinket::Badges
      badge :winnar_is_you do
        must_have_achieved :elected_president
      end
    end

    desc = Trinket::Badges::Rules::WinnarIsYou.requirements_in_words
    assert desc == "The user must have achieved the Elected President badge."
  end

  test "document must have achieved times" do
    module Trinket::Badges
      badge :winnar_is_you do
        must_have_achieved :elected_president, :times => 3
      end
    end

    desc = Trinket::Badges::Rules::WinnarIsYou.requirements_in_words
    assert desc == "The user must have achieved the Elected President badge 3 times."
  end

  test "has achieved must have achieved constraint" do
    module Trinket::Badges
      badge :winnar_is_you do
        must_have_achieved :elected_president
      end
    end

    user = users(:sarah)
    user.badges << Badge.find_by_name("elected_president")
    Trinket::Badges.award_if_qualified(user, :winnar_is_you)

    assert Badge.find_by_name("winnar_is_you").users.include?(user)
    assert user.badges.size == 2
  end

  test "can only be awarded once" do
    module Trinket::Badges
      badge :winnar_is_you do
        is_one_time_only
      end
    end

    user = users(:sarah)
    user.badges << Badge.find_by_name("winnar_is_you")

    Trinket::Badges.award_if_qualified(user, :winnar_is_you)
    assert Badge.find_by_name("winnar_is_you").users.include?(user)
    assert user.badges.size == 1
  end

  test "document is one time only" do
    module Trinket::Badges
      badge :winnar_is_you do
        is_one_time_only
      end
    end

    desc = Trinket::Badges::Rules::WinnarIsYou.requirements_in_words
    assert desc == "Can only be awarded once."
  end

  test "event must have occurred" do
    module Trinket::Badges
      badge :resolvinator do
        event_must_have_occurred :status, :value => "resolved"
      end
    end

    user = users(:sarah)
    Event.create!(:user => user, :name => "status", :value => "resolved")

    Trinket::Badges.award_if_qualified(user, :resolvinator)
    assert Badge.find_by_name("resolvinator").users.include?(user)
    assert user.badges.size == 1
  end

  test "document event must have occurred" do
    module Trinket::Badges
      badge :resolvinator do 
        event_must_have_occurred :status, :value => "resolved"
      end
    end

    desc = Trinket::Badges::Rules::Resolvinator.requirements_in_words
    assert desc == "The user must have performed the status event with the value resolved."
  end

  test "event must have occurred value incorrect" do
    module Trinket::Badges
      badge :resolvinator do
        event_must_have_occurred :status, :value => "resolved"
      end
    end

    user = users(:sarah)
    Event.create!(:user => user, :name => "status")

    Trinket::Badges.award_if_qualified(user, :resolvinator)
    assert !Badge.find_by_name("resolvinator").users.include?(user)
    assert user.badges.size == 0
  end

  test "event must have occurred, but hasn't" do
    module Trinket::Badges
      badge :resolvinator do
        event_must_have_occurred :status, :value => "resolved"
      end
    end

    user = users(:sarah)

    Trinket::Badges.award_if_qualified(user, :resolvinator)
    assert !Badge.find_by_name("resolvinator").users.include?(user)
    assert user.badges.size == 0
  end
end
