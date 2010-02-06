require 'test_helper'
require 'authlogic/test_case'
require 'lib/badges'

class EventsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  teardown_badge_definitions

  test "create event with no badges to award" do
    UserSession.create(users(:sarah))
    assert_difference("Event.count") do
      post(:create, {"name" => "status", "email" => users(:sarah).email})
      assert_response :success
      assert users(:sarah).badges.size == 0
    end
  end

  test "create event with badge to award" do
    module Trinket::Badges
      badge :winnar_is_you do
        event_must_have_occurred :status, :value => "resolved"
      end
    end

    UserSession.create(users(:sarah))
    assert_difference("users(:sarah).badges.count") do
      post(:create, {"name" => "status", "value" => "resolved", "email" => users(:sarah).email})
      assert_response :success
    end
  end

  test "create event with badge to award but event doesn't award the badge" do
    module Trinket::Badges
      badge :winnar_is_you do
        event_must_have_occurred :status, :value => "resolved"
      end
    end

    UserSession.create(users(:sarah))
    assert_no_difference("users(:sarah).badges.count") do
      post(:create, {"name" => "status", "value" => "opened", "email" => users(:sarah).email})
      assert_response :success
    end
  end

  test "create event requires that you be logged in" do
    post(:create, {"name" => "status", "value" => "opened", "email" => users(:sarah).email})
    assert_response :unauthorized
  end
end
