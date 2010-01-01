require 'test_helper'
require 'lib/badges'

class BadgesTest < ActiveSupport::TestCase
  def teardown
    # Clear out all of the rules that were created after every test.
    Trinket::Badges::Rules.constants.each do |rule|
      Trinket::Badges::Rules.class_eval { remove_const(rule) }
    end
  end

  test "hasn't acheived must have acheived constraint" do
    module Trinket::Badges
      badge :winnar_is_you do
        must_have_acheived :elected_president
      end
    end

    user = users(:sarah)
    Trinket::Badges.award_if_qualified(user, :winnar_is_you)

    assert !Badge.find_by_name("winnar_is_you").users.include?(user)
    assert user.badges.size == 0
  end

  test "has acheived must have acheived constraint" do
    module Trinket::Badges
      badge :winnar_is_you do
        must_have_acheived :elected_president
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
end
